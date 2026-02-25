#!/bin/bash
# date -d +180days +%Y-%m-%d

if [ "$1" == "" ]; then
	echo ""
	echo "Usage: $0 [NUM_DAYS_FROM_NOW] [USERNAME]"
	echo ""
	exit
fi
if [ "$2" == "" ]; then
	echo ""
	echo "Usage: $0 [NUM_DAYS_FROM_NOW] [USERNAME]"
	echo ""
	exit
fi

if [ `whoami` != 'root' ]; then
	echo ""
	echo "Exiting. Not root user."
	echo ""
	exit
fi

DAYS_FROM_NOW=`echo -n $1`
USER=`echo -n $2`

if [ "$DAYS_FROM_NOW" == "0" ]; then
	echo "Disabling Account $USER .."
	chage -E0 $USER
	exit
fi

A="date -d +"
B=`echo -n $DAYS_FROM_NOW`
C="days +%Y-%m-%d"
STRING=`echo "${A}${B}${C}"`
DATE_TO_EXPIRE=`$STRING`

echo "Setting expiry date of $DATE_TO_EXPIRE for $USER .."
chage -E $DATE_TO_EXPIRE $USER
