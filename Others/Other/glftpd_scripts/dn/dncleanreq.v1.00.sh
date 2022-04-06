#!/bin/bash
#<dncleanreq.sh> by dn (#glftpd@efnet)
#May 30, 2001
#Please direct any questions, comments, idea or bugs to dn@blaze.ca

#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.

#DESCRIPTION
#This script is basically the same as my dncleanonel.sh script.  It will 
#clean your glftpd requests file of old requests based on the number of days
#you specify.  There is an added option of being able to record old requests
#into another file.

#CHANGELOG
#v1.00
# - Initial release.  Thanks to Jehsom for the original code.

#INSTRUCTIONS
# - copy dncleanreq.v1.00.sh /glftpd/bin/dncleanreq.sh
# - make sure the following bins are in your /glftpd/bin dir and that
#   they are chmod 755:
#   bash, date, printf, mv, dirname
# - set up the VARIABLES section below

#----------------------------------------------------------------------------#

#VARIABLES
#full path to your glftpd dir (no trailing /)
glftpd="/glftpd"

#delete requests older than how many days?
daysold=60

#the directory and filename to store old requests, comment this out or set
#to "" if you don't want to keep old requests
oldreqs="/glftpd/ftp-data/misc/oldrequests"

#temporary directory and filename (no trailing /)
tmpfile="/glftpd/tmp/.tmpreqs"

#----------------------------------------------------------------------------#

#DO NOT EDIT THE BELOW
#ver="1.00"

[ ! -d "$glftpd" ] && {
    echo "ERROR:" 1>&2
    echo "$glftpd does not exist!" 1>&2
    exit 1
}

[ ! -d "$(dirname "$oldreqs")" ] && {
    echo "ERROR:" 1>&2
    echo "The directory to store the old requests does not exists!" 1>&2
    exit 1
}

[ ! -d "$(dirname "$tmpfile")" ] && {
    echo "ERROR:" 1>&2
    echo "The temporary directory does not exist!" 1>&2
    exit 1
}

now="$(date +%s)"
umask 000

old=0
keep=0
while read user time && read req; do
    if [ "$[($now - $time) / 86400]" -ge "$daysold" ]; then
        old=$[++old]
        if [ -n "$oldreqs" ]; then
            redir="$oldreqs"
        else
            redir="/dev/null"
        fi
    else
        keep=$[++keep]
        redir="$tmpfile"
    fi

    printf "%-24s%s\n%s\n" "$user" "$time" "$req" >> $redir
done < "$glftpd/ftp-data/misc/requests"

mv -f "$tmpfile" "$glftpd/ftp-data/misc/requests"

if [ -n "$oldreqs" ]; then
    echo ""
    echo "$old requests were older than $daysold days and were moved"
    echo "to your old requests file and $keep remain."
    echo ""
else
    echo ""
    echo "$old requests were older than $daysold days and were removed"
    echo "and $keep remain."
    echo ""
fi

exit 0
