# Cloudreve v4 API Reference

Reverse-engineered from Cloudreve v4 frontend source. All endpoints use `/api/v4` prefix.

## Authentication

### Login

```
POST /api/v4/session/token
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "your-password"
}
```

**Response:**
```json
{
  "code": 0,
  "data": {
    "user": {
      "id": "nGck",
      "email": "user@example.com",
      "nickname": "username",
      "status": "active",
      "group": { "id": "5lcE", "name": "Admin" }
    },
    "token": {
      "access_token": "eyJ...",
      "refresh_token": "eyJ...",
      "access_expires": "2026-03-30T22:56:42+08:00",
      "refresh_expires": "2026-04-13T21:56:42+08:00"
    }
  }
}
```

### Refresh Token

```
POST /api/v4/session/token/refresh
```

### Logout

```
DELETE /api/v4/session/token
```

## Storage

### Get Storage Capacity

```
GET /api/v4/user/capacity
Authorization: Bearer <token>
```

**Response:**
```json
{
  "code": 0,
  "data": {
    "total": 1099511627776,
    "used": 61438
  }
}
```

## Files

### List Directory

```
GET /api/v4/file?uri=<URL-encoded URI>
Authorization: Bearer <token>
```

- URI format: `cloudreve://my` (root), `cloudreve://my/subfolder` (subfolder)
- URL-encode the URI parameter

**Response:**
```json
{
  "code": 0,
  "data": {
    "files": [
      {
        "type": 0,
        "id": "mNuG",
        "name": "test.md",
        "size": 1024,
        "path": "cloudreve://my/test.md",
        "created_at": "2026-03-30T06:49:43Z"
      }
    ],
    "parent": { "type": 1, "id": "aRcd", "name": "" }
  }
}
```

- `type: 0` = file, `type: 1` = directory

### Upload File

**Step 1: Create Upload Session**

```
PUT /api/v4/file/upload
Authorization: Bearer <token>
Content-Type: application/json

{
  "uri": "cloudreve://my/filename.txt",
  "size": 12345
}
```

**Response:**
```json
{
  "code": 0,
  "data": {
    "session_id": "a39b0f4d-c3de-4aa4-aa4b-dc93c942c524",
    "chunk_size": 26214400
  }
}
```

**Step 2: Upload Binary**

```
POST /api/v4/file/upload/<session_id>/0
Authorization: Bearer <token>
Content-Type: application/octet-stream

<binary data>
```

### Download File

**Step 1: Get Download URL**

```
POST /api/v4/file/url
Authorization: Bearer <token>
Content-Type: application/json

{
  "uris": ["cloudreve://my/file.txt"]
}
```

**Response:**
```json
{
  "code": 0,
  "data": {
    "urls": [
      {
        "url": "https://cloudreve.example.com/api/v4/file/content/..."
      }
    ]
  }
}
```

**Step 2: Download from signed URL**

```
GET <signed_url>
```

### Delete File

```
DELETE /api/v4/file
Authorization: Bearer <token>
Content-Type: application/json

{
  "uris": ["cloudreve://my/file.txt"]
}
```

## URI Scheme

Cloudreve v4 uses `cloudreve://` URIs:

| URI | Description |
|-----|-------------|
| `cloudreve://my` | User's root directory |
| `cloudreve://my/path/file.txt` | File in subdirectory |
| `cloudreve://share` | Shared files |
| `cloudreve://mount?<params>` | Mounted storage |

## Error Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 40001 | Validation error (empty field) |
| 40016 | Path not exist |
| 40077 | Entity not exist |
| 40081 | File operation failed |
| 403 | Not supported action |
