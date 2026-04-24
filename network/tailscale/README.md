# Tailscale VPN

Tailscale provides secure overlay networking between remote devices and the local LAN.

## Architecture

- **Gateway** runs Tailscale natively as subnet router for `192.168.10.0/24`
- **Application server** runs Tailscale in Docker (host network) as subnet router for secondary subnets
- **Self-hosted DERP relay** on a public server for cases where direct connections fail
- **Tailscale DNS** configured with global nameserver pointing to the gateway's `dnsmasq`

## Setup

### 1. Gateway (Subnet Router)

Install and run Tailscale directly on the gateway:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --accept-dns=false --advertise-routes=${LAN_SUBNET}
```

In the Tailscale admin console: Machines → Subnets → Edit route settings → approve the advertised subnet.

### 2. App Server (Docker Container)

Use the `docker-compose.yml` in this directory. After starting:

```bash
docker exec tailscale tailscale up --reset --accept-dns=false --advertise-routes=192.168.3.0/24
```

### 3. DERP Relay

Deploy `derper/docker-compose.yml` on a public server. See `derper/README.md`.

### 4. DNS

In the Tailscale admin console: DNS → Nameservers → add a Global nameserver pointing to the gateway IP. Enable "Override local DNS".

### 5. Client

Install Tailscale on remote devices and log in. LAN devices are accessible via their LAN addresses, such as `192.168.10.x` in the default template.

## Tuning

If IPv6 connectivity drops on certain ISPs (e.g., China Mobile), reduce MTU:

```bash
sudo ip link set dev <wan_interface> mtu 1280
# Persist:
sudo nmcli connection modify "<connection_name>" 802-3-ethernet.mtu 1280
```
