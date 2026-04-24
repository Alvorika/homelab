# Environment Reference

Use `.env.example` as the source of truth for variable names. Copy it to `.env`, then replace every placeholder before deployment.

## Core Required

These values are needed by most deployments.

| Variable | Required | Purpose |
|----------|----------|---------|
| `DOMAIN` | yes | Base internal domain, default `lab.internal` |
| `LAN_SUBNET` | yes | LAN CIDR |
| `GATEWAY_IP` | yes | Gateway and local DNS address |
| `SERVER_IP` | yes | Application server address |
| `BIND_WEB` | yes | Bind address for reverse-proxy web services, default `127.0.0.1` |
| `BIND_DATA` | yes | Bind address for databases/object storage APIs, default `127.0.0.1` |
| `CA_CERT_PATH` | yes | Host path to the local root CA certificate |

## Gateway Required

Only required if this repo configures your router/gateway.

| Variable | Required | Purpose |
|----------|----------|---------|
| `LAN_INTERFACE` | gateway | LAN NIC |
| `WAN_INTERFACE` | gateway | WAN NIC |
| `BIND_LAN` | gateway | Bind address for LAN services such as Samba or Gitea SSH |
| `CLASH_SUBSCRIPTION_URL` | optional | Clash provider URL |
| `CLASH_EXTERNAL_CONTROLLER_SECRET` | optional | Clash controller API secret |

## Remote Access

| Variable | Required | Purpose |
|----------|----------|---------|
| `TAILSCALE_AUTH_KEY` | optional | Tailscale auth key |
| `DERP_DOMAIN` | DERP only | Public DERP relay domain |
| `BIND_PUBLIC` | DERP only | Bind address for public DERP ports |

## Authentication

| Variable | Required | Purpose |
|----------|----------|---------|
| `AUTHELIA_SESSION_SECRET` | auth | Authelia session secret |
| `AUTHELIA_STORAGE_ENCRYPTION_KEY` | auth | Authelia storage encryption key |
| `AUTHELIA_SMTP_*` | auth | SMTP settings for notifications |
| `OIDC_PRIVATE_KEY` | auth | OIDC signing key material or rendered placeholder |
| `*_OIDC_CLIENT_SECRET` | per app | Plain client secret configured in each service |
| `*_OIDC_CLIENT_SECRET_HASH` | auth | Hashed client secret configured in Authelia |

## Storage

| Variable | Required | Purpose |
|----------|----------|---------|
| `POSTGRES_USER` | storage | PostgreSQL admin username |
| `POSTGRES_PASSWORD` | storage | PostgreSQL admin password |
| `POSTGRES_DB` | storage | Default database |
| `MINIO_ROOT_USER` | storage | MinIO root username |
| `MINIO_ROOT_PASSWORD` | storage | MinIO root password |

## Application-Specific

| Variable | Required | Purpose |
|----------|----------|---------|
| `GITEA_ADMIN_*` | Gitea | Initial Gitea administrator |
| `GITEA_LFS_JWT_SECRET` | Gitea | Gitea LFS JWT secret |
| `GITEA_INTERNAL_TOKEN` | Gitea | Gitea internal token |
| `GITEA_OAUTH2_JWT_SECRET` | Gitea | Gitea OAuth2 JWT secret |
| `NEXTCLOUD_*` | Nextcloud | Admin, database, and storage path settings |
| `OUTLINE_*` | Outline | App secrets, database password, and S3 credentials |
| `WEBUI_SECRET_KEY` | OpenWebUI | OpenWebUI session secret |
| `OPEN_WEBUI_PORT` | OpenWebUI | Host port for OpenWebUI |
| `SEARXNG_SECRET_KEY` | SearXNG | SearXNG application secret |
| `SAMBA_*` | Samba | SMB users, passwords, and share paths |
| `JUPYTERHUB_ADMIN` | JupyterHub | Initial JupyterHub admin username |

## Reverse Proxy Template

These variables are used by `examples/nginx/service.conf.template`.

| Variable | Required | Purpose |
|----------|----------|---------|
| `SERVICE_DOMAIN` | render | Domain for one rendered Nginx server |
| `UPSTREAM_URL` | render | Local upstream URL |
| `TLS_CERT` | render | Certificate path |
| `TLS_KEY` | render | Private key path |
| `CLIENT_MAX_BODY_SIZE` | render | Nginx upload size limit |

