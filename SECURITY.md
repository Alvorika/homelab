# Security Policy

## Supported Scope

This repository is a homelab infrastructure template for internal, zero-trust deployments. It is not a hardened public-internet appliance.

Use it behind local DNS, TLS, reverse proxy, Authelia/OIDC, host firewall rules, and Tailscale ACLs. Review every service before exposing it outside a trusted network.

## High-Privilege Components

Pay special attention to:

- JupyterHub: DockerSpawner uses the Docker socket and host user directories. Treat this as host-admin equivalent.
- Samba: the template includes a writable guest public share. Restrict SMB ports to trusted LAN/VPN segments.
- Clash: host networking and controller API must not be exposed without a strong secret and network controls.
- Tailscale subnet routing: advertised routes can make LAN services reachable from remote devices.
- mkcert CA material: the CA private key can mint trusted certificates for your local domain.
- Published Docker ports: some templates intentionally publish host ports for flexibility.

## Secret Handling

Never commit:

- `.env`
- private keys
- generated TLS key material
- Authelia user databases with real password hashes
- database files or application data
- MinIO access keys or OIDC client secrets

Rotate any secret that was accidentally pushed to a public remote.

## Reporting Issues

Open a GitHub issue for template hardening suggestions or documentation gaps. If an issue contains real secrets, remove them first and rotate the affected values.

