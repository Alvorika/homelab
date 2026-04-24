#!/bin/sh
set -eu

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$root_dir"

status=0

if [ ! -f .env ]; then
    echo "WARN: .env is missing. Copy .env.example to .env before deployment."
fi

if command -v docker >/dev/null 2>&1; then
    if ! docker network inspect global_docker_network >/dev/null 2>&1; then
        echo "WARN: Docker network global_docker_network does not exist."
    fi
else
    echo "WARN: docker command not found; skipping Docker checks."
fi

echo "Checking compose files..."
find . -name docker-compose.yml -type f | sort | while IFS= read -r compose_file; do
    compose_dir="$(dirname "$compose_file")"
    if command -v docker >/dev/null 2>&1; then
        if ! (cd "$compose_dir" && docker compose --env-file "$root_dir/.env.example" config >/dev/null); then
            echo "ERROR: docker compose config failed in $compose_dir" >&2
            exit 1
        fi
    fi
done || status=1

echo "Scanning for unresolved template placeholders in deployable config files..."
if command -v rg >/dev/null 2>&1; then
    rg -n '\$\{[A-Za-z_][A-Za-z0-9_]*(?::[?\-][^}]*)?\}' \
        -g '*.yml' -g '*.yaml' -g '*.conf' -g '*.ini' -g '*.toml' -g '*.service' \
        . || true
else
    find . \( -name '*.yml' -o -name '*.yaml' -o -name '*.conf' -o -name '*.ini' -o -name '*.toml' -o -name '*.service' \) \
        -type f -exec grep -n '\${' {} \; || true
fi

if [ "$status" -eq 0 ]; then
    echo "Config check completed."
else
    echo "Config check completed with errors." >&2
fi

exit "$status"
