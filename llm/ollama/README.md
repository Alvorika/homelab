# Ollama

Local LLM inference with NVIDIA GPU acceleration.

## Prerequisites

- NVIDIA driver + Container Toolkit (see `infra/nvidia/`)

## Usage

```bash
# Start
docker compose up -d

# Pull a model
docker exec ollama ollama pull qwen2.5:7b

# List models
docker exec ollama ollama list

# Run interactively
docker exec -it ollama ollama run qwen2.5:7b
```

## Network

Joined to `global_docker_network` so OpenWebUI can reach it at `http://ollama:11434`.
