#!/bin/sh
ver=0.2
#
#  Directory log cleaner
#	v0.2
#
#	by: ip
#
#	Simple script to run in a cron to limit the size of those 
#	unsightly logs.
#
#	This is free code, no guarantee, blah.......
#
#
# Bugs & Contact: ip|@efnet
#	 	  ip@eliteo*	
#	 	  ip@socals*
#		  ipfreely@internet-protocol.org
#
##### CONFIG ######################
logdir="/iP/ftp-data/logs"        # <----- Location of your logs 
#				  #        (Relative to Root )
maxlogsize=5242880                # <----- Maximum Log size in BYTES
#                                 #
files="dirlog xferlog glftpd.log" # <----- Files That Script should
#				  #        maintain
############### END CONFIG ########

cd $logdir

echo "************************"
echo "** Log Cleaner v$ver   **"
echo "************************"
echo
echo
echo "Checking Log Files:"
for x in $files
do
	echo -n "			Checking $x Size: "
	curlog=`du -b $logdir/$x|cut -f1`
	if `test $curlog -gt $maxlogsize`;then
		tail -c$maxlogsize $x > $x.tmp
		mv $x.tmp $x
		echo "OVERSIZE - TRIMMING"
	else
		echo "OK"
	fi
done

echo;echo "LOGS CLEANED ... EXITING"
exit 0;
