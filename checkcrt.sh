#!/usr/bin/erl
use strict;
use warnings;
use Date::Parse;

# MODIFY THE BELOW FOR YOUR SITE.

#*****************************************
# Certificates to be checked
my @certs = < /tmp/x509up_u502 /etc/grid-security/hostcert.pem /etc/grid-security/certificates/*.[0-9] >;
# Uncomment below statement if no certificates are to be checked
#my @certs;

# CRLs to be checked
my @crls = < /etc/grid-security/certificates/*.r[0-9] >;
# Uncomment below statement if NO CRLs are to be checked
#my @crls;

# Where should warning emails go?
my $adminEmail = "root\@localhost";

# Minimum validity period to check for
my $minCertdays = 100;
my $minCrldays = 5;
#*****************************************


# Certificates
foreach my $file (@certs) {
   print "PROCESSING CERTIFICATE FILE: $file\n";
   my $enddate = `openssl x509 -enddate -in $file -noout`;$enddate =~ s/notAfter=//g;
   my $end = str2time($enddate);
   my $daysleft = ($end - time())/86400;
   my $issuer = `openssl x509 -issuer -in $file -noout`;$issuer =~ s/issuer=//g;
   if($daysleft < $minCertdays) {
     my $msg = "$file expires/expired in ".int($daysleft)." days\n" .
               "on $enddate\n" .
               "Please contact the CA $issuer for renewing the certificate.\n" .
               "\n" .
               "NOTE: You can check the contents of this certificate by running\n" .
               "'openssl x509 -text -noout -in $file'\n\n" .

               "If applicable, MyProxy renewal may be used. Please refer to\n" .
               "http://grid.ncsa.illinois.edu/myproxy/renew.html\n" .
               "for more information.\n";

     system("echo \"$msg\" | mail -s \"Certificate Expiration Warning\" $adminEmail");
   }


#DATESTRING=`openssl s_client -connect sgn-srv1.adtran.com:443 -showcerts </dev/null 2>/dev/null|openssl x509 -outform PEM 2>/dev/null |openssl x509 -noout -dates|tail -1 |awk -F'=' '{print $2}'`
#echo $DATESTRING



