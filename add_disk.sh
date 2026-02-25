#!/bin/bash
# Linux KVM make a disk and initialze it for use in a VM. 

VM=$1
SIZE=$2
DEVICE=$3


dd if=/dev/zero of=/data/images/$VM-$DEVICE.img bs=1024M count=$SIZE

virsh attach-disk $VM \
--source /data/images/$VM-$DEVICE.img \
--target $DEVICE \
--persistent
