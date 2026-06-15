# Docker Nginx Reverse Proxy

This directory is a template for the Docker-network-only reverse proxy pattern.

In this model, web applications do not publish host ports. The Nginx container is the only HTTP/HTTPS entry point and reaches applications by Docker DNS names on a shared internal network.

## Layout

| File | Purpose |
|------|---------|
| `docker-compose.yml.template` | Nginx container entry point |
| `nginx.conf.template` | Main Nginx config with WebSocket upgrade mapping |
| `conf.d/service.conf.template` | Generic per-service HTTPS reverse proxy |

## Network Model

Attach Nginx and each proxied application to the same Docker network:

```yaml
networks:
  global_docker_network:
    external: true
    name: global_docker_network
```

Then proxy to the application by service/container name, for example:

```text
UPSTREAM_URL=http://nextcloud:80
UPSTREAM_URL=http://outline:3001
UPSTREAM_URL=http://open-webui:8080
UPSTREAM_URL=http://onlyoffice:80
```

The application compose files can omit `ports:` for web traffic when Nginx is the only entry point.

## Rendering

Render these templates into deployment files with local environment variables, for example:

```bash
SERVICE_DOMAIN=cloud.example.internal \
UPSTREAM_URL=http://nextcloud:80 \
TLS_CERT=/etc/nginx/ssl/cloud.example.internal/cert.crt \
TLS_KEY=/etc/nginx/ssl/cloud.example.internal/private.key \
CLIENT_MAX_BODY_SIZE=10g \
../../scripts/render-template.sh conf.d/service.conf.template rendered/cloud.conf
```

Keep real domains, certificate paths, and secrets out of Git.
