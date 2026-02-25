#!/bin/bash

VM=$1
MAC=$2

if [ ! $VM ] || [! $MAC ]; then
	clear
	echo "Usage: $0 [vmname] [mac addr of nic]"
else

echo
virsh detach-interface --domain $VM --type network --mac $MAC  --config --live
echo "MAC: $MAC"
echo

fi
