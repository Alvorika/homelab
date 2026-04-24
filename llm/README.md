# LLM Services

Local LLM inference with GPU acceleration and web chat interface.

## Components

| Path | Service | Role |
|------|---------|------|
| `llm/ollama/` | Ollama | Model serving (GPU) |
| `services/openwebui/` | OpenWebUI | Chat interface (OIDC auth) |

## Architecture

```
Browser ── nginx ── OpenWebUI ── Ollama (GPU)
                      │
                      └── Authelia OIDC
```

## Network

Both Ollama and OpenWebUI are on `global_docker_network`. OpenWebUI reaches Ollama via the service name `ollama`.
