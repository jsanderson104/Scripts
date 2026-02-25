#!/usr/bin/perl -w

use strict;
use Net::LDAP;
use Term::ReadKey;
if ( $#ARGV != 1 ) { 
        print "\nUsage: ";
        print "./script [server_ip] [login_username] \n\n";
        print "NOTE: If [login_username] is NOT in the LDAP 'Users' OU the Login will fail.\n";
        print "DOS-PROMPT CMD=  'dsquery user -name [login_username]' \n\n";
}else {

my $server = "ldap://" . $ARGV[0];
my $bind_dn = "CN=" . $ARGV[1] . ",CN=Users,DC=ADATUM,DC=com";
my $user = "nobody";


my $basedn = "dc=ADATUM,dc=com";
 
print "=======================================================\n";
print "   Provide password for $ARGV[1]\@$server logon.\n"; 
print "=======================================================\n:";
ReadMode 'noecho';
my $password = <STDIN>; chomp($password);
ReadMode 'original';

my $ldap = Net::LDAP->new($server, verify=> 'require') || die $@;
$ldap->bind($bind_dn , password => $password) || die $@;

my $result = $ldap->search( base => $basedn,
			 filter => "(sAMAccountName=$user)");

die $result->error if $result->code;

foreach my $entry ($result->entries) {
    $entry->dump;
}

print "===============================================\n";
 
$ldap->unbind;

}
