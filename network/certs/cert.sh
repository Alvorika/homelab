#!/bin/bash
# Certificate management via mkcert in Docker
# Usage: cert.sh --init-ca | --update | --add <domain> | --remove <domain>
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MKCERT_CA_DIR="${SCRIPT_DIR}/mkcert_data/ca"
MKCERT_CERTS_DIR="${SCRIPT_DIR}/mkcert_data/certs"
DOMAINS_FILE="${SCRIPT_DIR}/domains.txt"

run_mkcert_in_docker() {
    echo "  Docker Exec: mkcert $@"
    (cd "${SCRIPT_DIR}" && docker compose run --rm -T mkcert "$@")
}

initialize_ca_if_needed() {
    if [ ! -f "${MKCERT_CA_DIR}/rootCA.pem" ]; then
        echo "Local CA not found. Initializing..."
        mkdir -p "${MKCERT_CA_DIR}" "${MKCERT_CERTS_DIR}"
        run_mkcert_in_docker -install
        echo "--------------------------------------------------------------------------"
        echo "IMPORTANT: New CA created at '${MKCERT_CA_DIR}/rootCA.pem'."
        echo "Install it on all devices/client systems."
        echo "--------------------------------------------------------------------------"
    else
        run_mkcert_in_docker -install > /dev/null
    fi
}

generate_certificate_for_domain() {
    local domain_or_ip="$1"
    [ -z "$domain_or_ip" ] && { echo "Error: No domain provided."; return 1; }
    echo "Generating certificate for: ${domain_or_ip}"
    run_mkcert_in_docker -cert-file "${domain_or_ip}.pem" -key-file "${domain_or_ip}-key.pem" "${domain_or_ip}"
    echo "Created: ${MKCERT_CERTS_DIR}/${domain_or_ip}.pem, ${MKCERT_CERTS_DIR}/${domain_or_ip}-key.pem"
}

read_domains_to_array() {
    local -n domains_array_ref=$1
    domains_array_ref=()
    [ ! -f "${DOMAINS_FILE}" ] && return
    mapfile -t temp_domains < <(grep -v '^\s*#' "${DOMAINS_FILE}" | grep -v '^\s*$')
    for domain in "${temp_domains[@]}"; do
        domains_array_ref+=("$(echo "$domain" | xargs)")
    done
}

main() {
    case "$1" in
        --init-ca)
            echo "Ensuring CA is initialized..."
            initialize_ca_if_needed
            ;;
        --update)
            initialize_ca_if_needed
            local domains_to_process
            read_domains_to_array domains_to_process
            [ ${#domains_to_process[@]} -eq 0 ] && { echo "No domains found."; exit 0; }
            for domain in "${domains_to_process[@]}"; do
                generate_certificate_for_domain "$domain"
            done
            echo "Certificate update complete."
            ;;
        --add)
            [ -z "$2" ] && { echo "Usage: $0 --add <domain>"; exit 1; }
            local new_domain="$2"
            initialize_ca_if_needed
            [ ! -f "${DOMAINS_FILE}" ] && touch "${DOMAINS_FILE}"
            grep -q -x -E "${new_domain}" "${DOMAINS_FILE}" || echo "${new_domain}" >> "${DOMAINS_FILE}"
            generate_certificate_for_domain "$new_domain"
            ;;
        --remove)
            [ -z "$2" ] && { echo "Usage: $0 --remove <domain>"; exit 1; }
            local domain_to_remove="$2"
            [ -f "${DOMAINS_FILE}" ] && {
                tmp_file=$(mktemp)
                grep -v -x -E "${domain_to_remove}" "${DOMAINS_FILE}" > "${tmp_file}"
                mv "${tmp_file}" "${DOMAINS_FILE}"
            }
            rm -f "${MKCERT_CERTS_DIR}/${domain_to_remove}.pem" "${MKCERT_CERTS_DIR}/${domain_to_remove}-key.pem"
            echo "Removed: ${domain_to_remove}"
            ;;
        *)
            echo "Usage: $0 [--init-ca|--update|--add <domain>|--remove <domain>]"
            exit 1
            ;;
    esac
}

main "$@"
