#! /usr/bin/bash

DISK=disk-aarch64.qcow2

if [ -z "$1" ]; then
  echo "ERROR: Missing ISO file argument"
  exit 1
fi

# create the disk with if it does not exist yet
if [ ! -f "$DISK" ]; then
  qemu-img create -f qcow2 "$DISK" 30G
fi

qemu-system-aarch64 \
  -M virt \
  -cpu max \
  -m 4096 \
  -smp 4 \
  -bios /usr/share/qemu/qemu-uefi-aarch64.bin \
  -device virtio-gpu-pci \
  -display default,show-cursor=on \
  -device qemu-xhci -device usb-kbd -device usb-tablet \
  -netdev user,id=net0,hostfwd=tcp::44443-:443 \
  -device virtio-net-pci,netdev=net0 \
  -drive if=none,file="$DISK",id=hd0 \
  -device virtio-blk-device,drive=hd0 \
  -cdrom "$1"
