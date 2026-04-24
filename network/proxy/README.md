# Clash Proxy

Transparent HTTP/SOCKS5 proxy running on the gateway. LAN and Tailscale devices can use it for outbound traffic.

## Deployment

1. Copy `clash/config/config.yaml`.
2. Replace `${CLASH_SUBSCRIPTION_URL}` and `${CLASH_EXTERNAL_CONTROLLER_SECRET}`, or render the file from `.env` with your config management tool.
3. Start: `docker compose -f clash/docker-compose.yml up -d`
4. Dashboard: `docker compose -f yacd/docker-compose.yml up -d`

## Usage

- HTTP proxy: `http://${GATEWAY_IP}:7897`
- SOCKS5 proxy: `socks5://${GATEWAY_IP}:7898`
- Dashboard: `http://${GATEWAY_IP}:1234`

The Clash external controller binds to `127.0.0.1:9097` by default. Use SSH tunneling, Tailscale ACLs, or an authenticated reverse proxy for remote dashboard access.

## Firewall

Ensure ufw allows LAN and Tailscale access to port 7897.
