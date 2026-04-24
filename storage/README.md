# Storage & Databases

Shared data services used by multiple applications. All connected via `global_docker_network`.

## Components

| Path | Service | Used By | Service Name |
|------|---------|---------|--------------|
| `minio/` | MinIO (S3-compatible) | Outline | `minio` |
| `postgresql/` | PostgreSQL | Outline, Nextcloud | `db` |
| `redis/` | Redis config | Authelia, Outline | `redis` (in authelia compose) |

## Network

All services share `global_docker_network`. Create it once:

```bash
docker network create global_docker_network
```

## Deployment Order

1. `docker network create global_docker_network`
2. PostgreSQL
3. MinIO
4. Authelia (includes Redis)
5. Application services
