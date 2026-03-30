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

```bash
TOKEN=$(curl -sf -X POST "${CLOUDREVE_URL}/api/v4/session/token" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${CLOUDREVE_USER}\",\"password\":\"${CLOUDREVE_PASS}\"}" \
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

Default remote dir: `cloudreve://my`. File URI format: `cloudreve://my/path/file.txt`.

## Workflow

1. Get token via auth command
2. Run script: `scripts/<cmd>.sh "$CLOUDREVE_URL" "$TOKEN" <args>`
3. Check exit code — `0` = success, non-zero = failure with error message
4. On auth error (401), re-login and retry once

## API Reference (Cloudreve v4)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v4/session/token` | POST | Login (fields: `email`, `password`) |
| `/api/v4/user/capacity` | GET | Storage usage |
| `/api/v4/file?uri=<URI>` | GET | List directory contents |
| `/api/v4/file/upload` | PUT | Create upload session |
| `/api/v4/file/upload/<session_id>/<chunk>` | POST | Upload binary chunk |
| `/api/v4/file/url` | POST | Get download URLs |
| `/api/v4/file` | DELETE | Delete files |

## Gotchas

- API prefix is `/api/v4/`
- Login endpoint is `/api/v4/session/token` (NOT `/api/v4/user/login`)
- Login fields are `email` and `password` (lowercase, not `userName`/`Password`)
- File URIs use `cloudreve://` scheme (e.g., `cloudreve://my/file.txt`)
- Upload creates session with **PUT**, then uploads binary with **POST**
- Tokens expire (~1 hour); re-authenticate on 401
- URL-encode URIs when passing as query parameters

## License

MIT
