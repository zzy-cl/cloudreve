#!/usr/bin/env bash
# Delete a file from Cloudreve v4
# Usage: delete.sh <CLOUDREVE_URL> <TOKEN> <FILE_URI>

set -euo pipefail

CLOUDREVE_URL="${1:?Missing URL}"; TOKEN="${2:?Missing TOKEN}"; FILE_URI="${3:?Missing URI}"

CODE=$(curl -sf -X DELETE \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d "{\"uris\":[\"${FILE_URI}\"]}" \
  "${CLOUDREVE_URL}/api/v4/file" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("code",-1))')

[ "$CODE" = "0" ] && echo "OK: Deleted $FILE_URI" || { echo "ERROR: Delete failed (code: $CODE)" >&2; exit 1; }
