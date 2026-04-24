# Gitea

Self-hosted Git service with OAuth2 (Authelia OIDC) login.

## First-Run Setup

Set the initial admin variables before first start:

```env
GITEA_ADMIN_USER=admin
GITEA_ADMIN_PASSWORD=<strong-password>
GITEA_ADMIN_EMAIL=admin@example.com
```

The custom entrypoint creates this admin account if it does not already exist. After starting, visit `https://gitea.${DOMAIN}` and configure OIDC login.

## OAuth2 (Authelia)

In Site Administration → Identity & Access → Authentication Sources → Add:

- Authentication Type: OAuth2
- Authentication Name: Authelia
- OAuth2 Provider: OpenID Connect
- OpenID Connect Auto Discovery URL: `https://auth.${DOMAIN}/.well-known/openid-configuration`

## Notes

- Web UI exposed on host port 4000, internal container port 3000
- SSH exposed on port 2222
- Uses SQLite database (no external PostgreSQL required)
- Public registration is disabled; use OIDC login and administrator invitations
