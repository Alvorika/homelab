# Overleaf

Online LaTeX editor (self-hosted).

## docker-compose.yml

```yaml
services:
  sharelatex:
    image: sharelatex/sharelatex:latest
    container_name: sharelatex
    restart: unless-stopped
    ports:
      - "${BIND_WEB:-127.0.0.1}:8080:80"
    volumes:
      - ./sharelatex_data:/var/lib/sharelatex
      - ./sharelatex_data/tmp:/var/lib/sharelatex/tmp
    environment:
      SHARELATEX_APP_NAME: 'Overleaf'
      SHARELATEX_SITE_URL: 'https://latex.${DOMAIN}'
      SHARELATEX_ADMIN_EMAIL: 'admin@${DOMAIN}'
    networks:
      - overleaf_net

  mongo:
    image: mongo:latest
    container_name: overleaf_mongo
    restart: unless-stopped
    volumes:
      - ./mongo_data:/data/db
    networks:
      - overleaf_net

  redis:
    image: redis:alpine
    container_name: overleaf_redis
    restart: unless-stopped
    volumes:
      - ./redis_data:/data
    networks:
      - overleaf_net

networks:
  overleaf_net:
    driver: bridge
```
