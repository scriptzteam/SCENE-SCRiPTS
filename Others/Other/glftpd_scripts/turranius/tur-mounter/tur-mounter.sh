#!/bin/bash
VER=1.0
#-------------------------------------------------------------------#
#                                                                   #
# Tur-Mounter. A script for removable disks.                        #
#                                                                   #
# Ever had the problem with using, for example, USB disks that they #
# always get new device ID's during bootup? I did, so I made this   #
# script to handle the mounting. Its basically very simple. Each    #
# disk has a small file in its rootdir which decides where it wants #
# to be mounted. In other words, each disk decides for itself where #
# it goes.                                                          #
#                                                                   #
# You may use this script on "normal" disks as well, if for some    #
# reason you do not like /etc/fstab...                              #
#                                                                   #
#-------------------------------------------------------------------#
#                                                                   #
# You need to create a file on each disk, so mount it somewhere so  #
# you can create the file. After finished, you may unmount it again #
#                                                                   #
# The file in its root should be named 'mountpoint' and in it goes  #
# the path to where to mount it.                                    #
#                                                                   #
# This is written as MOUNT_POINT="/destination/dir"                 #
# where /destination/dir is the location you want this disk mounted #
# Example format:                                                   #
# MOUNT_POINT="/mnt/disk55"                                         #
#                                                                   #
# You may also add a custom MOUNT_OPTIONS in this file if you need  #
# a special format for the mount command instead of the default     #
# used in MOUNT_OPTIONS (see below).                                #
# Example format:                                                   #
# MOUNT_OPTIONS="mount -t ext3"                                     #
#                                                                   #
#-------------------------------------------------------------------#
#                                                                   #
# Options are as follows:                                           #
#                                                                   #
# TEMP_MOUNT=             In order to read the mountpoint file, we  #
#                         need to mount the disk somewhere first.   #
#                         This is the location. Make sure the dir   #
#                         exists.                                   #
#                                                                   #
# MOUNT_OPTIONS=          How the mount command will be executed.   #
#                         This is the default used if there is no   #
#                         MOUNT_OPTIONS specified in the mountpoint #
#                         file.                                     #
#                                                                   #
# AVAILABLE_DISKS=        Each device you want to look for the      #
#                         mountpoint in, space seperated. Or, you   #
#                         can, as the example, add one device per   #
#                         newline.                                  #
#                         Now, you can enter each device manually   #
#                         here if you like but there is also a way  #
#                         to let the script detect the devices      #
#                         using fdisk -l. Say you want to mount all #
#                         your /dev/sd* disks. Then type this here: #
#                         ALL:/dev/sd                               #
#                         So, it can look like this:                #
#                         AVAILABLE_DISKS="/dev/hda1 ALL:/dev/sd"   #
#                         Note that you must enter /dev/ or the     #
#                         full starting path to the device or it    #
#                         will not find it in the fdisk -l list.    #
#                                                                   #
#                         It will only affect drives which have the #
#                         /mountpoint file, so dont worry if the    #
#                         ALL list finds other disks.               #
#                                                                   #
#                         Should you want it to find and try ALL    #
#                         disks, just specify ALL:/dev/             #
#                                                                   #
#                         Swap disks are automatically excluded     #
#                         from the ALL list.                        #
#                                                                   #
# DB=                     See extra features at the bottom of       #
#                         the instructions.                         #
#                                                                   #
#                         This is the full path to the database     #
#                         file.                                     #
#                                                                   #
# LOG=                    Save a logfile of mounted disks if this   #
#                         is set. Leave empty to not log.           #
#                                                                   #
# MOUNT_LOG=              If this is set, a file containing the     #
#                         current mount info will be created after  #
#                         each execution of this script.            #
#                         This mountfile will contain all the disks #
#                         and not just the one in AVAILABLE_DISKS.  #
#                         This might be useful if you loose a disk  #
#                         and want to know where it was last        #
#                         mounted.                                  #
#                                                                   #
#-------------------------------------------------------------------#
#                                                                   #
# And thats it. Chmod the script to 700 or something and try        #
# running it. If ok, you can add it to /etc/rc.local so it gets     #
# executed at startup or just run it manually when needed.          #
#                                                                   #
# Needed binaries: cut, df, fdisk, grep, cat, mount, umount         #
# Tested on a Fedora Core 3 system with                             #
# fdisk v2.12a                                                      #
# cut (coreutils) 5.2.1                                             #
# df (coreutils) 5.2.1                                              #
# grep (GNU grep) 2.5.1                                             #
# cat (coreutils) 5.2.1                                             #
# mount/umount mount-2.12a                                          #
#                                                                   #
#-------------------------------------------------------------------#
#                                                                   #
# Some extra features.. Mounting disks this way, if you have a lot  #
# of them, it might be nice to get a status report that all         #
# removable disks really are mounted as they should.                #
#                                                                   #
# This can be accomplished by creating a database of all disks it   #
# mounts so we have something to check against.                     #
#                                                                   #
# To create this list, make sure all your disks are mounted, as it  #
# will overwrite the DB on each execution, then run this script     #
# with 'newdb' as first argument ( ./tur-mounter.sh newdb )         #
#                                                                   #
# Now, whenever you want to verify that all disks are mounted as    #
# they should be, run this script with 'check' as first argument.   #
# ( ./tur-mounter.sh check )                                        #
#                                                                   #
#-------------------------------------------------------------------#

TEMP_MOUNT=/mnt/tempmount

MOUNT_OPTIONS="mount -t auto"

AVAILABLE_DISKS="
/dev/sda1
/dev/sdb1
/dev/sdc1
/dev/sdd1
/dev/sde1
/dev/sdf1
/dev/sdg1
/dev/sdh1
/dev/sdi1
/dev/sdj1
/dev/sdk1
/dev/sdl1
/dev/sdm1
/dev/sdn1
"

AVAILABLE_DISKS="ALL:/dev/sd"

DB=/tmp/mount.db

LOG=/var/log/tur-mounter.log

MOUNT_LOG=/var/log/mountlog.log

#-[ Script Start ]--------------------------------------------------#

if [ ! -e "$DB" ]; then
  echo "First run it seems. Creating $DB file."
  touch "$DB"
  chmod 700 "$DB"
fi

proc_log() {
  if [ "$LOG" ]; then
    echo `date "+%a %b %e %T %Y"` \"$*\" >> $LOG
  fi
}

if [ "$1" = "check" ]; then
  num_ok=0; num_bad=0
  for rawdata in `cat $DB | tr ':' ' '`; do
    dev="`echo "$rawdata" | cut -d '~' -f1`"
    dst="`echo "$rawdata" | cut -d '~' -f2`"

    FOUND="NO"
    for dfoutput in `df | cut -d ' ' -f1 | grep -v "Filesystem"`; do
      if [ "$dfoutput" = "$dev" ]; then
        FOUND="YES"
        num_ok=$[$num_ok+1]
        break
      fi
    done

    if [ "$FOUND" = "NO" ]; then
      echo "Warning: Device $dev does not seem mounted."
      echo "         Last know location: $dst"
      echo ""
      FAIL="TRUE"
      num_bad=$[$num_bad+1]
    fi

  done
  if [ "$FAIL" != "TRUE" ]; then
    echo "All $num_ok disks seems mounted OK according to $DB"
  else
    num_tot=$[$num_ok+$num_bad]
    echo "Not all $num_tot disks are ok. $num_bad are bad and $num_ok are good."
    echo "NOTE: If the bad disks are removable drives, you can disregard"
    echo "      from the \"Last known location\" information."
  fi
  exit 0
fi

if [ ! -d "$TEMP_MOUNT" ]; then
  echo "Error TEMP_MOUNT ($TEMP_MOUNT) does not exist. Quitting."
  exit 1
fi

if [ "`df | grep "$TEMP_MOUNT"`" ]; then
  echo "Notice: $TEMP_MOUNT already mounted. Unmounting it."
  umount -lf "$TEMP_MOUNT"
  if [ "`df | grep "$TEMP_MOUNT"`" ]; then
    echo "Error: Seems I could not unmount $TEMP_MOUNT. Quitting."
    exit 1
  fi
fi

if [ "$1" = "newdb" ]; then
  echo "Clearing $DB.."
  echo "" > $DB
fi

unset new_disks
for disk in $AVAILABLE_DISKS; do
  if [ "`echo "$disk" | cut -d ':' -f1`" = "ALL" ]; then
    got_all="true"
    new_dev="`echo "$disk" | cut -d ':' -f2`"
    if [ -z "`fdisk -l | grep "^$new_dev" | grep -v " swap$"`" ]; then
      echo "Error. No devices starting with $new_dev found in fdisk -l list."
    else
      for each in `fdisk -l | grep "^$new_dev" | grep -v " swap$" | cut -d ' ' -f1`; do
        if [ -z "$new_disks" ]; then
          new_disks="$each"
        else
          new_disks="$new_disks $each"
        fi
      done
    fi
  else
    if [ -z "$new_disks" ]; then
      new_disks="$disk"
    else
      new_disks="$new_disks $disk"
    fi
  fi
done

if [ "$got_all" = "true" ]; then
  echo "Replacing AVAILABLE_DISKS ($AVAILABLE_DISKS) with: \"$new_disks\""
  AVAILABLE_DISKS="$new_disks"
  unset new_disks; unset got_all
fi

for disk in $AVAILABLE_DISKS; do
  unset mount_o
  SKIP="NO"

  ## Restore mount options if modified.
  if [ "$MOUNT_OPTIONS_ORG" ]; then
    MOUNT_OPTIONS="$MOUNT_OPTIONS_ORG"
    unset MOUNT_OPTIONS_ORG
  fi

  for dfoutput in `df | cut -d ' ' -f1 | grep -v "Filesystem"`; do
    if [ "$dfoutput" = "$disk" ]; then
      echo "Skipping $disk as its already mounted."
      SKIP="YES"
      if [ "$1" = "newdb" ]; then
        echo "${disk}~UNKNOWN(Not_an_error)" | tr ' ' ':' >> "$DB"
      fi
    fi
  done

  if [ "$SKIP" = "NO" ]; then
    if [ -z "`fdisk -l | grep "$disk"`" ]; then  
      echo "Device $disk does not exist according to fdisk -l. Skipping."
      proc_log "Device $disk does not exist according to fdisk -l. Skipping."
    else
      $MOUNT_OPTIONS $disk $TEMP_MOUNT
      if [ -z "`df $TEMP_MOUNT`" ]; then
        echo "Error mounting $disk to $TEMP_MOUNT. Skipping."
        proc_log "Error mounting $disk to $TEMP_MOUNT for some reason. Skipping."
      else
        if [ ! -e "$TEMP_MOUNT/mountpoint" ]; then
          echo "Notice: $TEMP_MOUNT/mountpoint does not exist on $disk. Skipping."
          proc_log "Notice: $TEMP_MOUNT/mountpoint does not exist on $disk. Skipping."
          umount $TEMP_MOUNT
        else
          ## Read the file... Set old MOUNT_OPTIONS first so its saved..
          MOUNT_OPTIONS_ORG="$MOUNT_OPTIONS"
          . $TEMP_MOUNT/mountpoint

          if [ -z "$MOUNT_POINT" ]; then
            echo "Error: Did not find any MOUNT_POINT in file \"mountpoint\" on $disk"
            proc_log "Error: Did not find any MOUNT_POINT in file \"mountpoint\" on $disk"
          else
            if [ ! -d "$MOUNT_POINT" ]; then
              echo "Error: Destination for $disk does not exist ($MOUNT_POINT). Skipping."
              proc_log "Error: Destination for $disk does not exist ($MOUNT_POINT). Skipping."
              umount $TEMP_MOUNT
            else
              umount $TEMP_MOUNT
              if [ "`df | grep " ${MOUNT_POINT}$"`" ]; then
                echo "Warning! Already have something else mounted on ${MOUNT_POINT}. Skipping $disk"
                proc_log "Warning! Already have something else mounted on ${MOUNT_POINT}. Skipping $disk"
              else
                $MOUNT_OPTIONS ${disk} ${MOUNT_POINT}
                if [ -z "`df ${MOUNT_POINT}`" ]; then
                  echo "Error: Could not mount $disk to ${MOUNT_POINT}."
                  proc_log "Error: Could not mount $disk to ${MOUNT_POINT}."
                else
                  echo "Success: Mounted $disk to ${MOUNT_POINT}."
                  proc_log "Success: Mounted $disk to ${MOUNT_POINT}."
                  if [ "$1" = "newdb" ]; then
                    echo "${disk}~${MOUNT_POINT}" | tr ' ' ':' >> "$DB"
                  fi
                fi
              fi
            fi
          fi
        fi
      fi
    fi
  fi
done

if [ "$MOUNT_LOG" ]; then
  datenow="`date +%Y"-"%m"-"%d" "%H":"%M":"%S`"
  echo "" >> "$MOUNT_LOG"
  echo "----------------------------------------------------------" >> "$MOUNT_LOG"
  echo "" >> "$MOUNT_LOG"
  echo "Logfile created at $datenow" >> "$MOUNT_LOG"
  echo "" >> "$MOUNT_LOG"
  mount | grep -v "^none" >> "$MOUNT_LOG"
fi

exit 0
