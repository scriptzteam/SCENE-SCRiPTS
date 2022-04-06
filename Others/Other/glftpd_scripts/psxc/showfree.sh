#!/bin/bash

# showfree v0.1
# -------------
# Made by request (more or less), this script will make a dir, file or echo a
# string into .message, stating how much space is left in the dir.
#
# commands needed in path: bash df grep cat mkdir chmod chown echo
#
# this script should be run by root - if not make sure chown has the sticky
# bit (+s) set. Either config glftpd to run this after every upload, or run
# it as a cronjob, like this:
# */5 * * * * /path/to/script

###############################################################################

# config
#-------

# sectionname:path
sections="MP3:/glftpd/site/MP3 0DAY:/glftpd/site/TODAY"

# temporary dir
temp="/glftpd/temp"

# dir (D), .message (M) or file (F)
type="D"
#type="M"
#type="F"

# owner of the dir/file
ouser=130
ogroup=1000

######

count=0
for folder in $sections; do
 section="`echo $folder | cut -d ':' -f1`"
 pathname="`echo $folder | cut -d ':' -f2`"
 let count=count+1
 if [ -e $pathname ]; then
  free="`df -h $pathname | grep / | { read crap crap crap free crap; echo $free; };`""B"
  if [ -e $temp/psxc-showfree-$count.txt ]; then
    rm -fR `cat $temp/psxc-showfree-$count.txt`
  fi
  string="_""$free"".free.in.""$section""_"
  if [ "$type" = "D" ]; then
   mkdir $pathname/$string
    chmod 666 $pathname/$string
    chown $ouser:$ogroup $pathname/$string
    echo "$pathname/$string" > $temp/psxc-showfree-$count.txt
  elif [ "$type" = "F" ]; then
    touch $pathname/$string
    chmod 666 $pathname/$string
    chown $ouser:$ogroup $pathname/$string
    echo "$pathname/$string" > $temp/psxc-showfree-$count.txt
  else
    echo $string >> $pathname/.message
    chmod 666 $pathname/.message
    chown $ouser:$ogroup $pathname/.message
    echo "$pathname/.message" > $temp/psxc-showfree-$count.txt
  fi
 else
  echo "config error!"
  echo "could not find the path $pathname for section $section"
  echo "skipping this section."
 fi
done
exit 0
