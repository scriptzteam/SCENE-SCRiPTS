#!/bin/sh
#  Purge routine ver.7 written by clubber
#  originally v.6 was written by barkeep
#
#  WORKS ONLY WITH 17.0+ glftpd.
#  PURPOSE:  Find users within glftpd that have not logged in
#            within a specified number of days.  
#
#
######################################################
# Your glftpd users path.  NO / at the end!
GLUSERS=/glftpd/ftp-data/users

# Number of days your scanning old users for.  example...
# if a user has not logged in for 45 days
DAYS=20

# If you do NOT want to be asked about a user.  add his name to the |grep -v "usernames" below
# backup this file if your not sure what you are doing.
######################################################
CURTIME=`date +%s`
NEVER=10000

ls $GLUSERS/ > $GLUSERS/.testfile
echo " "
echo " User Purge by barkeep..."
echo " ************************"
echo "                         "
echo " SCANNING Userfiles...   "
echo " "
for x in `cat $GLUSERS/.testfile |grep -v "default.user" | grep -v "glftpd" | grep -v "backup"`
do
   LASTTIME=`cat $GLUSERS/$x |grep "TIME" | grep -v "TIMEFRAME" |awk '{print $3}'`
   LASTON=`expr $CURTIME - $LASTTIME`
   NUMDAYS=`expr $LASTON / 86400`
   USER=`basename $x`
   if [ $NUMDAYS -gt $DAYS ] && [ $NUMDAYS -lt $NEVER ] ; then
       echo -n " $USER has not logged in for $NUMDAYS days.  Purge? (Y/N) "
       read PURGE
       case $PURGE in
          [Yy])
               echo " PURGING $USER ..."
               mkdir $GLUSERS/backup >/dev/null 2>&1
               mv $GLUSERS/$x $GLUSERS/backup
               echo "# This user is purged, backed up in $GLUSERS /backup " > $GLUSERS/$x
               echo "# To finalize the purge do a |site purge| " >> $GLUSERS/$x
               echo "FLAGS 6" >> $GLUSERS/$x
               echo "TIME 0 $CURTIME 0" >> $GLUSERS/$x
               echo " User $USER Purged succesfully "
               ;;
          [Nn])
               echo " Skipping $USER "
               ;;
          *)
               echo " Incorrect option.. Skipping user "
               ;;
       esac
       echo " "
    fi
    if  [ $NUMDAYS -gt $NEVER ] ; then
       
       echo " WARNING:  user $USER has never logged in"      
       echo " "
    fi
done
rm $GLUSERS/.testfile

echo " "
echo " *************************************************** "
echo " To finalize the settings you must do a |site purge| "
echo " at the ftp prompt.  all users purged are backed up  "
echo " in the users/backup/ dir.                           "
echo " *************************************************** "
