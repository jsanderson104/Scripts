#!/bin/bash
# Caveman style backup of system. Was used during my NFSroot boot project. 
# This script backs-up all the necessary files to duplicate an OS. You can then use this as a tarball to either restore your OS to another VM/physical -or- you can use it manually build a container-os-image


TARDEST=$1
IMAGENAME=$2
REMOTESYSTEM=$3

# IF SYSTEM IS REMOTE
# rsync --exclude=/proc/* --exclude=/sys/* --exclude=/home/* --exclude=/media/* --exclude=/tmp/* --exclude=/dev/* --exclude=/run/* --exclude=/opt/* --delete -avz root@n:/ .

# IF SYSTEM IS LOCAL (ie im running the script on it locally as root.
# tar  --exclude=./proc --exclude=./sys --exclude=./dev --exclude=./run -C / -cvfz $TARDEST/$IMAGENAME.tgz


#tar  --exclude=./proc \
#	--exclude=./sys \
#	--exclude=./dev \ 
#	--exclude=./run \
#	--exclude=./home \
#		-C / # Change to path before execute 
#		-cvfz $TARDEST/$IMAGENAME.tgz # Save as 
#

cd $TARDEST && rsync --exclude=/proc/* --exclude=/sys/*  --exclude=/home/* --exclude=/media/* --exclude=/tmp/*  --exclude=/dev/*  --exclude=/run/*  --exclude=/opt/* --exclude=/var/lib/containers  \
		-avz root@$REMOTESYSTEM:/ . && tar cvfz /data/$IMAGENAME.tgz -C $TARDEST


# Start and interact with container shell on startup.
# podman run -it --name test-container1 new-image1 /bin/bash

# After container has been created and you simply want to start it again and attach to it...
# podman start -ai [container_name or ID]


# Detach from a running image AND leave it running use the key sequence "CTRL-P CTRL-Q" then do a podman ps to verify it's still running.



# IMPORT the tarball as an image base using podman
#podman import --change ENTRYPOINT=/bin/bash testimg.tgz new-image1

