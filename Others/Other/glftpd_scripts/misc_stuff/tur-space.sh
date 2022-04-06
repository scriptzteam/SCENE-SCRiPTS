#!/bin/bash
VER=1.1

## Set where tur-space.conf is located here.
config=/glftpd/bin/tur-space.conf

###############################################################################
# No changes should be needed under here.                                     #
###############################################################################

## Verify config file
if [ -z "$config" ]; then
  echo "Error. You must specify the location of the config at the top of tur-space.sh."
  exit 1
fi

if [ ! -e "$config" ]; then
  echo "Error. The configuration can not be read from $config - Quitting."
  echo "Make sure you specify its location in tur-space.sh"
  exit 1
fi

proc_debug() {
  if [ "$DEBUG" = "TRUE" ]; then
    echo "$*"
  fi
}

proc_log() {
  if [ "$LOGFILE" ]; then
    echo `$DATE_BINARY "+%a %b %e %T %Y"` SPACE: \"$*\" >> $LOGFILE
  fi
}

proc_announce() {
  ANNOUNCE_TEXT="$1"
  if [ "$GLLOG" ] && [ "$DEBUG" != "TRUE" ]; then
    if [ ! -w "$GLLOG" ]; then
      proc_log "Error. Can not write to $GLLOG - Check paths and perms."
      proc_debug "Error. Can not write to $GLLOG - Check paths and perms."
    else
      echo `$DATE_BINARY "+%a %b %e %T %Y"` $ANNOUNCE_TEXT >> $GLLOG
    fi
  fi
}

proc_get_free_space() {
  trigger_device_check="$1"
  unset free_space

#  proc_log "In proc_get_free_space for $trigger_device_check"

  if [ -z "$trigger_device_check" ]; then
    proc_debug "Error. Did not get a device to check free space from ($1)."
    proc_log "Error. Did not get a device to check free space from ($1)."
    exit 1
  fi

  free_space="`df -Pm | grep "$trigger_device_check" | tr -s ' ' | cut -d ' ' -f4`"

#  if [ "$MODE" = "ARCHIVE" ]; then
#    proc_log "Got free space on $trigger_device_check : $free_space MB"
#  fi

  if [ -z "$free_space" ]; then
    if [ "$MODE" = "ARCHIVE" ]; then
      proc_debug "Error. Could not calculate free space for archive: $trigger_device_check - Skipping."
      proc_log "Error. Could not calculate free space for archive: $trigger_device_check - Skipping."
    else
      proc_debug "Error. Could not calculate free space for incoming: $trigger_device_check - Aborting."
      proc_log "Error. Could not calculate free space for incoming: $trigger_device_check - Aborting."
      proc_exit
    fi
  else
    if [ $[$free_space-$free_space] != "0" ]; then
      proc_debug "Error. Something wrong when checking free space for $trigger_device_check. Got: $free_space"
      proc_log "Error. Something wrong when checking free space for $trigger_device_check. Got: $free_space"
      proc_exit
    fi
  fi
}

proc_get_release_size() {
  check_release_size="`$DU_BINARY -csm "$source_release_path/$source_release" | tail -n1 | cut -f1`"
}

proc_find_oldest_dir() {

  unset oldest_dir_raw


  source_dir="$1"
  source_name="$2"
  source_device="$3"
  source_dated="$4"

  cd $source_dir

  if [ "$source_dated" != "DATED" ]; then
    unset DATED_
    oldest_dir_raw="`$TULS | grep "^d" | egrep -v "$IGNORES" | tr '^' ' ' | sort -k6 -n -r | tail -n1`"
    oldest_dir="`echo "$oldest_dir_raw" | awk -F"::::" '{print $4}'`"
    oldest_date="`echo "$oldest_dir_raw" | awk -F"::::" '{print $5}' | cut -d ' ' -f6`"
  else

    if [ "`$TULS | grep "^d" | egrep -v "$IGNORES" | tr -s ':' ' ' | cut -d ' ' -f4 | grep "^12"`" ]; then
      oldest_dir_raw="`$TULS | grep "^d" | egrep -v "$IGNORES|^.*::::.*::::.*::::01|^.*::::.*::::.*::::02|^.*::::.*::::.*::::03|^.*::::.*::::.*::::04|^.*::::.*::::.*::::05|^.*::::.*::::.*::::06" | tr -s ':' ' ' | sort -k4 -n -r | tail -n1`"
    else
      oldest_dir_raw="`$TULS | grep "^d" | egrep -v "$IGNORES" | tr -s ':' ' ' | sort -k4 -n -r | tail -n1`"
    fi
    oldest_dir="`echo "$oldest_dir_raw" | cut -d ' ' -f4`"
    oldest_date="`echo "$oldest_dir_raw" | cut -d ' ' -f7 | cut -d '^' -f3`"
    DATED_="(dated dir)"
  fi

  if [ -z "$oldest_dir_raw" ]; then

    if [ "$MODE" = "ARCHIVE" ]; then
      ## If we are in the archive and dont find anything to del, just quit.
      proc_debug "Warning: Did not find any dir to delete in $source_dir ($source_name). Aborting."
      proc_debug "If this is on the same partition as some other section, manually delete some releases"
      proc_debug "from the other archive to make space in this one."
      proc_log "Warning: Did not find any dir to delete in $source_dir ($source_name). Aborting. If this is the same partition as some other section, manually delete som releases from the other archive to make space in this one."
      exit 1
    else
      ## If we are in the incoming sections and dont find anything, just skip this section for now.
      proc_debug "Warning: Did not find any dir to move/delete in $source_dir ($source_name). Skipping."
      proc_log "Warning: Did not find any dir to move/delete in $source_dir ($source_name). Skipping."
      if [ "$last_source_dir" = "$source_dir" ]; then
        ## If no other incoming sections went ok, quit here or we'll get an endless loop.
        proc_debug "Error. No dirs found at all to process in any incoming section. Quitting."
        proc_log "Error. No dirs found at all to process in any incoming section. Quitting."
        exit 1
      fi
    fi

  else
    if [ "$DEBUG" = "TRUE" ]; then
      DEBUG_TIME="`$DATE_BINARY -d "1970-01-01 $oldest_date sec" +%F" "%T`"
    fi

    source_release_path="$source_dir"
    source_release="$oldest_dir"
    proc_get_release_size

    proc_debug "Oldest dir in $source_dir ($source_name) seems to be $oldest_dir ($check_release_size MB) <- $DEBUG_TIME"

    if [ "${source_dir}" ] && [ "${source_name}" ] && [ "${oldest_dir}" ] && [ "${oldest_date}" ] && [ "${check_release_size}" ] && [ "${source_device}" ]; then
      echo "${source_dir} ${source_name} ${oldest_dir} ${oldest_date} ${check_release_size} ${source_device}" >> "$TMP/oldest_dir.tmp"
    else
      proc_log "-----------------------------------------------"
      proc_log "Error. Missing info when checking oldest dir:"
      proc_log "source_dir:${source_dir}"
      proc_log "source_name:${source_name}"
      proc_log "oldest_dir:${oldest_dir}"
      proc_log "oldest_data:${oldest_date}"
      proc_log "check_release_size:${check_release_size}"
      proc_log "source_device:${source_device}"
      proc_log "-----------------------------------------------"
      exit 1
    fi
  fi
}

proc_find_destination_old() {
  destinations="$*"

  if [ -e "$TMP/oldest_dir.tmp" ]; then
    rm -f "$TMP/oldest_dir.tmp"
  fi

  for destination in $destinations; do

    dest_device="`echo "$destination" | cut -d ':' -f1`"
    dest_path="`echo "$destination" | cut -d ':' -f2`"
    if [ -z "`echo "$mount_errors" | grep " $dest_device "`" ]; then
      unset source_dated
      MODE="ARCHIVE"
      proc_find_oldest_dir $dest_path $source_name $dest_device
    fi
  done

  if [ ! -e "$TMP/oldest_dir.tmp" ]; then
    proc_debug "Error. Could not find oldest dir to remove from $destinations."
    proc_log "Error. Could not find oldest dir to remove from $destinations."
  else
    source_release_raw="`cat "$TMP/oldest_dir.tmp" | sort -k4 -n -r | tail -n1`"
    source_release_path="`echo "$source_release_raw" | cut -d ' ' -f1`"
    source_name="`echo "$source_release_raw" | cut -d ' ' -f2`"
    source_release="`echo "$source_release_raw" | cut -d ' ' -f3`"
    source_time="`echo "$source_release_raw" | cut -d ' ' -f4`"
    release_size="`echo "$source_release_raw" | cut -d ' ' -f5`"
    source_device="`echo "$source_release_raw" | cut -d ' ' -f6`"

    if [ -z "${source_release_raw}" ] || [ -z "${source_release_path}" ] || [ -z "${source_name}" ] || [ -z "${source_release}" ] || [ -z "${source_time}" ] || [ -z "${release_size}" ] || [ -z "${source_device}" ]; then
      proc_log "Error in proc_find_destination_old"
      proc_log "Found $TMP/oldest_dir.tmp but could not read all from it:"
      proc_log "source_release_raw:${source_release_raw}"
      proc_log "source_release_path:${source_release_path}"
      proc_log "source_name:${source_name}"
      proc_log "source_release:${source_release}"
      proc_log "source_time:${source_time}"
      proc_log "release_size:${release_size}"
      proc_log "source_device:${source_device}"
      proc_log "--------------------------------------"
      exit 1
    fi

    proc_delete $source_release_path $source_release $source_size

    if [ -z "$looping_to_find_space" ]; then
      looping_to_find_space="true"
      loop_count=0

      ## Check free space on device now..
      proc_get_free_space $source_device

      destinations="$source_device:$source_release_path"

      while [ "$source_release_size" -ge "$free_space" ]; do

proc_log "Starting loop. source_release_size: $source_release_size - free_space: $free_space - $destinations"

        ## Make sure we dont del more then $MAX_LOOP things.
        loop_count=$[$loop_count+1]
        if [ "$loop_count" -ge "$MAX_LOOP" ]; then
          proc_debug "Warning: Deleted more then $MAX_LOOP things from $source_release_path - Safety abort!"
          proc_log "Warning: Deleted more then $MAX_LOOP things from $source_release_path - Safety abort!"
          exit 1
        fi

#        if [ "$DEBUG" != "TRUE" ]; then
#          proc_log "Running proc_get_free_space on $source_device"
#          proc_get_free_space $source_device
#          proc_debug "Space on $source_device: $free_space MB. Need $release_size !!"
#        fi

        if [ "$DEBUG" = "TRUE" ]; then IGNORES="$IGNORES|::$source_release::"; fi

        MODE="ARCHIVE"
proc_log  "Running proc_find_oldest_dir $source_release_path $source_name $source_device"
        proc_find_oldest_dir $source_release_path $source_name $source_device
proc_log "proc_find_oldest_dir returned $oldest_dir_raw"

        if [ -z "$oldest_dir_raw" ]; then
          proc_debug "Error. Nothing to delete in $source_release_path on $source_device."
          proc_log "Error. Nothing to delete in $source_release_path on $source_device."
          break
        else

          source_release="`echo "$oldest_dir_raw" | awk -F"::::" '{print $4}'`"
          proc_get_release_size $source_release_path $source_release
          proc_delete $source_release_path $source_release $check_release_size

          if [ "$DEBUG" = "TRUE" ]; then
            echo "Get free space again on $source_device (fake. $free_space + $check_release_size (for real: check $source_device)"
            free_space="`echo "$free_space + $check_release_size" | bc -l | cut -d '.' -f1 | tr -d ' '`"
          else


#            proc_log "Running proc_get_free_space AGAIN on $source_device. ( $destinations ) loop - $source_device"
            proc_get_free_space $source_device
#            proc_log "done"
          fi

        fi
      done

      if [ "$DEBUG" = "TRUE" ]; then
        proc_debug "Space needed ($release_size) fixed. Would have moved the original release now."
        proc_log "Space needed ($release_size) fixed. Would have moved the original release now."
      fi

    fi
  fi
}

proc_delete() {

  source_release_path="$1"
  source_release="$2"
  source_size="$3"

  if [ "$mount_error" = "true" ]; then
    no_delete=true
    proc_log "WARNING. Will not delete ${source_release_path}/${source_release} since we seem to have mount errors."
  else

    if [ ! -d "${source_release_path}/${source_release}" ]; then
      proc_debug "Error. Could not find ${source_release_path}/${source_release} to delete !"
      proc_log "Error. Could not find ${source_release_path}/${source_release} to delete !"
    else

      proc_get_release_size

      proc_log "Freeing ${check_release_size} MB from ${source_release_path} by deleting ${source_release}"
      proc_announce "TSD: \"${source_release}\" \"${check_release_size}\" \"${source_release_path}\" \"${source_name}\""

      if [ "$SECURITY_PATH" ]; then
        if [ -z "`echo "${source_release_path}/${source_release}" | grep "${SECURITY_PATH}"`" ]; then
          proc_log "Error: Tried to delete \"${source_release_path}/${source_release}\" but that is outside the SECURITY_PATH (${SECURITY_PATH}) - Aborting !"
          exit 1
        fi
      fi

      if [ "$DEBUG" = "TRUE" ]; then
        proc_debug "would have executed rm -rf \"${source_release_path}/${source_release}\""
      else
        rm -rf "${source_release_path}/${source_release}"
        if [ -d "${source_release_path}/${source_release}" ]; then
          proc_log "Error. Deleted ${source_release_path}/${source_release} but its still there! Quitting."
          exit 1
        fi
      fi
    fi

  fi
  if [ "$DEBUG" = "TRUE" ]; then IGNORES="$IGNORES|::$source_release::"; fi
}

proc_move() {
  if [ "`echo "$last_moved_release" | cut -d ':' -f1`" = "$source_release" ]; then
    last_moved_path="`echo "$last_moved_release" | cut -d ':' -f2`"
    last_moved_release="`echo "$last_moved_release" | cut -d ':' -f1`"
    proc_debug "Error: $last_moved_path/$last_moved_release was moved just before. Quitting."
    proc_log "Error: $last_moved_path/$last_moved_release was moved just before. Quitting."

    proc_exit
  fi

  source_release_path="$1"
  source_release="$2"
  dest_release_path="$3"
  source_size="$4"
  most_size="$5"

  if [ "$SECURITY_PATH" ]; then
    if [ -z "`echo "${source_release_path}/${source_release}" | grep "${SECURITY_PATH}"`" ]; then
      proc_log "Error: Tried to move \"${source_release_path}/${source_release}\" but that is outside the SECURITY_PATH (${SECURITY_PATH}) - Aborting !"
      exit 1
    else
      proc_log "Test: \"${source_release_path}/${source_release}\" seems to be within ${SECURITY_PATH}"
    fi

    if [ -z "`echo "${dest_release_path}" | grep "${SECURITY_PATH}"`" ]; then
      proc_log "Error: Tried to move TO \"${dest_release_path}\" but that is outside the SECURITY_PATH (${SECURITY_PATH}) - Aborting !"
      exit 1
    fi
  fi

  proc_log "$trigger_device at $trigger_device_free MB. Freeing $source_size MB by moving $source_release_path/$source_release -> $dest_release_path ($most_size MB free)."
  proc_announce "TSM: \"$source_release\" \"$source_size\" \"$trigger_device_free\" \"$dest_release_path\" \"$free_space\" \"$source_name\""

  if [ "$DEBUG" = "TRUE" ]; then
    proc_debug "Would have moved ${source_release_path}/${source_release} (${source_size} MB) to ${dest_release_path}"
  else

    if [ -d "${dest_release_path}/${source_release}" ]; then
      proc_log "WARNING. ${dest_release_path}/${source_release} already exists. Probably due to a bad copy earlier."
      proc_log "Wiping it out before I start the copy."
      rm -rf "${dest_release_path}/${source_release}"
    fi

    rsync_retries=0
    while true; do
        rsync $RSYNC_OPTIONS "${source_release_path}/${source_release}" "${dest_release_path}" && break
        if [[ $rsync_retries -eq $MAX_RSYNC_RETRIES ]]; then
            proc_log "Error: Rsync retries exceeded while copying $source_release from $source_release_path into $dest_release_path."
            proc_debug "Error: Rsync retries exceeded while copying $source_release from $source_release_path into $dest_release_path."
            proc_debug "Quitting and you should check why this happened on a simple copy."
            sleep 5
            proc_exit
        fi
        rsync_retries=$((rsync_retries + 1))
    done

    ## Verification no longer required when using rsync
    #num_files_source="`ls -1 "$source_release_path/$source_release" | wc -l | tr -d ' '`"
    #num_files_dest="`ls -1 "$dest_release_path/$source_release" | wc -l | tr -d ' '`"
    #if [ "$num_files_source" != "$num_files_dest" ]; then
    #  sleep 5
    #  num_files_source="`ls -1 "$source_release_path/$source_release" | wc -l | tr -d ' '`"
    #  num_files_dest="`ls -1 "$dest_release_path/$source_release" | wc -l | tr -d ' '`"
    #  if [ "$num_files_source" != "$num_files_dest" ]; then
    #    proc_log "Error: After copying $source_release from $source_release_path into $dest_release_path, the number of files does not match up. Source:$num_files_source Dest:$num_files_dest"
    #    proc_debug "Error. After copying $source_release from $source_release_path into $dest_release_path, the number of files does not match up. Source:$num_files_source Dest:$num_files_dest"
    #    proc_debug "Quitting and you should check why this happened on a simple copy."
    #    proc_exit
    #  fi
    #else

      ## Copy verified. Remove releases from original location.
      rm -rf "$source_release_path/$source_release"
      if [ "$CHOWN_OPTIONS" ]; then
        chown $CHOWN_OPTIONS "$dest_release_path/$source_release"
      fi
      if [ "$CHMOD_OPTIONS" ]; then
        chmod $CHMOD_OPTIONS "$dest_release_path/$source_release"
      fi

    #fi
  fi

  if [ "$DEBUG" = "TRUE" ]; then IGNORES="$IGNORES|::$source_release::"; fi

  last_moved_release="$source_release:$source_release_path"
}

proc_find_most_space_free() {
  destinations="$*"

  most_size=0; unset most_size_device
  for destination in `echo $destinations`; do
    dest_device="`echo "$destination" | cut -d ':' -f1`"
    dest_path="`echo "$destination" | cut -d ':' -f2`"

    proc_get_free_space $dest_device
    if [ -z "$free_space" ]; then
      proc_debug "Error. $dest_device dosnt seem mounted.. skipping that as destination."
      mount_error=true
      mount_errors=" $mount_errors $dest_device "
    elif [ "$free_space" -gt "$most_size" ]; then
      most_size="$free_space"
      most_size_device="$dest_device"
      most_size_path="$dest_path"
    elif [ "$free_space" -ge "$most_size" ]; then
      if [ -z "$most_size_device" ]; then
        most_size="$free_space"
        most_size_device="$dest_device"
        most_size_path="$dest_path"
      fi
    fi

  done
  if [ -z "$most_size_device" ]; then
    proc_debug "Error. Seems I could not get a destination for $dest_device - Skipping."
  else

## FAKE
#most_size="500"

    proc_debug "Most free space seems to be in $most_size_path on $most_size_device ($most_size MB free)."
    ## Check if the release will fit there.
    release_size="`$DU_BINARY -csm "$source_release_path/$source_release" | tail -n1 | cut -f1`"
    source_release_size="$release_size"
    if [ -z "$release_size" ]; then
      proc_debug "Error. Couldnt get the size for $source_release - Skipping."
    else
      if [ "$release_size" -ge "$most_size" ]; then
        proc_debug "Seems $source_release ($release_size MB) would not fit in $most_size_path ($most_size MB free)"
        proc_log "$source_release ($release_size MB) would not fit in $most_size_path ($most_size MB)."

        if [ "$DEBUG" = "TRUE" ]; then IGNORES="$IGNORES|::$source_release::"; fi

        unset looping_to_find_space

        proc_find_destination_old $destinations
      else
        proc_move $source_release_path $source_release $most_size_path $release_size $most_size
      fi
    fi

  fi
}

proc_exit() {
  rm -f "$TMP/tur-space.lock"
  exit 0
}

proc_find_destination() {
  unset destination_found; unset destinations
  source_release_path="$1"
  source_release="$2"
  source_name="$3"

  proc_debug "Checking destinations for $source_release from $source_name in $source_release_path"

  for destination_dirs in `grep "^ARC$source_name=" $config`; do
    destination_found=TRUE
    dest_device="`echo "$destination_dirs" | cut -d '=' -f2 | cut -d ':' -f1`"
    dest_path="`echo "$destination_dirs" | cut -d ':' -f2`"
    proc_debug "Found destination: $dest_path on device $dest_device"
    destinations="$destinations $dest_device:$dest_path"
  done

  if [ -z "$destination_found" ]; then
    proc_debug "NO destination dir found. Deleting $source_release_path/$source_release."
    proc_delete $source_release_path $source_release
  else
    MODE="ARCHIVE"
    proc_find_most_space_free $destinations
  fi
}

proc_find_sourcedirs() {
  # trigger_device_check="$1"

  if [ -e "$TMP/oldest_dir.tmp" ]; then
    rm -f "$TMP/oldest_dir.tmp"
  fi
  for incoming_sections in `grep "^INC" $config | grep "=$trigger_device:"`; do
    source_name="`echo "$incoming_sections" | cut -d '=' -f1 | cut -c4-`"
    source_device="`echo "$incoming_sections" | cut -d '=' -f2- | cut -d ':' -f1`"
    source_dir="`echo "$incoming_sections" | cut -d ':' -f2`"
    source_dated="`echo "$incoming_sections" | cut -d ':' -f3`"
    proc_debug "Found source dir for section $source_name on $trigger_device_check - $source_dir - $source_dated"

    MODE="INCOMING"

    proc_find_oldest_dir $source_dir $source_name $source_device $source_dated
    last_source_dir="$source_dir"

  done

  if [ ! -e "$TMP/oldest_dir.tmp" ]; then
    proc_debug "Error. No dir found to delete. Skipping."
  else

    source_release_raw="`cat "$TMP/oldest_dir.tmp" | sort -k4 -n -r | tail -n1`"
    source_release_path="`echo "$source_release_raw" | cut -d ' ' -f1`"
    source_name="`echo "$source_release_raw" | cut -d ' ' -f2`"
    source_release="`echo "$source_release_raw" | cut -d ' ' -f3`"
    proc_debug "Oldest dir on $trigger_device_check is $source_name -> $source_release_path/$source_release."

    proc_find_destination $source_release_path $source_release $source_name
  fi
}


## Get dirs settings.
IGNORE_DIRS="`grep "^IGNORE=" $config | cut -d '=' -f2 | tr -d '"'`"
for ignore in $IGNORE_DIRS; do
  if [ -z "$IGNORES" ]; then
    IGNORES="::$ignore::"
  else
    IGNORES="::$ignore::|$IGNORES"
  fi
done
IGNORES="$IGNORES|^Listing\ |::\.::|::\.\.::"

TMP="`grep "^TMP=" $config | cut -d '=' -f2 | tr -d '"'`"
if [ -z "$TMP" ]; then
  TMP="/tmp"
fi
TULS="`grep "^TULS=" $config | cut -d '=' -f2 | tr -d '"'`"
if [ -z "$TULS" ]; then
  TULS="tuls"
fi

RSYNC_OPTIONS="`grep "^RSYNC_OPTIONS=" $config | cut -d '=' -f2- | tr -d '"'`"
if [ -z "$RSYNC_OPTIONS" ]; then
  proc_log "Warning: RSYNC_OPTIONS not defined. Forcing '-ra'."
  proc_debug "Warning: RSYNC_OPTIONS not defined. Forcing '-ra'."
  RSYNC_OPTIONS="-ra"
fi

MAX_RSYNC_RETRIES="`grep "^MAX_RSYNC_RETRIES=" $config | cut -d '=' -f2 | tr -d '"'`"
if [ -z "$MAX_RSYNC_RETRIES" ]; then
  MAX_RSYNC_RETRIES="10"
fi

CHOWN_OPTIONS="`grep "^CHOWN_OPTIONS=" $config | cut -d '=' -f2 | tr -d '"'`"
CHMOD_OPTIONS="`grep "^CHMOD_OPTIONS=" $config | cut -d '=' -f2 | tr -d '"'`"
GLLOG="`grep "^GLLOG=" $config | cut -d '=' -f2 | tr -d '"'`"
STRIP_OUTPUT="`grep "^STRIP_OUTPUT=" $config | cut -d '=' -f2 | tr -d '"'`"
SECURITY_PATH="`grep "^SECURITY_PATH=" $config | cut -d '=' -f2 | tr -d '"'`"

DATE_BINARY="`grep "^DATE_BINARY=" $config | cut -d '=' -f2 | tr -d '"'`"
if [ -z "$DATE_BINARY" ]; then
  DATE_BINARY="date"
else
  DATE_DEFAULT="FALSE"
  if [ ! -x "$DATE_BINARY" ]; then
    echo "Error. Cant not execute $DATE_BINARY - Check path and permissions on date binary."
    proc_debug "Error. Cant not execute $DATE_BINARY - Check path and permissions on date binary."
    proc_exit
  fi
fi

DU_BINARY="`grep "^DU_BINARY=" $config | cut -d '=' -f2 | tr -d '"'`"
if [ -z "$DU_BINARY" ]; then
  DU_BINARY="du"
else
  DU_DEFAULT="FALSE"
  if [ ! -x "$DU_BINARY" ]; then
    echo "Error. Cant not execute $DU_BINARY - Check path and permissions on du binary."
    proc_debug "Error. Cant not execute $DU_BINARY - Check path and permissions on du binary."
    proc_exit
  fi
fi

MAX_LOOP="`grep "^MAX_LOOP=" $config | cut -d '=' -f2 | tr -d '"'`"
if [ -z "$MAX_LOOP" ]; then
  MAX_LOOP="10"
fi

LOGFILE="`grep "^LOGFILE=" $config | cut -d '=' -f2 | tr -d '"'`"

if [ ! -x "$TULS" ]; then
  echo "Error. Can not execute tuls ( $TULS )."
  proc_log "Error. Can not execute tuls ( $TULS )."
  proc_exit
fi

proc_verify_triggers() {
  if [ -z "$trigger_device" ]; then
    proc_debug "Error: In $triggers, I fail to find the device name. Check your config."
    proc_log "Error: In $triggers, I fail to find the device name. Check your config."
    exit 2
  elif [ -z "$trigger_free" ]; then
    proc_debug "Error: In $triggers, I fail to find the amount free to trigger on. Check your config."
    proc_log "Error: In $triggers, I fail to find the amount free to trigger on. Check your config."
    exit 2
  elif [ -z "$trigger_clean" ]; then
    proc_debug "Error: In $triggers, I fail to find the amount to make free. Check your config."
    proc_log "Error: In $triggers, I fail to find the amount to make free. Check your config."
    exit 2
  elif [ "`echo "$trigger_free" | tr -d '[:digit:]'`" ]; then
    proc_debug "Error: In $triggers, it seems that the amount of free space to trigger on is not a number. Check config."
    proc_log "Error: In $triggers, it seems that the amount of free space to trigger on is not a number. Check config."
    exit 2
  elif [ "`echo "$trigger_clean" | tr -d '[:digit:]'`" ]; then
    proc_debug "Error: In $triggers, it seems that the amount of free space to clean is not a number. Check config."
    proc_log "Error: In $triggers, it seems that the amount of free space to clean is not a number. Check config."
    exit 2
  fi
}

proc_sanity_check() {
  echo "Sanity check for Tur-Space $VER"
  echo "---------------------------------"

  echo "Configuration file used: $config"

  if [ "$RSYNC_OPTIONS" ]; then
    echo "Rsync mode used: rsync $RSYNC_OPTIONS"
  fi
  echo "A maximum of $MAX_RSYNC_RETRIES rsync retries will be attempted."

  if [ "$CHOWN_OPTIONS" ]; then
    echo "Moved releases owner will be set to $CHOWN_OPTIONS"
  fi
  if [ "$CHMOD_OPTIONS" ]; then
    echo "Moved releases permissions will be set to $CHMOD_OPTIONS"
  fi
  if [ "$DATE_DEFAULT" = "FALSE" ]; then
    echo "Date binary used: $DATE_BINARY"
  else
    echo "Date binary used: default 'date'. Hope it supports '-d'"
  fi
  echo "A maximum of $MAX_LOOP releases will be deleted from archive to make room for one release."
  if [ "$SECURITY_PATH" ]; then
    echo "Nothing above $SECURITY_PATH can be deleted by mistake."
  fi

  for triggers in `grep "^TRIGGER=" $config`; do
    trigger_device="`echo "$triggers" | cut -d '=' -f2 | cut -d ':' -f1`"
    trigger_free="`echo "$triggers" | cut -d ':' -f2`"
    trigger_clean="`echo "$triggers" | cut -d ':' -f3`"

    if [ "`df -PhT | grep "$trigger_device" | wc -l | tr -d ' '`" -gt "1" ]; then
      echo ""
      echo "ERROR on $triggers - grep on $trigger_device returns 2 or more lines."
      echo "Each device set in the config on TRIGGERS can only return one line when running df."
      echo "Aborting and leaving lockfile."
      exit 1
    fi

    proc_verify_triggers

    echo "Ignores set to: $IGNORES"
    echo ""
    echo "On device $trigger_device, we will check if theres less then $trigger_free MB free."
    echo "If there is, we will delete stuff until theres $trigger_clean MB free space."

    if [ -e "$TMP/oldest_dir.tmp" ]; then
      rm -f "$TMP/oldest_dir.tmp"
    fi

    echo "Source dirs for device $trigger_device are:"
    for incoming_sections in `grep "^INC" $config | grep "=$trigger_device:"`; do
      source_name="`echo "$incoming_sections" | cut -d '=' -f1 | cut -c4-`"
      source_device="`echo "$incoming_sections" | cut -d ':' -f1 | cut -d '=' -f2`"
      source_dir="`echo "$incoming_sections" | cut -d ':' -f2`"
      source_dated="`echo "$incoming_sections" | cut -d ':' -f3`"
      echo " $source_dir - $source_device"

      if [ ! -d "$source_dir" ]; then
        echo "Error. Incoming dir $source_dir does not exist. This is bad."
      else
        cd $source_dir

        if [ "$source_dated" != "DATED" ]; then
          unset DATED_
          oldest_dir_raw="`$TULS | grep "^d" | egrep -v "$IGNORES" | tr '^' ' ' | sort -k6 -n -r | tail -n1`"
          oldest_dir="`echo "$oldest_dir_raw" | awk -F"::::" '{print $4}'`"
          oldest_date="`echo "$oldest_dir_raw" | awk -F"::::" '{print $5}' | cut -d ' ' -f1-4`"
        else

          if [ "`$TULS | grep "^d" | egrep -v "$IGNORES" | tr -s ':' ' ' | cut -d ' ' -f4 | grep "^12"`" ]; then
            echo " - Dated dir setup found a dir starting with 12. Ignoring 01-06."
            oldest_dir_raw="`$TULS | grep "^d" | egrep -v "$IGNORES|^.*::::.*::::.*::::01|^.*::::.*::::.*::::02|^.*::::.*::::.*::::03|^.*::::.*::::.*::::04|^.*::::.*::::.*::::05|^.*::::.*::::.*::::06" | tr -s ':' ' ' | sort -k4 -n -r | tail -n1`"
          else
            oldest_dir_raw="`$TULS | grep "^d" | egrep -v "$IGNORES" | tr -s ':' ' ' | sort -k4 -n -r | tail -n1`"
          fi
          oldest_dir="`echo "$oldest_dir_raw" | cut -d ' ' -f4`"
          oldest_date="`echo "$oldest_dir_raw" | cut -d ' ' -f5 | cut -d '^' -f1-3 | tr '^' ' '`"
          DATED_="(dated dir)"

        fi

        echo " - Oldest release seems to be $oldest_dir <- $oldest_date $DATED_"
      fi

      unset destination_found
      for destination_dirs in `grep "^ARC$source_name=" $config`; do
        destination_found=TRUE
        dest_device="`echo "$destination_dirs" | cut -d '=' -f2 | cut -d ':' -f1`"
        dest_path="`echo "$destination_dirs" | cut -d ':' -f2`"
        echo " -- Destination is $dest_path on $dest_device"

        if [ "`df -PhT | grep "$dest_device" | wc -l | tr -d ' '`" -gt "1" ]; then
          echo ""
          echo "ERROR on $destination_dirs - grep on $dest_device returns 2 or more lines."
          echo "Each device set in the config on ARC* can only return one line when running df."
          echo "Aborting and leaving lockfile."
          exit 1
        fi

        df_verify="`df -PhT | grep "$dest_device" | tr -s ' '`"
        if [ -z "$df_verify" ]; then
          echo " --- ERROR! Device: $dest_device not found in df list. Sure its mounted?"
          echo " -----------------------------------------------------------------------"
          echo ""
        else
          device="`echo "$df_verify" | cut -d ' ' -f1`"
          file_system="`echo "$df_verify" | cut -d ' ' -f2`"
          total="`echo "$df_verify" | cut -d ' ' -f3`"
          used="`echo "$df_verify" | cut -d ' ' -f4`"
          free="`echo "$df_verify" | cut -d ' ' -f5`"
          percent_used="`echo "$df_verify" | cut -d ' ' -f6`"
          mounted_on="`echo "$df_verify" | cut -d ' ' -f7`"
          if [ -z "`echo "$dest_path" | grep "^$mounted_on"`" ]; then
            echo " --- WARNING! Device $device is mounted on $mounted_on but destination dir is set for $dest_path."
            echo " --- This might not be an error, but it looks like it."
            echo " --- df reports: Device:$device FS:$file_system Tot:$total Used:$used Free:$free %Use:$percent_used"
            echo " --- Mountpoint:$mounted_on"
            echo ""
          else
            echo " --- Looks good! df reports: Device:$device FS:$file_system Tot:$total Used:$used Free:$free %Use:$percent_used"
            echo " --- Mountpoint:$mounted_on"
            echo ""
          fi
        fi
      done
      if [ -z "$destination_found" ]; then
        echo " -- NO destination dir. Releases will be deleted."
      fi
      echo ""
    done

    echo ""
  done

  for rawdata in `grep "^INC" $config`; do
    sdevice="`echo "$rawdata" | cut -d '=' -f2 | cut -d ':' -f1`"
    if [ -z "`grep "^TRIGGER=" $config | grep "\=$sdevice\:"`" ]; then
      echo "Warning on $rawdata - device $sdevice does not match any TRIGGER. It will be ignored."
    fi
  done

  for rawdata in `grep "^ARC" $config`; do
    sec_name="`echo "$rawdata" | cut -d '=' -f1 | cut -c4-`"
    if [ -z "`grep "^INC$sec_name=" $config`" ]; then
      echo "Warning: Section $sec_name's archive defined as $rawdata - No source (INC$sec_name) found for that section."
      echo "It will be ignored."
    fi
  done

  proc_exit
}

proc_help() {
  echo ""
  echo "Tur-Space $VER by Turranius."
  echo ""
  echo "Commands:"
  echo "sanity = Verify configuration in tur-space.conf"
  echo "go     = Proceed and move stuff."
  echo "         Specify 'debug' as second arg to enable debug output"
  echo "         Nothing is actually done in debug mode."
  echo ""
  proc_exit
}

proc_go() {
  for triggers in `grep "^TRIGGER=" $config`; do
    unset mount_error; unset no_delete; unset mount_errors; unset did_something

    trigger_device="`echo "$triggers" | cut -d '=' -f2 | cut -d ':' -f1`"
    trigger_free="`echo "$triggers" | cut -d ':' -f2`"
    trigger_clean="`echo "$triggers" | cut -d ':' -f3`"

    proc_verify_triggers

    proc_debug "Found trigger: $trigger_device - $trigger_free - $trigger_clean"
    proc_get_free_space $trigger_device

    trigger_device_free="$free_space"

    if [ -z "$free_space" ]; then
      proc_debug "Error. Could not get free space from device $trigger_device defined in $triggers - skipping"
      proc_log "Error: Could not get free space from device $trigger_device defined in $triggers - skipping"
    else
      proc_debug ""
      counter="0"
      unset said_header

      if [ "$free_space" -lt "$trigger_free" ]; then
        while [ "$free_space" -lt "$trigger_clean" ]; do

          did_something=true

          if [ -z "$said_header" ]; then
            proc_log "Device $trigger_device has $free_space MB free. Needs $trigger_clean MB so processing it."
            said_header="true"
          fi

          proc_debug ""
          proc_find_sourcedirs $trigger_device
          proc_get_free_space $trigger_device

          trigger_device_free="$free_space"

          if [ "$no_delete" = "true" ]; then
            proc_debug "Skipping $trigger_device since we have mount errors and its time to delete."
            unset no_delete
            break
          fi

          if [ "$DEBUG" = "TRUE" ]; then
            counter=$[$counter+1]
            if [ "$counter" -ge "20" ]; then
              proc_debug "Debug: Forcing Quit after 20 loops. Normally it wouldnt stop until its finished"
              proc_debug "or if there are errors."
              break
            fi
          fi

        done

        proc_log "Done. $free_space MB free on $trigger device"
      fi

      if [ -z "$did_something" ]; then
        proc_debug "$trigger_device got enough space already. Skipping."
      fi
    fi
  done

  proc_exit
}

case $2 in
  [dD][eE][bB][uU][gG]) DEBUG="TRUE" ;;
esac

if [ -e "$TMP/tur-space.lock" ]; then
  if [ "$1" = "sanity" ]; then
    DEBUG="TRUE"
  fi

  if [ "`find \"$TMP/tur-space.lock\" -type f -mmin -1440`" ]; then
    proc_debug "Lockfile $TMP/tur-space.lock exists and is not 24 hours old yet. Quitting."
    if [ "$DEBUG" = "TRUE" ]; then
      LAST_ERROR="`egrep "Error|Warning" $LOGFILE | tail -n1`"
      if [ "$LAST_ERROR" ]; then
        proc_debug "Last error was:"
        proc_debug "$LAST_ERROR"
      fi
    fi
    exit 0
  else
    proc_debug "Lockfile exists, but its older then 24 hours. Removing lockfile."
    touch "$TMP/tur-space.lock"
  fi
else
  touch "$TMP/tur-space.lock"
fi

case $1 in
  [sS][aA][nN][iI][tT][yY]) DEBUG="TRUE"; proc_sanity_check ;;
  [gG][oO]) proc_go ;;
  *) proc_help ;;
esac

proc_exit