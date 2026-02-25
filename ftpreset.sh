#!/bin/bash

clear
ACCOUNT=$1
EMAIL=$2
MAILFILE=`/bin/mktemp`
PWFILE=`/bin/mktemp`
LOGFILE=/var/log/ftpaccounts.log
RECIPIENTS="ftpadmins@mydomain.com $EMAIL"
date +%s | sha256sum | base64 | head -c 8 > $PWFILE

if [ "$#" -ne 2 ]; then
        echo "Illegal number of parameters. Requires two args."
        echo " Usage: "
        echo "./ftpreset.sh [ACCOUNTNAME] [E-Mail Address]"
        echo ""
else

