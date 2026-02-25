#!/bin/bash
# Author: Justin Sanderson 08/03/21
# Purpose:
# Compare an SSL certificate to a KEY to see if they match.
# SSL works on the same principle of pub/priv key. The cert is pub and key is private.

CERT=$1
KEY=$2

if [ $# -ne 2 ]; then
	echo "Enter the path to the certificate file and the key file to see if they are a valid pair."
	echo "Usage: $0 [SSL certificate file] [SSL key to verify match]"
	exit 1
fi

CERT_MODULUS=$(openssl x509 -in $CERT -noout -modulus)
KEY_MODULUS=$(openssl rsa -in $KEY -noout -modulus)


if [ "$CERT_MODULUS" != "$KEY_MODULUS" ]; then
	echo "Not a Match!"
	exit 2
else
	echo "We have a match!"
	exit 0
fi
