#!/bin/sh
# Nextcloud custom entrypoint — install self-signed CA then delegate to original entrypoint
set -e

echo ">>> [CUSTOM ENTRYPOINT] Starting custom entrypoint script..."

if [ -f /usr/local/share/ca-certificates/custom_host_ca.crt ]; then
    echo ">>> [CUSTOM ENTRYPOINT] Custom CA certificate found. Updating certificate store..."
    update-ca-certificates
    echo ">>> [CUSTOM ENTRYPOINT] Certificate store updated."
else
    echo ">>> [CUSTOM ENTRYPOINT] Custom CA certificate not found, skipping update."
fi

if [ $# -eq 0 ]; then
  set -- "apache2-foreground"
fi

echo ">>> [CUSTOM ENTRYPOINT] Handing over to original entrypoint with command: $@"
exec /entrypoint.sh "$@"
