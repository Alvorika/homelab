# Samba

SMB/CIFS file sharing for LAN access.

## Setup

1. Configure environment variables in `.env`
2. Start: `docker compose up -d`
3. Access: `smb://${SERVER_IP}`

## Environment Variables

| Variable | Description |
|----------|-------------|
| `SAMBA_USER` | Primary SMB user |
| `SAMBA_USER_PASSWORD` | Password for primary user |
| `SAMBA_ADMIN_USER` | Admin username |
| `SAMBA_ADMIN_PASSWORD` | Admin password |
| `SAMBA_STORAGE_DIR` | Host path for user storage share |
| `SAMBA_PUBLIC_DIR` | Host path for public share |

## Shares

- `\\<server>\${SAMBA_USER}` — private user share (auth required)
- `\\<server>\public` — read/write public share (guest ok)
