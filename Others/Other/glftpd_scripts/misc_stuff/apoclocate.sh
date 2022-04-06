#!/bin/bash
#
#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.
#
# Apocalypse SITE LOCATE0DAY script v1.0
#
# To use this script, add to glftpd.conf:
# site_cmd LOCATE0DAY     EXEC    /bin/apoclocate.sh
# custom-locate0day       *
# Replace * with the desired glftpd option(s) (read glftpd.docs)
#
# Make sure you are running the apocmidnight.sh script and
# enable the "Locate Cache updater" part of the script.
#
# Required bin's: "echo, awk, cat, grep, rm, ls, wc" in glftpd's bin dir

# Where is your 0day directory
# Relative to glftpd, of course
SITEDIR="/site/AppRiPs"

# Use Cached dirlist?
# HIGHLY recommended - see the apocdircache.sh script
USECACHED="1"

# Where is the cache?
# Only if USECACHED=1 above
# Relative to glftpd dir
CACHE="/ftp-data/0day.dir.cache"

# Display how many results?
DISPL="5"

# Settings if you are not using the cache - beware, it is very slow!

# Zipscript complete format - to select the complete releases
ZSCOMPLETE="COMPLETE"

# Zipscript incomplete format - to weed out the incompletes
ZSINC="iNCoMPLETe"

# Zipscript incomplete % format - to weed out the incompletes
ZSPER="%"

# Nuke variable - to weed out the Nuked releases
NUKEVAR="NUKED"

# DO not edit below unless you know what you're doing

# Checks for missing binaries
BINS="grep echo awk cat rm ls wc"
for i in $BINS; do
	if [ ! -x "/bin/$i" ]; then
		echo -e 'Error:' $i 'Missing from /bin or cannot execute it!'
		exit 2
	fi
done

# Cleanup process
clean_up ()
{
TEMPFILES="l.$$ l1.$$ l2.$$ l3.$$ l4.$$ l5.$$ l6.$$ c1.$$"
for i in $TEMPFILES; do
	if [ -e "/tmp/$i" ]; then
		rm /tmp/$i
	fi
done
}

# Start main routine
TESTREQ=`echo "$1" | grep -vE "([^[:alnum:]])"`

if [ "$TESTREQ" ]; then
	echo -e 'Searching for '$1'.'
	if [ "$USECACHED" -eq "1" ]; then
		if [ -r "$CACHE" ]; then
			grep -i "$1" "$CACHE" > /tmp/c1.$$
			if [ -s "/tmp/c1.$$" ]; then
				locatecount=0
				for i in `cat /tmp/c1.$$`; do
					if [ "$locatecount" -lt "$DISPL" ]; then
						echo $i
						locatecount=$(($locatecount+1))
					else
						locatecount="-1"
						break
					fi
				done
				if [ "$locatecount" -eq "-1" ]; then
					results=`wc -l "/tmp/c1.$$" | awk '{print $1}'`
					echo 'Your search returned '$results' results, please narrow it down.'
				fi
				clean_up
				exit 0
			else
                        	echo 'Sorry, unable to find '$1'.'
                        	clean_up
                        	exit 0
			fi
		else
			echo 'Error: cannot read the cached dirlist or it does not exist!'
			exit 2
		fi
	else
		ls -lR "$SITEDIR" | grep -i "$1" > /tmp/l.$$
		if [ -s "/tmp/l.$$" ]; then
			grep -i "$ZSCOMPLETE" /temp/l.$$ > /temp/l1.$$
			grep -v "4096" /tmp/l1.$$ > /tmp/l2.$$
			grep -v "$ZSINC" /tmp/l2.$$ > /tmp/l3.$$
			grep -v "$ZSPER" /tmp/l3.$$ > /tmp/l4.$$
			grep -v "$NUKEVAR" /tmp/l4.$$ > /tmp/l5.$$
			awk ' BEGIN { FS = "/" }
			{ if ( $4 ~ /SORTED/ ) { print $4 "/" $5 "/" $6 > "/tmp/l6.$$" } else { print $4 "/" $5 > "/tmp/l6.$$" } }' /tmp/l5.$$
			locatecount=0
			for i in `cat /tmp/l6.$$`; do
				if [ "$locatecount" -lt "$DISPL" ]; then
					echo $i
					locatecount=$(($locatecount+1))
				else
					locatecount="-1"
					break
				fi
			done
			if [ "$locatecount" -eq "-1" ]; then
				results=`wc -l "/tmp/l6.$$" | awk '{print $1}'`
				echo 'Your search returned '$results' results, please narrow it down.'
			fi
			clean_up
		else
			echo 'Sorry, unable to find '$1'.'
			clean_up
		fi
	fi
else
	echo 'Error! Your request contains illegal characters!'
	exit 2
fi