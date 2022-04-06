#!/bin/bash
##--- don't change anything in this file ---##
credits=`cat /jail/glftpd/ftp-data/users/$1 | grep -e "^CREDITS" | cut -d ' ' -f2`
ratio=`cat /jail/glftpd/ftp-data/users/$1 | grep -e "^RATIO" | cut -d ' ' -f2`
echo "$credits $ratio"
