#! /bin/sh

# the disk for multipath access need to be in RAW format
DISK=disk-multipath1.raw

if [ -z "$1" ]; then
  echo "ERROR: Missing ISO file argument"
  exit 1
fi

# create the disk with if it does not exist yet
if [ ! -f "$DISK" ];
then
  qemu-img create -f raw "$DISK" 30G
fi

# start the VM using KVM acceleration
qemu-system-x86_64 -enable-kvm -m 4G \
	-smp 4 \
	-cpu host \
  -blockdev "driver=file,filename=$DISK,node-name=mp-file0,cache.direct=on" \
  -blockdev driver=raw,file=mp-file0,node-name=mp0 \
  -device virtio-scsi-pci,id=scsi0 \
  -device virtio-scsi-pci,id=scsi1 \
  -device scsi-hd,drive=mp0,bus=scsi0.0,id=path0,share-rw=on,serial=MPATH0001,wwn=0x5000c50015ea71ac \
  -device scsi-hd,drive=mp0,bus=scsi1.0,id=path1,share-rw=on,serial=MPATH0001,wwn=0x5000c50015ea71ac \
	-cdrom "$1"
