groupmembers.pl - Fetches groups from AD by wbinfo

wbinfo may not be allowed to recurse into Active Directory's group
structure. This means libc's getent can't lookup groups by a standard
nss lookup. Instead, this script gets all available uids from AD,
probing each for their individual group membership, and collecting and
presenting the result as groups.

This script does NOT list local unix groups. It only lists groups
found by wbinfo lookups against AD.

When called without argument, it presents all found groups in classic
unix group fashion.

When called with one argument, it lists members of the matching group.
