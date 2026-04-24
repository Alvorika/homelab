# Jellyfin

Media streaming server.

## docker-compose.yml

```yaml
services:
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    restart: unless-stopped
    ports:
      - "${BIND_WEB:-127.0.0.1}:8096:8096"
    volumes:
      - ./config:/config
      - ./media:/media:ro
    environment:
      - TZ=Asia/Shanghai
```
