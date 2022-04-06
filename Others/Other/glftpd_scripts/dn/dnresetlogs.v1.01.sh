#!/bin/bash
#<dnresetlogs.sh> by dn (#glftpd@efnet)
#May 23, 2001
#Please direct any questions, comments, idea or bugs to dn@blaze.ca

#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.

#DESCRIPTION
#This script will make a backup of all your glftpd logs as well as any user
#or script generated logs, and then start fresh ones.  This should be run 
#weekly or monthly as a root cronjob, but it can run as often as you like.

#CHANGELOG
#v1.00
# - Initial release
#v1.01
# - Changed the oldlogdir variable to need a ful path, this way you can
#   store the backups whereever you want.  This also fixed a fatal bug.
#   Things to murth for sniffing it out

#INSTRUCTIONS
# - copy dnresetlogs.v1.01.sh /glftpd/bin/dnresetlogs.sh
# - make sure the following bins are in your /glftpd/bin dir and that
#   they are chmod 755:
#   bash, cp, cat, echo
# - add the following line to your root crontab:
#   1 0 * * sun /usr/local/glftpd/bin/dnresetlogs.sh
#   this will run the script every sunday at 12:01, you can change this
#   accordingly. man crontab :) 
# - set up the VARIABLES section below

#----------------------------------------------------------------------------#

#VARIABLES
#full path to your glftpd directory, no trailing /
glroot="/glftpd"           

#full path to where you would like to store your old logs.
#The same dir as the original logs is fine, no trailing /
oldlogdir="/glftpd/ftp-data/logs"

#extension you would like on the old logs, this an be anything BUT "log",
#unless you have specified a different directory for the old logs to be
#stored in.  Do not include an initial period
oldlogext="old"

#please specify the logs you wish to backup, the logs created by glftpd are
#listed below, but any logs contained in your glftpd log dir are valid.  
#You must enter the exact filename of the log, each must be separated with a
#space.
#glftpd logs are:
#dirlog      - Not recommended, this should grow forever!  
#dupefile    - Not recommended, this should grow forever! 
#dupelog     - Not recommended, this should grow forever! 
#error.log   - Optional, usually a small log 
#glftpd.log  - Recommended  
#login.log   - Recommended  
#nukelog     - Not recommended, use nukelogclean to keep this small 
#request.log - Optional, usually a small log  
#sysop.log   - Optional, usually a small log  
#xferlog     - Recommended 
logs="error.log glftpd.log login.log request.log sysop.log xferlog"

#----------------------------------------------------------------------------#

#DO NOT EDIT THE BELOW
#ver="1.00"

for log in $logs; do
  if [ -e $glroot/ftp-data/logs/$log ]; then
  cp -f $glroot/ftp-data/logs/$log $oldlogdir/$log.$oldlogext
  cat /dev/null > $glroot/ftp-data/logs/$log
  else
    echo "$log does not exists!"
  fi
done
exit 0
