#!/bin/bash
#
# DISCLAIMER - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.
#
# Apocalypse Directory Locate Cache script v1.0
#
# Make sure you are running the apocmidnight.sh script and
# enable the "Locate Cache Maker" part of the script.
#
# Required bin's: "echo, awk, cat, grep, chmod, rm, touch, ls" in /bin dir

# Where is your 0day directory?
SITEDIR="/glftpd/site/AppRiPs"

# Where should the cache be?
CACHE="/glftpd/ftp-data/0day.dir.cache"

# Zipscript complete format - to select the complete releases
ZSCOMPLETE="COMPLETE"

# Zipscript incomplete format - to weed out the incompletes
ZSINC="iNCoMPLETe"

# Nuke variable - to weed out the Nuked releases
NUKEVAR="NUKED"

# Your Log directory
LOGDIR="/glftpd/ftp-data/logs/apoc"

# Name of your Log
GENLOG="cache.updater.log"

# DO not edit below unless you know what you're doing

time_stamp ()
{
    echo -n `echo '( ' && date +%T && echo ' | ' && date +%D && echo ' | DirCache )'`
}

# Check the temp dir for logs
if [ ! -d "$LOGDIR" ]; then
	echo 'Log Directory is nonexistent!'
	exit 0
else
	if [ ! -x "$LOGDIR/$CACHELOG" ]; then
		if [ ! -e "$LOGDIR/$CACHELOG" ]; then
			touch $LOGDIR/$CACHELOG
			chmod 666 $LOGDIR/$CACHELOG
			time_stamp && echo ' Information: Creating Error Log!' >> $LOGDIR/$GENLOG
			if [ ! -e "$LOGDIR/$CACHELOG" ]; then
				echo 'Unable to create error log!'
				exit 0
			fi
		fi
	fi
fi

# Checks for missing binaries
BINS="grep echo awk cat chmod rm touch ls"
for i in $BINS; do
	if [ ! -x "/bin/$i" ]; then
		if [ ! -x "/usr/bin/$i ]; then
			time_stamp && echo ' Error:' $i 'Missing from /bin or cannot execute it!' >> $LOGDIR/$GENLOG
			exit 0
		fi
	fi
done

# Begin the main routine
ls -lR "$SITEDIR" > /tmp/locate.temp
grep -i "$ZSCOMPLETE" /tmp/locate.temp > /tmp/temp1.tmp
grep -v "4096" /tmp/temp1.tmp > /tmp/temp2.tmp
grep -v "$ZSINC" /tmp/temp2.tmp > /tmp/temp3.tmp
grep -v "$NUKEVAR" /tmp/temp3.tmp > /tmp/finishdir.tmp
awk ' BEGIN { FS = "/" }
{ if ( $5 ~ /SORTED/ ) { print $5 "/" $6 "/" $7 > "/tmp/finishdir1.tmp" } else { print $5 "/" $6 > "/tmp/finishdir1.tmp" } }' /tmp/finishdir.tmp

# Move the dirlist to the destination
mv /tmp/finishdir1.tmp $CACHE
chmod 666 $CACHE

# Clean up temp files
TEMPFILES="locate.temp temp1.tmp temp2.tmp temp3.tmp temp4.tmp finishdir.tmp"
for i in $TEMPFILES; do
	if [ -e "/tmp/$i" ]; then
		rm /tmp/$i
	fi
done