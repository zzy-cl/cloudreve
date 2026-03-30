# cloudreve

An [Agent Skills](https://agentskills.io)-compatible skill for managing files on a self-hosted [Cloudreve v4](https://cloudreve.org) cloud storage instance.

## Features

- Upload local files to Cloudreve
- Download files from Cloudreve to local
- List directory contents
- Delete files
- Check storage usage
- JWT authentication via Cloudreve v4 session API

## How it works

```
User: "upload to cloudreve"
  ↓
Agent loads SKILL.md, gets token via /api/v4/session/token
  ↓
Calls scripts/upload.sh with URL + token + file
  ↓
Cloudreve v4 API: PUT session → POST binary chunk → Done
```

## Requirements

- A running Cloudreve v4 instance (Docker or binary)
- `CLOUDREVE_URL`, `CLOUDREVE_USER`, `CLOUDREVE_PASS` environment variables
- `curl` and `python3` in agent shell

## Installation

### OpenClaw

Copy to your skills folder:

```bash
cp -r cloudreve ~/.agents/skills/
```

Then add to `openclaw.json`:

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

Restart gateway after saving.

### Other Agents

Copy this directory to your agent's skills folder. The skill follows the [Agent Skills specification](https://agentskills.io/specification.md).

## Structure

```
cloudreve/
├── SKILL.md                      # Core instructions (agent loads this)
├── README.md                     # This file
├── LICENSE                       # MIT License
├── scripts/
│   ├── upload.sh                 # Upload file to Cloudreve
│   ├── download.sh               # Download file from Cloudreve
│   ├── list.sh                   # List directory contents
│   ├── delete.sh                 # Delete a file
│   └── storage.sh                # Show storage usage
└── references/
    └── api-reference.md          # Cloudreve v4 API documentation
```

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

## Changelog

### v1.1.0 (2026-03-30)

- **Breaking:** Updated all API endpoints for Cloudreve v4
- **Breaking:** Login endpoint changed from `/api/v4/user/login` to `/api/v4/session/token`
- **Breaking:** Login fields changed from `userName`/`Password` to `email`/`password`
- Fixed JSON injection vulnerability in upload.sh and delete.sh (now using python3 for JSON construction)
- Updated file list API from `/api/v4/directory` to `/api/v4/file?uri=`
- Verified all scripts against live Cloudreve v4 instance

### v1.0.0 (2026-03-28)

- Initial release targeting Cloudreve v4

## License

MIT
