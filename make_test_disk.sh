#!/bin/bash
# Based on u-boot/doc/README.gpt.
# This script creates a block device inside a file.
# The block device is useful for testing commands like gdisk
# or u-boot's sandbox.
#
# Alison Chaiken, alison@she-devel.com

DISK=test.raw
truncate -s 1200M "$DISK"
/sbin/sgdisk -n 1:2048:206847 -n 2:206848:411647 -n 3:411648:436223 -n 4:436224:460799 -n 5:460800:1279999 -n 6:1280000:2099199 "$DISK"
/sbin/sgdisk -t 1:EF00 -t 2:EF00 -t 3:8300 -t 4:8300 -t 5:8300 -t 6:8300 "$DISK"
LODEV="$(sudo losetup -P -f --show "$DISK")"
sudo mkfs.vfat -n EFI -v "$LODEV"p1
sudo mkfs.vfat -n EFI -v "$LODEV"p2
sudo mkfs.ext4 -v "$LODEV"p3
sudo mkfs.ext4 -v "$LODEV"p4
sudo mkfs.ext4 -L ROOT -v "$LODEV"p5
sudo mkfs.ext4 -L ROOT -v "$LODEV"p6
