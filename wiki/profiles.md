# Deployment Profiles

The repository is organized so you can start with a small working core and add services later.

## Core

Use this to validate DNS, certificates, and authentication.

Components:

- `network/certs`
- `auth/authelia`
- reverse proxy template

Validation:

- `https://auth.${DOMAIN}/.well-known/openid-configuration` returns metadata.
- Authelia can authenticate a test user.

## Storage

Add shared backing services.

Components:

- `storage/postgresql`
- `storage/minio`
- Redis where each app requires it

Validation:

- PostgreSQL accepts admin login.
- MinIO console is reachable through the reverse proxy.
- Required buckets and access keys exist.

## First App

Gitea is the recommended first app because it has a small dependency footprint.

Components:

- `services/gitea`
- Authelia OIDC client for Gitea

Validation:

- Initial admin account exists.
- Public registration is disabled.
- OIDC login works.

## Collaboration

Components:

- `services/nextcloud`
- `services/outline`
- PostgreSQL users/databases
- MinIO bucket/access key for Outline

Validation:

- Nextcloud can log in and upload a file.
- Outline can create a document and upload an attachment.

## AI Tools

Components:

- `llm/ollama`
- `services/openwebui`
- optional `services/searxng`

Validation:

- OpenWebUI can authenticate through OIDC.
- OpenWebUI can reach Ollama.
- Search integration works if SearXNG is enabled.

## High-Privilege Compute

Components:

- `services/jupyterhub`
- optional GPU image under `services/jupyterhub/gpu`

Use this only after reading `wiki/jupyterhub.md`.

## File Sharing

Components:

- `services/samba`

Use only on trusted LAN/VPN segments. The template includes a guest-writable public share.

