---
name: cloudreve
description: >
  Manage files on a self-hosted Cloudreve v4 cloud storage instance.
  Upload local files to Cloudreve, download files from Cloudreve to local,
  list files, check storage capacity, and delete files.
  Activate when user mentions "upload to cloudreve", "cloudreve upload",
  "网盘上传", "传到网盘", "cloudreve下载", "从网盘下载", "网盘文件列表",
  "cloudreve文件", or any Cloudreve/cloud drive file operations.
metadata:
  openclaw:
    always: true
    emoji: "☁️"
    requires:
      env:
        - CLOUDREVE_URL
        - CLOUDREVE_USER
        - CLOUDREVE_PASS
    primaryEnv: CLOUDREVE_URL
---

# Cloudreve File Manager

Manage files on a self-hosted Cloudreve v4 instance via its API.

## Setup

Set environment variables in `openclaw.json`:

```json5
{
  skills: {
    entries: {
      "cloudreve": {
        enabled: true,
        env: {
          CLOUDREVE_URL: "https://cloudreve.example.com",
          CLOUDREVE_USER: "your-email@example.com",
          CLOUDREVE_PASS: "your-password"
        }
      }
    }
  }
}
```

Restart gateway after saving. **Never log or echo credentials.**

## Authentication

Cloudreve v4 uses JWT Bearer tokens (`Authorization: Bearer <token>`).

### Get Token

**Method A: Browser session (preferred)**

Use `agent-browser` with persistent session. Token lives in `localStorage`:

```bash
agent-browser --session-name cloudreve open "${CLOUDREVE_URL}" && agent-browser --session-name cloudreve wait --load networkidle

# Extract token
TOKEN=$(agent-browser --session-name cloudreve eval '
  (() => {
    const s = JSON.parse(localStorage.getItem("cloudreve_session"));
    const id = Object.keys(s.sessions)[0];
    return s.sessions[id].token.access_token;
  })()
' | tr -d '"')
```

**Method B: curl login (headless)**

```bash
# Login and extract token in one step
TOKEN=$(curl -sf -X POST "${CLOUDREVE_URL}/api/v4/user/login" \
  -H "Content-Type: application/json" \
  -d "{\"userName\":\"${CLOUDREVE_USER}\",\"Password\":\"${CLOUDREVE_PASS}\"}" \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['data']['token']['access_token'])")
```

## Commands

All scripts in `scripts/` dir, relative to this skill.

| Command | Usage | Description |
|---------|-------|-------------|
| upload | `upload.sh <URL> <TOKEN> <FILE> [NAME] [DIR]` | Upload local file |
| download | `download.sh <URL> <TOKEN> <URI> [PATH]` | Download file to local |
| list | `list.sh <URL> <TOKEN> [DIR_URI]` | List directory contents |
| delete | `delete.sh <URL> <TOKEN> <FILE_URI>` | Delete a file |
| storage | `storage.sh <URL> <TOKEN>` | Show storage usage |

Default remote dir: `cloudreve://my/`. File URI format: `cloudreve://my/path/file.txt`.

## Workflow

1. Get token via Method A or B
2. Run script: `scripts/<cmd>.sh "$CLOUDREVE_URL" "$TOKEN" <args>`
3. Check exit code — `0` = success, non-zero = failure with error message
4. On auth error (401), re-login and retry once

## Gotchas

- API prefix is `/api/v4/` — v3 returns 404
- Upload creates session with **PUT** (not POST), then uploads binary with POST
- File URIs use `cloudreve://` scheme; URL-encode when passing as query params
- Docker port 5212 direct connection more reliable than nginx proxy
- Tokens expire (~1 hour); re-authenticate on 401
- API reference: see `references/api-reference.md`
