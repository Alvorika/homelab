# OpenWebUI

Chat interface for LLM models, connected to Ollama. Uses Authelia OIDC for authentication.

## Dependencies

- Ollama (see `llm/ollama/`)
- Authelia OIDC

## Environment Variables

| Variable | Description |
|----------|-------------|
| `WEBUI_SECRET_KEY` | Random secret for session encryption |
| `OPENWEBUI_OIDC_CLIENT_SECRET` | OIDC client secret matching Authelia config |
| `OPEN_WEBUI_PORT` | Host port (default: 3000) |
