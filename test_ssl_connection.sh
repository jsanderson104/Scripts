#!/bin/bash
# Author: Justin Sanderson 08/03/21
# Purpose:
# View Certificate Info

URL=$1

if [ $# -ne 1 ]; then
	echo "Enter the URL to test connection and view certificate information."
	echo "Usage: $0 www.something.com  -or- serverFQDN" 
	exit 1
fi

echo "EOF" |openssl s_client $URL:443

if [ "$?" = "0" ]; then echo "Success!" else echo "Connection Failed.. try nc -zv $URL 443 instead" ; fi
