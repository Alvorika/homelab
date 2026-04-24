# Outline

Collaborative Markdown knowledge base with Authelia OIDC auth, PostgreSQL storage, and MinIO object storage.

## Dependencies

- PostgreSQL (see `storage/postgresql/`)
- Redis (shared)
- MinIO (see `storage/minio/`)
- Authelia OIDC (see `auth/authelia/`)

## Setup

1. Start dependencies first: PostgreSQL, Redis, MinIO
2. Create an S3 bucket named `outline` in MinIO
3. Create S3 access keys and set them in `docker.env`
4. Start Outline: `docker compose up -d`

## Environment Variables

See `docker.env` for all variables. Key ones:

| Variable | Source |
|----------|--------|
| `OUTLINE_SECRET_KEY` | `openssl rand -hex 32` |
| `OUTLINE_UTILS_SECRET` | `openssl rand -hex 32` |
| `OUTLINE_DB_PASSWORD` | From PostgreSQL user setup |
| `OUTLINE_S3_ACCESS_KEY` | From MinIO access keys |
| `OUTLINE_S3_SECRET_KEY` | From MinIO access keys |
| `OUTLINE_OIDC_CLIENT_SECRET` | Matches Authelia OIDC client |
