#!/bin/bash
#
#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.
#
# Apocalypse SITE UNDIRDUPE script v1.0
#
# To use this script, add to glftpd.conf:
# site_cmd UNDIRDUPE     EXEC    /bin/apocundirdupe.sh
# custom-undirdupe       *
# Replace * with the desired glftpd option(s) (read glftpd.docs)
#
# Make sure your log directory + dupelog is world-writable
#
# Required bin's: "echo, grep, chmod, rm, mv" in glftpd's bin dir

# Where is the dupelog?
# You probably don't need to change this...
DUPELOG=/ftp-data/logs

# What is the name of your dupelog?
# You probably don't need to change this...
DUPELOGFILE=dupelog

# DO not edit below unless you know what you're doing

# Checks for missing binaries
BINS="grep echo chmod rm mv"
for i in $BINS; do
	if [ ! -x "/bin/$i" ]; then
		echo -e 'Error:' $i 'Missing from /bin or cannot execute it!'
		exit 2
	fi
done

# Checks to see if we can write to dupelog
if [ ! -w "$DUPELOG/$DUPELOGFILE" ]; then
	echo -e 'Unable to write to Dupelog!'
	exit 2
fi

# Checks to see if we can write to dupelog dir
if [ ! -w "$DUPELOG" ]; then
	echo -e 'Unable to write to Dupelog dir!'
	exit 2
fi

# Check the undirdupe request to see if it is valid
DIRDUPEREQ=`echo "$1" | grep -vE "(\;|\#|\/|\^|\&|\(|\)|\{|\}|\[|\]|\,)"`

appenddate=`date +%s`

if [ "$DIRDUPEREQ" ]; then
	grep -v "$1" $DUPELOG/$DUPELOGFILE > $DUPELOG/dirlog.$appenddate.tmp
	rm $DUPELOG/$DUPELOGFILE
	mv $DUPELOG/dirlog.$appenddate.tmp $DUPELOG/$DUPELOGFILE
	chmod 777 $DUPELOG/$DUPELOGFILE
	echo -e 'Request done, '$1' undirduped now!'
	exit 0
else
	echo -e 'Error! Your request contains illegal characters!'
	exit 2
fi