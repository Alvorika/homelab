# Redis

Shared Redis server used by Authelia, Outline, and Nextcloud.

The Redis instance is defined inside the Authelia `docker-compose.yml` (see `auth/authelia/`). All services share `global_docker_network`, so other services reach it as `redis`.

The `redis.conf` here serves as a reference configuration.
