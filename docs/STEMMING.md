# Batch stemming wrapper — investigation phase

## Status — 2026-09-15

Investigation phase is essentially complete. The measurements are in **Results** below;
the recommendation is `StemLine` (space-delimited).

**Done**

- `nuget-packages/Stemmer.cs` — `Stemming.Batch.StemAll` (nested) and `.StemLine`
  (delimited). Compiles into the existing `_nuget-packages.dll` via the NuGet package's
  own `dotnet publish`, so no build, `⎕USING` or deployment change is needed. Verified
  byte-identical to the current per-word loop over an 803-word vocabulary.
- `Admin/BENCH/` — `stem.apls` (format shoot-out, no server required), `http.sh`
  (end-to-end latency by term count), `load.sh` (concurrency).
- Measurement and recommendation.

**Deferred** — developer/build documentation (section 3), until the wrapper is actually
integrated and the call sites are settled.

**Next, in order**

1. Integrate `StemLine` at the two call sites: `QUERY/VIDEOS/Query.aplf:110` and
   `CACHE/Build.aplf:84` (which carries the FIXME this work answers).
2. Preserve the invariant that tokens never contain spaces — `StemLine` splits on them.
   Both call sites are safe today; the integration must keep them so.
3. While in `Query.aplf`: move the `∪` before `Stem¨` rather than after, so duplicate
   query terms are stemmed once; and drop the per-request `⎕NEW` at line 103, since the
   stemmer is stateless and one shared instance is correct. Neither is a performance fix
   (`⎕NEW` costs 0.0065 ms) — both are tidiness.
4. Re-run `Admin/BENCH/http.sh` and confirm the predicted end-to-end drop: a 100-term
   search from ~32 ms to ~15 ms, a 50-term from ~25 ms to ~15 ms.
5. Re-run `Admin/BENCH/stem.apls` as a regression check — its correctness gate fails the
   run if the wrapper and the per-word loop ever disagree.
6. `Admin.RunTests 1`.
7. Write section 3.

## Context

Search queries are stemmed one word at a time through the Porter2Stemmer NuGet package.
Each `Stem` is a separate APL→.NET interop call, and the interop cost per call is large
compared with the stemming work itself — especially off thread 0, where DCMS actually
serves requests. The code already knows this; `APLSource/CACHE/Build.aplf:83` carries the
FIXME *"modify package to accept a list of words, else implement in Dyalog"*.

This phase does **not** change the product. It builds a benchmark harness, prototypes two
batch-wrapper calling conventions, measures them, and produces a recommendation with
numbers. Integrating the winner into `Query.aplf` / `Build.aplf` is a separate work unit.

### Baseline already measured

Measured in this devcontainer against the running dev server and via `dyalogscript`.
All figures are milliseconds.

**Per-word `Stem¨` loop, current code:**

| words | thread 0 | spawned thread |
|------:|---------:|---------------:|
| 1     | 0.05     | 0.7            |
| 10    | 0.2      | 2.0            |
| 50    | 1.1      | 8.4            |
| 250   | 8.2      | 43.7           |

The ~7–10× spawned-thread surcharge is the known DCMS .NET thread effect, and it is what
request handlers pay.

**`GET /videos?search=…`, mean of 5, dev server:**

| terms | distinct | all-identical |
|------:|---------:|--------------:|
| 1     | 12.5     | 12.3          |
| 10    | 15.4     | 14.3          |
| 50    | 28.6     | 26.1          |
| 100   | 45.3     | 48.7          |

`Query.aplf:110` stems *before* `∪`, so the identical-terms column pays full stemming cost
but collapses to one term for `Lookup`/`Rank`. The two columns agree, which pins the whole
per-term cost on stemming: **at 50 terms, ~15 ms of a ~27 ms request is stemming.**

**Marshalling cost of one .NET call carrying N words** (measured with `String.Join` for
`string[]` and `String.Concat` for a single `string`):

| N    | `string[]` in, thread 0 | `string[]` in, spawned | single `string` in, thread 0 | single `string` in, spawned |
|-----:|------------------------:|-----------------------:|-----------------------------:|----------------------------:|
| 1    | 0.014 | 0.064 | 0.016 | 0.112 |
| 50   | 0.090 | 0.110 | 0.032 | 0.074 |
| 250  | 0.516 | 0.284 | 0.028 | 0.096 |
| 1000 | 1.102 | 2.596 | 0.020 | 0.092 |

Single-string cost is **flat in N**; `string[]` cost grows roughly linearly. The user's
instinct is confirmed — but below ~50 words the two are indistinguishable, so the format
choice only really matters for the cache build.

**APL-side cost of the split/join that the space-delimited format requires:**
`1↓∊' ',¨words` and `' '(≠⊆⊢)text` cost 0.0035/0.0025 ms at 50 words and 0.057/0.041 ms at
1000 — an order of magnitude below the `string[]` marshalling it replaces.

**Ruled out:** passing a char matrix (`↑words`) where `string[]` is expected raises
`EXCEPTION`. Not a viable format.

### Why the existing NuGet project is the right home

`NuGet.Setup` only creates `_nuget-packages.csproj` if absent, and `NuGet.Publish` is just
`dotnet publish <dir> -o <dir>/published`. Any `.cs` in `nuget-packages/` is therefore
compiled into `_nuget-packages.dll`. `NuGet.Using` already appends that primary DLL to the
`⎕USING` list it returns (`includePrimary←1` by default), which
`APLSource/Setup.aplf:28` assigns and `ADMIN/RefreshData.aplf:11` forwards into the cache
isolate. `CI/install.apls` already calls `NuGet.Publish`, and the Jenkins `Install
dependencies` stage runs it before the FTP publish of `**/*`.

So a new `.cs` file needs **no change** to `Dockerfile`, `Jenkinsfile`, `docker-compose.yml`,
`install.apls`, `service.yml`, or the `⎕USING` plumbing. It needs one `.gitignore` line.

## Work

### 1. C# wrapper — `nuget-packages/Stemmer.cs` — DONE

One new file. Both formats as static methods on one class so the benchmark can switch
between them without rebuilding:

```csharp
using Porter2Stemmer;

namespace DCMS;

public static class BatchStemmer
{
    private static readonly EnglishPorter2Stemmer S = new();

    // Format A — nested: APL nested vector of char vectors <-> string[]
    public static string[] StemAll(string[] words);

    // Format B — delimited: APL simple char vector <-> single string
    // Splits on ' ', stems each, rejoins with ' '. Same word count in and out.
    public static string StemLine(string line);
}
```

Notes for implementation:
- Thread safety: **settled**. Reflecting over `Porter2Stemmer.dll` shows
  `EnglishPorter2Stemmer` has eight instance fields, all `readonly`, and no settable
  properties — `Stem` is pure. One shared `static readonly` instance is safe; no
  `[ThreadStatic]`. This also means the per-request `⎕NEW` at `Query.aplf:103` is pure
  waste, worth removing during integration.
- `StemLine` should use `string.Split(' ', StringSplitOptions.RemoveEmptyEntries)` and
  `string.Join(' ', …)`. Input from DCMS is already lowercase ASCII (`Unidecode`
  normalisation at `Build.aplf:56`, `Norm` at `Query.aplf:110`), so no culture handling.
- Do not add a `PackageReference`; `Porter2Stemmer` is already referenced.

`.gitignore`: add `!nuget-packages/*.cs` after the existing `!nuget-packages/_nuget-packages.csproj`.

### 2. Benchmark harness — `Admin/BENCH/`

Three layers, each independently runnable.

**`Admin/BENCH/stem.apls`** — the primary decision tool. A `dyalogscript` script; needs no
server, no database, no compose stack. It must:

- `⎕USING←NuGet.Using '/workspace/nuget-packages'` so it exercises the real resolution
  path, not a hardcoded DLL path. Confirmed to return both
  `,…/published/Porter2Stemmer.dll` and `,…/published/_nuget-packages.dll`, so the
  wrapper is reachable exactly as the app reaches it.
- Loading NuGet outside a Link/Tatin session: `⎕FX` each `.aplf`
  (`ns.⎕FX⊃⎕NGET file 1`), which handles both the tradfn and dfn files. `⎕FIX 'file://…'`
  does not — these are function source files, not scripts.
- Time four variants at each size: current `Stem¨` per-word loop; `StemAll` (nested);
  `StemLine` (delimited, including the APL-side `1↓∊' ',¨` and `' '(≠⊆⊢)`); and a no-op
  control that isolates pure marshalling from stemming work.
- Run every variant **both on thread 0 and under `⎕TSYNC f&`**. The spawned-thread column
  is the one that matters; a thread-0-only benchmark will understate the win by ~8×.
- Sweep sizes `1 2 5 10 25 50 100 250 500 1000 2500 5000`, configurable by argument so the
  user can find where extra sizes stop adding information.
- Use a realistic word list, not one repeated word — sample from the actual corpus
  vocabulary if a cache file is available, else a fixed list of ~200 English words of
  mixed stemmability. Stemmer cost varies with suffix structure.
- Warm up each variant before timing (JIT and first-call assembly load are significant —
  the first HTTP sweep above read ~2× the second).
- Assert correctness before timing: all three variants must produce identical stems for
  the whole word list. A fast wrong answer is not a result.
- Emit CSV to stdout. `dyalogscript` output in this container concatenates lines oddly
  unless you build the newlines yourself — join rows with `⎕UCS 10` and emit in one `⎕←`.

**`Admin/BENCH/http.sh`** — single-request end-to-end timing. `curl -w "%{time_total}"`
against `GET /videos?search=…` for each term count, N samples, report mean and median.
Include the distinct-vs-identical pair from the baseline above; it is what separates
stemming cost from `Lookup`/`Rank` cost without needing the `X-API-Key` profiling endpoint.
Default URL `http://host.docker.internal:8081` (verified reachable from the devcontainer),
overridable by `$1`.

**`Admin/BENCH/load.sh`** — concurrency, using `ab`. `ab` is not installed here and the
devcontainer Dockerfile lives outside this repo (`../../dev-environment/.devcontainer/`),
so the script should check for `ab` and `sudo apt-get install -y apache2-utils` if missing
(`node` has passwordless sudo). Sweep concurrency `1 2 4 8` × term counts `1 10 50`,
report the `ab` mean and p95. Two cautions to encode in the script: send no conditional
headers, or `CacheControl` (`APLSource/QUERY/CacheControl.aplf`) returns 304 and you
measure nothing; and production is capped at `cpus: "0.50"` (`service.yml`), so
devcontainer concurrency numbers are optimistic.
### 3. Developer instructions — DEFERRED

Not worth writing until the wrapper is actually integrated; the build and deploy notes
would only have to be rewritten once the call sites change. Deferred to the integration
work unit.

### 4. Findings — DONE, see Results below

## Expectation

Batching replaces N interop calls with one. At 50 terms on a spawned thread that is
~8.4 ms → ~0.1 ms of marshalling plus the actual stemming work, taking a 50-term
`/videos` request from ~27 ms to ~13 ms. The delimited format should win at cache-build
sizes; at query sizes the two should tie, in which case pick delimited anyway for the
single implementation.

If the measurements contradict this, say so and stop — the point of the phase is the
number, not the wrapper.

## Verification

1. `dotnet publish /workspace/nuget-packages -o /workspace/nuget-packages/published`
   succeeds and `nuget-packages/published/_nuget-packages.dll` grows beyond its current
   3584 bytes.
2. From `dyalogscript`, `⎕USING←NuGet.Using '/workspace/nuget-packages'` then
   `DCMS.BatchStemmer.StemLine⊂'running packages ingenuity amicable'` returns
   `'run packag ingenu amic'`, and `StemAll` returns the same four stems nested. The first
   two match `Test_Stemming`/`stemmable.apla` expectations
   (`Admin/TESTS/GENERATE/stemmable.apla`).
3. `Admin/BENCH/stem.apls` runs clean, its correctness assertion passes, and it emits a
   CSV covering both threading modes.
4. `Admin/BENCH/http.sh` reproduces the baseline table above against the running dev
   server (±20%).
5. `Admin/BENCH/load.sh` installs `ab` if needed and completes a sweep without 304s.
6. `Admin.RunTests 1` still passes — no product code changed, so this is a regression
   check that adding the `.cs` did not disturb assembly loading.

## Results

Measured in the devcontainer on 2026-09-14 with the code in this branch. `stem.apls`
figures are the minimum of 3 trials; HTTP figures are medians of 30 samples. The box
also runs the dev stack and MariaDB, so absolute milliseconds are noisy — the ratios
are the durable part. Production is capped at `cpus: "0.50"` (`service.yml`), so these
are optimistic in absolute terms.

### Format shoot-out, spawned thread (`Admin/BENCH/stem.apls`)

This is the column that matters: DCMS serves requests off thread 0. ms per call.

| words | per-word | nested | delimited | transport only (nested) | transport only (delim) | speedup |
|------:|---------:|-------:|----------:|------------------------:|-----------------------:|--------:|
| 1     |    0.160 |  0.179 |     0.163 |                   0.090 |                  0.075 |      1× |
| 10    |    1.050 |  0.146 |     0.169 |                   0.079 |                  0.059 |      7× |
| 25    |   10.100 |  0.312 |     0.213 |                   0.092 |                  0.114 |     47× |
| 50    |   11.400 |  0.353 |     0.290 |                   0.147 |                  0.377 |     39× |
| 100   |   22.125 |  0.913 |     0.400 |                   0.212 |                  0.199 |     55× |
| 250   |   47.500 |  2.971 |     1.870 |                   0.645 |                  0.095 |     25× |
| 500   |  101.000 |  1.985 |     2.140 |                   1.240 |                  0.194 |     51× |
| 1000  |  176.750 |  5.300 |     3.441 |                   3.020 |                  0.310 |     51× |
| 2500  |  340.750 |  8.450 |     8.688 |                   3.425 |                  0.278 |     40× |
| 5000  |  608.500 | 16.667 |    13.643 |                   6.059 |                  0.455 |     45× |

On thread 0 the same shape holds at roughly a seventh of the cost — per-word 1.020 ms
at 50 words against 0.153 ms delimited, 102.5 ms against 13.25 ms at 5000.

### The headline

**Batching is worth 25–55× at every realistic query size.** Below ~10 words the win
disappears into noise, which is fine: those queries are already fast. The FIXME at
`Build.aplf:83` is correct and the fix is worth doing.

### Nested vs delimited: delimited, but narrowly

The expectation above was that delimited would win big at cache-build sizes. It does win,
but by ~20–35% rather than the order of magnitude the transport numbers imply:

- Transport genuinely differs by ~13× at 5000 words (6.06 ms nested vs 0.455 ms delimited),
  exactly as the pre-work marshalling probes predicted.
- But by then **actual stemming work dominates**. Delimited's 13.6 ms is 0.455 ms of
  transport and ~13 ms of Porter2. Eliminating the remaining transport difference buys
  little.

At query sizes (1–100) the two formats are within noise of each other.

So the recommendation is **delimited**, on these grounds rather than raw speed:

1. Never slower than nested at any size, and 20–35% faster at cache-build sizes.
2. Transport is flat in word count, so it degrades gracefully if the corpus vocabulary
   grows.
3. One implementation serves both call sites.

**Constraint the integration must preserve:** `StemLine` splits on spaces, so it silently
corrupts if any token contains one. Both call sites are safe today — `Build.aplf:77`
tokenises to `⎕C ⎕A` runs, `Query.aplf:110` splits on `', '` — but that invariant is now
load-bearing. If it is ever at risk, switch to `StemAll`; the cost is small.

### The per-request `⎕NEW` is not the problem

`⎕NEW Porter2Stemmer.EnglishPorter2Stemmer` costs **0.0065 ms**. Removing it from
`Query.aplf:103` is tidy — the object is stateless, so one shared instance is correct —
but it is not a performance fix. Earlier notes in this document called it "pure waste";
it is waste, but negligible waste.

### End-to-end (`Admin/BENCH/http.sh`, median of 30)

| terms | distinct | repeated |
|------:|---------:|---------:|
| 1     |     23.4 |     14.3 |
| 5     |     15.5 |     14.5 |
| 10    |     16.6 |     15.8 |
| 25    |     19.2 |     17.4 |
| 50    |     25.3 |     20.7 |
| 100   |     31.9 |     26.2 |

`distinct ≈ repeated` throughout, which is the point of the pairing: `Query.aplf:110`
stems before `∪`, so the repeated column pays full stemming cost but collapses to one
term for `Lookup`/`Rank`. The per-term cost is stemming, not search.

Floor is ~14 ms of fixed request handling. A 100-term query spends ~18 ms on top of that,
nearly all of it stemming — so batching should take a 100-term search from ~32 ms to
~15 ms, and a 50-term search from ~25 ms to ~15 ms.

### Concurrency (`Admin/BENCH/load.sh`) — incomplete

| terms | concurrency | rps | server wait (ms) |
|------:|------------:|----:|-----------------:|
| 1     | 1 | 99.3 | 7 |
| 1     | 2 | 177.1 | 8 |
| 1     | 4 | 152.4 | 21 |
| 10    | 1 | 84.2 | 9 |
| 10    | 2 | 119.3 | 13 |
| 10    | 4 | 117.6 | 30 |
| 10    | 8 | 117.6 | 63 |
| 50    | 1 | 48.7 | 17 |
| 50    | 2 | 64.6 | 27 |

Throughput falls as term count rises (99 → 84 → 49 rps at concurrency 1), consistent with
stemming being the per-term cost.

Treat these as indicative only. The cells at 1 term/c=8, 50/c=4 and 50/c=8 are missing,
and the dev server intermittently stalls for seconds at a time under concurrent load
regardless of endpoint — including endpoints that do no stemming at all. That behaviour is
unrelated to the stemming question and is being tracked separately; it does mean the
concurrency layer is the least trustworthy of the three, and no stemming conclusion rests
on it. `load.sh` reports `wait_mean_ms` (server processing) apart from `total_p95_ms` and
`connect_max_ms` so the stalls are visible rather than folded into p95.

### Where to stop sweeping

The ratios plateau above ~1000 words: 51×, 40×, 45× at 1000/2500/5000. Sizes past 1000
add runtime (the full default sweep takes ~2 minutes, most of it at 2500 and 5000) without
changing any conclusion. For routine use run `stem.apls 1,10,50,100,250,1000`; keep the
5000 row only when validating cache-build scale.

### Recommendation

Adopt `StemLine` (delimited). Integrate at both call sites — `Query.aplf:110` and
`Build.aplf:84` — preserving the no-spaces-in-tokens invariant. Expect a 100-term search
to roughly halve, and the cache build's `Stem¨ w_index` over the whole corpus vocabulary
to drop by a factor of ~45.
