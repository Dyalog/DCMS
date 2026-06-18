#!/usr/bin/env bash
# Refresh the vendored Swagger UI assets.
#
# We bundle these files into the service rather than loading them from a CDN:
# a CDN reference would make the user's browser send their IP address (PII) to a
# third party on every page load — a GDPR concern. All assets are served by DCMS
# itself from /swagger/*.
#
# Usage: ./fetch.sh [version]   (defaults to the version pinned in VERSION)
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${1:-$(sed 's/.*@//' VERSION)}"
echo "Fetching swagger-ui-dist@${VERSION} ..."

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
( cd "$TMP" && npm pack "swagger-ui-dist@${VERSION}" >/dev/null && tar xzf "swagger-ui-dist-${VERSION}.tgz" )

cp "$TMP/package/swagger-ui.css"                 swagger-ui.css
cp "$TMP/package/swagger-ui-bundle.js"           swagger-ui-bundle.js
cp "$TMP/package/swagger-ui-bundle.js.LICENSE.txt" swagger-ui-bundle.js.LICENSE.txt
cp "$TMP/package/LICENSE"                         LICENSE

echo "swagger-ui-dist@${VERSION}" > VERSION
echo "Done. Pinned to swagger-ui-dist@${VERSION}."
echo "Note: index.html and theme.css are hand-maintained DCMS files — not overwritten."
