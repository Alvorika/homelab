# JupyterHub Mode

The current JupyterHub template is a high-privilege DockerSpawner deployment.

## docker-host Mode

This mode is practical for a trusted internal compute host:

- JupyterHub mounts `/var/run/docker.sock`.
- JupyterHub mounts host user directories.
- The Hub container runs as root so it can prepare user directories and spawn containers.
- User notebook containers can receive CPU, R, or GPU images.

Treat this as host-admin equivalent. If the Hub container or a Hub admin account is compromised, the attacker may be able to control the host through Docker.

## Why It Exists

The template needs to:

- map Authelia users to host UID/GID values
- create per-user `jupyterhub_data` directories
- mount those directories into spawned notebook containers
- optionally attach NVIDIA GPU devices

## Hardening Path

Recommended next steps for a more reusable deployment:

1. Move UID/GID lookup and directory creation into a small host-side helper.
2. Limit that helper to known Authelia users and `/home/<user>/jupyterhub_data`.
3. Remove the full `/home` mount from the Hub container.
4. Replace raw Docker socket access with a Docker socket proxy where possible.
5. Consider rootless Docker, KubernetesSpawner, or a separate compute node for stronger isolation.

## Domain Placeholders

`jupyterhub_config.py` contains literal `${DOMAIN}` strings. Python will not expand them automatically. Replace them during deployment or update the config to read `DOMAIN` from the environment.

