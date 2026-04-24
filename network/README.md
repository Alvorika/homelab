# Network Configuration

The gateway (lab-gateway) acts as a soft router for the 192.168.10.0/24 LAN, providing NAT, DNS, proxy, VPN, and firewall services.

## Topology

```
WAN (ISP) ── enp2s0f0 (DHCP) ── [Gateway] ── enp2s0f1 (192.168.10.1/24) ── LAN
                                      │
                                      ├─ dnsmasq (DNS + DHCP)
                                      ├─ Tailscale (subnet router)
                                      ├─ Clash (transparent proxy)
                                      └─ ufw (firewall + NAT)
```

## Components

| Path | Service | Role |
|------|---------|------|
| `gateway/` | netplan, ufw, dnsmasq, sysctl | OS-level routing + firewall |
| `tailscale/` | Tailscale + self-hosted DERP | VPN overlay + relay |
| `proxy/` | Clash + YACD dashboard | Transparent proxy |
| `certs/` | mkcert | Self-signed CA + per-service certs |

## Deployment Order

1. `gateway/` — netplan, sysctl, ufw, dnsmasq (base networking)
2. `certs/` — mkcert (CA needed by other services)
3. `proxy/` — Clash (optional, for outbound proxy)
4. `tailscale/` — VPN overlay (after base networking works)
