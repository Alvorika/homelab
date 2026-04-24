# Infrastructure Setup

OS-level guides and configurations for bare-metal setup.

## Topics

| Path | Topic |
|------|-------|
| `docker-install/` | Docker CE installation (Ubuntu/Debian) |
| `lvm-raid/` | RAID array + LVM for Docker data migration |
| `system/` | SSH, user management, resource limits |
| `nvidia/` | NVIDIA drivers + Container Toolkit |

## Server Specs

- **Gateway**: Ubuntu, dual NIC, acts as soft router
- **App Server**: Ubuntu/Debian, NVIDIA GPU, RAID storage array
