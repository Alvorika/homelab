# UFW Firewall

## Setup

```bash
# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default deny forward

# Allow LAN services
sudo ufw allow in on ${LAN_INTERFACE} from ${LAN_SUBNET} to any port 202 proto tcp   # SSH
sudo ufw allow in on ${LAN_INTERFACE} from ${LAN_SUBNET} to any port 53                # DNS
sudo ufw allow in on ${LAN_INTERFACE} from any port 68 to any port 67 proto udp        # DHCP

# Allow Tailscale
sudo ufw allow in on tailscale0
sudo ufw allow 41641/udp

# Allow proxy from LAN and Tailscale
sudo ufw allow in on ${LAN_INTERFACE} from ${LAN_SUBNET} to any port 7897 proto tcp
sudo ufw allow in on tailscale0 from ${LAN_SUBNET} to any port 7897 proto tcp

# Forwarding rules
sudo ufw route allow in on ${LAN_INTERFACE} out on ${WAN_INTERFACE}
sudo ufw route allow in on ${WAN_INTERFACE} out on ${LAN_INTERFACE}
```

## Configuration File

Edit `/etc/default/ufw` and set:
```
DEFAULT_FORWARD_POLICY="ACCEPT"
```

## NAT Rules

Add the content of `before.rules` to `/etc/ufw/before.rules` before the `*filter` section.
