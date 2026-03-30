# Cloudreve v4 API Reference

## Authentication

- **Type**: JWT Bearer Token
- **Header**: `Authorization: Bearer <access_token>`
- **Token source**: Browser `localStorage` → `cloudreve_session` → `sessions[id].token.access_token`

## Endpoints

### File Operations

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v4/file?uri=<encoded_uri>` | List files in directory |
| PUT | `/api/v4/file/upload` | Create upload session |
| POST | `/api/v4/file/upload/{session_id}/{chunk}` | Upload file chunk |
| POST | `/api/v4/file/url` | Get signed download URLs |
| DELETE | `/api/v4/file` | Delete files |
| GET | `/api/v4/file/thumb?uri=<uri>` | Get file thumbnail |

### User

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v4/user/capacity` | Storage usage |

### Site

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v4/site/config/basic` | Site configuration |
| GET | `/api/v4/site/config/explorer` | Explorer configuration |

## URI Format

Cloudreve uses `cloudreve://` scheme:

```
cloudreve://my/                    # Root directory
cloudreve://my/folder/             # Subdirectory
cloudreve://my/folder/file.txt     # File path
```

URL-encode when passing as query parameter: `cloudreve%3A%2F%2Fmy%2Ffolder`

## Request/Response Details

### Create Upload Session (PUT)

**Request**:
```json
{
  "uri": "cloudreve://my/file.txt",
  "size": 12345
}
```

**Response**:
```json
{
  "code": 0,
  "data": {
    "session_id": "uuid",
    "chunk_size": 26214400,
    "expires": 3600
  },
  "msg": ""
}
```

### Get Download URL (POST)

**Request**:
```json
{
  "uris": ["cloudreve://my/file.txt"]
}
```

**Response**:
```json
{
  "code": 0,
  "data": {
    "urls": [
      {
        "url": "/api/v4/file/content/{id}/{index}/{name}?sign={signature}"
      }
    ],
    "expires": "2026-03-30T15:00:00+08:00"
  },
  "msg": ""
}
```

### Delete Files (DELETE)

**Request**:
```json
{
  "uris": ["cloudreve://my/file.txt"]
}
```

**Response**:
```json
{
  "code": 0,
  "msg": ""
}
```

## Error Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 40001 | Missing required parameter |
| 40016 | Path/file not found |
| 40081 | Aggregated error (multi-file operation) |
