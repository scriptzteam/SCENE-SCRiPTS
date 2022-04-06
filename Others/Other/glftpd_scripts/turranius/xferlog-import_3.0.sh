#!/bin/bash
VER=3.0

#----------------------------------------------------------#
#                                                          #
# This script is used to import your xferlog into a mysql  #
# database so you can do other fun stuff with it.          #
#                                                          #
# Only tested on glftpd 2.
#                                                          #
#-[ Setup ]------------------------------------------------#
#                                                          #
# * Setup the database and table to something like this:   #
#
# 
#----------------------------------------------------------#
 
## Path to mysql binary. Leave as "mysql" if in path.
SQLBIN="mysql"

## Hostname of MySQL server. Try localhost if 127.0.0.1 gives you problems.
SQLHOST="localhost"

## MySQL user.
SQLUSER="root"

## MySQL users password.
SQLPASS="YourPassWord"

## Database to use.
SQLDB="transfers"

## Table to use.
SQLTB="transfers"

## Path to current xferlog.
xferlog=/glftpd/ftp-data/logs/xferlog

## Path where it will be stored instead.
archive=/glftpd/ftp-data/logs/xferlog.archived

## Lockfile to use. 
lockfile=/tmp/xferlog-import.lock

## Temporary path to store stuff. Make sure it exists.
tmp=/glftpd/tmp

#--[ Script Start ]----------------------------------------------------#

SQL="$SQLBIN -u $SQLUSER -p"$SQLPASS" -h $SQLHOST -D $SQLDB -N -s -e"

if [ "$1" = "debug" -o "$1" = "test" ]; then
  DEBUG="TRUE"
fi
proc_debug() {
  if [ "$DEBUG" = "TRUE" ]; then
    echo "$*"
  fi
}

if [ -e "$lockfile" ]; then
  if [ "`find \"$lockfile\" -type f -mmin -60`" ]; then
    echo "Lockfile $lockfile exists and is not 60 minutes old yet. Quitting."
    exit 0
  else
    echo "Lockfile exists, but its older then 60 minutes. Removing lockfile."
    rm -f "$LOCKFILE"
  fi
fi

if [ ! -r "$xferlog" ]; then
  proc_debug "Cant read xferlog. Quitting."
  exit 1
fi

proc_sqlconnecttest() {
  sqldata="`$SQL "show table status" | tr -s '\t' '^' | cut -d '^' -f1`"
  if [ -z "$sqldata" ]; then
    unset ERRORLEVEL
    echo "Mysql error. Check server"
    exit 0
  fi
}

touch $lockfile

proc_sqlconnecttest

mv -f $xferlog $tmp/xferlog.processing

cat $tmp/xferlog.processing | tr ' ' '\t' | tr -s '\t' | tr '?' ' ' > $tmp/xferlog.processing.sort

$SQL "load data infile \"$tmp/xferlog.processing.sort\" INTO TABLE $SQLTB"

cat $tmp/xferlog.processing >> $archive

rm -f $tmp/xferlog.processing
rm -f $tmp/xferlog.processing.sort
rm -f $lockfile
exit 0
