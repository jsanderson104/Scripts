#!/bin/bash
# Author: Justin Sanderson 08/03/21
# Purpose:
# View Certificate Info

CERT=$1

if [ $# -ne 1 ]; then
	echo "Enter the path to the certificate file"
	echo "Usage: $0 /path/to/cert/file"
	exit 1
fi

openssl x509 -in $CERT -text -noout |less
