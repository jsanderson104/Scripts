#!/bin/bash
# Linux KVM command to start a vm and install Linux over http kickstart

VM=$1
virt-install --name $VM --vcpu=1 --memory=2048 --disk /data/images/$VM.img,size=10 --location=http://192.168.1.9/iso -x"ks=http://192.168.1.9/ks/minimal.ks" --network network="lab"

