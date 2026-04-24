# Scrutiny

SMART HDD/SSD health monitoring dashboard.

## docker-compose.yml

```yaml
services:
  scrutiny:
    image: ghcr.io/analogj/scrutiny:master-omnibus
    container_name: scrutiny
    restart: unless-stopped
    ports:
      - "${BIND_WEB:-127.0.0.1}:8082:8080"
    volumes:
      - ./config:/opt/scrutiny/config
      - ./influxdb:/opt/scrutiny/influxdb
      - /run/udev:/run/udev:ro
    cap_add:
      - SYS_RAWIO
    devices:
      - /dev/sda:/dev/sda
      - /dev/sdb:/dev/sdb
    environment:
      SCRUTINY_WEB: "true"
      SCRUTINY_COLLECTOR: "true"
```
