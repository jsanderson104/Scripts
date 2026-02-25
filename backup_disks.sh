#!/bin/bash

DATE=$(date +%m%d%y)
BASEPATH=/backup
HOSTNAME=$(hostname)
ID=$(whoami)
if [ $ID != 'root' ]; then
	echo "Run me as Root user.. Exiting"
	exit 1
fi

function backup_scsi_fdisk {
for scsi_disk in $(ls -1rt /dev/sd* | grep -vE '^(.*)sd[a-z][1-9]$');
do  
SCRUB=$(echo $scsi_disk |sed 's/\//_/g')
echo "Getting partition layout for $scsi_disk !"
fdisk -l $scsi_disk > $BASEPATH$HOSTNAME.fdisk.$SCRUB.$DATE 2>&1 && echo "Partition Layout for $scsi_disk was written to $BASEPATH$HOSTNAME.fdisk.$SCRUB.$DATE" || \
echo "Error: Failed to run FDISK on $scsi_disk  "

done

}


function vgcfgbkp {
	for VG in $(vgdisplay |grep "VG Name" | awk '{print $3}');
	do
	SCRUB=$(echo $VG |sed 's/\//_/g')
		vgcfgbackup -f $BASEPATH/$HOSTNAME.vgcfg.$SCRUB.$DATE  2>&1 && echo "Volume Group information for $VG has been written to $BASEPATH/$HOSTNAME.vgcfg.$SCRUB.$DATE" || \
		echo "Error: Failed to backup Volume Group $VG "
done

}

function lvdisplaybkp {
	for LV in $(ls -1rt /dev/mapper/ | grep -v control);
	do
	echo $LV
	SCRUB=$(echo $LV |sed 's/\//_/g')
	lvdisplay -vvv /dev/mapper/$LV  > $BASEPATH$HOSTNAME.lvcfg.$SCRUB.$DATE 2>&1 || \
		echo "Error: Failed to backup Logical Volume $LV info ! "
done

}


function lsblkbkp {
	lsblk > $BASEPATH/$HOSTNAME.lsblk.$DATE 2>&1 && echo "Backed up LSBLK info to $BASEPATH/$HOSTNAME.lsblk.$DATE" || \
	echo "Error: Failed to backup LSBLK information ! "
}	

function xfs_dump {
	for mount in `mount |grep ' xfs ' |awk '{print $3}'`; 
	do
	SCRUB=$(echo $mount |sed 's/\//_/g')
	xfsdump -o -J -f $BASEPATH/$SCRUB.xfsdump.$DATE -l 0 -L $SCRUB -M $SCRUB $mount
	done
}

function backup_parttable {
	for disk in $(ls -1rt /dev/sd* | grep -vE '^(.*)sd[a-z][1-9]$');
	do
	SCRUB=$(echo $disk |sed 's/\//_/g')
	dd if=$disk of=$BASEPATH/$SCRUB.mbr bs=512 count=1
	done
}


function main {
	backup_scsi_fdisk
	vgcfgbkp
	lvdisplaybkp
	lsblkbkp
	xfs_dump
	backup_parttable
}

main

