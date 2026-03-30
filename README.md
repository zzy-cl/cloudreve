# cloudreve

An [Agent Skills](https://agentskills.io)-compatible skill for managing files on a self-hosted [Cloudreve v4](https://cloudreve.org) cloud storage instance.

## Features

- Upload local files to Cloudreve
- Download files from Cloudreve to local
- List directory contents
- Delete files
- Check storage usage
- JWT authentication via browser session or curl login

## How it works

```
User: "upload to cloudreve"
  ↓
Agent loads SKILL.md, gets token via agent-browser or curl
  ↓
Calls scripts/upload.sh with URL + token + file
  ↓
Cloudreve v4 API: PUT session → POST binary chunk → Done
```

## Requirements

- A running Cloudreve v4 instance (Docker or binary)
- `CLOUDREVE_URL`, `CLOUDREVE_USER`, `CLOUDREVE_PASS` environment variables
- `curl` and `python3` in agent shell
- `agent-browser` (optional, for browser-based token extraction)

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

## API Discovery

Cloudreve v4 has no public API documentation. All endpoints were reverse-engineered from browser network requests. Key findings:

- API prefix: `/api/v4/` (v3 returns 404)
- Upload: `PUT` to create session, `POST` to upload binary (not multipart)
- File URIs use `cloudreve://` scheme
- Download: `POST /api/v4/file/url` returns signed URLs

## License

MIT
