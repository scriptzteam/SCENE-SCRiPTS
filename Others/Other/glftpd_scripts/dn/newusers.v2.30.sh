#!/bin/bash -
#<newusers.sh> by dn (#glftpd@efnet)          
#May 6th, 2001       
#Please direct any questions, comments, idea or bugs to dn@blaze.ca

#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.

#DESCRIPTION
#This script will scan your current sysop.log and/or a backup sysop.log, if
#specified and report a list of new users that have been added.  You can
#specify the new users to report back on.  Main reason for this script is
#a lot of sites have more than one person capable of adding users, like
#other siteops or gadmins.

#CHANGELOG
#v1.00
# - Initial release
#v2.10
# - I put the wrong version on the website, so just in case anyone grabbed
#   that already, I've changed the version number.
#v2.20
# - Ugh, still rushed out the last version.  Fixed a few small errors
#v2.30
# - Optimized some of the code.  Yeah, thats what I did. (Barstow, shh!)

#INSTRUCTIONS
#cp newusers.v2.30.sh /glftpd/bin/newusers.sh; chmod 755
#add the following lines to your glftpd.conf
#  site_cmd newusers       EXEC    /bin/newusers.sh
#  custom-newusers <flags/=groups/-usernames>
#setup the variables listed below

#VARIABLES
syslogold=0 #Do you backup your log, and start a fresh one (0=no, 1=yes)
syslogo=/ftp-data/logs/sysop.old #If above is 1, then what is the name of your backup log

#----------------------------------------------------------------------------#

#DO NOT EDIT THE BELOW
VER="2.30"

if [ -z $1 ]; then
  echo -e " .------------------------"
  echo -e "| NewUsers v"$VER" by dn"
  echo -e " \`------------------------"
  echo -e "ERROR: You must enter the number of users to display, if the number of users"
  echo -e "       in the log is less then the number specified, only those will be displayed."
  exit 0
else
  echo -e " .------------------------"
  echo -e "| NewUsers v"$VER" by dn"            
  echo -e " \`------------------------"
  numuser=$1
  syslog=/ftp-data/logs/sysop.log
  user=`grep "added user" $syslog | awk '{print $2 "|" $3 "|" $8 "|" $11}' | tr '.' ' ' | tail -"$numuser"`
  usertest=`echo $user | tr -d ' ' | tr -d '\n'`
  if [ -n "$usertest" ]; then
    total=`echo $user | tr ' ' '\n' | wc -l | awk '{print $1}'`
    numuser=`echo $[$numuser - $total]`
    for x in `echo $user | tr ' ' '\n'`; do
      date=`echo $x | tr '|' ' ' | awk '{print $1 " " $2}'`
      addedby=`echo $x | tr '|' ' ' | awk '{print $3}' | tr -d [=\'=]`
      new=`echo $x | tr '|' ' ' | awk '{print $4}' | tr -d [=\'=]`
      echo -e "$new was added by $addedby on $date"
    done
  else
    echo -e "No new users in currently log!"
  fi

  if [ $syslogold = "1" ]; then
    userold=`grep "added user" $syslogo | awk '{print $2 "|" $3 "|" $8 "|" $11}' | tail -"$numuser"`
    useroldtest=`echo $userold | tr -d ' ' | tr -d '\n'`
      if [ -n "$useroldtest" ]; then
        for x in `echo $user | tr ' ' '\n'`; do
          date=`echo $x | tr '|' ' ' | awk '{print $1 " " $2}'`
          addedby=`echo $x | tr '|' ' ' | awk '{print $3}' | tr -d [=\'=]`
          new=`echo $x | tr '|' ' ' | awk '{print $4}' | tr -d [=\'=]`
          echo -e "$new was added by $addedby on $date"
        done
      else
        echo -e "No new users in backup log!"
      fi
  fi
fi
exit 0

