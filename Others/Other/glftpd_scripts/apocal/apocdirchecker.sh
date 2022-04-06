#!/bin/bash
#
#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.
#
# Apocalypse Dupechecker for Directories v1.0
# dn helped out with this one
#
# To use this script, add to glftpd.conf:
# pre_dir_check  /bin/apocdirchecker.sh
#
# Required bin's: "echo, grep" in glftpd's bin dir

# Where is the dupelog?
# Relative to glftpd directory
# You probably don't need to change this...
DUPELOG="/ftp-data/logs/dupelog"

# DO not edit below unless you know what you're doing

# Checks for missing binaries
BINS="grep echo"
for i in $BINS; do
	if [ ! -x "/bin/$i" ]; then
		echo 'Error:' $i 'Missing from /bin or cannot execute it!'
		exit 2
	fi
done

# Good Directory routine
dir_fine ()
{
echo '#0This is not a dupe, proceeding...'
exit 0
}

# Scan the dupelog and return dupe or not
if [ `echo "$1" | grep -iE "^(cd|dis[ck])[-_]?([0-9]{1,2}|one|two|three|four|five|six|seven|eight|nine|ten)|sample|stats|vobsub|oggdec|test"` ]; then
	dir_fine
else
	if [ -r "$DUPELOG" ]; then
		if grep -qi "$1" "$DUPELOG" ; then
    			echo 'Dupe detected! Directory denied.'
			exit 2
		else
    			dir_fine
		fi
	else
		echo 'ERROR! Dupelog not found!'
		exit 2
	fi
fi