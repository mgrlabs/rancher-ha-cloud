#!/bin/bash
set -e

dev=("sdc" "sdd" "sde")
path=("/var/lib/etcd/data" "/var/lib/etcd/wal" "/opt/rke/etcd-snapshots/ ")
count=0
for i in "${dev[@]}"
do
	echo $i
	echo ${path[$count]}
	((count++))
	echo "sudo parted /dev/${i} --script mklabel gpt mkpart extpart ext4 0% 100%"
	echo "sudo mkfs.ext4 /dev/${i}1"
	echo "sudo partprobe /dev/${i}1"
	UUID=$(ls -al /dev/disk/by-uuid/ | grep ${i}1 | awk '{print $9}')
	echo "printf "UUID=$UUID       ${path[$count]}      ext4    defaults,noexec,nofail        0       0\n" >> /etc/fstab"
done


# sudo parted /dev/sdc --script mklabel gpt mkpart extpart ext4 0% 100%
# sudo parted /dev/sdd --script mklabel gpt mkpart extpart ext4 0% 100%
# sudo parted /dev/sde --script mklabel gpt mkpart extpart ext4 0% 100%

# sudo mkfs.ext4 /dev/sdc1
# sudo mkfs.ext4 /dev/sdd1
# sudo mkfs.ext4 /dev/sde1

# sudo partprobe /dev/sdc1
# sudo partprobe /dev/sdd1
# sudo partprobe /dev/sde1


# UUID=$(ls -al /dev/disk/by-uuid/ | grep sdc1 | awk '{print $9}')
# printf "UUID=$UUID       /var/lib/etcd/data      ext4    defaults,noexec,nofail        0       0\n" >> /etc/fstab


# UUID=$(ls -al /dev/disk/by-uuid/ | grep sdd1 | awk '{print $9}')
# printf "UUID=$UUID       /var/lib/etcd/wal      ext4    defaults,noexec,nofail        0       0\n" >> /etc/fstab


# UUID=$(ls -al /dev/disk/by-uuid/ | grep sde1 | awk '{print $9}')
# printf "UUID=$UUID       /opt/rke/etcd-snapshots/     ext4    defaults,noexec,nofail        0       0\n" >> /etc/fstab