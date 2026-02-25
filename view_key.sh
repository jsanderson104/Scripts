#!/bin/bash
# Author: Justin Sanderson 08/03/21
# Purpose:
# View SSL Key Info

KEY=$1

if [ $# -ne 1 ]; then
	echo "Enter the path to the certificate file"
	echo "Usage: $0 /path/to/key/file"
	exit 1
fi

openssl rsa -in $KEY -text -noout |less
