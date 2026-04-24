# LVM & RAID Setup

## RAID

Configure in UEFI/BIOS storage settings.

## LVM Creation

Example for a 21TB array: 16TB data, 4TB Docker.

```bash
# Physical Volume
sudo pvcreate /dev/md126

# Volume Group
sudo vgcreate storage_vg /dev/md126

# Logical Volumes
sudo lvcreate -L 16T -n data_lv storage_vg
sudo lvcreate -L 4T -n docker_lv storage_vg
```

## Docker Data Migration to LVM

```bash
# Stop Docker
sudo systemctl stop docker.socket docker.service

# Format and mount
sudo mkfs.xfs /dev/storage_vg/docker_lv
sudo mkdir /mnt/docker_root
sudo mount /dev/storage_vg/docker_lv /mnt/docker_root

# Copy data
sudo rsync -aXS --info=progress2 /var/lib/docker/ /mnt/docker_root/

# Update fstab (use actual UUID from blkid)
# UUID=<uuid> /var/lib/docker xfs defaults 0 2
sudo blkid /dev/storage_vg/docker_lv

# Switch over
sudo mv /var/lib/docker /var/lib/docker.bak
sudo mkdir /var/lib/docker
sudo umount /mnt/docker_root
sudo mount -a

# Verify and restart
df -h | grep /var/lib/docker
sudo systemctl start docker
docker info | grep "Docker Root Dir"
```

## LVM Resize

See `lvm-resize.md` for extending LVs when disk space runs low.
