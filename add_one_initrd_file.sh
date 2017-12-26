#!/bin/bash
set -u
set -e

readonly OUTFILE=/tmp/new-initrd/initrd-new.img
readonly OUTDIR=/tmp/new-initrd

usage() {
  cat <<EOT
usage: add_one_initrd_file.sh FILETOADD TARGETDIRECTORY
Example: add_one_initrd_file.sh dsdt.aml kernel/firmware/acpi
See for example Documentation/acpi/initrd_table_override.txt.
EOT
}

check_prerequisites() {
 if [[ ! -x /usr/bin/unmkinitramfs ]]; then
    echo "Please install the initramfs-tools-core package."
    exit 1
  fi
  if [[ ! -x ./scripts/gen_initramfs_list.sh ]]; then
    echo "Please run this script from the top-level kernel-source directory."
    exit 1
  fi
  if [[ ! -r /boot/initrd.img-"$(uname -r)" ]]; then
    echo "No initrd.img with which to start."
    exit 1
  fi
  if [[ ! -r "$1" ]]; then
    echo "Cannot stat ${1}"
    exit 1
  fi
}

prepare_files() {
  echo "Cleaning ${OUTDIR}."
  /bin/rm -rf "$OUTDIR"/*
  unmkinitramfs /boot/initrd.img-"$(uname -r)" "$OUTDIR"
  cd "$OUTDIR"
  mv main/* .
  mv early/* .
  rmdir main early
  cd -
}

check_new_initrd() {
  type="$(file "$OUTFILE" | grep "gzip compressed data, max compression, from Unix")"
  readonly type
  if [[ ! -n "$type" ]]; then
    echo "New initrd ${1} is wrong type."
    exit 1
  fi
  target="$(basename "$1")"
  found="$(lsinitramfs ${OUTFILE} | grep "$2"/"$target")"
  if [[ ! -n "$found" ]]; then
     echo "Copy failed."
  fi
}

main() {
  if (( $# != 2 )); then
    usage
    exit 1
  fi
  check_prerequisites "$1"

  echo "Extracting into ${OUTDIR}"
  prepare_files
  mkdir -p "$2"
  cp "$1" "$OUTDIR/$2"

  ./scripts/gen_initramfs_list.sh -o "$OUTFILE" "$OUTDIR"
  check_new_initrd "$1" "$2"
  echo "New initrd generated in ${OUTFILE}."
  echo "The new initrd should be at least as large as /boot/initrd.img-$(uname -r)."
}

main "$@"
