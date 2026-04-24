#!/bin/bash
# Authelia service management
# Usage: ./auth.sh [--start|--stop|--restart|--logs|--fix-perms|--help]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/data/config"
COMPOSE_DIR="${SCRIPT_DIR}"

fix_config_permissions() {
    echo "Fixing permissions for $CONFIG_DIR..."
    sudo chown -R "$(id -u):$(id -g)" "$CONFIG_DIR" 2>/dev/null || \
        echo "Warning: Could not fix permissions. Run manually: sudo chown -R \$(id -u):\$(id -g) $CONFIG_DIR"
}

case "${1:---help}" in
    --start)
        (cd "$COMPOSE_DIR" && docker compose up -d)
        fix_config_permissions
        ;;
    --stop)
        (cd "$COMPOSE_DIR" && docker compose down)
        ;;
    --restart)
        (cd "$COMPOSE_DIR" && docker compose down && docker compose up -d)
        fix_config_permissions
        ;;
    --logs)
        (cd "$COMPOSE_DIR" && docker compose logs -f authelia)
        ;;
    --fix-perms)
        fix_config_permissions
        ;;
    *)
        echo "Usage: $0 [--start|--stop|--restart|--logs|--fix-perms]"
        exit 1
        ;;
esac
