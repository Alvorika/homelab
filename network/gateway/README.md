# Gateway (Soft Router)

## Overview

The gateway functions as a soft router, providing NAT, DNS, DHCP, and firewall services using standard Linux tools. It has two NICs: one for WAN (DHCP), one for LAN (static IP).

## Components

| File | Purpose |
|------|---------|
| `netplan/01-netcfg.yaml` | Network interface configuration |
| `sysctl/99-forwarding.conf` | Enable kernel IP forwarding |
| `ufw/before.rules` | NAT masquerade rules |
| `ufw/README.md` | UFW firewall rules |
| `dnsmasq/dnsmasq.conf` | DNS + DHCP server config |
| `dnsmasq/dnsmasq_hosts` | Local DNS A records |
| `traffic-shaping/cake-setup.sh` | CAKE QoS for bufferbloat |

## Setup Order

1. **netplan** — Configure interfaces (`/etc/netplan/`), run `sudo netplan apply`
2. **Cloud-init** — Disable cloud-init network management:
   ```bash
   echo "network: {config: disabled}" | sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
   ```
3. **sysctl** — Enable IP forwarding: `sudo sysctl -p /etc/sysctl.d/99-forwarding.conf`
4. **ufw** — Set up NAT and firewall rules (see `ufw/README.md`)
5. **dnsmasq** — Install and configure: `sudo apt install dnsmasq -y`

   If `systemd-resolved` conflicts with port 53:
   ```bash
   sudo sed -i 's/^nameserver.*/nameserver 127.0.0.1/' /etc/resolv.conf
   sudo systemctl restart dnsmasq
   ```

6. **CAKE** (optional) — Run `traffic-shaping/cake-setup.sh` for bufferbloat mitigation

## SSH

Gateway SSH runs on port 202 (non-standard).

## Firewall Summary

| Port | Interface | Purpose |
|------|-----------|---------|
| 202/tcp | LAN | SSH |
| 53 | LAN | DNS |
| 67/udp | LAN | DHCP |
| 7897/tcp | LAN, Tailscale | Clash proxy |
| 41641/udp | Any | Tailscale |
