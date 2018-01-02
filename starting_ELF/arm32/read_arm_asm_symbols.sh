#!/bin/bash
# Alison Chaiken
# alison@she-devel.com

# Create symlinks to glibc sources.
readonly TLD=/usr/src/glibc/glibc-2.25
if [[ ! -d "$TLD"/csu || ! -d "$TLD"/sysdeps ]]; then
  echo "Wrong path to glibc sources?"
  exit 1
else
  ln -s "$TLD"/csu ../csu
  ln -s "$TLD"/sysdeps ../sysdeps
fi

# Check for Makefile.
if [[ ! -f Makefile.arm ]]; then
  echo "Cannot proceed with Makefile"
  exit 1
else
  cp Makefile.arm Makefile
fi

# Here's a C file for convenience.
readonly SRC=endian.c
make endian

arm-linux-gnueabihf-gdb endian
# Now type
#
# (gdb) info files
#
# Find "Entry point" hex VALUE.
# Type
#
# (gdb) l *(VALUE)
#
# You should find yourself at _start in
# ./sysdeps/arm/start.S.
