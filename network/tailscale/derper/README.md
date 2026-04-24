# Self-hosted DERP Relay

DERP relays Tailscale traffic when direct peer-to-peer connections fail (NAT/CGNAT). Self-hosting one in your region avoids relying solely on Tailscale's official servers.

## Deployment

1. Set `${DERP_DOMAIN}` in `.env` to your public domain pointing to this server.
2. Place SSL certificate files in `./ssl/`:
   - `ssl/${DERP_DOMAIN}.crt`
   - `ssl/${DERP_DOMAIN}.key`
3. Start with Docker Compose, or use the systemd service.

## Firewall

Open ports:
- `4825/tcp` — DERP
- `43478/udp` — STUN

## Tailscale ACL Configuration

Add to your Tailscale ACL (Access Controls):

```json
"derpMap": {
    "OmitDefaultRegions": true,
    "Regions": {
        "900": {
            "RegionID": 900,
            "RegionCode": "myderp",
            "Nodes": [{
                "Name": "1",
                "RegionID": 900,
                "HostName": "${DERP_DOMAIN}",
                "DERPPort": 4825,
                "STUNPort": 43478,
                "InsecureForTests": true
            }]
        }
    }
}
```

## Verification

```bash
tailscale netcheck
# Should show only your self-hosted DERP region

curl https://${DERP_DOMAIN}:4825
# Should return "This is a Tailscale DERP server."
```
