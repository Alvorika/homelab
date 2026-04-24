# Homelab Server Wiki

This wiki is the main deployment guide for the repository. Service-level README files remain as reference notes, but a new deployment should start here.

## Pages

- `deployment.md` - step-by-step first deployment
- `env.md` - environment variable reference
- `profiles.md` - recommended staged deployment profiles
- `ports.md` - host port matrix and exposure notes
- `reverse-proxy.md` - reusable Nginx template workflow
- `backup.md` - backup and restore plan
- `jupyterhub.md` - high-privilege JupyterHub mode and hardening path

## Scope

The templates target an internal zero-trust homelab:

- Services are intended to live behind local DNS, TLS, reverse proxy, Authelia OIDC, LAN firewall rules, and Tailscale ACLs.
- Some compose files still publish host ports because deployments differ. Review every `ports:` section before exposing the host to untrusted networks.
- Storage mount paths are examples. Adjust them to match your SSD/HDD/data-disk layout before starting stateful services.

## Deployment Path

1. Clone the repository on the target host.
2. Copy `.env.example` to `.env` and fill every secret and host-specific value.
3. Create the shared Docker network:

```bash
docker network create global_docker_network
```

4. Render local templates with `scripts/render-all.sh` or your own config management tool.
5. Configure gateway networking if this host is also the router: netplan, sysctl, UFW, dnsmasq.
6. Generate or import local TLS certificates.
7. Start storage services: PostgreSQL, MinIO, Redis-bearing services.
8. Start Authelia and verify OIDC discovery.
9. Start application services.
10. Configure the reverse proxy and local DNS records.
11. Test each service through its final HTTPS domain, not only by host port.

## Required Planning

Before running compose, decide these values:

| Area | Decision |
|------|----------|
| LAN | `LAN_SUBNET`, `GATEWAY_IP`, `SERVER_IP`, physical interfaces |
| Domain | Internal domain such as `lab.internal`, plus service subdomains |
| Storage | SSD paths for databases, HDD paths for bulk files, backup paths |
| Auth | Authelia users, OIDC client secrets, 2FA method |
| Exposure | Which ports stay host-published and which are reverse-proxy only |
| Remote access | Tailscale subnet routes, ACLs, DERP if needed |

## Compose Working Directory

Compose files use relative paths. Run each compose command from the directory containing that service's `docker-compose.yml`.

Example:

```bash
cd services/gitea
docker compose up -d
```

Do not assume a compose file will work the same way if launched from the repository root unless you explicitly pass the right project directory and environment file.

## Environment Variables

Start from `.env.example`:

```bash
cp .env.example .env
```

Generate secrets with at least 32 random bytes where possible:

```bash
openssl rand -hex 32
```

Important variables:

| Variable | Purpose |
|----------|---------|
| `DOMAIN` | Base internal domain used by service URLs |
| `GATEWAY_IP` | DNS resolver and gateway address used by containers |
| `BIND_WEB`, `BIND_DATA`, `BIND_LAN`, `BIND_PUBLIC` | Host bind addresses for published ports |
| `POSTGRES_PASSWORD` | PostgreSQL admin password |
| `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD` | MinIO root credentials |
| `WEBUI_SECRET_KEY` | OpenWebUI session secret |
| `CLASH_EXTERNAL_CONTROLLER_SECRET` | Clash controller API secret |
| `GITEA_ADMIN_USER`, `GITEA_ADMIN_PASSWORD`, `GITEA_ADMIN_EMAIL` | Initial Gitea admin account |

Never commit a real `.env`, private key, certificate key, database file, or generated user database.

## Template Placeholders

Docker Compose expands variables from `.env`, but many application config files do not. Files such as `app.ini`, `configuration.yml`, `jupyterhub_config.py`, and Clash `config.yaml` may contain literal placeholders like `${DOMAIN}`.

Before starting a service, either:

- run `scripts/render-all.sh` to render the templates listed in `templates/render-manifest.tsv`, or
- replace placeholders in that service's config files with real values, or
- generate configs with Ansible, Helm, or another config management tool.

Rendered target files are kept in the repository as readable examples. Rendering for your own deployment will modify your local working tree; review the diff and do not commit secrets. `.gitignore` cannot protect files that are already tracked by Git.

Do not assume an application will expand `${VAR}` unless that application's documentation explicitly says so.

## Storage And Volumes

The repository intentionally leaves volume paths as templates or examples. Adjust them based on actual disks:

- Put PostgreSQL, SQLite, Redis persistence, and app metadata on SSD or NVMe.
- Put Nextcloud files, Samba shares, media, and large object storage on HDD or bulk storage.
- Keep MinIO data on reliable storage with backups. Do not treat it as a cache if Outline depends on it.
- Avoid placing large mutable service data inside the Git working tree.
- Confirm host directory ownership before first start. Many containers will create root-owned directories if the path does not exist.

Examples of paths that usually need local decisions:

| Service | Variables or mounts |
|---------|---------------------|
| Nextcloud | `NEXTCLOUD_DATA_DIR`, `NEXTCLOUD_DB_DATA_DIR` |
| Samba | `SAMBA_STORAGE_DIR`, `SAMBA_PUBLIC_DIR`, `/home/${SAMBA_USER}` |
| JupyterHub | `/home`, `/opt/jupyterhub_scripts`, user `jupyterhub_data` directories |
| MinIO | `minio_data` volume or equivalent host mount |
| PostgreSQL | `postgres_data` volume or equivalent host mount |

## Network And Ports

The intended access path for web services is:

```text
Browser -> HTTPS domain -> reverse proxy -> localhost or Docker service
```

Review published ports before deployment. If a service is only accessed through the reverse proxy, prefer binding it to loopback:

```yaml
ports:
  - "127.0.0.1:3001:3001"
```

Services such as Samba and Gitea SSH may need LAN-visible ports. Restrict those with host firewall rules and Tailscale ACLs.

## Reverse Proxy Targets

Typical upstream map:

| Domain | Upstream |
|--------|----------|
| `auth.${DOMAIN}` | `http://127.0.0.1:9091` |
| `gitea.${DOMAIN}` | `http://127.0.0.1:4000` |
| `cloud.${DOMAIN}` | `http://127.0.0.1:8003` |
| `wiki.${DOMAIN}` | `http://127.0.0.1:3001` |
| `chat.${DOMAIN}` | `http://127.0.0.1:3000` |
| `jupyter.${DOMAIN}` | `http://127.0.0.1:8000` |
| `search.${DOMAIN}` | `http://127.0.0.1:8014` |
| `minio.${DOMAIN}` | `http://127.0.0.1:9000` |
| `minio-console.${DOMAIN}` | `http://127.0.0.1:9001` |

## Authentication

Authelia is the central OIDC provider. Add or update OIDC clients in `auth/authelia/configuration.yml`, then configure each service with the matching client ID, secret, redirect URI, and discovery URL.

The discovery URL is:

```text
https://auth.${DOMAIN}/.well-known/openid-configuration
```

For production-like internal deployments:

- Use unique OIDC client secrets per service.
- Use hashed client secrets in Authelia where required.
- Keep password reset disabled unless SMTP is fully configured.
- Require two-factor authentication for user-facing services.

## Service Notes

### Gitea

The template disables public registration and expects users to enter by OIDC or administrator invitation. Set these before first start:

```env
GITEA_ADMIN_USER=admin
GITEA_ADMIN_PASSWORD=<strong-password>
GITEA_ADMIN_EMAIL=admin@example.com
```

The custom entrypoint creates the initial admin user if it does not exist. After startup, configure Authelia as an OAuth2/OpenID Connect authentication source in Gitea administration.

### Clash

The controller is bound to `127.0.0.1:9097` and should be protected with a strong secret. Replace `${CLASH_EXTERNAL_CONTROLLER_SECRET}` in the Clash config before starting, or render the config from a template. For remote dashboard access, prefer SSH tunneling, Tailscale ACL-restricted access, or a reverse proxy protected by Authelia. Do not expose the controller on `0.0.0.0` without a strong secret.

### JupyterHub

The current DockerSpawner template is a high-privilege mode because it uses the Docker socket and host user directories. Read `wiki/jupyterhub.md` before enabling it.

### SearXNG

The template keeps JSON search enabled for OpenWebUI integration and disables strict limiter behavior for private use. If exposed to a larger LAN or shared Tailscale network, enable limiter controls before use.

### Samba

The public share is writable by guests in the current template. Only use it on trusted LAN segments, and restrict SMB ports with firewall rules.

## Validation Checklist

After deployment:

- `docker network inspect global_docker_network` shows all expected services.
- `https://auth.${DOMAIN}/.well-known/openid-configuration` returns OIDC metadata.
- Each service works through its HTTPS domain.
- Direct host ports are reachable only from intended interfaces.
- Gitea public registration is disabled.
- Clash controller requires a secret and is not reachable from LAN unless intentionally proxied.
- Backups cover databases, MinIO data, Nextcloud files, Gitea repositories, Authelia config, and service secrets.
