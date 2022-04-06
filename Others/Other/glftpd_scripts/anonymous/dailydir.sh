#!/bin/sh
#
# You should add an entry in ur crontab like this
#
# This script adds a new dated directory at the given base dir.
#
# Things to change: location of directory to create
# 
# 0 0 * * *  /path/to/script
#

#date=`date +%m%d`

#Use the following line if you need to create the new dated dir ahead of what 
#your system time is.
date = `date_plus`

mkdir -m 777 /glftpd/site/incoming/$date
ln -sf incoming/$date today
cp -df today /glftpd/site
rm -f today

#This will create a 'today' link as follows.
#/glftpd/site/today -> incoming/NEW_DATE
