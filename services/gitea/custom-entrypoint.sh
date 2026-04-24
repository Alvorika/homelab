#!/bin/sh
# Gitea custom entrypoint — install self-signed CA then delegate to original entrypoint
set -e

echo "[Gitea Custom Entrypoint] Starting..."

run_gitea() {
    if command -v su-exec >/dev/null 2>&1; then
        su-exec git gitea "$@"
    else
        gitea "$@"
    fi
}

if [ -f /usr/local/share/ca-certificates/custom_host_ca.crt ]; then
    echo "[Gitea Custom Entrypoint] Installing custom CA certificate..."
    update-ca-certificates
fi

if [ -n "${GITEA_ADMIN_PASSWORD:-}" ]; then
    GITEA_CONFIG="${GITEA_CONFIG:-/data/gitea/conf/app.ini}"
    GITEA_ADMIN_USER="${GITEA_ADMIN_USER:-admin}"
    GITEA_ADMIN_EMAIL="${GITEA_ADMIN_EMAIL:-admin@example.com}"

    echo "[Gitea Custom Entrypoint] Ensuring initial admin user exists..."
    run_gitea migrate --config "${GITEA_CONFIG}" >/dev/null

    if run_gitea admin user list --config "${GITEA_CONFIG}" | awk '{print $2}' | grep -Fxq "${GITEA_ADMIN_USER}"; then
        echo "[Gitea Custom Entrypoint] Admin user '${GITEA_ADMIN_USER}' already exists."
    else
        run_gitea admin user create \
            --config "${GITEA_CONFIG}" \
            --username "${GITEA_ADMIN_USER}" \
            --password "${GITEA_ADMIN_PASSWORD}" \
            --email "${GITEA_ADMIN_EMAIL}" \
            --admin \
            --must-change-password=false
    fi
else
    echo "[Gitea Custom Entrypoint] GITEA_ADMIN_PASSWORD is not set; skipping initial admin creation."
fi

echo "[Gitea Custom Entrypoint] Handing over to original entrypoint..."
exec /usr/bin/entrypoint "$@"
