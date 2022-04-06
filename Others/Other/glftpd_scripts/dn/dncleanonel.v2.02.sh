#!/bin/bash
#<dncleanonel.sh> by dn (#glftpd@efnet)
#May 28, 2001
#Please direct any questions, comments, idea or bugs to dn@blaze.ca

#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.

#DESCRIPTION
#This script will clean your glftpd oneliners file of old oneliners based
#on the number of days you specify.  There is an added option of being able
#to record old oneliners into another file.

#CHANGELOG
#v1.00
# - Initial release
#v2.00
# - Jehsom pretty much rewrote the whole script in order to teach me a few
#   more things and to help improve the speed of the script.  Thanks Jehsom
#v2.01
# - Fixed something small in Jehsom's code.
# - Added some output telling you how many oneliners were moved/removed
#   and kept etc.
# - Added some tests for the variables, to ensure the directories exist before
#   continuing.
#v2.02
# - Clean up the code some more with help from Jehsom

#INSTRUCTIONS
# - copy dncleanonel.v2.02.sh /glftpd/bin/dncleanonel.sh
# - make sure the following bins are in your /glftpd/bin dir and that
#   they are chmod 755:
#   bash, date, printf, mv, dirname
# - set up the VARIABLES section below

#----------------------------------------------------------------------------#

#VARIABLES
#full path to your glftpd dir (no trailing /)
glftpd="/glftpd"

#delete oneliners older than how many days?
daysold=60

#the directory and filename to store old oneliners, comment this out or set
#to "" if you don't want to keep old oneliners
oldonels="/glftpd/ftp-data/misc/oldoneliners"

#temporary directory and filename (no trailing /)
tmpfile="/glftpd/tmp/.tmponel"

#----------------------------------------------------------------------------#

#DO NOT EDIT THE BELOW
#ver="2.02"

[ ! -d "$glftpd" ] && {
    echo "ERROR:" 1>&2
    echo "$glftpd does not exist!" 1>&2
    exit 1
}

[ ! -d "$(dirname "$oldonels")" ] && {
    echo "ERROR:" 1>&2
    echo "The directory to store the old oneliners does not exists!" 1>&2
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
while read user time && read onel; do
    if [ "$[($now - $time) / 86400]" -ge "$daysold" ]; then
        old=$[++old]
        if [ -n "$oldonels" ]; then
            redir="$oldonels"
        else
            redir="/dev/null"
        fi
    else
        keep=$[++keep]
        redir="$tmpfile"
    fi

    printf "%-24s%s\n%s\n" "$user" "$time" "$onel" >> $redir
done < "$glftpd/ftp-data/misc/oneliners"

mv -f "$tmpfile" "$glftpd/ftp-data/misc/oneliners"

if [ -n "$oldonels" ]; then
    echo ""
    echo "$old oneliners were older than $daysold days and were moved"
    echo "to your old oneliners file and $keep remain."
    echo ""
else
    echo ""
    echo "$old oneliners were older than $daysold days and were removed"
    echo "and $keep remain."
    echo ""
fi

exit 0
