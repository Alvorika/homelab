# System Configuration

## SSH

- Config file: `/etc/ssh/sshd_config`
- Gateway SSH on port 202 (non-standard)
- Key-based authentication recommended

```bash
# Disable cloud-init networking (local server)
# Add to /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg:
network: {config: disabled}
```

## User Management

```bash
# Create user
sudo useradd -m -s /bin/bash <username>
sudo passwd <username>

# Grant sudo
sudo usermod -aG sudo <username>

# Fix home permissions
sudo chown -R <username>:<username> /home/<username>
```

## Memory Limits for Users

Use cgroups/systemd user slices to limit per-user memory usage.
