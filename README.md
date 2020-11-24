groupmembers.pl - Fetches groups from AD by wbinfo

wbinfo is not allowed to recurse into AD's group structure, so getent
can't lookup groups by a standard nss lookup. Instead, this script
gets all available uids from AD, probe for their individual group
membership, and collecting and presenting the result as groups.

This script does NOT list local unix groups. It only lists groups
found by wbinfo lookups against AD.

When called without argument, it presents all found groups in classic
unix group fashion.

When called with one argument, it lists members of the matching group.
