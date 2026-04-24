# SearXNG

Privacy-respecting metasearch engine with JSON API for OpenWebUI integration.

## Setup

1. Start: `docker compose up -d`
2. In OpenWebUI, configure the search API URL: `https://search.${DOMAIN}/search?q=<query>`
3. The JSON API is available at `https://search.${DOMAIN}/search?format=json&q=<query>`

## Environment Variables

| Variable | Description |
|----------|-------------|
| `SEARXNG_SECRET_KEY` | Random secret for server (generate with `openssl rand -hex 32`) |
