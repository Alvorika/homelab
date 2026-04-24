#!/bin/bash
# Fetch certificates from gateway to app server
# Run on the app server periodically to sync certs

REMOTE_USER="${REMOTE_USER:-gateway}"
REMOTE_HOST="${REMOTE_HOST:-${GATEWAY_IP}}"
REMOTE_SSH_PORT="${REMOTE_SSH_PORT:-202}"
REMOTE_CERT_PARENT_DIR="${REMOTE_CERT_PARENT_DIR:-/opt/lab/mkcert/mkcert_data/certs}"
DOMAIN_NAME="${DOMAIN_NAME:-${DOMAIN}}"
SSH_KEY_PATH="${SSH_KEY_PATH:-${HOME}/.ssh/lab-gateway}"
REMOTE_UPDATE_SCRIPT_PATH="${REMOTE_UPDATE_SCRIPT_PATH:-/opt/lab/mkcert/cert.sh}"

REMOTE_CERT_FILENAME="${DOMAIN_NAME}.pem"
REMOTE_KEY_FILENAME="${DOMAIN_NAME}-key.pem"
LOCAL_SSL_BASE_DIR="/etc/nginx/ssl"
LOCAL_CERT_DEST_DIR="${LOCAL_SSL_BASE_DIR}/${DOMAIN_NAME}"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

SSH_OPTIONS="-i ${SSH_KEY_PATH} -p ${REMOTE_SSH_PORT}"
SCP_OPTIONS="-i ${SSH_KEY_PATH} -P ${REMOTE_SSH_PORT}"

echo "Syncing certs from ${REMOTE_USER}@${REMOTE_HOST}..."

# Trigger remote cert update
ssh ${SSH_OPTIONS} -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no \
    "${REMOTE_USER}@${REMOTE_HOST}" \
    "cd \$(dirname ${REMOTE_UPDATE_SCRIPT_PATH}) && ./\$(basename ${REMOTE_UPDATE_SCRIPT_PATH}) --update"

# Fetch cert and key
scp ${SCP_OPTIONS} "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_CERT_PARENT_DIR}/${REMOTE_CERT_FILENAME}" "${TEMP_DIR}/"
scp ${SCP_OPTIONS} "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_CERT_PARENT_DIR}/${REMOTE_KEY_FILENAME}" "${TEMP_DIR}/"

# Install
sudo mkdir -p "${LOCAL_CERT_DEST_DIR}"
sudo mv "${TEMP_DIR}/${REMOTE_CERT_FILENAME}" "${LOCAL_CERT_DEST_DIR}/cert.crt"
sudo mv "${TEMP_DIR}/${REMOTE_KEY_FILENAME}" "${LOCAL_CERT_DEST_DIR}/private.key"
sudo chown root:root "${LOCAL_CERT_DEST_DIR}/cert.crt" "${LOCAL_CERT_DEST_DIR}/private.key"
sudo chmod 0644 "${LOCAL_CERT_DEST_DIR}/cert.crt"
sudo chmod 0600 "${LOCAL_CERT_DEST_DIR}/private.key"

echo "Certificates installed to ${LOCAL_CERT_DEST_DIR}"
