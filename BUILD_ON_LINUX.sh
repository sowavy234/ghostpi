#!/bin/bash
# Run this script on a Linux system (Ubuntu/Debian)
# Copy this entire ghostpi folder to Linux and run:
#   sudo ./BUILD_ON_LINUX.sh [CM4|CM5]

CM_TYPE="${1:-CM5}"
cd "$(dirname "$0")"
sudo ./scripts/build_linux.sh "$CM_TYPE"
