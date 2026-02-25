#!/bin/bash

# Remove the welcome.conf file. pesky
rm -f /etc/httpd/conf.d/welcome.conf 2>/dev/null

# Setup env
export SSLCERTFILE=/opt/app-root/src/cert.pem
export SSLKEYFILE=/opt/app-root/src/key.pem
export SSLCERTEXPIRYDAYS=365
export SSLKEYSTRENGTH_BITS=4096
export ERRORLOG=/var/log/httpd/error_log
export CONFIGFILE=/etc/httpd/conf/httpd.conf
export SERVERNAME=test
export HTTPD_CONFIGURATION_PATH=/etc/httpd/conf.d/

# If the cert or the key is missing then gen a new key/pair to use
if [ ! -f $SSLCERTFILE ] || [ ! -f $SSLKEYFILE ]; then
	openssl req  -nodes -new -x509  -keyout $SSLKEYFILE -out $SSLCERTFILE
else
	# Update the cert line
	sed -e '/SSLCertificateFile/s/^/#/g' -i.bak.1 /etc/httpd/conf.d/ssl.conf
	echo "SSLCertificateFile $SSLCERTFILE" >> /etc/httpd/conf.d/ssl.conf

	# Update the key line
	sed -e '/SSLCertificateKeyFile/s/^/#/g' -i.bak.2 /etc/httpd/conf.d/ssl.conf
	echo "SSLCertificateKeyFile $SSLKEYFILE" >> /etc/httpd/conf.d/ssl.conf

	# Set Server Name in Apache	
	#echo "ServerName $SERVERNAME" >>$CONFIGFILE

	# Run it. 
	/usr/sbin/httpd -E /var/log/httpd/error_log -f /etc/httpd/conf/httpd.conf
fi

