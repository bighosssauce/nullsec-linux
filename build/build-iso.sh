#!/bin/bash
set -euo pipefail

EDITION="${1:-standard}"
ARCH="${2:-amd64}"
VERSION="5.0.0"

echo "[*] Building NullSec Linux v${VERSION}..."
mkdir -p build-workspace output
cd build-workspace

if [ -d "config" ]; then
    sudo lb clean --purge
fi

lb config \
    --distribution bookworm \
    --architectures "${ARCH}" \
    --binary-images iso-hybrid \
    --debian-installer false \
    --archive-areas "main contrib non-free non-free-firmware"

sudo lb build

if [ -f "binary.iso" ]; then
    mv binary.iso "../output/nullsec-${VERSION}-${EDITION}-${ARCH}.iso"
    echo "[+] Success! ISO generated."
else
    echo "[-] Error: binary.iso was not generated."
    exit 1
fi
