#!/bin/bash
#
#DISCLAIMER
# - I TAKE NO RESPONSIBILITY OF THE CONSEQUENCES OF USING THIS SCRIPT.
# - USE AT YOUR OWN RISK
#
# Apocalypse NewDay Dir Maker v1.0
#
# Crontab this script to run at exactly 11:59 pm as root
# If you want to set it to GST, reflect that in your crontab
#
# Required bin's: "date, echo, chmod, touch, rm, ln, mkdir" in /bin dir

# Where is glftpd's site located?
FTPROOT="/glftpd/site"

# Where is your 0day dir?
# (Relative to glftpd site dir)
DAYDIR="/AppRiPs"

# What is your desired day naming scheme?
# %d = day, %m = month, %Y = year
# i.e. +%m%d = 0128
# or +%d%m%Y = 28012002
DATEFORMAT="+%m%d"

# How many days old for backfilling?
DAYSOLD="2"

# Do you want a symlink from ftp root to newday?
# 1 = yes, 0 = no
SYMLINK="1"

# Name of your symlink
# (only if SYMLINK = 1 above)
SYMLINKNAME="Today0day"

# Your Log directory
LOGDIR="/glftpd/ftp-data/logs/apoc"

# Your Log Name
GENLOG="newday.log"

# DO not edit below unless you know what you're doing

time_stamp ()
{
    echo -n `echo '( ' && date +%T && echo ' | ' && date +%D && echo ' | NewDay )'`
}

# Check the temp dir for logs
if [ ! -w "$LOGDIR" ]; then
	echo 'Unable to write to log dir or it is nonexistant'
	exit 0
else
	if [ ! -w "$LOGDIR/$GENLOG" ]; then
		if [ ! -e "$LOGDIR/$GENLOG" ]; then
			touch $LOGDIR/$GENLOG
			chmod 777 $LOGDIR/$GENLOG
			time_stamp && echo ' Information: Creating Error Log!' >> $LOGDIR/$GENLOG
			if [ ! -e "$LOGDIR/$GENLOG" ]; then
				echo 'Unable to create error log!'
				exit 0
			fi
		fi
	fi
fi

# Checks for missing binaries
BINS="date echo chmod touch rm ln mkdir"
for i in $BINS; do
	if [ ! -x "/bin/$i" ]; then
		time_stamp && echo ' Error:' $i 'Missing from /bin or cannot execute it!' >> $LOGDIR/$GENLOG
		exit 0
	fi
done

# Check for permission on our 0day dir
if [ ! -w "$FTPROOT$DAYDIR" ]; then
	time_stamp && echo ' Error: Cannot write in' $FTPROOT$DAYDIR >> $LOGDIR/$GENLOG
	exit 0
fi

# Check for permission on our root dir
if [ ! -w "$FTPROOT" ]; then
	time_stamp && echo ' Error: Cannot write in' $FTPROOT >> $LOGDIR/$GENLOG
	exit 0
fi

# Check to see if the backfilling setting is bogus
if [ "$DAYSOLD" -lt "1" ]; then
	time_stamp && echo ' Error: Having DAYSOLD set to '$DAYSOLD' does not make sense!' >> $LOGDIR/$GENLOG
	exit 0
fi

# Get the date
NEWDIR=`date -d +1day $DATEFORMAT`

# Create the new dir and chmod it
mkdir $FTPROOT$DAYDIR/$NEWDIR
chmod 777 $FTPROOT$DAYDIR/$NEWDIR

# Stop backfilling on the old dir
OLDDIR=`date -d "+$DAYSOLD days ago" $DATEFORMAT`
chmod -R 555 $FTPROOT$DAYDIR/$OLDDIR

# Make symlink
if [ "$SYMLINK" -eq "1" ]; then
    cd $FTPROOT
    rm -f $SYMLINKNAME
    ln -sf $DAYDIR/$NEWDIR $SYMLINKNAME
fi