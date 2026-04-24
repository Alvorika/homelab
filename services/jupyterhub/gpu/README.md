# GPU Notebook

Custom PyTorch-based Jupyter notebook image with CUDA support.

## Build

```bash
docker build -t gpu-notebook:torch128 -f gpu.Dockerfile .
```

## UV (Python Environment Manager)

Pre-installed. Usage inside the container:

```bash
uv venv -p python3.11 myenv
source myenv/bin/activate
uv pip install ipykernel
python -m ipykernel install --user --name myenv --display-name "myenv"
```

If uv times out on slow networks:

```bash
export UV_HTTP_TIMEOUT=1200
export UV_REQUEST_TIMEOUT=1200
```
