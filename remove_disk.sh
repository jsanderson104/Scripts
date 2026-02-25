#!/bin/bash


VM=$1
DEVICE=$2

virsh detach-disk --domain $VM --live --target $DEVICE

echo "Deleting /data/images/$VM-$DEVICE.img"
rm -f /data/images/$VM-$DEVICE.img
