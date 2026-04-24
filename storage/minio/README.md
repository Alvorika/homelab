# MinIO

S3-compatible object storage. Console at `https://minio-console.${DOMAIN}`, API at `https://minio.${DOMAIN}`.

## Setup

1. Start: `docker compose up -d`
2. Access console at `https://minio-console.${DOMAIN}`
3. Login with `MINIO_ROOT_USER` / `MINIO_ROOT_PASSWORD`
4. Create a bucket (e.g., `outline`)
5. Create Access Keys under Access Keys → Create

## Policy

Bucket policies can be configured in the console or via the MinIO client (`mc`).

## Environment Variables

| Variable | Description |
|----------|-------------|
| `MINIO_ROOT_USER` | Admin username |
| `MINIO_ROOT_PASSWORD` | Admin password |
