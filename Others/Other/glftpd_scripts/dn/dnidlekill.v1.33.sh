#!/bin/bash
#<dnidlekill.sh> by dn (#glftpd@efnet)
#February 4th, 2001
#Please direct any questions, comments, idea or bugs to dn@blaze.ca

#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.

#DESCRIPTION
#This little script kills anyone on the site that is in a current state
#of IDLE.  You have an option to ignore certain users, as well as
#remove a specified number of megabytes from the user each time he 
#is killed for being idle, as well as set a max number of times he
#can be killed before he gets flag 6!  The log information can easily
#be read for use with your bots.

#CHANGELOG
#v1.0
# - Initial Release
#v1.1
# - Added the option to ignore user(s)
#v1.2 
# - Added logging
# - Added the option to remove a specified amount of credits for each kill
# - Added the option to set a max number per day that a user can be killed
#   before adding flag 6
# - Can now setup a specified user who to send an email too when a user
#   has flag 6 set
# - Setup the script for public use
# - Optimized the code
#v1.3
# - Fixed a path problem to ftpwho
# - Added some checks to ensure paths and file exist
# - Removed some debug lines I left in
# - Added the tag KILL: and DELETE: to the log.  This will make it easier
#   for bot use.
# - If you use the delete option, it will be logged (as DELETE:)
# - The dirname and rm bin are now required in /glftpd/bin
#v1.31
# - Fixed a couple of spelling errors
# - Changed the logging format, so it matches the standards use in 
#   glftpd.log.  In case people wish to log the information there.
# - Changed the log tags KILL: and DELETE: to IDLEKILL: and IDLEDEL: so
#   they are more specific if used in the glftpd.log etc
# - Changed how the number of times the user has been killed is found.
#   Due to the changes in logging, this was necessary.
#v1.32
# - Fixed an error in the calculation of the number of times a user was
#   killed in a day.  Should be correct in the log now as well.
# - Changed it so if the user has hit the max idle kills in one day it
#   doesn't log both the IDLEKILL and the IDLEDEL, just the IDLEDEL.
# - Specified the glftpd bin path to call the kill binary from.  May
#   have caused problems if for some reason the only place the kill 
#   binary was located was in your glftpd bin dir, as I originally wasn't
#   calling it from there.
#v1.33 
# - If the delete option was set to "0", nothing would log and no credits
#   would be removed.  This has been fixed.
# - Made the output and email message a little more descriptive.

#INSTRUCTIONS
# - copy dnidlekill.v1.33.sh to /glftpd/bin/dnidlekill.sh
# - make sure the following bins are in your /glftpd/bin dir and that
#   they are chmod 755:
#   ftpwho, bash, grep, tr, wc, awk, echo, cut, mv, sed, cat, kill, date,
#   dirname, rm
# - setup the VARIABLES section below
# - create the logfile you specified below in /ftp-data/logs.  Make sure its
#   chmod 666.

#----------------------------------------------------------------------------#

#VARIABLES
#path to glftpd, no trailing /
glftpd="/glftpd"

#path and file for temporary use.  Must be set.
temp=/glftpd/tmp/.idlekill.tmp #full path to tempfile (leave as is)

#path and file for logging.  Must be set.
log="/glftpd/ftp-data/logs/idlekill.log"

#the amount of credits to remove in MB each time a user is killed.  Set to
#"" or comment out to disable
credits="200"

#set this to the number of a times a user can be killed to set flag 6.  Set
#to 0 to disable.  Setting to 0 will also disable the logging for this
#feature.
delete="0"

#who to notify when a user gets flag 6
mailto="root"

#user(s) to ignore.  format is user1, or user1|user2.  Comment out or set to
#"" to disable
ignore="SiteBot|dn"

#----------------------------------------------------------------------------#

#DO NOT TOUCH ANYTHING BELOW HERE!
#ver="1.3"

[ ! -d "$glftpd" ] && {
    echo "ERROR:" 1>&2
    echo "$glftpd does not exist!" 1>&2
    exit 1
}
            
[ ! -d "$(dirname $temp)" ] && {
    echo "ERROR:" 1>&2
    echo "$(dirname $temp) does not exist!" 1>&2
    exit 1
}
    
[ ! -e "$log" ] && {
    echo "ERROR:" 1>&2
    echo "$log does not exist!" 1>&2
    exit 1
}

umask 000
today="$(date +"%b %d")"

if [ -n "$ignore" ]; then
    $glftpd/bin/ftpwho | grep -vE "$ignore" | grep -w "Idle:" | tr -d '|' > $temp
    if [ -e "$temp" ]; then
        while read user pid time; do
            numtoday="$(grep -wE "$today.*IDLEKILL:.*$user" $log | wc -l | awk '{print $1}')"
            numtoday=`echo $[$numtoday + 1]`

            [ "$numtoday" -lt "$delete" -o "$delete" == "0" ] && {
                echo "$(date +"%a %b %d %T %Y") IDLEKILL: \"$user\" \"$pid\" \"$credits\" \"$numtoday\"" >> $log
                echo "$user using PID $pid has been killed! ($numtoday time(s) today)"
            }	

            [ -n "$credits" -a "$numtoday" -lt "$delete" -o -n "$credits" -a "$delete" == "0" ] && {
                echo "Removing $credits"MB" from $user"
                creditline="$(grep -wE "^CREDITS" "$glftpd"/ftp-data/users/$user)"
                creditsnow="$(grep -wE "^CREDITS" "$glftpd"/ftp-data/users/$user | cut -d ' ' -f2)"
                creditsnew=`echo $[$creditsnow - ($credits * 1024)]`
                cat "$glftpd"/ftp-data/users/$user | sed 's/'"$creditline"'/CREDITS '"$creditsnew"'/g' >> $user.new
                mv $user.new "$glftpd"/ftp-data/users/$user
            }

            [ "$numtoday" == "$delete" ] && {
                echo "Deleting $user for being idle killed $delete time(s)"
                echo "$user has been deleted for being idle killed $delete times, do a site purge to remove" | mail -s "$0" $mailto
                flagline="$(grep -wE "^FLAGS" "$glftpd"/ftp-data/users/$user)"
                cat "$glftpd"/ftp-data/users/$user | sed 's/'"$flagline"'/#'"$flagline"'/g' >> $user.new
                echo "FLAGS 6" >> $user.new
                mv $user.new "$glftpd"/ftp-data/users/$user
                echo "$(date +"%a %b %d %T %Y") IDLEDEL: \"$user\" \"$numtoday\"" >> $log
            }
            $glftpd/bin/kill -9 $pid
        done < $temp
        rm $temp
    else
        echo "No users are currently idling!"
    fi
else
    $glftpd/bin/ftpwho | grep -w "Idle:" | tr -d '|' > $temp
    if [ -e "$temp" ]; then
        while read user pid time; do
            numtoday="$(grep -wE "$today.*IDLEKILL:.*$user" $log | wc -l | awk '{print $1}')"
            numtoday=`echo $[$numtoday + 1]`
 
            [ "$numtoday" -lt "$delete" -o "$delete" == "0" ] && {
                echo "$(date +"%a %b %d %T %Y") IDLEKILL: \"$user\" \"$pid\" \"$credits\" \"$numtoday\"" >> $log
                echo "$user using PID $pid has been killed! ($numtoday time(s) today)"
            }
    
            [ -n "$credits" -a "$numtoday" -lt "$delete" -o -n "$credits" -a "$delete" == "0" ] && {
                echo "Removing $credits"MB" from $user"
                creditline="$(grep -wE "^CREDITS" "$glftpd"/ftp-data/users/$user)"
                creditsnow="$(grep -wE "^CREDITS" "$glftpd"/ftp-data/users/$user | cut -d ' ' -f2)"
                creditsnew=`echo $[$creditsnow - ($credits * 1024)]`
                cat "$glftpd"/ftp-data/users/$user | sed 's/'"$creditline"'/CREDITS '"$creditsnew"'/g' >> $user.new
                mv $user.new "$glftpd"/ftp-data/users/$user
            }
             
            [ "$numtoday" == "$delete" ] && {
                echo "Deleting $user for being idle killed $delete time(s)"
                echo "$user has been deleted for being idle killed $delete times, do a site purge to remove" | mail -s "$0" $
                flagline="$(grep -wE "^FLAGS" "$glftpd"/ftp-data/users/$user)"
                cat "$glftpd"/ftp-data/users/$user | sed 's/'"$flagline"'/#'"$flagline"'/g' >> $user.new
                echo "FLAGS 6" >> $user.new
                mv $user.new "$glftpd"/ftp-data/users/$user
                echo "$(date +"%a %b %d %T %Y") IDLEDEL: \"$user\" \"$numtoday\"" >> $log
            }
            $glftpd/bin/kill -9 $pid
        done < $temp
        rm $temp
    else
        echo "No users are currently idling!"
    fi
fi
exit 0
