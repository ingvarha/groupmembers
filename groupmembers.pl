#!/usr/bin/perl

use strict;

my $wbinfo;
my %groups;
my %users;
my $q="";

if ( defined $ARGV[0] ) { $q="$ARGV[0]";}

if ( $q eq '-?' || $q eq '-h' || $q eq '--help' ) {
	print "
NAME
        $0 - Fetches groups from AD by wbinfo

SYNOPSIS
        $0 [-h|--help|-?] [group]

DESCRIPTION

        wbinfo may not be allowed to recurse into AD's group
        structure, so libc's getent can't lookup groups by a standard
        nss lookup. Instead, this script gets all available uids from
        AD, probing each for their individual group membership, and
        collecting and presenting the result as groups.

        This script does NOT list local unix groups. It only lists groups
	found by wbinfo lookups against AD.

        When called without argument, it presents all found groups in
	classic unix group fashion.

	When called with one argument, it lists members of the matching group.

AUTHOR
        Ingvar Hagelund <ingvar\@redpill-linpro.com>

SEE ALSO
        wbinfo(1)
        
";
	exit 0;
}

open ( $wbinfo, "/usr/bin/wbinfo -u |" ) or die "Unable to run wbinfo, $!";
while (<$wbinfo>) {
	my $id=`/usr/bin/id $_`;
	if ( $id =~ /^uid=(\d+)\(([^\)]+)\)\s+gid=(\d+)\(([^\)]+)\)\s+groups=(.+)/ ) {
		my $uid=$1;
		my $username=$2;
		my $gid=$3;
		my $groupname=$4;
		my $othergroups=$5;
		$users{$uid}=$username;
		$groups{$gid}{"name"}=$groupname;
		$groups{$gid}{"members"}{$uid}=$uid;
		foreach my $g (split /,/,$othergroups) {
			if ( $g =~ /^(\d+)\(([^\)]+)\)/ ) {
				my $gid=$1;
				my $groupname=$2;
				$groups{$gid}{'name'}=$groupname;
				$groups{$gid}{'members'}{$uid}=$uid;
			}
			else { die "ERROR: Unable to parse output for group: $g"; }
		}
		
	}
	else { die "ERROR: Unable to parse output from id: $id"; }
}

close $wbinfo;

# output like 'getent group'
if ( "$q" eq "" ) {
	foreach my $gid (sort { $a <=> $b } keys %groups) {
		print "$gid:x:$groups{$gid}{'name'}:";
		print join ',', sort map { $users{$_} } keys %{$groups{$gid}{'members'}};
		print "\n";
	}
}

# output members of the queried group
else {
	foreach my $gid (keys %groups) {
		if ( $groups{$gid}{'name'} eq $q ) {
			print join ',', sort map { $users{$_} } keys %{$groups{$gid}{'members'}};
			print "\n";
			last;
		}
	}
}


