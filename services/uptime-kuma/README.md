# Uptime Kuma

Self-hosted uptime monitoring dashboard.

## docker-compose.yml

```yaml
services:
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    container_name: uptime-kuma
    restart: unless-stopped
    ports:
      - "${BIND_WEB:-127.0.0.1}:3002:3001"
    volumes:
      - ./data:/app/data
```
