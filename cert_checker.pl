#!/usr/bin/perl
use strict;
use warnings;
use Date::Parse;

my $fqdn = $ARGV[0]; if (!$fqdn) { print "You must supply the FQDN of the site."; exit;}

#Download the CRT from the site w/o all of the openssl details. We want just the cert itself.
my $cert_to_check = `openssl s_client -connect $fqdn:443 -showcerts </dev/null 2>/dev/null |openssl x509 -outform PEM 2>/dev/null >/tmp/$fqdn.crt`;

#Process the cert downloaded and get the expiration date from it in string format.
my $expiry_date_string = `openssl x509 -noout -dates -in /tmp/$fqdn.crt |tail -1 |awk -F'=' '{print \$2}'`;

#Convert the date string to a digit in seconds.
my $expiry_date_integer = str2time($expiry_date_string);

# Figure out how many days are left on the cert by subtracting the current date/time from the certs expiry date number. Divide it by 86400 (how many secs in a day).
# the int() function is just removing the decimal places.
my $daysleft = int(($expiry_date_integer - time())/86400);

if ($daysleft <= 30) { print "Cert on $fqdn will expire in $daysleft days. \n"; }
	


