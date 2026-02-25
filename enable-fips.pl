#!/usr/bin/perl -w

use strict;

sub disable_prelinking {
	my $sedcmd = "sed -i.bak 's/PRELINKING=yes/PRELINKING=no/' /etc/sysconfig/prelink && echo \$?";
	my $result = readpipe($sedcmd);
}

sub fips_grub_default {
my $file = "/etc/default/grub";
open(ORIGDEFAULTGRUB,"<", $file) ||die "Error: $! \n";
while(<ORIGDEFAULTGRUB>) {
	if ($_ =~ m/GRUB_CMDLINE_LINUX/) {
	my @grubargs_a = split('"', $_ );
	my $kernelargs = $grubargs_a[1];
	
	if ($kernelargs =~ m/fips=1/ ) { print "FIPS Already enabled at GRUB DEFAULT FILE\n"; }
	else { print "FIPS NOT ENABLED at GRUB DEFAULT FILE\n";
		close(ORIGDEFAULTGRUB);
		open(NEWDEFAULTGRUB,">>",$file) || die "Unable to open $file for writing.\n";	
		my $newkernelargs = $kernelargs . " fips =1";
		while(<NEWDEFAULTGRUB>) {
			if ($_ =~ m/$kernelargs/) { $_ =~ s/$kernelargs/$newkernelargs/; }
		}}
	close(NEWDEFAULTGRUB);
	}
}
}


sub fstab_boot_uuid {
my $BOOTUUID = "";
open(FSTAB,"<","/etc/fstab") || die "Error: $! \n";
while(<FSTAB>) {
	my $line = $_; chomp($line);
	if (($line =~ m/\/boot/) && ($line =~ m/UUID/i)) { 
		my @line_a = split(" ",$line);
		$BOOTUUID = $line_a[0];
		print "$BOOTUUID\n";
	}
	else { next; }
}
close(FSTAB);


return $BOOTUUID;
}


sub fstab_boot_dev {
my $BOOTDEV = "";
open(FSTAB,"<","/etc/fstab") || die "Error: $! \n";
while(<FSTAB>) {
	my $line = $_; chomp($line);
	if (($line =~ m/\/boot/) && ($line =~ m/\/dev\//i)) { 
		my @line_a = split(" ",$line);
		$BOOTDEV = $line_a[0];
	}
	else { next; }
}
close(FSTAB);

return $BOOTDEV;
}

sub blkid_boot {
	my $BOOTDEV = $_[0]; chomp($BOOTDEV);
	my $cmd = "/sbin/blkid |grep $BOOTDEV |awk '{print \$2}' ";
	my $UUID = readpipe($cmd) || die "Failed to read pipe from shell and determine UUID of /boot.\n";

return $UUID;
} # END BLKID_BOOT

sub main{

my $BOOTUUID = fstab_boot_uuid();
my $BOOTDEV = fstab_boot_dev();
if (($BOOTUUID eq "")&&($BOOTDEV eq "")) { print "Error: Unable to determine /boot partition\nMust exit for safety.\n"; exit;}
if ($BOOTDEV ne "") {
			print "UUID of boot partition was not found in /etc/fstab.\n\nAttempting to determine from /sbin/blkid output using $BOOTDEV.\n";
			$BOOTUUID = blkid_boot($BOOTDEV); chomp($BOOTUUID);
			print "Found $BOOTUUID of /boot by referencing $BOOTDEV ...\n";
}


&disable_prelinking();
&fips_grub_default();

} #END MAIN

&main();
