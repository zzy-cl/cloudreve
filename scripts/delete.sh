#!/usr/bin/env bash
# Delete a file from Cloudreve v4
# Usage: delete.sh <CLOUDREVE_URL> <TOKEN> <FILE_URI>

set -euo pipefail

CLOUDREVE_URL="${1:?Usage: delete.sh <URL> <TOKEN> <FILE_URI>}"
TOKEN="${2:?Missing TOKEN}"
FILE_URI="${3:?Missing FILE_URI}"

RESPONSE=$(curl -sf -X DELETE \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(python3 -c "
import json, sys
print(json.dumps({'uris': [sys.argv[1]]}))
" "$FILE_URI")" \
  "${CLOUDREVE_URL}/api/v4/file")

CODE=$(echo "$RESPONSE" | python3 -c "import json,sys; print(json.load(sys.stdin).get('code',-1))")

if [ "$CODE" = "0" ]; then
    echo "OK: Deleted -> $FILE_URI" >&2
else
    echo "ERROR: Delete failed (code=$CODE)" >&2; exit 1
fi
