#!/bin/bash
# Based on u-boot/doc/README.gpt.
# This script creates a block device inside a file.
# The block device is useful for testing commands like gdisk
# or u-boot's sandbox.
#
# Alison Chaiken, alison@she-devel.com
set -u
set -e

DISK=test.raw
LODEV=

create_disk() {
  echo "Creating new disk."
  /bin/rm "$DISK"
  truncate -s 1200M "$DISK"
}

partition_disk() {
  echo "Partitioning disk."
  sudo /sbin/sgdisk -n 1:2048:206847 -n 2:206848:411647 -n 3:411648:436223 -n 4:436224:460799 -n 5:460800:1279999 -n 6:1280000:2099199 "$DISK"
  sudo /sbin/sgdisk -t 1:EF00 -t 2:EF00 -t 3:8300 -t 4:8300 -t 5:8300 -t 6:8300 "$DISK"
}

create_filesystems() {
  echo "Creating filesystems."
  LODEV="$(sudo losetup -P -f --show "$DISK")"
  sudo mkfs.vfat -n EFI -v "$LODEV"p1
  sudo mkfs.vfat -n EFI -v "$LODEV"p2
  sudo mkfs.ext4 -v "$LODEV"p3
  sudo mkfs.ext4 -v "$LODEV"p4
  sudo mkfs.ext4 -L ROOT -v "$LODEV"p5
  sudo mkfs.ext4 -L ROOT -v "$LODEV"p6
}

copy_kernel() {
  echo "Copying the current kernel."
  sudo cp /boot/vmlinuz-"$(uname -r)" /mnt/testdisk/bzImage
}

copy_devicetree() {
  if [[ -f u-boot.dtb ]]; then
    echo "Copying the device-tree."
    sudo cp u-boot.dtb /mnt/testdisk/
  else
    echo "No u-boot.dtb device-tree found."
  fi
}

main() {
  create_disk
  partition_disk
  create_filesystems
  sudo mkdir -p /mnt/testdisk
  sudo mount -o loop "$LODEV"p1 /mnt/testdisk
  copy_kernel
  copy_devicetree
  sudo umount /mnt/testdisk
  sudo rmdir /mnt/testdisk
  sync
  echo "Done."
}

main "$@"
