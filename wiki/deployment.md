# Deployment Guide

This guide describes a practical first deployment path. Run each compose command from the service directory unless stated otherwise.

## 1. Prepare Environment

```bash
cp .env.example .env
```

Edit `.env` and replace every `change-me`, `generate-a-random-secret`, and placeholder value.

Generate random secrets:

```bash
openssl rand -hex 32
```

Create the shared Docker network:

```bash
docker network create global_docker_network
```

## 2. Render Local Templates

Some non-compose config files contain literal `${VAR}` placeholders. Render or replace them before starting services.

Render all tracked templates:

```bash
scripts/render-all.sh
```

Render one template manually:

```bash
SERVICE_DOMAIN=gitea.lab.internal \
UPSTREAM_URL=http://127.0.0.1:4000 \
TLS_CERT=/etc/nginx/ssl/gitea.lab.internal/cert.crt \
TLS_KEY=/etc/nginx/ssl/gitea.lab.internal/private.key \
CLIENT_MAX_BODY_SIZE=100m \
scripts/render-template.sh examples/nginx/service.conf.template examples/nginx/rendered/gitea.conf
```

The default manifest is `templates/render-manifest.tsv`. Remove entries for services you do not deploy, or maintain your own manifest.

The repository keeps rendered target files in place as readable examples. Running `scripts/render-all.sh` will overwrite those files in your local working tree. Review the resulting diff before starting services. `.gitignore` cannot protect files that are already tracked by Git, so never commit rendered secrets.

## 3. Gateway And DNS

If this repository also configures your gateway:

1. Review `network/gateway/netplan/01-netcfg.yaml`.
2. Review `network/gateway/sysctl/99-forwarding.conf`.
3. Review `network/gateway/ufw/README.md`.
4. Render dnsmasq files and verify local DNS records.

Do not apply gateway networking blindly on a remote machine without console access.

## 4. Certificates

Use `network/certs/` for local CA and service certificates, or replace it with your own CA process.

Install the root CA only on devices you control. Keep the CA private key out of Git.

## 5. Storage

Start PostgreSQL:

```bash
cd storage/postgresql
docker compose up -d
```

Create application databases and users as needed. For Outline, see `storage/postgresql/README.md`.

Start MinIO:

```bash
cd storage/minio
docker compose up -d
```

Create required buckets and access keys, such as the `outline` bucket.

## 6. Authentication

Prepare Authelia config:

- user database
- secrets under `auth/authelia/data/secrets`
- OIDC private key
- hashed OIDC client secrets

Start Authelia:

```bash
cd auth/authelia
docker compose up -d
```

Verify:

```bash
curl -k https://auth.${DOMAIN}/.well-known/openid-configuration
```

## 7. Applications

Start only the services you need. See `wiki/profiles.md` for staged deployment profiles.

Gitea:

```bash
cd services/gitea
docker compose up -d
```

Nextcloud:

```bash
cd services/nextcloud
docker compose up -d
```

Outline:

```bash
cd services/outline
docker compose up -d
```

OpenWebUI and Ollama:

```bash
cd llm/ollama
docker compose up -d

cd ../../services/openwebui
docker compose up -d
```

## 8. Reverse Proxy

Render one Nginx config per service from `examples/nginx/service.conf.template`, install it into your Nginx sites directory, then test and reload Nginx.

See `wiki/reverse-proxy.md`.

## 9. Validate

Run:

```bash
scripts/check-config.sh
```

Then verify each service through its final HTTPS domain.
