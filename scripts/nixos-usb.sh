#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "err: script for macOS only."
  exit 1
fi

NIXOS_VERSION="25.11"
ISO_URL="https://channels.nixos.org/nixos-${NIXOS_VERSION}/latest-nixos-minimal-x86_64-linux.iso"
ISO_FILE="/tmp/nixos-minimal.iso"

if [[ -f "$ISO_FILE" ]]; then
  echo ".iso already downloaded at $ISO_FILE, continuing..."
else
  echo "downloading NixOS ISO..."
  curl -L -o "$ISO_FILE" "$ISO_URL"
  echo "downloaded."
fi

echo
echo "detected USBs:"
echo

diskutil list external physical

echo
read -rp "select disk number of usb to write to (ex. /dev/diskN): " target_device

if [[ -z "$target_device" || ! -e "$target_device" ]]; then
  echo "invalid/missing device. aborting."
  exit 1
fi

echo
echo "warning: ready to erase all data on $target_device?"
echo "if so, type: yeah erase $target_device"
read -rp "> " confirmation

if [[ "$confirmation" != "yeah erase $target_device" ]]; then
  echo "sorry, didn't match. aborting."
  exit 1
fi

echo "unmounting $target_device..."
diskutil unmountDisk "$target_device"
raw_device="${target_device/disk/rdisk}"
echo "writing ISO to $raw_device..."
sudo dd if="$ISO_FILE" of="$raw_device" bs=4m status=progress
sync
diskutil eject "$target_device"

echo
echo "done."
