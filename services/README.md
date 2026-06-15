# Application Services

User-facing applications, all deployed via Docker Compose on the app server. Most services use Authelia OIDC for authentication.

All services share a single Docker network: `global_docker_network`. Services reference each other by Docker service name (e.g., `authelia`, `postgresql`, `minio`, `ollama`).

## Services

| Service | Default upstream | Dependencies |
|---------|------------------|--------------|
| Authelia (auth) | `${BIND_WEB}:9091` | Redis |
| Gitea | `${BIND_WEB}:4000` | Authelia (OIDC) |
| Nextcloud | `${BIND_WEB}:8003` | PostgreSQL, Redis, Authelia (OIDC) |
| OnlyOffice | `${BIND_WEB}:8004` | Nextcloud |
| Outline | `${BIND_WEB}:3001` | PostgreSQL, Redis, MinIO, Authelia (OIDC) |
| OpenWebUI | `${BIND_WEB}:${OPEN_WEBUI_PORT:-3000}` | Ollama, Authelia (OIDC) |
| JupyterHub | `${BIND_WEB}:8000` | Docker socket, Authelia (OIDC) |
| SearXNG | `${BIND_WEB}:8014` | — |
| MinIO API | `${BIND_DATA}:9000` | — |
| MinIO Console | `${BIND_WEB}:9001` | — |

## Certificate Trust

Services that need to reach HTTPS endpoints internally (OIDC callbacks) use `custom-entrypoint.sh` to install the self-signed root CA at container start.

## Reverse Proxy

Nginx on the host terminates TLS and reverse-proxies to each service by domain:

| Domain | Upstream |
|--------|----------|
| `auth.${DOMAIN}` | `http://127.0.0.1:9091` |
| `gitea.${DOMAIN}` | `http://127.0.0.1:4000` |
| `cloud.${DOMAIN}` | `http://127.0.0.1:8003` |
| `office.${DOMAIN}` | `http://127.0.0.1:8004` |
| `wiki.${DOMAIN}` | `http://127.0.0.1:3001` |
| `chat.${DOMAIN}` | `http://127.0.0.1:3000` |
| `jupyter.${DOMAIN}` | `http://127.0.0.1:8000` |
| `search.${DOMAIN}` | `http://127.0.0.1:8014` |
| `minio-console.${DOMAIN}` | `http://127.0.0.1:9001` |
| `minio.${DOMAIN}` | `http://127.0.0.1:9000` |
