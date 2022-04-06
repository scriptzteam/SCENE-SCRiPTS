#!/bin/sh 
#
# little wrapper for audiosorting pre's :) needs awk
#
# add to glftpd.conf:
# cscript	site[:space:]pre	post	/bin/audiosortpre.sh
#
# $1: SITE PRE <rls> <section>

# set todaydir symlink, or "/site/mp3/`date +%m%d`"
#TODAY="/site/mp3-today"
TODAY="/site/mp3/`date +%Y-%m-%d`"

if [ "$1" != "" ]; then
  RLS="`echo "$1"|awk '{ print $3 }'`"
  echo "`date '+%Y-%m-%d %H:%M:%S'` START: 1: $1 T/R: $TODAY/$RLS" >> /ftp-data/logs/audiosortpre.log
  if [ -d "$TODAY/$RLS" ]; then
    echo "`date '+%Y-%m-%d %H:%M:%S'` MATCH: DIR EXISTS!" >> /ftp-data/logs/audiosortpre.log
    #/bin/audiosort "$TODAY/$RLS" >/dev/null 2>&1
    /bin/audiosort "$TODAY/$RLS" >>/ftp-data/logs/audiosortpre.log 2>&1
    echo "`date '+%Y-%m-%d %H:%M:%S'` DONE" >>/ftp-data/logs/audiosortpre.log
  fi
fi
