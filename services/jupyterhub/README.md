# JupyterHub

Multi-user Jupyter notebook server with DockerSpawner. Each user gets an isolated container with their choice of image (CPU, GPU, R).

## Dependencies

- Docker (needs Docker socket access)
- Authelia OIDC (for authentication)
- GPU: NVIDIA Container Toolkit + GPU Dockerfile (in `gpu/`)

## Setup

1. Build the JupyterHub image: `docker build -t jupyterhub:v5.3.0 -f Dockerfile.jupyterhub .`
2. Build GPU notebook images (see `gpu/README.md`)
3. Create `/opt/jupyterhub_scripts/prepare_user_dir.sh` on the host
4. Start: `docker compose up -d`

## Template Notes

`jupyterhub_config.py` contains literal `${DOMAIN}` placeholders. Python will not expand them automatically. Replace them during deployment or change the config to read `DOMAIN` from the environment.

The DockerSpawner setup uses the Docker socket and host user directories so it can create per-user notebook containers and bind user storage. Treat this mode as high privilege. For stronger isolation, move UID/GID lookup and directory creation into a restricted host helper, or use a Docker socket proxy, rootless Docker, KubernetesSpawner, or a separate compute node.

## GPU Support

Place GPU-related Dockerfiles in `gpu/`. The spawner detects `is_custom: true` images and mounts additional volumes (kernels, uv cache).

## VSCode Connection

1. Generate API token from JupyterHub → Hub Control Panel → Token
2. In VSCode: Select Kernel → Existing JupyterHub Server
3. URL: `https://jupyter.${DOMAIN}/user/<username>/lab`
