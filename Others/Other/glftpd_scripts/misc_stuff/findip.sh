#!/bin/bash 
#########################################################
# Script to locate which user has a specific IP number. #
# Say you have someone port scanning you and you want   #
# to know if it is a user on your site.                 #
# Version 1.0, 2002-03-14, created by Turranius.        #
#########################################################
# What you need to do:                                  #
# Preferebly, copy this script to /glftpd/bin.          #
# chmod 4777 /glftpd/bin/listip.sh                      #
#                                                       #
# Change the cd path to where your users folder is.     #
#                                                       #
# If you have any folders below users/, you can add     #
# them to the exclude list, '|' seperated.              #
# Can also exclude usernames in that line.              #
#########################################################
USERPATH=/glftpd/ftp-data/users
EXCLUDES='default.user|glftpd|backup|disabled'

# Nothing should need to be changed below.


cd $USERPATH

if [ -z $1 ]; then
  echo "Usage: findip.sh IPnumber"
  echo "Example: findip.sh 192.168"
  echo "Partial IP's are ok, IE '192.' or '.178'"
  echo "You can also search on ident"
  exit 0
fi

for i in `ls -f -A | egrep -v $EXCLUDES `
do
	IP=`grep IP $i | awk -F" " '{print $2}'`
	echo $i - $IP | grep $1
done
