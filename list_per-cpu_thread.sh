#!/bin/bash
# List all the kernel's per-CPU threads, sorted by the processor on which
# they are running.

ps -u root -o comm,psr --sort psr | egrep '/[0-3]'
