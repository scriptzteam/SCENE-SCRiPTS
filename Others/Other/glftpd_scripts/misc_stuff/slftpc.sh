#!/bin/bash

# slftp-cleaner 20161204 slv
# keeps slftp dir nice and clean, most useful in cron

SLDIR="/home/user/slFtp"

# disable/enable [0/1] cleaning logs, backups and db
# you have to enable one or more options first for the script to work :)

CLEAN_LOGS="1"			# truncate slftp.log, compress and del oldest
CLEAN_BACKUPS="1"		# compress and delete oldest backups
CLEAN_DB="1"			# clean hit table in stats.db (for !statsites)

DISK_NEED="51200" 		# need 50MB free to compress files, else skip
LOG_MAXSIZE="10240"		# log file may not exceed 10MB filesize
LOG_MAXFILES="10"		# keep 10 log files
BKP_DIR="backup"
BKP_MAXFILES="5"		# keep 5 backup files
DB_MAXSIZE="102400"		# db may not exceed 100MB filesize
DB_KEEP="1 year ago"		# delete db records older than 1 year

DATE=$( date +%Y-%m-%d )	# dont delete today/yesterdays files
DATEAGO=$( date --date="1 day ago" +%Y-%m-%d )
DISK_AVAIL=$( df -k $SLDIR | tail -1 | awk '{ print $4 }' )

if [[ "$1" != "" && "$1" != "DEBUG" ]]; then
  printf "slftp-cleaner\n\n"
  printf "SLDIR=\"%s\"\nCLEAN_LOGS=%s CLEAN_BACKUPS=%s CLEAN_DB=%s\n\n" "$SLDIR" "$CLEAN_LOGS" "$CLEAN_BACKUPS" "$CLEAN_DB"
  printf "run %s without arguments to start\n\n" "$(basename $0)"
fi
if [ "$CLEAN_LOGS" = "1" ]; then
LOG_DATE=$( date +%Y%m%d%H%M )
  for i in $SLDIR/{slftp,precatcher}.log; do
     if (( "$( du -k $i | awk '{ print $1 }' )" > "$LOG_MAXSIZE" )); then
       cp $i ${i}_${LOG_DATE} && truncate -c -s 0 $i
     fi
  done
  LOG_NRFILES="$( ls -1 $SLDIR | grep -E slftp.log_[0-9]{12} | wc -l )"
  LOG_OLDEST=$( ls -1t $SLDIR | grep -E slftp.log_[0-9]{12} | tail -1 )
  COUNT=0
  while [ "$LOG_NRFILES" -gt "$LOG_MAXFILES" ]; do
    # make sure we never delete more than 3 files
    if (( "$COUNT" > "3" )); then
      break 
    fi
    if [ "$1" = "DEBUG" ]; then echo "DEBUG: COUNT: $COUNT LOG_NRFILES: $LOG_NRFILES > LOG_MAXFILES: $LOG_MAXFILES LOG_OLDEST: $LOG_OLDEST"; fi
    if [[ ! $LOG_OLDEST =~ ^$SLDIR/$BKP_DIR/slftp.log_($DATE|$DATEAGO) ]]; then
      rm $SLDIR/$LOG_OLDEST
    else
      break
    fi
    LOG_NRFILES="$( ls -1 $SLDIR | grep -E slftp.log_[0-9]{12} | wc -l )"
    LOG_OLDEST=$( ls -1t $SLDIR | grep -E slftp.log_[0-9]{12} | tail -1 )
    COUNT=$(( $COUNT + 1 ))
  done
  for i in $SLDIR/slftp.log_*[0-9][0-9][0-9][0-9]; do
    if [ -s $i ]; then
      if (( "$DISK_AVAIL" > "$DISK_NEED" )); then
         bzip2 $i
      fi
    fi
  done
fi

if [ "$CLEAN_BACKUPS" = "1" ]; then
  BKP_NRFILES="$( ls -1 $SLDIR/$BKP_DIR | grep -E slftp-backup-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}.tar | wc -l )"
  BKP_OLDEST=$( ls -1t $SLDIR/$BKP_DIR | grep -E slftp-backup-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}.tar | tail -1 )
  COUNT=0
  while [ "$BKP_NRFILES" -gt "$BKP_MAXFILES" ]; do
    # make sure we never delete more than 3 files
    if (( "$COUNT" > "3" )); then
      break 
    fi
    if [ "$1" = "DEBUG" ]; then echo "DEBUG: COUNT: $COUNT BKP_NRFILES: $BKP_NRFILES > BKP_MAXFILES: $BKP_MAXFILES BKP_OLDEST: $BKP_OLDEST"; fi
    if [[ ! $BKP_OLDEST =~ ^$SLDIR/$BKP_DIR/slftp-backup-($DATE|$DATEAGO) ]]; then
      rm $SLDIR/$BKP_DIR/$BKP_OLDEST
    else
      break
    fi
    BKP_NRFILES="$( ls -1 $SLDIR/$BKP_DIR | grep -E slftp-backup-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}.tar | wc -l )"
    BKP_OLDEST=$( ls -1t $SLDIR/$BKP_DIR | grep -E slftp-backup-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}.tar | tail -1 )
    COUNT=$(( $COUNT + 1 ))
  done 
  for i in $SLDIR/$BKP_DIR/slftp-backup-[0-9][0-9][0-9][0-9]-*.tar; do
    if [ -f $i ]; then
      if (( "$DISK_AVAIL" > "$DISK_NEED" )); then
         bzip2 $i
      fi
    fi
  done
fi

if [ "$CLEAN_DB" = "1" ]; then
DB_DATE=$( date --date="$DB_KEEP" +%Y-%m-%d )
  if [ -f "$SLDIR/stats.db" ]; then
    if (( "$( du -k $SLDIR/stats.db | awk '{ print $1 }' )" > "$DB_MAXSIZE" )); then
      sqlite3 $SLDIR/stats.db "DELETE FROM hit where ts < '$DB_DATE'"
      sqlite3 $SLDIR/stats.db "VACUUM hit"
    fi
  fi
fi
