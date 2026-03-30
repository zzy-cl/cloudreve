#!/usr/bin/env bash
# Upload a file to Cloudreve v4
# Usage: upload.sh <CLOUDREVE_URL> <TOKEN> <LOCAL_FILE> [REMOTE_NAME] [REMOTE_DIR]

set -euo pipefail

CLOUDREVE_URL="${1:?Missing URL}"; TOKEN="${2:?Missing TOKEN}"
LOCAL_FILE="${3:?Missing FILE}"; REMOTE_NAME="${4:-$(basename "$LOCAL_FILE")}"
REMOTE_DIR="${5:-cloudreve://my}"

[ -f "$LOCAL_FILE" ] || { echo "ERROR: File not found: $LOCAL_FILE" >&2; exit 1; }

FILE_SIZE=$(stat -c%s "$LOCAL_FILE" 2>/dev/null || stat -f%z "$LOCAL_FILE" 2>/dev/null)
TARGET_URI="${REMOTE_DIR}/${REMOTE_NAME}"

echo "Uploading: $LOCAL_FILE ($FILE_SIZE bytes) -> $TARGET_URI"

# Step 1: Create upload session (PUT)
SESSION_RESP=$(curl -sf -X PUT \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d "$(python3 -c "import json,sys; print(json.dumps({'uri':sys.argv[1],'size':int(sys.argv[2])}))" "$TARGET_URI" "$FILE_SIZE")" \
  "${CLOUDREVE_URL}/api/v4/file/upload")

SESSION_ID=$(python3 - "$SESSION_RESP" << 'PYEOF'
import json, sys
data = json.loads(sys.argv[1])
if data.get("code") != 0: sys.exit(data.get("msg", "err"))
print(data["data"]["session_id"])
PYEOF
)

# Step 2: Upload binary (POST, Content-Type: octet-stream)
UPLOAD_CODE=$(curl -sf -X POST \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/octet-stream" \
  --data-binary "@${LOCAL_FILE}" \
  "${CLOUDREVE_URL}/api/v4/file/upload/${SESSION_ID}/0" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("code",-1))')

[ "$UPLOAD_CODE" = "0" ] && echo "OK: Uploaded -> $TARGET_URI" || { echo "ERROR: Upload failed" >&2; exit 1; }
