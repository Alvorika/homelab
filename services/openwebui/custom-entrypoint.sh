#!/bin/sh
# OpenWebUI custom entrypoint — install self-signed CA
set -e

echo "[OpenWebUI Custom Entrypoint] Preparing to update CA certificates..."

CUSTOM_CA_DIR_SRC="/usr/local/share/ca-certificates"
MOUNTED_CA_FILE="/etc/ssl/certs/custom_ca.pem"
TARGET_CA_FILENAME="custom_host_ca.crt"
TARGET_CA_FILE_FULL_PATH="${CUSTOM_CA_DIR_SRC}/${TARGET_CA_FILENAME}"

SYSTEM_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
SYSTEM_CA_DIR_HASHED="/etc/ssl/certs"

mkdir -p "${CUSTOM_CA_DIR_SRC}"

if [ -f "${MOUNTED_CA_FILE}" ]; then
    echo "[OpenWebUI Custom Entrypoint] Copying custom CA..."
    cp "${MOUNTED_CA_FILE}" "${TARGET_CA_FILE_FULL_PATH}"
    chmod 644 "${TARGET_CA_FILE_FULL_PATH}"

    update_ca_output=$(update-ca-certificates 2>&1)
    echo "[OpenWebUI Custom Entrypoint] update-ca-certificates output:"
    echo "${update_ca_output}"
else
    echo "[OpenWebUI Custom Entrypoint] WARNING: Custom CA file ${MOUNTED_CA_FILE} not found."
fi

export REQUESTS_CA_BUNDLE="${SYSTEM_CA_BUNDLE}"
export SSL_CERT_FILE="${SYSTEM_CA_BUNDLE}"
export SSL_CERT_DIR="${SYSTEM_CA_DIR_HASHED}"

echo "[OpenWebUI Custom Entrypoint] Executing original command: $@"
exec "$@"
