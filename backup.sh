#!/bin/bash
# Author: Justin Sanderson 09/03/21
# Purpose: System Backup script using tar with index and incremental
#
# Usage: Put whatever filepaths you want in BACKUP_a list and it will back it up.
#        The BACKUP_DEST should be a remote NFS storage target of some kind.
#
# How it works:
# Once we get all of the variables for structuring the backup data (month,year,etc) we depend on the INDEX files.
# The 'tar' command when using option 'listed-incremental' will look for the index file provided and if it doesn't exist it will do a "full" tar.
# If the index file does exist it uses that as a "baseline" and only grabs the files that have modified in some way (ie an incremental backup)
# If you run this backup script more than once in a day, it will create a new incremental backup in the SameDay's folder BUT any subsequent executions of this script
# will simply overwrite the previous incremental based on the Full baseline index files for the week.

# CALENDAR STUFF
MONTH=$(date +%B) || logger "Failed running date command for backup script..."
WEEKNUM=$(date +%U) || logger "Failed running date command. for backup script.."
YEAR=$(date +%Y) || logger "Failed running date command for backup script..."
DAYOFWEEK=$(date +"%A") || logger "Failed running date command for backup script..."

#What to backup
BACKUP_a=( /etc /boot /home /opt /var/log /var/log/audit )
if [ -f /sys/class/firmware/efi ]; then BACKUP_a+=( /boot/efi ) ; fi

# Where to put it. CHANGE THIS TO WHAT YOU WANT
BACKUP_DEST=/mnt/backup/$HOSTNAME/$YEAR/$MONTH/week_$WEEKNUM

# DO NOT MODIFY
SESSIONLOG=$BACKUP_DEST/session.$DAYOFWEEK.log

# Make PATH to put our backup files or drop an entry in syslog and exit with errcode
mkdir -p $BACKUP_DEST/$DAYOFWEEK
if [ "$?" != "0" ]; then
	echo "Unable to create backup destination path $BACKUP_DEST...exiting."  >> $SESSIONLOG
	# Send error msg to syslog
	logger "!!!BACKUP SCRIPT FAILED!!!! Can't create dest path... $BACKUP_DEST/$DAYOFWEEK"
	exit 1
fi

 # Check to see if we want to reset the backup catalog for the week and start fresh with a new FULL backup.
if [ ! -z $1 ]; then
       	if [ "$1" == "forcefull" ]; then
		echo "WARNING: Forcing a full backup will delete the index and incrementals for $WEEKNUM."
		read -p 'Continue (yn): ' continue
		if [ "$continue" == "y" ] || [ "$continue" == "Y" ]; then
			rm -fv $BACKUP_DEST/*.index
			if [ "$?" != "0" ]; then echo "Failed to remove index files... Check path permissions. Exiting for safety." && exit 2 ; fi
		echo "Index removed.. Starting backup job"
		fi
	else
		echo "This script only takes one option. It's best to run $0 without any options."
		echo "Usage: $0 forcefull  --> Use caution!"
	fi
fi


# ALL THE WORK IS DONE BELOW
for mount in ${BACKUP_a[@]} ; do
	# Convert slashes to underscores in vars and situate then correct the INDEXFILE var
	ARCHIVE=$(echo $mount |sed 's/\//_/g')
	INDEXFILE=$(echo $mount |sed 's/\//_/g')
	INDEXFILE=$BACKUP_DEST/$INDEXFILE.index

		# Generic echos from loop. Cleaned up the if-else block
		echo "=============== Begin FileSystem ====================" >> $SESSIONLOG
		echo -n "Start Time: " >> $SESSIONLOG ; date +%Y-%m-%d_%H-%M >> $SESSIONLOG
		echo "Week Number: $WEEKNUM" >> $SESSIONLOG
		echo "DAY: $DAYOFWEEK" >> $SESSIONLOG
		echo "DEST: $BACKUP_DEST" >> $SESSIONLOG

	if [ -f $INDEXFILE ]; then
		# If the index file is found, assume this is NOT the first backup of the week; therefore, it must be an incremental.
		ARCHIVE=$ARCHIVE.incr.tgz
		echo "Found Index: $INDEXFILE" >> $SESSIONLOG
		echo "Type: Incr" >> $SESSIONLOG
		echo "Archive: $ARCHIVE" >> $SESSIONLOG
		cd $mount && tar -cvzf $BACKUP_DEST/$DAYOFWEEK/$ARCHIVE --listed-incremental=$INDEXFILE --one-file-system . >> $SESSIONLOG 2>&1
		echo -n  "End Time: " >> $SESSIONLOG ; date +%Y-%m-%d_%H-%M >> $SESSIONLOG
		echo "=============== End FileSystem ====================" >> $SESSIONLOG
	else
		# If the index file is NOT found, assume this is the first backup of the week. the tar command will run a FULL backup if it doesnt find the refenced index file.
		ARCHIVE=$ARCHIVE.full.tgz
		echo "Created Index: $INDEXFILE" >> $SESSIONLOG
		echo "Type: Full" >> $SESSIONLOG
		echo "Archive: $ARCHIVE" >> $SESSIONLOG
		cd $mount && tar  -cvzf $BACKUP_DEST/$DAYOFWEEK/$ARCHIVE --listed-incremental=$INDEXFILE --one-file-system . >> $SESSIONLOG 2>&1
		echo -n "End Time: " >> $SESSIONLOG ; date +%Y-%m-%d_%H-%M >> $SESSIONLOG
		echo "=============== End FileSystem ====================" >> $SESSIONLOG
	fi
done
