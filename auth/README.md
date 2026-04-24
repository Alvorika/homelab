# Authentication & Identity

Centralized SSO via Authelia with OIDC provider support. All user-facing services authenticate through Authelia.

## Architecture

```
Browser ── nginx (TLS) ── service (gitea/nextcloud/...) ── callback ── Authelia OIDC
                                │
                                └── redirect to https://auth.${DOMAIN}
```

## Network

All services share a single Docker network: `global_docker_network`.

Create it once before deploying any service:

```bash
docker network create global_docker_network
```

## Components

| Path | Purpose |
|------|---------|
| `authelia/` | Authelia SSO server (OIDC provider + 2FA + access control) |

## Adding a New OIDC Client

1. Add a `client` block in Authelia `configuration.yml`
2. Configure the service to use OIDC/OAuth2 with the Authelia discovery URL:
   `https://auth.${DOMAIN}/.well-known/openid-configuration`
