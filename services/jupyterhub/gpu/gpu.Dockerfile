# GPU Notebook Dockerfile (PyTorch)
# Build: docker build -t gpu-notebook:torch128 -f gpu.Dockerfile .
FROM pytorch/pytorch:1.28.0-cuda12.4-cudnn9-devel

# System packages
COPY apt-packages.txt /tmp/apt-packages.txt
RUN apt-get update && \
    xargs -a /tmp/apt-packages.txt apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Python packages
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# Jupyter config
COPY jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

# Entrypoint scripts
COPY start.sh /usr/local/bin/start.sh
COPY start-notebook.sh /usr/local/bin/start-notebook.sh
COPY start-singleuser.sh /usr/local/bin/start-singleuser.sh
RUN chmod +x /usr/local/bin/start*.sh

# UV (fast Python package manager)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
COPY uv.toml /etc/uv/uv.toml

# Fix permissions
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod +x /usr/local/bin/fix-permissions

ENV NB_USER=jovyan
ENV NB_UID=1000
ENV NB_GID=100

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER || true

USER $NB_USER
WORKDIR /home/$NB_USER

ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]
