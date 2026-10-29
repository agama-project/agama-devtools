#! /bin/bash

DISK=disk-s390x-x3270.qcow2

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
  -drive if=none,file="$DISK",id=hd0 \
  -cdrom "$1" \
  -device virtio-blk-ccw,drive=hd0 \
  -chardev socket,id=ch0,host=0.0.0.0,port=2300,wait=off,server=on,tn3270=on \
  -device x-terminal3270,chardev=ch0,devno=fe.0.000a,id=terminal0
