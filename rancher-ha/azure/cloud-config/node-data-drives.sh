#!/bin/bash
set -e

mkdir -p /var/lib/etcd/data
mkdir -p /var/lib/etcd/wal
mkdir -p /opt/rke/etcd-snapshots/

parted /dev/sdc --script mklabel gpt mkpart extpart ext4 0% 100%
parted /dev/sdd --script mklabel gpt mkpart extpart ext4 0% 100%
parted /dev/sde --script mklabel gpt mkpart extpart ext4 0% 100%

mkfs.ext4 /dev/sdc1
mkfs.ext4 /dev/sdd1
mkfs.ext4 /dev/sde1

partprobe /dev/sdc1
partprobe /dev/sdd1
partprobe /dev/sde1

UUID=$(ls -al /dev/disk/by-uuid/ | grep sdc1 | awk '{print $9}')
printf "UUID=$UUID       /var/lib/etcd/data      ext4    defaults,noexec,nofail        0       0\n" >> /etc/fstab

UUID=$(ls -al /dev/disk/by-uuid/ | grep sdd1 | awk '{print $9}')
printf "UUID=$UUID       /var/lib/etcd/wal      ext4    defaults,noexec,nofail        0       0\n" >> /etc/fstab

UUID=$(ls -al /dev/disk/by-uuid/ | grep sde1 | awk '{print $9}')
printf "UUID=$UUID       /opt/rke/etcd-snapshots/     ext4    defaults,noexec,nofail        0       0\n" >> /etc/fstab

mount -a