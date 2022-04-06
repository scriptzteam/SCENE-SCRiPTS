#!/bin/sh
# spacefree = Name of file.
# /glftpd/bin = Current Path.

# EXIT codes..
# 0 - Good: 
# 1 - Bad:

#exit 0
#Remove ABOVE LINE to enable script.  Know WTF you're doing before doing so!
#Be sure your <site>/dev/null is chmod 666.

# This script is based upon the Barkeep's fspace script cron job.
# Thanks to barkeep for sharing his scripts!
# Modified to fit your screen by godbox 09.29.99

# Minimum amount of free space in megabytes before glFtpD will stop accepting uploads

min_space=300

# Site device

mount=/dev/hda1

    min_space=`expr $min_space \* 1024`
    if [ `df | grep $mount | awk '{print $4}'` -gt "$min_space" ] ; then
       min_space=`expr $min_space / 1024`
       exit 0;
    else
       echo "Not enough free disk space remaining to accept uploads.  Please notify the administrator!"
       exit 1;
    fi
    ;;
*)
exit 0
;;
esac
