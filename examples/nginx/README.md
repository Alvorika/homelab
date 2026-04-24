# Nginx Reverse Proxy Template

This directory contains a single reusable Nginx server template. Render it once per service by setting `SERVICE_DOMAIN`, `UPSTREAM_URL`, `TLS_CERT`, and `TLS_KEY`.

Example:

```bash
SERVICE_DOMAIN=gitea.lab.internal \
UPSTREAM_URL=http://127.0.0.1:4000 \
TLS_CERT=/etc/nginx/ssl/gitea.lab.internal/cert.crt \
TLS_KEY=/etc/nginx/ssl/gitea.lab.internal/private.key \
scripts/render-template.sh examples/nginx/service.conf.template examples/nginx/rendered/gitea.conf
```

Install the rendered file into your Nginx sites directory and reload Nginx after testing the config.

For WebSocket support, add this once in the `http {}` block of your main Nginx config:

```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}
```
