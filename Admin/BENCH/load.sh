#!/usr/bin/env bash
# Concurrency sweep over GET /videos?search=… using Apache Bench.
#
# Usage: Admin/BENCH/load.sh [base_url] [requests] [concurrency] [term_counts]
#   base_url     default http://host.docker.internal:8081
#   requests     total requests per data point, default 200
#   concurrency  comma-separated, default 1,2,4,8
#   term_counts  comma-separated, default 1,10,50
#
# Emits CSV: terms,concurrency,rps,wait_mean_ms,total_p95_ms,connect_max_ms
#
# wait_mean_ms is server processing time and is the number to compare. total_p95_ms
# includes connection establishment, which on this setup occasionally stalls for
# seconds at a time while processing stays in the tens of milliseconds — connect_max_ms
# is reported so that artifact is visible rather than silently inflating p95.
#
# Caveats worth carrying into any conclusion:
#   - ab is not in the devcontainer image, and that image is built from outside this
#     repo (../../dev-environment/.devcontainer/), so this installs it on demand.
#   - Production is capped at cpus: "0.50" per service (service.yml). Numbers here are
#     optimistic relative to deployment.
#   - No conditional headers, so CacheControl does not short-circuit to 304.

set -euo pipefail

URL="${1:-http://host.docker.internal:8081}"
REQUESTS="${2:-200}"
CONCURRENCY="${3:-1,2,4,8}"
COUNTS="${4:-1,10,50}"

WORDS=(running packages dyalog arrays conferences programming happily
       nationalisation performance interpreter workspace recommendation
       presenter stemming relevance pagination migration authentication)

if ! command -v ab >/dev/null 2>&1; then
    echo "installing apache2-utils for ab..." >&2
    sudo apt-get update -qq && sudo apt-get install -y -qq apache2-utils >&2
fi

if ! curl -s -m 5 -o /dev/null "$URL/version"; then
    echo "cannot reach $URL — is the dev stack up?" >&2
    exit 1
fi

echo "terms,concurrency,rps,wait_mean_ms,total_p95_ms,connect_max_ms"

for n in ${COUNTS//,/ }; do
    q=""
    for ((i=0; i<n; i++)); do
        q="${q:+$q+}${WORDS[$((i % ${#WORDS[@]}))]}"
    done

    for c in ${CONCURRENCY//,/ }; do
        # A single ab failure must not abort the sweep.
        set +e
        out=$(ab -n "$REQUESTS" -c "$c" -s 60 -q "$URL/videos?search=$q&per_page=5" 2>&1)
        rc=$?
        set -e
        if [ $rc -ne 0 ]; then
            echo "warning: ab failed (rc=$rc) terms=$n c=$c" >&2
            echo "$n,$c,NA,NA,NA,NA"
            continue
        fi
        rps=$(awk '/^Requests per second:/ {print $4}' <<<"$out")
        wait_mean=$(awk '/^Waiting:/ {print $3}' <<<"$out")
        p95=$(awk '/^ *95%/ {print $2}' <<<"$out")
        conn_max=$(awk '/^Connect:/ {print $6}' <<<"$out")
        failed=$(awk '/^Failed requests:/ {print $3}' <<<"$out")
        non2xx=$(awk '/^Non-2xx responses:/ {print $3}' <<<"$out")
        if [ "${failed:-0}" != "0" ] || [ -n "${non2xx:-}" ]; then
            echo "warning: terms=$n c=$c failed=$failed non2xx=${non2xx:-0}" >&2
        fi
        echo "$n,$c,${rps:-NA},${wait_mean:-NA},${p95:-NA},${conn_max:-NA}"
    done
done
