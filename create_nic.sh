#!/bin/bash
# KVM command to add a NIC to an existing VM

VM=$1
NETWORK=$2
MAC=`/data/scripts/macgen.sh`

if [ ! $VM ]; then
	clear
	echo "Usage: $0 [vmname] [network]" 
else

echo
virsh attach-interface --domain $VM --type network --source $NETWORK --model virtio --mac $MAC  --config --live
echo "MAC: $MAC"
echo

fi
