#!/bin/bash

################################################################################
# Script name:  free_space_dated_dirs_v1.4beta2.sh                             #
# Author:       SoD-                                                           #
# Contact:      SoD- @ EFNet                                                   #
# Releasedate:  2002-08-29                                                     #
#                                                                              #
# This script have been confirmed to work in Slackware 8.0 and FreeBSD 4.5.    #
# This script is meant to be run from crontab at an approperiate interval and  #
# will then delete dirs in a DATED DIR STRUCTRE until a specified amount of    #
# space is free. The script can be run with arguments or with the settings in  #
# this file. Running it with arguments can be handy if u have many sections    #
# since it then only requires 1 copy of this script.                           #
# If all/some of your sections doesn't use dated dirs you should use another   #
# script, for example my free_space_v1.2.2.sh for them.                        #
# This script is meant for mp3/0-day and other sections that uses dated dirs.  #
# You can specify how much space the section is allowed to contain, letting    #
# you have multiple sections on one device. You can set groups whos releases   #
# you don't want deleted by the script (eg,don't delete any of CORE's or SND's #
# releases). The "VIP group releases" will be moved to a different location    #
# and if a dir with the same name already exists there, the one to be moved    #
# will be renamed (adds the current date in seconds to the end).               #
# Nuked dirs from "VIP groups" will get deleted, not moved.                    #
# It deletes the dated dirs by their name (hence the dated dirs only) and all  #
# the dirs/files inside them by their modification date. It only deletes dated #
# dirs (ie. 0311) so dirs named otherwise than a dated dir won't be touched.   #
# It will delete a dir named '0000' and a few more non-dated-dirs that consist #
# of four digits.                                                              #
# Since some filesystems (and mounts) don't write the status of the files on   #
# the hard discs right away, there's an option that makes the script wait for  #
# a specified time until it continues to delete.                               #
# To easy the configuration there's a variable called DEBUG, which when set to #
# 1 runs the script without deleting anything. It will say which dir is about  #
# to get deleted but not deleting it. Since it isn't deleted, the script will  #
# run forever so just hit ctrl-c to stop it. It writes to glftpd.log so that a #
# botscript can announce it (see below on how to configure the botscript).     #
# The script does something like this:                                         #
# * Deleting any files directly inside the oldest dated dir.                   #
# * Deleting any nuked dirs inside the oldest dated dir.                       #
# * Deleting oldest dir inside oldest dated dir.                               #
# * Moving any "VIP groups" releases to a specified dir.                       #
# * Deleting the oldest dated dir if it's empty.                               #
# * Repeats above in the "next" dated dir until enough space is free.          #
#                                                                              #
# Installation: -Put this file in some approperiate place, for example         #
#                /glftpd/bin/free_space_dated_dirs_v1.4beta2.sh                #
#               -Make it executable                                            #
#                (chmod 755 /glftpd/bin/free_space_dated_dirs_v1.4beta2.sh)    #
#               -Edit your crontab (crontab -e) and write something like:      #
#                0,20,40 * * * * /glftpd/bin/free_space_dated_dirs_v1.4beta2.sh#
#               -Edit this script to suit your setup. Note that all you need   #
#                to configure if you want to call the script with arguments is #
#                the location of the config-/logfiles.                         #
#               -Execute the script manually to spot any obvious errors.       #
#               -If the execution went fine, set DEBUG to 0 (DEBUG=0).         #
#               -Add it to your crontab (crontab -e) by writing something like:#
#                0,20,40 * * * * /glftpd/bin/free_space_dated_dirs_v1.4beta2.sh#
#                or if you want to call it with arguments:                     #
#                0,20,40 * * * * /glftpd/bin/free_space_dated_dirs_v1.4beta2.sh <MIN_FREE_SPACE> <MAX_SPACE_ALLOWED> <"INCOMINGPATH"> <"VIP_GROUPS"> <"VIP_DESTINATION"> <ANNOUNCE> <NAP> <"SECTION_NAME">
#                DEBUG, GL_CONFIG_FILE, GL_LOG_FILE and ERROR_LOG_FILE must be #
#                set in this file. Note that you can't have multiple           #
#                executions of the same script in some (or all) crontabs       #
#                unless u put them as background jobs.                         #
#               +NOTE to people not using glftpd: Just make shure that all the #
#                logs exists and that $NUKED_DIR_NAMES is set, you can         #
#                hardcode it instead of having it read from any config file.   #
#                                                                              #
# Bot config:   -If you are using Darkheart's botscript you should add the     #
#                following 8 lines to sitebot-glftpd.api and then rehash it.:  #
#                set chans(sectionname-AUTODEL) " #channelname "               #
#                               ^-edit                 ^-edit                  #
#                set chans(sectionname-RMDIR) " #channelname "                 #
#                               ^-edit                 ^-edit                  #
#                set echovars(AUTODEL) "size section deldir"                   #
#                set echovars(RMDIR) "section"                                 #
#                set enabled_announce(AUTODEL) 1                               #
#                set enabled_announce(RMDIR) 1                                 #
#                set mask(AUTODEL) "[b]\[%sitein AUTO-DELETE\][b] System freed [b]%size[b]MB in [b]%section[b] by deleting [b]%deldir[b]."
#                set mask(RMDIR) "[b]\[%sitein AUTO-DELETE\][b] System deleted [b]%section[b]. Now continuing in next dated dir."
#               -If you are using vShit's botscript you should add the         #
#                following 2 lines in the scanlog proc and then rehash it.:    #
#                AUTODEL: {sndall "[b]\[$sitename AUTO-DELETE\][b] System freed [b][lindex $args 0][b]MB in [b][lindex $args 1][b] by deleting [b][lindex $args 2][b]."}
#                RMDIR: {sndall "[b]\[$sitename AUTO-DELETE\][b] System deleted [b][lindex $args 0][b]. Now continuing in next dated dir."}
#               -If you are using vrpack (1.6.0 Beta) botscript you should add #
#                the following 2 lines in the scanlog proc and then rehash it.:#
#                AUTODEL: {sndall "\002\[$sns AUTO-DELETE\]\002 System freed \002[lindex $args 0]\002MB in \002[lindex $args 1]\002 by deleting \002[lindex $args 2]\002."}
#                RMDIR: {sndall "\002\[$sns AUTO-DELETE\]\002 System deleted \002[lindex $args 0]\002. Now continuing in next dated dir."}
#               -If you are using Dark0n3's botscript you should add 'AUTODEL' #
#                and 'RMDIR' to the list in 'set msgtypes(DEFAULT) "..."'.     #
#                Also add following 8 lines to dZSbot.tcl and then rehash it.: #
#                set chanlist(AUTODEL) "#channelname"                          #
#                                             ^-edit                           #
#                set chanlist(RMDIR) "#channelname"                            #
#                                           ^-edit                             #
#                set disable(AUTODEL) 0                                        #
#                set disable(RMDIR) 0                                          #
#                set variables(AUTODEL) "%size %msg %deldir"                   #
#                set variables(RMDIR) "%msg"                                   #
#                set announce(AUTODEL) "%bold\[%sitename AUTO-DELETE\]%bold System freed %bold%size%bold MB in %bold%msg%bold by deleting %bold%deldir%bold"
#                set announce(RMDIR) "%bold\[%sitename AUTO-DELETE\]%bold System deleted %bold%msg%bold. Now continuing in next dated dir."
#                                                                              #
# Requirements: awk, cp, date, df, du, echo, expr, find, grep, ls, rm, rmdir,  #
#               sleep, tail, tr.                                               #
#                                                                              #
# Limitations:  -Can only handle dirnames without spaces. Dirs that are inside #
#                the releases that are inside the dated dirs can contain       #
#                spaces (eg, /glftpd/site/0-day/0219/Some_Wares-KvE/[100% OK]).#
#               -The chars '[' and ']' are only supported in nuked dirs.       #
#               -Nuked dirs names must start with the nukedir_style.           #
#               -Only handles dated dirs named like 1127 (not 11-27, 11.27...).#
#               -No more than 3 months can be handled.                         #
#                                                                              #
# Changelog:    v1.0 -> v1.1.beta:    Certain groups releases can now be set   #
#                                     to not be deleted.                       #
#               Changes in settings:  Specify $VIP_GROUPS and $VIP_DESTINATION #
#               v1.1.beta -> v1.2beta:Announcing can now be set to 2 levels.   #
#                                     Level 2 announes all deleted dirs, level #
#                                     1 only announces when a complete dated   #
#                                     dir gets been deleted.                   #
#                                     Free space in $VIP_DESTINATION is now    #
#                                     checked before "VIP DIRS" are moved, it  #
#                                     would cause the script to run forever if #
#                                     $VIP_DESTINATION didnt have enough space.#
#               Changes in settings:  Change $ANNOUNCE if you want to.         #
#                                     Update botscript so it triggers on RMDIR #
#               v1.2beta -> v1.3beta: Changed so the script can handle 3       #
#                                     months of dated dirs and made it check a #
#                                     few variables for errors.                #
#               Changes in settings:  None.                                    #
#               v1.3beta -> v1.3beta2:Some checks have been implemented to     #
#                                     make the script less sensitive to faulty #
#                                     settings/dirnames/filenames. Added a     #
#                                     DEBUG setting that disables the actual   #
#                                     deleting. Also made the script send any  #
#                                     errors to glftpd's error.log.            #
#                                     On some systems, 'df -m' didn't work as  #
#                                     planned. Changed it to 'df -Pm'. Also    #
#                                     added braces around the parameters that  #
#                                     are sent to glftpd.log.                  #
#               Changes in settings:  Specify $ERROR_LOG_FILE.                 #
#               v1.3beta2 -> v1.4beta:Made the DEBUG feature give some         #
#                                     feedback.                                #
#                                     The script should now work in FreeBSD    #
#                                     since ive changed the parameters to 'ls'.#
#                                     Added a new variable, $NAP, that makes   #
#                                     the script wait $NAP seconds between     #
#                                     deletions. This is for those whos fs     #
#                                     isn't updating its free space            #
#                                     immediately (like BSD's softupdate).     #
#                                     Made the script exit if deletion of the  #
#                                     nuked dirs freed up enough space.        #
#                                     Fixed a bug that caused some dirs to be  #
#                                     treated as $VIP_GROUPS.                  #
#                                     Nuked releases from $VIP_GROUPS are now  #
#                                     being deleted, not moved as before.      #
#                                     The script can now take the settings as  #
#                                     arguments to the script.                 #
#                                     Also made some minor changes that might  #
#                                     improve performance.                     #
#               Changes in settings:  Specify $NAP.                            #
#               v1.4beta -> v1.4beta2:Fixed so that the script will rename any #
#                                     $VIP_GROUPS dirs that are about to be    #
#                                     moved to $VIP_DESTINATION if they        #
#                                     already exist in $VIP_DESTINATION.       #
#                                     Refined the search for $VIP_GROUPS       #
#                                     dirnames, if 2 groups names were too     #
#                                     similar, both could be excluded.         #
#                                     Fixed a problem when using $NAP, it      #
#                                     deleted 1 release too much.              #
#                                     Corrected the instructions for Dark0n3's #
#                                     botscript.                               #
#                                     When $VIP_GROUP dirs couldn't be moved   #
#                                     to $VIP_DESTINATION because of lack of   #
#                                     space, their deletion wasn't logged to   #
#                                     glftpd.log. Fixed now.                   #
#                                     When the oldest dir inside the oldest    #
#                                     dated dir was a symlink the script would #
#                                     loop indefinitely. Fixed now.            #
#                                     Announcing of deleted and/or moved       #
#                                     $VIP_GROUP dirs can be turned on/off by  #
#                                     commenting in/out a few rows at the end  #
#                                     of the script (search for 'announced').  #
#                                     Also changed so that the script won't    #
#                                     output errors when $INCOMINGPATH is      #
#                                     faulty (but it will abort).              #
#               Changes in settings:  None.                                    #
################################################################################
# This setting disables the actual deleting of the dirs. Set to 0 for no debug.
DEBUG=1

# How many Megabyte shall be kept free? (free space when script exits).
MIN_FREE_SPACE=1000

# If you only want to use a part of the device for the section this script keeps
# free you can set that amount (in MB) here. If you want to use the entire
# device, set this to 0 (zero). The above setting is nescessary too.
# Just think of this setting as the capacity of the disc. If you have a device
# with a capacity of 40000 MB and you want the section to only occupy 25000 MB
# of it, set this to 25000. Since the script uses this value as the capacity of
# the device, make shure there's at least this much space available.
MAX_SPACE_ALLOWED=0

# Where are the dirs to be freed located? (eg, /glftpd/site/mp3/).
# Use a trailing frontslash (/).
INCOMINGPATH="/glftpd/site/mp3/"

# What groups releases don't you want this script to delete? Separate with space
VIP_GROUPS="bmi mtc snd pow"

# If $VIP_GROUPS is set, then you must specify a location to where these will be
# moved when the oldest dated dir only consists of $VIP_GROUPS. If this is not
# set (or incorrectly set), all VIP_GROUPS releases will be deleted. Use a trailing frontslash (/).
VIP_DESTINATION="/glftpd/site/private/"

# Do you want the script to write to glftpd.log (for announcing)? Set to '1' if
# you only want dated-dir-deletion announced, '2' if you want all deletions
# announced or 'n' if you don't want any announcing at all.
ANNOUNCE=2

# For how many seconds shall the script wait between deletions? This is only
# interesting if your fs isn't updating its free space immediately. (like BSD's
# softupdate). The script will delete smaller dirs without waiting (up to about
# 100 MB). Set to zero (0) to disable the delay.
NAP=0

# What do you want the bot to call the section? (eg, MP3, iSO, PR0N).
SECTION_NAME=MP3

# What's the location of glftpd.conf?
GL_CONFIG_FILE="/etc/glftpd.conf"

# What's the location of glftpd.log?
GL_LOG_FILE="/glftpd/ftp-data/logs/glftpd.log"

# What's the location of glftpd's error.log?
ERROR_LOG_FILE="/glftpd/ftp-data/logs/error.log"

################################################################################
# No more specifications needed below,just some editing if the script won't work
################################################################################

if [ $# -ne 0 ] && [ $# -ne 8 ]; then
  if [ $DEBUG -ne 0 ]; then
    echo "Too few or too many arguments to script, aborting."
  elif [ -w $ERROR_LOG_FILE ]; then
    echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to execute:" \
    "too few or too many arguments to script, aborting" >> $ERROR_LOG_FILE
  fi
  exit 1
fi

if [ $# -eq 8 ]; then
  MIN_FREE_SPACE=$1
  MAX_SPACE_ALLOWED=$2
  INCOMINGPATH=$3
  VIP_GROUPS=$4
  VIP_DESTINATION=$5
  ANNOUNCE=$6
  NAP=$7
  SECTION_NAME=$8
fi

# Scan glftpd.conf for the nukestyle.
NUKED_DIR_NAMES=`grep nukedir_style -i $GL_CONFIG_FILE | grep -v '#' | \
awk '{print $2}' | awk -F "%N" '{print $1}'`

# Make shure that the incomingpath is correct.
if [ ! -d "$INCOMINGPATH" ]; then
  if [ $DEBUG -ne 0 ]; then
    echo "Incomingpath ( $INCOMINGPATH ) is faulty, aborting."
  elif [ -w $ERROR_LOG_FILE ]; then
    echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to execute:" \
    "the incomingpath is faulty" >> $ERROR_LOG_FILE
  fi
  exit 1
fi
# Check for disk usage/free space.
if [ $MAX_SPACE_ALLOWED -eq 0 ]; then
  FREE_ON_DEVICE=`df -Pm "$INCOMINGPATH" | grep "/dev/" | awk '{print $4}'`
else
  SPACE_USED=`expr \`du -ks "$INCOMINGPATH" | awk '{print $1}'\` / 1024`
  FREE_ON_DEVICE=`expr $MAX_SPACE_ALLOWED - $SPACE_USED`
fi
# Just make shure that glftpd's log- and configfile are accessible.
if [ ! -r "$GL_CONFIG_FILE" ] || [ ! -w "$GL_LOG_FILE" ]; then
  if [ $DEBUG -ne 0 ]; then
    echo "One or more of your settings are faulty, aborting."
  elif [ -w "$ERROR_LOG_FILE" ]; then
    echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to execute:" \
    "one or more of your settings are faulty" >> $ERROR_LOG_FILE
  fi
  exit 1
fi
if [ -z $NUKED_DIR_NAMES ] || [ -z $MIN_FREE_SPACE ] || \
[ -z $FREE_ON_DEVICE ]; then
  if [ $DEBUG -ne 0 ]; then
    echo "Error in script: variables not set properly, aborting."
  elif [ -w "$ERROR_LOG_FILE" ]; then
    echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to execute:" \
    "error in script, variables not set properly" >> $ERROR_LOG_FILE
  fi
  exit 1
fi
if [ "$VIP_DESTINATION" ] && [ ! -w "$VIP_DESTINATION" ]; then
  if [ $DEBUG -ne 0 ]; then
    echo "Can't write to VIP_DESTINATION ($VIP_DESTINATION), aborting."
  elif [ -w "$ERROR_LOG_FILE" ]; then
    echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to execute:" \
    "$VIP_DIR doesnt exist or cant be written to" >> $ERROR_LOG_FILE
  fi
  exit 1
fi

DEL_DIR_SIZE=0
DEL_DIR_SIZE_SUM=0

# Loop until enough space has been freed.
until [ $FREE_ON_DEVICE -gt $MIN_FREE_SPACE ]; do
  # Get the oldest dir (sorted by NAME not date) (eg, 1115).
  OCTOBER_CHECK=`ls -lr $INCOMINGPATH | awk '{print $9}' | \
  grep -x "10[0123][[:digit:]]" | tail -n1`
  NOVEMBER_CHECK=`ls -lr $INCOMINGPATH | awk '{print $9}' | \
  grep -x "11[0123][[:digit:]]" | tail -n1`
  DECEMBER_CHECK=`ls -lr $INCOMINGPATH | awk '{print $9}' | \
  grep -x "12[0123][[:digit:]]" | tail -n1`
  JANUARY_CHECK=`ls -lr $INCOMINGPATH | awk '{print $9}' | \
  grep -x "01[0123][[:digit:]]" | tail -n1`
  if [ $OCTOBER_CHECK ] && [ $JANUARY_CHECK ]; then
    OLDEST_DIR=$OCTOBER_CHECK
  elif [ $NOVEMBER_CHECK ] && [ $JANUARY_CHECK ]; then
    OLDEST_DIR=$NOVEMBER_CHECK
  elif [ $DECEMBER_CHECK ] && [ $JANUARY_CHECK ]; then
    OLDEST_DIR=$DECEMBER_CHECK
  else
    OLDEST_DIR=`ls -lr $INCOMINGPATH | awk '{print $9}' | \
    grep -x "[01][[:digit:]][0123][[:digit:]]" | tail -n1`
  fi

  # Make shure $OLDEST_DIR contains something.
  if [ ! "$OLDEST_DIR" ]; then
    if [ $DEBUG -ne 0 ]; then
      echo "Error in script: no directory to delete, aborting."
    elif [ -w $ERROR_LOG_FILE ]; then
      echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to execute:" \
      "error in script, no directory to delete" >> $ERROR_LOG_FILE
    fi
    exit 1
  fi

  # Remove any files lying directly in $OLDEST_DIR (eg, 1115/01-MrMjao.mp3).
  if [ $DEBUG -eq 0 ]; then
    while [ "`find "$INCOMINGPATH$OLDEST_DIR" -mindepth 1 -maxdepth 1 -type f \
    | tail -n 1`" ]; do
      rm -f "`find "$INCOMINGPATH$OLDEST_DIR" -mindepth 1 -maxdepth 1 -type f \
      | tail -n 1`"
    done
  else
    echo "Deleting any files directly inside "$INCOMINGPATH$OLDEST_DIR/""
  fi

  # Remove any nuked dirs in $OLDEST_DIR (eg, !NUKED-VA-MrMjao-2001-KvEMP3).
  if [ $DEBUG -eq 0 ]; then
    rm -rf "$INCOMINGPATH$OLDEST_DIR/$NUKED_DIR_NAMES"*
  else
    echo "Deleting all nuked dirs in "$INCOMINGPATH$OLDEST_DIR/""
  fi

  if [ $NAP -gt 0 ];then
    sleep $NAP
  fi

  # Exit script if the deletion of nuked dirs freed up enough space.
  if [ $MAX_SPACE_ALLOWED -eq 0 ]; then
    FREE_ON_DEVICE=`df -Pm "$INCOMINGPATH" | grep "/dev/" | awk '{print $4}'`
  else
    SPACE_USED=`expr \`du -ks "$INCOMINGPATH" | awk '{print $1}'\` / 1024`
    FREE_ON_DEVICE=`expr $MAX_SPACE_ALLOWED - $SPACE_USED`
  fi
  if [ -z $FREE_ON_DEVICE ] || [ -z $MIN_FREE_SPACE ]; then
    if [ $DEBUG -ne 0 ]; then
      echo "Error in script: variables not set properly, aborting."
    elif [ -w $ERROR_LOG_FILE ]; then
      echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to execute:" \
      "error in script, variables not set properly" >> $ERROR_LOG_FILE
    fi
    exit 1
  elif [ $FREE_ON_DEVICE -gt $MIN_FREE_SPACE ]; then
    exit
  fi

  # Create a list for use in $DEL_DIR with releases that aren't to be deleted.
  EXCLUDE_DIRS=""
  if [ "$VIP_GROUPS" ]; then
    for VIP_GROUP in $VIP_GROUPS; do
      EXCLUDE_DIR=`ls "$INCOMINGPATH$OLDEST_DIR" | grep -i "[-_.]$VIP_GROUP$"`
      EXCLUDE_DIRS=`echo "$EXCLUDE_DIRS$EXCLUDE_DIR"" "`
    done
  fi

  # Remove oldest dir in $OLDEST_DIR, get the size for the botscript and
  # announce deletion if $ANNOUNCE is set to 2.
  DEL_DIR=`ls -lt "$INCOMINGPATH$OLDEST_DIR" | awk '{print $9}' | tr -d '/'`
  for EXCLUDE_DIR in $EXCLUDE_DIRS; do
    DEL_DIR=`echo "$DEL_DIR" | grep -vx '\'"$EXCLUDE_DIR"`
  done
  DEL_DIR=`echo "$DEL_DIR" | tail -n1`

  if [ "$DEL_DIR" ] && [ -d "$INCOMINGPATH$OLDEST_DIR" ]; then
    if [ -d "$INCOMINGPATH$OLDEST_DIR/$DEL_DIR" ] || \
    [ -h "$INCOMINGPATH$OLDEST_DIR/$DEL_DIR" ]; then
      DEL_DIR_SIZE=`expr \`du -ks "$INCOMINGPATH$OLDEST_DIR/$DEL_DIR" | \
      awk '{print $1}'\` / 1024`
      if [ $DEBUG -eq 0 ]; then
        rm -rf "$INCOMINGPATH$OLDEST_DIR/$DEL_DIR"
      else
        echo "Deleting $INCOMINGPATH$OLDEST_DIR/$DEL_DIR"
      fi
      if [ $ANNOUNCE = 2 ]; then
        echo `date +"%a %b %d %T %Y"` AUTODEL: \""$DEL_DIR_SIZE"\" \
        \""$SECTION_NAME/$OLDEST_DIR"\" \""$DEL_DIR"\" >> $GL_LOG_FILE
      fi
    fi
  fi

  NO_OF_VIP_GROUP_DIRS=0
  for VIP_GROUP in $VIP_GROUPS; do
    NO_OF_VIP_GROUP_DIRS=`expr $NO_OF_VIP_GROUP_DIRS + \`ls \
    "$INCOMINGPATH$OLDEST_DIR" | grep -ic "[-_.]$VIP_GROUP$"\``
  done

  # Are there any $VIP_GROUP dirs to move?
  if [ `ls -l "$INCOMINGPATH$OLDEST_DIR" | grep -cv '^total'` -eq \
  $NO_OF_VIP_GROUP_DIRS ] && [ $NO_OF_VIP_GROUP_DIRS -ne 0 ]; then
    # Loop through each $VIP_DIR.
    until [ `ls -l "$INCOMINGPATH$OLDEST_DIR" | grep -cv '^total'` -eq 0 ]; do
      DIR_TO_MOVE=`ls -l "$INCOMINGPATH$OLDEST_DIR" | awk '{print $9}' | \
      tail -n1`
      if [ ! "$DIR_TO_MOVE" ] || \
      [ ! -d "$INCOMINGPATH$OLDEST_DIR/$DIR_TO_MOVE" ] && \
      [ ! -h "$INCOMINGPATH$OLDEST_DIR/$DIR_TO_MOVE" ]; then
        if [ $DEBUG -ne 0 ]; then
          echo "Error in script: variables not set properly, aborting."
        elif [ -w "$ERROR_LOG_FILE" ]; then
          echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to" \
          "execute: error in script, variables not set properly" \
          >> $ERROR_LOG_FILE
        fi
        exit 1
      fi

      # Move "VIP DIRS" if there's enough space in $VIP_DESTINATION and if
      # $VIP_DESTINATION exist, else remove them.
      if [ -d "$VIP_DESTINATION" ] && [ `df -Pm "$VIP_DESTINATION" | \
      grep "/dev/" | awk '{print $4}'` -gt `expr \`du -ks \
      "$INCOMINGPATH$OLDEST_DIR" | awk '{print $1}'\` / 1024` ]; then
        if [ $DEBUG -eq 0 ]; then
          # Rename and move the dir if it already exists in $VIP_DESTINATION.
          if [ -e "$VIP_DESTINATION$DIR_TO_MOVE" ]; then
            cp -pr "$INCOMINGPATH$OLDEST_DIR/$DIR_TO_MOVE" \
            "$VIP_DESTINATION$DIR_TO_MOVE-`date +%s`"
          else
            cp -pr "$INCOMINGPATH$OLDEST_DIR/$DIR_TO_MOVE" "$VIP_DESTINATION"
          fi
# If you want moved dirs to be announced as deleted, uncomment following 5 rows.
#            if [ $ANNOUNCE = 2 ]; then
#              echo `date +"%a %b %d %T %Y"` AUTODEL: \""$DEL_DIR_SIZE"\" \
#              \""$SECTION_NAME/$OLDEST_DIR"\" \""$DEL_DIR"\" >> $GL_LOG_FILE
#              sleep 1s
#            fi
          rm -rf "$INCOMINGPATH$OLDEST_DIR/$DIR_TO_MOVE"
        else
          echo "Movin $INCOMINGPATH$OLDEST_DIR/$DIR_TO_MOVE to $VIP_DESTINATION"
        fi
      else
        if [ $DEBUG -eq 0 ]; then
# If you dont want deleted VIP_GROUP dirs announced,comment out the next 5 rows.
          if [ $ANNOUNCE = 2 ]; then
            echo `date +"%a %b %d %T %Y"` AUTODEL: \""$DEL_DIR_SIZE"\" \
            \""$SECTION_NAME/$OLDEST_DIR"\" \""$DEL_DIR"\" >> $GL_LOG_FILE
            sleep 1s
          fi
          rm -rf "$INCOMINGPATH$OLDEST_DIR/$DIR_TO_MOVE"
        else
          echo "Removing $INCOMINGPATH$OLDEST_DIR/$DIR_TO_MOVE (unable to move)"
        fi
      fi
    done
  fi

  # Now delete the dated dir and announce it if announce is set to 1 or 2.
  if [ `ls -l "$INCOMINGPATH$OLDEST_DIR" | grep -cv '^total'` -eq 0 ]; then
    if [ $DEBUG -eq 0 ]; then
      rmdir "$INCOMINGPATH$OLDEST_DIR"
    else
      echo "Deleting $INCOMINGPATH$OLDEST_DIR"
    fi
    if [ $ANNOUNCE = 1 ] || [ $ANNOUNCE = 2 ]; then
      echo `date +"%a %b %d %T %Y"` RMDIR: \""$SECTION_NAME/$OLDEST_DIR"\" \
      >> $GL_LOG_FILE
    fi
  fi

  if [ $NAP -gt 0 ]; then
    DEL_DIR_SIZE_SUM=`expr $DEL_DIR_SIZE_SUM + $DEL_DIR_SIZE`
    if [ $DEL_DIR_SIZE_SUM -gt 100 ]; then
      sleep $NAP
      DEL_DIR_SIZE_SUM=0
    fi
  fi

  # Are enough files deleted?
  if [ $MAX_SPACE_ALLOWED -eq 0 ]; then
    FREE_ON_DEVICE=`df -Pm "$INCOMINGPATH" | grep "/dev/" | awk '{print $4}'`
  else
    SPACE_USED=`expr \`du -ks "$INCOMINGPATH" | awk '{print $1}'\` / 1024`
    FREE_ON_DEVICE=`expr $MAX_SPACE_ALLOWED - $SPACE_USED`
  fi

  if [ -z $FREE_ON_DEVICE ] || [ -z $MIN_FREE_SPACE ]; then
    if [ $DEBUG -ne 0 ]; then
      echo "Error in script: variables not set properly, aborting."
    elif [ -w $ERROR_LOG_FILE ]; then
      echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to execute:" \
      "error in script, variables not set properly" >> $ERROR_LOG_FILE
    fi
    exit 1
  fi
done
exit
