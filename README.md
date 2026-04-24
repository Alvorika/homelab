# Homelab Infrastructure

Homelab server infrastructure configuration, organized by service type. Covers two physical machines — a gateway/router and a main application server — connected via a 192.168.10.0/24 LAN with Tailscale overlay for remote access.

## Architecture

```
Internet ── lab-gateway (Router/NAT) ── 192.168.10.0/24 LAN ── lab-server (App Server)
                │                                                   │
                ├─ NAT / ufw firewall                               ├─ Authelia (SSO/OIDC)
                ├─ Tailscale subnet router                          ├─ Gitea, Nextcloud, Outline
                ├─ Clash proxy                                      ├─ JupyterHub, OpenWebUI
                ├─ dnsmasq (local DNS)                              ├─ Ollama (GPU)
                ├─ DERP relay                                       ├─ MinIO, PostgreSQL
                └─ mkcert (self-signed CA)                          └─ Samba, Jellyfin, ...
```

```mermaid
flowchart LR
    internet((Internet))
    remote[Tailscale clients]

    subgraph gateway["lab-gateway / Router"]
        nat[NAT + UFW]
        dns[dnsmasq DNS/DHCP]
        clash[Clash proxy]
        tsGateway[Tailscale subnet router]
        certs[mkcert CA]
    end

    subgraph lan["192.168.10.0/24 LAN"]
        app["lab-server / App Server"]
    end

    subgraph appstack["Application stack"]
        rp[Reverse proxy]
        authelia[Authelia SSO/OIDC]
        gitea[Gitea]
        nextcloud[Nextcloud]
        outline[Outline]
        jupyter[JupyterHub]
        openwebui[OpenWebUI]
        searxng[SearXNG]
        samba[Samba]
        ollama[Ollama GPU]
        postgres[(PostgreSQL)]
        minio[(MinIO)]
    end

    internet --> nat
    remote --> tsGateway
    tsGateway --> lan
    nat --> lan
    dns --> lan
    clash --> nat
    certs -. local trust .-> rp

    app --> rp
    rp --> authelia
    rp --> gitea
    rp --> nextcloud
    rp --> outline
    rp --> jupyter
    rp --> openwebui
    rp --> searxng
    app --> samba

    gitea --> authelia
    nextcloud --> authelia
    outline --> authelia
    jupyter --> authelia
    openwebui --> authelia

    nextcloud --> postgres
    outline --> postgres
    outline --> minio
    openwebui --> ollama
```

## Directory Structure

| Directory | Purpose |
|-----------|---------|
| `network/` | Gateway routing, Tailscale VPN, proxy, DNS, certificates |
| `auth/` | Authelia SSO/OIDC identity provider |
| `services/` | User-facing applications |
| `storage/` | Databases and object storage |
| `llm/` | LLM inference services |
| `dev/` | Development tools and Dockerfiles |
| `infra/` | OS-level setup guides (Docker, LVM/RAID, NVIDIA, SSH) |

## Quick Start

Start with the centralized wiki:

1. Read `wiki/README.md`
2. Copy `.env.example` to `.env` and fill in your values
3. Render local templates with `scripts/render-all.sh`
4. Review storage mount paths for your SSD/HDD layout
5. Deploy services in order: network → storage → auth → services

## Conventions

- All sensitive values (passwords, keys, tokens) are replaced with placeholders
- Each service uses environment variables or `.env` files for configuration
- Docker Compose is the primary deployment method
- Services share `global_docker_network` unless a service explicitly uses host networking
- Rendering templates can modify tracked example files; review diffs before committing

## Documentation

- `wiki/README.md` — main deployment guide
- `wiki/deployment.md` — step-by-step deployment path
- `wiki/env.md` — environment variable reference
- `wiki/profiles.md` — staged deployment profiles
- `wiki/ports.md` — host port matrix
- `wiki/reverse-proxy.md` — reusable Nginx reverse proxy template
- `wiki/backup.md` — backup and restore plan
- `wiki/jupyterhub.md` — high-privilege JupyterHub mode and hardening path
- `templates/render-manifest.tsv` — config template rendering manifest
- `SECURITY.md` — security model and high-risk components
- Service-level `README.md` files — service-specific notes and manual setup details
