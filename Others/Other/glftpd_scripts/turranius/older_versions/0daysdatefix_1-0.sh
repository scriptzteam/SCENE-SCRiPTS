#!/bin/bash
## Version 1.0 by Turranius
## Change the CD path below to the path of your 0DAYS
## If you have folders you wish to exclude, add them below, | separated.

cd /glftpd/site/0DAYS
EXCLUDE=GROUPS|!Today|!Yesterday


today="$(date +%m%e)"

for i in `ls -f -A | /bin/egrep -v $EXCLUDE`
do
  if [ "$i" != "$today" ]; then
    echo $i
    touch $i -t $i"0000"
  fi
done  