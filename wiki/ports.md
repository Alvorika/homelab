# Port Matrix

Published host ports are parameterized by bind address variables:

- `BIND_WEB=127.0.0.1` for reverse-proxy web services.
- `BIND_DATA=127.0.0.1` for database and object storage APIs.
- `BIND_LAN=0.0.0.0` for LAN/VPN services such as SMB and Git SSH.
- `BIND_PUBLIC=0.0.0.0` for public DERP relay ports.

| Service | Host port | Bind variable | Intended access | Notes |
|---------|-----------|---------------|-----------------|-------|
| Authelia | 9091 | `BIND_WEB` | Reverse proxy | Central auth endpoint |
| Gitea web | 4000 | `BIND_WEB` | Reverse proxy | Public registration disabled |
| Gitea SSH | 2222 | `BIND_LAN` | LAN/VPN | Restrict with firewall if needed |
| Nextcloud | 8003 | `BIND_WEB` | Reverse proxy | Large uploads may need proxy tuning |
| Outline | 3001 | `BIND_WEB` | Reverse proxy | Requires PostgreSQL, Redis, MinIO |
| OpenWebUI | `OPEN_WEBUI_PORT`, default 3000 | `BIND_WEB` | Reverse proxy | OIDC via Authelia |
| JupyterHub | 8000 | `BIND_WEB` | Reverse proxy | High-privilege DockerSpawner mode |
| SearXNG | 8014 | `BIND_WEB` | Reverse proxy/OpenWebUI | Limiter is relaxed in template |
| MinIO API | 9000 | `BIND_DATA` | Reverse proxy/internal apps | Protect credentials and bucket policies |
| MinIO Console | 9001 | `BIND_WEB` | Reverse proxy/admins | Admin UI |
| PostgreSQL | 5432 | `BIND_DATA` | Internal apps/admin LAN | Prefer loopback unless remote admin access is required |
| Samba | 139, 445 | `BIND_LAN` | LAN/VPN SMB | Public share is guest-writable |
| Clash HTTP | 7897 | host network | LAN/VPN proxy | Firewall controls required |
| Clash SOCKS | 7898 | host network | LAN/VPN proxy | Firewall controls required |
| Clash controller | 9097 | 127.0.0.1 in Clash config | local/tunnel only | Requires secret |
| YACD | 1234 | `BIND_WEB` | local/tunnel only | Dashboard frontend |
| DERP | 4825/tcp, 43478/udp | `BIND_PUBLIC` | public DERP host | Deploy only on intended public host |

To expose a web service directly to LAN, set `BIND_WEB=0.0.0.0`, but the recommended default is loopback plus reverse proxy.

