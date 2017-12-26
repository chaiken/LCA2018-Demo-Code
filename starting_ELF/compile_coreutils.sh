#!/bin/bash
#
set -u
set -e

if [[ ! -n $(which gcc) || ! -n $(which gdb) ]]; then
  echo "Install gcc and gdb to proceed."
  exit 1
else
  echo "Found GCC and GDB, proceeding."
fi
# This demo would also likely work on derivatives like Mint or Ubuntu.
if [[ ! -f /etc/debian_version ]]; then
  echo "Sorry, this is a Debian demo."
else
  echo "Confirmed Debian, proceeding."
fi
readonly GDBFILE="$(readlink -f gdb-coreutils.txt)"
if [[ ! -n "$GDBFILE" ]]; then
  echo "GDB commands file is missing."
  exit 1
else
  echo "Found GDB commands file."
fi

readonly TESTDIR=./coreutils
mkdir "$TESTDIR"

# Install glibc sources.
cd "$TESTDIR"
echo "Getting glibc source."
apt-get -q source glibc
# du -hcs glibc-2.24/
# 225M    glibc-2.24/
readonly GLIBCDIR="$(find . -name "glibc*" -type d)"

# Compile coreutils.
echo "Getting coreutils source."
apt-get -q source coreutils
TARBALL="$(ls coreutils*orig.tar.xz)"
tar xfJ "$TARBALL"
readonly COREUTILSDIR="$(find . -name "coreutils-*" -type d)"

# Build coreutils.
cd "$COREUTILSDIR"
echo "Configuring coreutils"
# Semicolon matters; 'configure' seems to eat the next line otherwise.
./configure -q; echo "Compiling coreutils"
make -s

# Run coreutils under GDB.
ln -s "$(readlink -f ../"$GLIBCDIR"/sysdeps)" ../sysdeps
ln -s "$(readlink -f ../"$GLIBCDIR"/csu)" ../csu
gdb --command="$GDBFILE" src/date
