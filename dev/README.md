# Developer Tools

Development environments and tooling on the app server.

## Components

| Path | Purpose |
|------|---------|
| `code-server/` | VS Code in browser |
| `labelstudio/` | Data labeling platform |
| `dockerfiles/` | Custom Docker images |

## VS Code Server

Install automatically when connecting via SSH from VS Code (`Remote - SSH` extension).

## Permissions

For shared user directories:

```bash
sudo chown -R $USER:$USER /home/<username>
```
