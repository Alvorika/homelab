# Reverse Proxy

The repository provides one generic Nginx template at `examples/nginx/service.conf.template`.

## Render A Service

Example for Gitea:

```bash
SERVICE_DOMAIN=gitea.lab.internal \
UPSTREAM_URL=http://127.0.0.1:4000 \
TLS_CERT=/etc/nginx/ssl/gitea.lab.internal/cert.crt \
TLS_KEY=/etc/nginx/ssl/gitea.lab.internal/private.key \
CLIENT_MAX_BODY_SIZE=100m \
scripts/render-template.sh examples/nginx/service.conf.template examples/nginx/rendered/gitea.conf
```

Install the rendered file:

```bash
sudo cp examples/nginx/rendered/gitea.conf /etc/nginx/sites-available/gitea.conf
sudo ln -s /etc/nginx/sites-available/gitea.conf /etc/nginx/sites-enabled/gitea.conf
sudo nginx -t
sudo systemctl reload nginx
```

## WebSocket Support

Add this once inside the main Nginx `http {}` block:

```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}
```

## Typical Upstreams

| Service | Domain | Upstream |
|---------|--------|----------|
| Authelia | `auth.${DOMAIN}` | `http://127.0.0.1:9091` |
| Gitea | `gitea.${DOMAIN}` | `http://127.0.0.1:4000` |
| Nextcloud | `cloud.${DOMAIN}` | `http://127.0.0.1:8003` |
| Outline | `wiki.${DOMAIN}` | `http://127.0.0.1:3001` |
| OpenWebUI | `chat.${DOMAIN}` | `http://127.0.0.1:3000` |
| JupyterHub | `jupyter.${DOMAIN}` | `http://127.0.0.1:8000` |
| SearXNG | `search.${DOMAIN}` | `http://127.0.0.1:8014` |
| MinIO API | `minio.${DOMAIN}` | `http://127.0.0.1:9000` |
| MinIO Console | `minio-console.${DOMAIN}` | `http://127.0.0.1:9001` |

Some applications need their own trusted proxy settings. Confirm each service's documentation after adding the reverse proxy.
