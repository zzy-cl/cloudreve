#!/usr/bin/env bash
# List files in Cloudreve v4 directory
# Usage: list.sh <CLOUDREVE_URL> <TOKEN> [DIR_URI]

set -euo pipefail

CLOUDREVE_URL="${1:?Usage: list.sh <URL> <TOKEN> [DIR_URI]}"
TOKEN="${2:?Missing TOKEN}"
DIR_URI="${3:-cloudreve://my}"

# URL-encode the URI
ENCODED_URI=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$DIR_URI")

RESPONSE=$(curl -sf -H "Authorization: Bearer $TOKEN" \
  "${CLOUDREVE_URL}/api/v4/file?uri=${ENCODED_URI}")

python3 - "$RESPONSE" << 'PYEOF'
import json, sys

data = json.loads(sys.argv[1])
if data.get("code") != 0:
    print(f"ERROR: {data.get('msg', 'unknown')}", file=sys.stderr)
    sys.exit(1)

files = data.get("data", {}).get("files", [])
if not files:
    print("(empty directory)")
    sys.exit(0)

for f in files:
    ftype = "📁" if f["type"] == 1 else "📄"
    name = f["name"]
    size = f.get("size", 0)
    if size > 1073741824:
        size_str = f"{size/1073741824:.1f} GB"
    elif size > 1048576:
        size_str = f"{size/1048576:.1f} MB"
    elif size > 1024:
        size_str = f"{size/1024:.1f} KB"
    else:
        size_str = f"{size} B"
    print(f"{ftype} {name:40s} {size_str:>10s}  {f['path']}")
PYEOF
