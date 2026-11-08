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
    --mode debian \
    --distribution bookworm \
    --architectures "${ARCH}" \
    --binary-images iso-hybrid \
    --debian-installer false \
    --security false \
    --archive-areas "main contrib non-free non-free-firmware" \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/"

# Ensure isolinux files exist where live-build expects them
sudo mkdir -p /root/isolinux
for path in /usr/lib/ISOLINUX /usr/share/syslinux /usr/lib/syslinux/modules/bios; do
    if [ -f "$path/isolinux.bin" ]; then
        sudo cp "$path/isolinux.bin" /root/isolinux/
    fi
    if [ -f "$path/vesamenu.c32" ]; then
        sudo cp "$path/vesamenu.c32" /root/isolinux/
    fi
done
sudo cp /usr/lib/syslinux/modules/bios/*.c32 /root/isolinux/ 2>/dev/null || true

sudo lb build

if [ -f "binary.iso" ]; then
    mv binary.iso "../output/nullsec-${VERSION}-${EDITION}-${ARCH}.iso"
    echo "[+] Success! ISO generated."
else
    echo "[-] Error: binary.iso was not generated."
    exit 1
fi
