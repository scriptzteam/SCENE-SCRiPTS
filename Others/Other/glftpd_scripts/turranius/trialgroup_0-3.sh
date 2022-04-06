#!/bin/bash
############################################################################
# Group Trial Script 0.3 by Turranius                                      #
# This script will check how much users in a group uploaded this week and  #
# add it togheter. It will then check the passlimit to see if they passed  #
# the trial week.                                                          #
# To make it announce in irc, make a trigger for SLOWDL: or change that    #
# in the script to something you already have set up. If you do not wish   #
# it to announce in mirc, simply remark the lines containing SLOWDL:       #
# It will not delete any users or do anything else. It will simply report  #
# how well the group have done this week. The rest is up to you.           #
#                                                                          #
# Also check out the trialgroup.cron.sh script. It will do the same thing  #
# but in scheduled cron job to a log file so you dont have to run this one #
# at 23:59 on saturday.                                                    #
############################################################################
# Changelog                                                                #
# 0.1 - Initial script.                                                    #
# 0.2 - Added TRiAL-2 which is to be used if they are up for trial next    #
#       week. Have to change it to TRiAL manually when its time for them   #
#       to start.                                                          #
#       Changed how the script checks if they are on trial. Instead of     #
#       reading a file, it checks the groups NFO. To set groups on trial   #
#       change the groups nfo (with site grpnfo) to either TRiAL or        #
#       TRiAL-2.                                                           #
# 0.3 - Just changed so announce to irc is one line instead of two.        #
############################################################################

USERPATH=/ftp-data/users
GROUPFILE=/etc/group
GLLOGFILE=/ftp-data/logs/glftpd.log
PASSLIMIT=7500

## Dont change anything below here unless you know what you are doing.

if [ -z "$1" ]; then
  echo "Group Trial 0.3 by Turranius"
  echo "Current Weekly limit is $PASSLIMIT MB"
  echo "Usage: gtrial <groupname>"
  echo "SiTEOPS: Set group nfo to TRiAL-2 for trial next week."
  echo "         or TRiAL for trial this week."
  echo "         Ex: site grpnfo SiTEOPS TRiAL-2"
  exit 0
fi

UPPED="0"
COUNT="0"
TOTAL="0"
EXISTS="NO"
cd $USERPATH

echo "-----[ Group Trial by Turranius ]-----"

## Check if group exists
for i in `cat $GROUPFILE`
do
  NAME="$(echo $i | awk -F":" '{print $1}')"  
  if [ "$NAME" = "$1" ]; then
    EXISTS="Yes"
  fi
done

if [ "$EXISTS" != "Yes" ]; then
  echo "That group does not exist."
  exit 0
fi

## Check group users and what they upped
for i in `ls -f -A | /bin/egrep -v 'default.user|glftpd|backup|disabled' `
do
  GROUP="$(cat $i | grep GROUP | awk -F" " '{print $2}')"
  INIT="$( echo $GROUP | grep $1 )"
  if [ "$INIT" != "" ]; then
    UPPED="$(cat $i | grep WKUP | awk -F" " '{print $3}')"
    UPPED="$(expr $UPPED \/ 1024)"
    echo "User: $i - $UPPED MB this week."
    COUNT="$(expr $COUNT \+ 1)"
    TOTAL="$(expr $UPPED \+ $TOTAL)"
  fi
done

## Are they past the trial limit?
PASSED="$(expr $PASSLIMIT \- $TOTAL)"
if [ "$PASSED" -lt "1" ]; then
  OK="Yes"
else
  OK="No"
fi

echo "--------------------------------------"

## Check the groups NFO to see if they are on trial or not.

NFO="$(cat $GROUPFILE | grep $1 | awk -F":" '{print $2}')"  
if [ "$NFO" = "TRiAL" ]; then
  echo "Group $1 is in trial!"
  GONTRIAL="YES"
else
  echo "Group $1 is not on trial"
  GONTRIAL="NO"
fi

if [ "$NFO" = "TRiAL-2" ]; then
  echo "Group $1 is up for trial next week."
  GONTRIAL="YES"
  WEEK="NEXT"
fi


## Show stats for group.
echo "Total users: $COUNT"
echo "Limit to pass: "$PASSLIMIT". Upped: $TOTAL MB. Passed: $OK"

## Show how much they need to upload or how much they passed with.

if [ "$GONTRIAL" = "YES" ]; then
  if [ "$PASSED" -gt "0" ]; then
    if [ "$WEEK" = "NEXT" ]; then
      echo "$1 is up for trial next week. Missing $PASSED MB to pass if it were this week."
      echo "$(date +'%a %b %d %T %Y') SLOWDL: \002-(GTRiAL) - $USER\002 looks at \002$1\002 ($COUNT users). $1 is up for trial next week. Had it been this week, they would need \002$PASSED\002 MB more to pass." >> $GLLOGFILE
    else
      echo "$1 is in trial. Missing $PASSED MB to pass the trial."
      echo "$(date +'%a %b %d %T %Y') SLOWDL: \002-(GTRiAL) - $USER\002 looks at \002$1\002 ($COUNT users). $1 is missing \002$PASSED\002 MB to pass trialweek." >> $GLLOGFILE
    fi
  else
    if [ "$WEEK" = "NEXT" ]; then
      echo "$1 is up for trial next week. Had it been this week, they would have passed with "$PASSED"- MB"
      echo "$(date +'%a %b %d %T %Y') SLOWDL: \002-(GTRiAL) - $USER\002 looks at \002$1\002 ($COUNT users). $1 is up for trial next week. Had it been this week, they would have passed with \002$PASSED-\002 MB to spare." >> $GLLOGFILE
    else
      echo "$1 has passed the trial with "$PASSED"- MB"
      echo "$(date +'%a %b %d %T %Y') SLOWDL: \002-(GTRiAL) - $USER\002 looks at \002$1\002 ($COUNT users). $1 has passed the trial with \002$PASSED-\002 MB to spare." >> $GLLOGFILE
    fi
  fi
else
  if [ "$PASSED" -gt "0" ]; then
    echo "$1 is not on trial. Had they been, they are missing $PASSED MB"
    echo "$(date +'%a %b %d %T %Y') SLOWDL: \002-(GTRiAL) - $USER\002 looks at \002$1\002. $1 is not on trial. They are missing \002$PASSED\002 MB if they had been." >> $GLLOGFILE
  else
    echo "$1 is not on trial. Had they been, they would have passed with "$PASSED"- MB"  
    echo "$(date +'%a %b %d %T %Y') SLOWDL: \002-(GTRiAL) - $USER\002 looks at \002$1\002. $1 is not on trial. They are past the limit with \002$PASSED-\002 if they had been." >> $GLLOGFILE
  fi
fi

exit 0
