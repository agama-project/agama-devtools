#! /bin/bash

DISK=disk-s390x.qcow2

if [ -z "$1" ]; then
  echo "ERROR: Missing ISO file argument"
  exit 1
fi

# create the disk with if it does not exist yet
if [ ! -f "$DISK" ]; then
  qemu-img create -f qcow2 "$DISK" 30G
fi

# https://www.qemu.org/docs/master/system/s390x/3270.html
qemu-system-s390x \
  -M s390-ccw-virtio \
  -cpu max \
  -m 4096 \
  -smp 4 \
  -nographic \
  -netdev user,id=net0,hostfwd=tcp::44443-:443 \
  -device virtio-net-ccw,netdev=net0 \
  -cdrom "$1" \
  -drive if=none,file="$DISK",id=hd0 \
  -device virtio-blk-ccw,drive=hd0
