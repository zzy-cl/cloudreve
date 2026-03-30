#!/usr/bin/env bash
# List files in Cloudreve v4 directory
# Usage: list.sh <CLOUDREVE_URL> <TOKEN> [DIR_URI]

set -euo pipefail

CLOUDREVE_URL="${1:?Usage: list.sh <CLOUDREVE_URL> <TOKEN> [DIR_URI]}"
TOKEN="${2:?Missing TOKEN}"
DIR_URI="${3:-cloudreve://my}"

ENCODED_URI=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${DIR_URI}', safe=''))")

RESPONSE=$(curl -sf -H "Authorization: Bearer $TOKEN" "${CLOUDREVE_URL}/api/v4/file?uri=${ENCODED_URI}")

python3 - "$RESPONSE" << 'PYEOF'
import json, sys
data = json.loads(sys.argv[1])
if data.get("code") != 0:
    sys.exit(data.get("msg", "unknown"))
files = data.get("data", {}).get("files", [])
if not files:
    print("(empty directory)")
    sys.exit(0)
for f in files:
    icon = chr(0x1f4c1) if f.get("type") == 1 else chr(0x1f4c4)
    size = f.get("size", 0)
    if size > 1073741824: sz = f"{size/1073741824:.1f} GB"
    elif size > 1048576: sz = f"{size/1048576:.1f} MB"
    elif size > 1024: sz = f"{size/1024:.1f} KB"
    else: sz = f"{size} B"
    name = f["name"]
    print(f"{icon} {name}  ({sz})")
PYEOF
