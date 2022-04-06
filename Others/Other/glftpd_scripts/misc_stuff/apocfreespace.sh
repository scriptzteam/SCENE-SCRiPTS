#!/bin/bash
#
#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.
#
# Apocalypse FreeSpace Maker v1.0
#
# To use this script, add it to root crontab to midnight daily
#
# Required bin's: "df, du, grep, echo, touch, chmod, awk, tail, rm, date, ls" in /bin dir

# Your Log directory
LOGDIR="/glftpd/ftp-data/logs/apoc"

# Your Log Name
GENLOG="freespace.log"

# Where do you want to free up space on?
# Format: 3 lines for each directory
# FreeDir[1]="/glftpd/site/incoming" <-- Your Directory to be checked
# FreeDev[1]="/dev/hdy4" <-- which device does FreeDir reside on?
# FreeSpace[1]="10000" <-- How much megabytes do you want free?
# Increment the number for each directory you have
# i.e. FreeDir[3] , FreeDev[3] , FreeSpace[3] and so on

FreeDir[1]="/glftpd/site/ISO/Games"
FreeDev[1]="/dev/hdc1"
FreeSpace[1]="10000"

FreeDir[2]="/glftpd/site/ISO/Apps"
FreeDev[2]="/dev/md0"
FreeSpace[2]="10000"

FreeDir[3]="/glftpd/site/Requests"
FreeDev[3]="/dev/hdd1"
FreeSpace[3]="1500"

# DO not edit below unless you know what you're doing

time_stamp ()
{
    echo -n `echo '( ' && date +%T && echo ' | ' && date +%D && echo ' | FreeSpace )'`
}

# Check the temp dir for logs
if [ ! -w "$LOGDIR" ]; then
	echo 'Unable to write to log dir or it is nonexistant'
	exit 0
else
	if [ ! -w "$LOGDIR/$GENLOG" ]; then
		if [ ! -e "$LOGDIR/$GENLOG" ]; then
			touch $LOGDIR/$GENLOG
			chmod 666 $LOGDIR/$GENLOG
			time_stamp && echo ' Information: Creating Error Log!' >> $LOGDIR/$GENLOG
			if [ ! -e "$LOGDIR/$GENLOG" ]; then
				echo 'Unable to create error log!'
				exit 0
			fi
		else
			echo 'Cannot write to error log! (Check permissions)'
			exit 0
		fi
	fi
fi

# Checks for missing binaries
BINS="date df du grep echo touch chmod awk tail rm ls"
for i in $BINS; do
	if [ ! -x "/bin/$i" ]; then
		if [ ! -x "/usr/bin/$i" ]; then
			time_stamp && echo ' Error:' $i 'Missing from /bin or /usr/bin or cannot execute it!' >> $LOGDIR/$GENLOG
			exit 0
		fi
	fi
done

# Sanity Checks
index=1
while [ "$index" -lt "$((${#FreeDir[@]}+1))" ]
do
	DevTEST=`df | grep "${FreeDev[$index]}"`
	DevFreeTEST=`df -m | grep "${FreeDev[$index]}" | awk '{print $2}' | tail -n1`
	if [ ! -e "${FreeDir[$index]}" ]; then
		time_stamp && echo ' Error: The Directory '${FreeDir[$index]}' Does not exist!' >> $LOGDIR/$GENLOG
		exit 0
	fi

	if [ ! "$DevTEST" ]; then
		time_stamp && echo ' Error: The Device '${FreeDev[$index]}' Does not exist!' >> $LOGDIR/$GENLOG
		exit 0
	fi

	if [ "${FreeSpace[$index]}" -lt "1" ]; then
		time_stamp && echo ' Error: Having '${FreeSpace[$index]}' desired free space for '${FreeDir[$index]}' Does not make sense!' >> $LOGDIR/$GENLOG
		exit 0
	fi

	if [ "$DevFreeTEST" -lt "${FreeSpace[$index]}" ]; then
		time_stamp && echo ' Error: Desired Free space '${FreeSpace[$index]}' Is bigger than the actual size of '$DevFreeTEST' on '${FreeDev[$index]} >> $LOGDIR/$GENLOG
	fi

	index=$(($index+1))
done

# Main Routine Starts Here
index=1
while [ "$index" -lt "$((${#FreeDir[@]}+1))" ]
do
	DevTEST=`df -m | grep "${FreeDev[$index]}" | awk '{print $4}' | tail -n1`
	while [ "$DevTEST" -lt "${FreeSpace[$index]}" ]
	do
		DirList=`ls -l --sort=t "${FreeDir[$index]}" | awk '{print $9}' | tail -n1`
		DirListSize=`du -m --max-depth=0 "${FreeDir[$index]}/$DirList" | cut -f1`
		time_stamp && echo ' Information: '$DirList' ('$DirListSize'mb) was deleted from '${FreeDir[$index]} >> $LOGDIR/$GENLOG
		rm -rf ${FreeDir[$index]}/$DirList
		DevTEST=`df -m | grep "${FreeDev[$index]}" | awk '{print $4}' | tail -n1`
	done
	index=$(($index+1))
done