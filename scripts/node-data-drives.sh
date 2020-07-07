#!/bin/bash
set -e

sudo parted /dev/sdc --script mklabel gpt mkpart extpart ext4 0% 100%
sudo parted /dev/sdd --script mklabel gpt mkpart extpart ext4 0% 100%
sudo parted /dev/sde --script mklabel gpt mkpart extpart ext4 0% 100%

sudo mkfs.ext4 /dev/sdc1
sudo mkfs.ext4 /dev/sdd1
sudo mkfs.ext4 /dev/sde1

sudo partprobe /dev/sdc1
sudo partprobe /dev/sdd1
sudo partprobe /dev/sde1


UUID=$(ls -al /dev/disk/by-uuid/ | grep sdc1 | awk '{print $9}')
printf "UUID=$UUID       /var/lib/etcd/data      ext4    defaults,noexec,nofail        0       0\n" >> /etc/fstab


UUID=$(ls -al /dev/disk/by-uuid/ | grep sdd1 | awk '{print $9}')
printf "UUID=$UUID       /var/lib/etcd/wal      ext4    defaults,noexec,nofail        0       0\n" >> /etc/fstab


UUID=$(ls -al /dev/disk/by-uuid/ | grep sde1 | awk '{print $9}')
printf "UUID=$UUID       /opt/rke/etcd-snapshots/     ext4    defaults,noexec,nofail        0       0\n" >> /etc/fstab