#!/bin/bash
############################################################################
# Group Trial Cron Script 0.2 by Turranius                                 #
# This script will check how much users in a group uploaded this week and  #
# add it togheter.                                                         # 
# This is the script ment to be run as a cron job to create a log file.    #
# Otherwise, you would have to use the trialgroup.sh before midnight at    #
# saturday night. With this you can just check the logfile. It basically   #
# runs trialgroup.sh for you.                                              #
# Copy this to /glftpd/bin and set crontab to                              #
# 55 23 * * 6 /glftpd/bin/trialgroup.cron.sh                               #
# This will run it at 23:55 on Saturday.                                   #
# Setup the parameters below. If you have any folders in your              #
# users folder, add them to the EXLUDE line, | delimited. You can also     #
# add any users you do not want to count, even if they are in a group with #
# trial.                                                                   #  
############################################################################
# Changelog                                                                #
# 0.1 - Initial script.                                                    #
# 0.2 - Added TRiAL-2 which is to be used if they are up for trial next    #
#       week. Have to change it to TRiAL manually when its time for them   #
#       to start. Nice to know how they are doing.                         #
#       Changed how the script checks if they are on trial. Instead of     #
#       reading a file, it checks the groups NFO. To set groups on trial   #
#       change the groups nfo (with site grpnfo) to either TRiAL or        #
#       TRiAL-2.                                                           #
############################################################################

USERPATH=/glftpd/ftp-data/users
GROUPFILE=/glftpd/etc/group
LOGFILE=/glftpd/ftp-data/logs/grouptrial.log
EXCLUDE="default.user|glftpd|backup|disabled"

## Dont change anything below here unless you know what you are doing.

UPPED="0"
COUNT="0"
TOTAL="0"
EXISTS="NO"
cd $USERPATH
touch $LOGFILE

echo "" >> $LOGFILE
echo "----------------------------------------------------" >> $LOGFILE
date >> $LOGFILE

for i in `cat $GROUPFILE`
do
  NAME="$(echo $i | awk -F":" '{print $1}')"
  TRIAL="$(echo $i | awk -F":" '{print $2}')"
  if [ "$TRIAL" = "TRiAL" ]; then
    for u in `ls -f -A | /bin/egrep -v $EXCLUDE`
    do
      if [ "$LAST" != $i ]; then
        TOTAL="0"
        echo " -----[ New group found: $i ]----- "
      fi
      GROUP="$(cat $u | grep GROUP | awk -F" " '{print $2}')"
      INIT="$( echo $GROUP | grep $NAME )"
      if [ "$INIT" != "" ]; then
        UPPED="$(cat $u | grep WKUP | awk -F" " '{print $3}')"
        UPPED="$(expr $UPPED \/ 1024)"
        COUNT="$(expr $COUNT \+ 1)"
        TOTAL="$(expr $UPPED \+ $TOTAL)"
        echo "Group: $NAME. User: $u - $UPPED MB this week. Total: $TOTAL" >> $LOGFILE
      fi
      LAST=$i
    done
  fi
done

## NEXT WEEKS TRIAL
i=""
u=""

for i in `cat $GROUPFILE`
do
  NAME="$(echo $i | awk -F":" '{print $1}')"
  TRIAL2="$(echo $i | awk -F":" '{print $2}')"
  if [ "$TRIAL2" = "TRiAL-2" ]; then
    for u in `ls -f -A | /bin/egrep -v $EXCLUDE`
    do
      if [ "$LAST" != $i ]; then
        TOTAL="0"
        echo " -----[ Found group for next week: $i ]----- "
      fi
      GROUP="$(cat $u | grep GROUP | awk -F" " '{print $2}')"
      INIT="$( echo $GROUP | grep $NAME )"
      if [ "$INIT" != "" ]; then
        UPPED="$(cat $u | grep WKUP | awk -F" " '{print $3}')"
        UPPED="$(expr $UPPED \/ 1024)"
        COUNT="$(expr $COUNT \+ 1)"
        TOTAL="$(expr $UPPED \+ $TOTAL)"
        echo "Group: $NAME. User: $u - $UPPED MB this week. Total: $TOTAL" >> $LOGFILE
      fi
      LAST=$i
    done
  fi
done


exit 0
