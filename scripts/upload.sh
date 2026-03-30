#!/usr/bin/env bash
# Upload a file to Cloudreve v4
# Usage: upload.sh <CLOUDREVE_URL> <TOKEN> <LOCAL_FILE> [REMOTE_NAME] [REMOTE_DIR]
# Docs: https://docs.cloudreve.org/zh/api/upload

set -euo pipefail

CLOUDREVE_URL="${1:?Missing URL}"; TOKEN="${2:?Missing TOKEN}"
LOCAL_FILE="${3:?Missing FILE}"; REMOTE_NAME="${4:-$(basename "$LOCAL_FILE")}"
REMOTE_DIR="${5:-cloudreve://my}"

[ -f "$LOCAL_FILE" ] || { echo "ERROR: File not found: $LOCAL_FILE" >&2; exit 1; }

FILE_SIZE=$(stat -c%s "$LOCAL_FILE" 2>/dev/null || stat -f%z "$LOCAL_FILE" 2>/dev/null)
TARGET_URI="${REMOTE_DIR}/${REMOTE_NAME}"

echo "Uploading: $LOCAL_FILE ($FILE_SIZE bytes) -> $TARGET_URI" >&2

# Step 1: Create upload session (PUT /api/v4/file/upload)
SESSION_RESP=$(curl -sf -X PUT \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(python3 -c "
import json, sys
print(json.dumps({'uri': sys.argv[1], 'size': int(sys.argv[2])}))
" "$TARGET_URI" "$FILE_SIZE")" \
  "${CLOUDREVE_URL}/api/v4/file/upload")

# Parse session response
eval "$(python3 - "$SESSION_RESP" << 'PYEOF'
import json, sys
data = json.loads(sys.argv[1])
if data.get("code") != 0:
    print(f'echo "ERROR: {data.get("msg", "session failed")}" >&2; exit 1')
    sys.exit(0)
d = data["data"]
print(f'SESSION_ID="{d["session_id"]}"')
print(f'CHUNK_SIZE={d["chunk_size"]}')
PYEOF
)"

echo "Session: $SESSION_ID, chunk_size: $CHUNK_SIZE" >&2

# Step 2: Upload chunks
CHUNK_INDEX=0
OFFSET=0

while [ "$OFFSET" -lt "$FILE_SIZE" ]; do
    REMAINING=$((FILE_SIZE - OFFSET))
    THIS_CHUNK=$((REMAINING < CHUNK_SIZE ? REMAINING : CHUNK_SIZE))

    # Extract chunk and upload via stdin pipe (avoids temp files)
    UPLOAD_CODE=$(dd if="$LOCAL_FILE" bs=1 skip="$OFFSET" count="$THIS_CHUNK" 2>/dev/null \
      | curl -sf -X POST \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/octet-stream" \
          --data-binary @- \
          "${CLOUDREVE_URL}/api/v4/file/upload/${SESSION_ID}/${CHUNK_INDEX}" \
      | python3 -c 'import json,sys; print(json.load(sys.stdin).get("code",-1))')

    if [ "$UPLOAD_CODE" != "0" ]; then
        echo "ERROR: Chunk $CHUNK_INDEX upload failed" >&2
        exit 1
    fi

    OFFSET=$((OFFSET + THIS_CHUNK))
    CHUNK_INDEX=$((CHUNK_INDEX + 1))
done

echo "OK: Uploaded -> $TARGET_URI ($CHUNK_INDEX chunk(s))" >&2
