#!/usr/bin/env bash
# Single-request timing of GET /videos?search=… against a running DCMS.
#
# Usage: Admin/BENCH/http.sh [base_url] [samples] [term_counts]
#   base_url     default http://host.docker.internal:8081 (the dev compose stack,
#                reachable from the devcontainer; localhost is not)
#   samples      requests per data point, default 10
#   term_counts  comma-separated, default 1,5,10,25,50,100
#
# Emits CSV: terms,distinctness,mean_ms,median_ms
#
# Two measurements per term count:
#   distinct  — N different words: stemming + Lookup + Rank
#   repeated  — the same word N times: Query.aplf stems before ∪, so this pays full
#               stemming cost but collapses to one term for Lookup/Rank
# The gap between them is everything that is not stemming. It has measured as noise,
# which is what pins the per-term cost on the stemmer.
#
# No conditional headers are sent; If-None-Match would short-circuit to 304 in
# QUERY/CacheControl.aplf and measure nothing.

set -euo pipefail

URL="${1:-http://host.docker.internal:8081}"
SAMPLES="${2:-10}"
COUNTS="${3:-1,5,10,25,50,100}"

WORDS=(running packages dyalog arrays conferences programming happily
       nationalisation performance interpreter workspace recommendation
       presenter stemming relevance pagination migration authentication)

if ! curl -s -m 5 -o /dev/null "$URL/version"; then
    echo "cannot reach $URL — is the dev stack up?" >&2
    exit 1
fi

echo "terms,distinctness,mean_ms,median_ms"

for n in ${COUNTS//,/ }; do
    for mode in distinct repeated; do
        q=""
        for ((i=0; i<n; i++)); do
            if [ "$mode" = distinct ]; then
                w="${WORDS[$((i % ${#WORDS[@]}))]}"
            else
                w="running"
            fi
            q="${q:+$q+}$w"
        done

        times=""
        for ((s=0; s<SAMPLES; s++)); do
            t=$(curl -s -o /dev/null -w "%{time_total}" "$URL/videos?search=$q&per_page=5")
            times="$times $t"
        done

        python3 -c "
import statistics, sys
v = sorted(float(x)*1000 for x in '''$times'''.split())
print(f'$n,$mode,{statistics.mean(v):.1f},{statistics.median(v):.1f}')
"
    done
done
