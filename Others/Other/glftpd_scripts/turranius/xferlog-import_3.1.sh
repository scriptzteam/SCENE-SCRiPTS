#!/bin/bash
VER=3.1

#----------------------------------------------------------#
#                                                          #
# This script is used to import your xferlog into a mysql  #
# database so you can do other fun stuff with it.          #
#                                                          #
# Only tested on glftpd 2.                                 #
# 3.1 Fixed to work... better? Now uses a TAB seperator    #
#     and also specifies the fieldnames to insert into.    #
#     3.0 gave me errors on newer MariaDBs without this.   #
#     Also fixed/renamed "transfefype" to "transfertype"   #
#     so if you're upgrading, take that into account!      #
#                                                          #
#-[ Setup ]------------------------------------------------#
#                                                          #
# * Setup the database and table to something like this:   #
#
# CREATE TABLE `transfers` (
#   `day` text,
#   `month` text,
#   `daynum` text,
#   `time` time DEFAULT NULL,
#   `year` year(4) DEFAULT NULL,
#   `transfertime` bigint(20) DEFAULT NULL,
#   `ip` text,
#   `bytes` bigint(20) DEFAULT NULL,
#   `path` text,
#   `transfertype` text,
#   `underscore` text,
#   `direction` text,
#   `r` text,
#   `FTPuser` text,
#   `FTPgroup` text,
#   `0or1` text,
#   `ident` text,
#   `ID` bigint(20) NOT NULL AUTO_INCREMENT,
#   PRIMARY KEY (`ID`)
# ) ENGINE=MyISAM DEFAULT CHARSET=latin1;
#
#----------------------------------------------------------#

## Path to mysql binary. Leave as "mysql" if in path.
SQLBIN="mysql"

## Hostname of MySQL server. Try localhost if 127.0.0.1 gives you problems.
SQLHOST="localhost"

## MySQL user.
SQLUSER="root"

## MySQL users password.
SQLPASS="YourPassword"

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

proc_sqlconnecttest

touch $lockfile

mv -f $xferlog $tmp/xferlog.processing

cat $tmp/xferlog.processing | tr ' ' '\t' | tr -s '\t' | tr '?' ' ' > $tmp/xferlog.processing.sort
$SQL "load data infile \"$tmp/xferlog.processing.sort\" INTO TABLE $SQLTB fields terminated BY '\t' (day, month, daynum, time, year, transfertime, ip, bytes, path, transfertype, underscore, direction, r, FTPuser, FTPgroup, 0or1, ident)"

cat $tmp/xferlog.processing >> $archive

rm -f $tmp/xferlog.processing
rm -f $tmp/xferlog.processing.sort
rm -f $lockfile
exit 0
