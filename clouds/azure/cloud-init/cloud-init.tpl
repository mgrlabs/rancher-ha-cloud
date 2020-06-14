#cloud-config
disk_setup:
  /dev/disk/azure/scsi1/lun0:
    table_type: gpt
    layout: true
    overwrite: false
  /dev/disk/azure/scsi1/lun1:
    table_type: gpt
    layout: true
    overwrite: false
  /dev/disk/azure/scsi1/lun2:
    table_type: gpt
    layout: true
    overwrite: false

fs_setup:
  - device: /dev/disk/azure/scsi1/lun0
    partition: 1
    filesystem: ext4
  - device: /dev/disk/azure/scsi1/lun1
    partition: 1
    filesystem: ext4
  - device: /dev/disk/azure/scsi1/lun2
    partition: 1
    filesystem: ext4

mounts:
  - [
      "/dev/disk/azure/scsi1/lun0-part1",
      "/var/lib/etcd/data",
      auto,
      "defaults,noexec,nofail",
    ]
  - [
      "/dev/disk/azure/scsi1/lun1-part1",
      "/var/lib/etcd/wal",
      auto,
      "defaults,noexec,nofail",
    ]
  - [
      "/dev/disk/azure/scsi1/lun2-part1",
      "/opt/rke/etcd-snapshots/",
      auto,
      "defaults,noexec,nofail",
    ]