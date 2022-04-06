#/bin/bash

################################################################################
# Script name:  free_space_v1.2.2.sh                                           #
# Author:       SoD-                                                           #
# Contact:      SoD- @ EFNet                                                   #
# Releasedate:  2002-08-04                                                     #
#                                                                              #
# This script have been confirmed to work in Slackware 8.0 and FreeBSD 4.5.    #
# This script is meant to be run from crontab at an approperiate interval and  #
# will then delete directorys until a specified amount of space is free. The   #
# script can be run with arguments or with the settings in this file. Running  #
# it with arguments can be handy if u have many sectios since it then only     #
# requires 1 copy of this script.                                              #
# This script only deletes directly inside the specified incomingpath and is   #
# meant for iso/vcd/divx/ and other sections were you normally don't use dated #
# dirs. If you have a dated dir structure you should use my other script,      #
# free_space_dated_dirs_v1.x.sh.                                               #
# You can specify how much space the section is allowed to contain, letting    #
# you have multiple sections on one device and you can set the time you want   #
# nuked dirs to stay on the site. You can specify groups whos releases you     #
# don't want deleted by the script (eg, don't delete any of RiSC's or FLT's    #
# releases) and of course "special" dirs that you want excluded. Nuked dirs    #
# gets deleted even if they are from "VIP groups".                             #
# Since some filesystems (and mounts) don't write the status of the files on   #
# the hard discs right away, there's an option that makes the script wait for  #
# a specified time until it continues to delete.                               #
# To easy the configuration there's a variable called DEBUG, which when set to #
# 1 runs the script without deleting anything. It will say which dir is about  #
# to get deleted but not deleting it. Since it isn't deleted, the script will  #
# run forever so just hit ctrl-c to stop it.                                   #
# The script deletes the dirs by their modification time and writes to         #
# glftpd.log so that a botscript can announce it (see below on how to          #
# configure the botscript). The script does something like this:               #
# * Deleting any nuked directorys inside incomingpath if they are older than   #
#   specified by $DELETE_NUKES_TIME.                                           #
# * Deleting oldest directory inside incomingpath.                             #
# * Repeats the above until enough space is free.                              #
#                                                                              #
# Installation: -Compile file_age.c (gcc -Wall -o file_age file_age.c).        #
#               -Move the file_age binary to some approperiate place.          #
#                (mv file_age /bin/file_age).                                  #
#               -Put this file in some approperiate place, for example         #
#                /glftpd/bin/free_space_v1.2.2.sh                              #
#               -Make it executable                                            #
#                (chmod 755 /glftpd/bin/free_space_v1.2.2.sh)                  #
#               -Edit this script to suit your setup. Note that all you need   #
#                to configure if you want to call the script with arguments is #
#                the location of the config-/logfiles.                         #
#               -Execute the script manually to spot any obvious errors.       #
#               -If the execution went fine, set DEBUG to 0 (DEBUG=0).         #
#               -Add it to your crontab (crontab -e) by writing something like:#
#                0,20,40 * * * * /glftpd/bin/free_space_v1.2.2.sh              #
#                or if you want to call it with arguments:                     #
#                0,20,40 * * * * /glftpd/bin/free_space_v1.2.2.sh <MIN_FREE_SPACE> <MAX_SPACE_ALLOWED> <"INCOMINGPATH"> <"VIP_DIRS"> <"VIP_GROUPS"> <ANNOUNCE> <DELETE_NUKES_TIME> <NAP> <"SECTION_NAME">
#                DEBUG, GL_CONFIG_FILE, GL_LOG_FILE and ERROR_LOG_FILE must be #
#                set in this file. Note that you can't have multiple           #
#                executions of the same script in some (or all) crontabs       #
#                unless u put them as background jobs.                         #
#               +NOTE to people not using glftpd: Just make shure that all the #
#                logs exists and that $NUKED_DIR_NAMES is set, you can         #
#                hardcode it instead of having it read from any config file.   #
#                                                                              #
# Bot config:   -If you are using Darkheart's botscript you should add the     #
#                following 4 lines to sitebot-glftpd.api and then rehash it.:  #
#                set chans(sectionname-AUTODEL) " #channelname "               #
#                               ^-edit                 ^-edit                  #
#                set echovars(AUTODEL) "size section deldir"                   #
#                set enabled_announce(AUTODEL) 1                               #
#                set mask(AUTODEL) "[b]\[%sitein AUTO-DELETE\][b] system freed [b]%size MB[b] in [b]%section[b] by deleting [b]%deldir[b]"
#               -If you are using vShit's botscript you should add the         #
#                following line in the scanlog proc and then rehash it.:       #
#                AUTODEL: {sndall "[b]\[$sitename AUTO-DELETE\][b] system freed [b][lindex $args 0] MB[b] in [b][lindex $args 1][b] by deleting [b][lindex $args 2][b]"}
#               -If you are using vrpack botscript you should add the          #
#                following line in the scanlog proc and then rehash it.:       #
#                AUTODEL: {sndall "\002\[$sns AUTO-DELETE\]\002 system freed \002[lindex $args 0] MB\002 in \002[lindex $args 1]\002 by deleting \002[lindex $args 2]\002"}
#               -If you are using Dark0n3's botscript you should add 'AUTODEL' #
#                to the list in 'set msgtypes(DEFAULT) "..."' in dZSbot.tcl.   #
#                Also add the following 4 lines and then rehash it.:           #
#                set chanlist(AUTODEL) "#channelname"                          #
#                                            ^-edit                            #
#                set disable(AUTODEL) 0                                        #
#                set variables(AUTODEL) "%size %msg %deldir"                   #
#                set announce(AUTODEL) "%bold\[%sitename AUTO-DELETE\]%bold system freed %bold%size%bold MB in %bold%msg%bold by deleting %bold%deldir%bold"
#                                                                              #
# Requirements: awk, cut, date, df, du, echo, expand, expr, file_age, grep,    #
#               ls, rm, sed, sleep, tail, tr.                                  #
#                                                                              #
# Limitations:  -Can only handle dirnames without spaces (dirs that are inside #
#                the releases (like CD1, sample and "[COMPLETE 100%]") can     #
#                have spaces in them).                                         #
#               -The chars '[' and ']' are only supported in nuked dirs.       #
#               -Oldest "item" (file or dir) must be a directory.              #
#               -Nuked directories names must start with the nukedir_style.    #
#                                                                              #
# Changelog:    v1.0 -> v1.1.beta:       Certain groups releases can now be    #
#                                        set to not be deleted.                #
#               Changes in settings:     N/A.                                  #
#               v1.1.beta -> v1.1.beta.2:A bug in $VIP_DIRS was fixed.         #
#               Changes in settings:     None.                                 #
#               v1.1.beta.2 -> v1.1beta3:Some checks have been implemented to  #
#                                        make the script less sensitive to     #
#                                        faulty settings/dirnames/filenames.   #
#                                        Added a DEBUG setting that disables   #
#                                        the actual deleting.                  #
#                                        Also made the script send any errors  #
#                                        to glftpd's error.log.                #
#                                        On some systems, 'df -m' didn't work  #
#                                        as planned. Changed it to 'df -Pm'.   #
#                                        Also added braces around the para-    #
#                                        meters that are sent to glftpd.log.   #
#               Changes in settings:     Specify $ERROR_LOG_FILE and $DEBUG.   #
#               v1.1beta3 -> v1.2:       Made the DEBUG feature give some      #
#                                        feedback.                             #
#                                        The script should now work in *BSD    #
#                                        since i've changed the parameters to  #
#                                        'df', 'du' and 'ls'.                  #
#                                        Added a new variable, $NAP, that      #
#                                        makes the script wait $NAP seconds    #
#                                        between deletions. This is for those  #
#                                        whos fs isn't updating its free space #
#                                        immediately (like BSD's softupdate).  #
#                                        Rewrote the entire deletion of nuked  #
#                                        dirs since it wasn't working well on  #
#                                        all os's. In fact it didn't work well #
#                                        at all. It now uses an external       #
#                                        binary since i saw no other choice.   #
#                                        The script can now take the settings  #
#                                        as arguments to the script.           #
#                                        Also made some minor changes that     #
#                                        might improve performance.            #
#               Changes in settings:     Specify $NAP.                         #
#               v1.2 -> v1.2.1:          Fixed a bug that caused some dirs to  #
#                                        not get deleted if their names were   #
#                                        similar to a $VIP_DIR.                #
#               Changes in settings:     None.                                 #
#               v1.2.1 -> v1.2.2:        Refined the search for $VIP_GROUPS    #
#                                        dirnames, if 2 groups names were too  #
#                                        similar, both could be excluded.      #
#                                        Fixed a problem when using $NAP, it   #
#                                        deleted 1 release too much.           #
#                                        Corrected the instructions for        #
#                                        Dark0n3's botscript.                  #
#                                        Made the script check if 'file_age'   #
#                                        can be executed.                      #
#               Changes in settings:     None.                                 #
################################################################################
# This setting disables the actual deleting of the dirs. Set to 0 for no debug.
DEBUG=1

# How many Megabyte shall be kept free? (free space when script exits)
MIN_FREE_SPACE=1000

# If you only want to use a part of the device for the section this script keeps
# free you can set that amount (in MB) here. If you want to use the entire
# device, set this to 0 (zero). The above setting is nescessary too.
# Just think of this setting as the capacity of the disc. If you have a device
# with a capacity of 40000 MB and you want the section to only occupy 25000 MB
# of it, set this to 25000. Since the script uses this value as the capacity of
# the device, make shure there's at least this much space available.
MAX_SPACE_ALLOWED=0

# Where are the dirs to be freed located? (eg, /glftpd/site/iso/)
# Use a trailing frontslash (/).
INCOMINGPATH="/glftpd/site/iso/"

# Put any dirs you don't want deleted here (directly inside INCOMINGPATH). Case
# sensitive. Separate them with space and DON'T use a trailing frontslash (/).
VIP_DIRS="temp pics.of.my.gf predir"

# What groups releases don't you want this script to delete? Separate with space
VIP_GROUPS="risc dod flt tfe"

# Do you want the script to write to glftpd.log? (for announcing) [y/n]
ANNOUNCE=y

# How long shall a nuked dir stay on site (in hours) before it's deleted?
DELETE_NUKES_TIME=0

# For how many seconds shall the script wait between deletions? This is only
# interesting if your fs isn't updating its free space immediately. (like BSD's
# softupdate). The script will delete smaller dirs without waiting (up to about
# 100 MB). Set to zero (0) to disable the delay.
NAP=0

# What do you want the botscript to call the section? (eg, VCD, iSO, DivX)
SECTION_NAME=iSO

# What's the location of glftpd.conf?
GL_CONFIG_FILE="/etc/glftpd.conf"

# What's the location of glftpd.log?
GL_LOG_FILE="/glftpd/ftp-data/logs/glftpd.log"

# What's the location of glftpd's error.log?
ERROR_LOG_FILE="/glftpd/ftp-data/logs/error.log"

################################################################################
# No more specifications needed below,just some editing if the script won't work
################################################################################

if [ $# -ne 0 ] && [ $# -ne 9 ]; then
  if [ $DEBUG -ne 0 ]; then
    echo "Too few or too many arguments to script, aborting."
  elif [ -w $ERROR_LOG_FILE ]; then
    echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to execute:" \
    "too few or too many arguments to script, aborting." >> $ERROR_LOG_FILE
  fi
  exit 1
fi

if [ $# -eq 9 ]; then
  MIN_FREE_SPACE=$1
  MAX_SPACE_ALLOWED=$2
  INCOMINGPATH=$3
  VIP_DIRS=$4
  VIP_GROUPS=$5
  ANNOUNCE=$6
  DELETE_NUKES_TIME=$7
  NAP=$8
  SECTION_NAME=$9
fi

# Scan glftpd.conf for the nukestyle.
NUKED_DIR_NAMES=`grep nukedir_style -i $GL_CONFIG_FILE | grep -v '#' | \
awk '{print $2}' | awk -F "%N" '{print $1}' | sed s/"\["/"\\\\\["/ | \
sed s/"\]"/"\\\\\]"/`

# Check for disk usage/free space.
if [ $MAX_SPACE_ALLOWED -eq 0 ]; then
  FREE_ON_DEVICE=`df -Pm "$INCOMINGPATH" | grep "/dev/" | awk '{print $4}'`
else
  SPACE_USED=`expr \`du -ks "$INCOMINGPATH" | awk '{print $1}'\` / 1024`
  FREE_ON_DEVICE=`expr $MAX_SPACE_ALLOWED - $SPACE_USED`
fi

# Just make shure some things exist...
if [ ! -r "$GL_CONFIG_FILE" ] || [ ! -w "$GL_LOG_FILE" ] || \
[ ! -w "$ERROR_LOG_FILE" ] || [ ! -d "$INCOMINGPATH" ]; then
  if [ $DEBUG -ne 0 ]; then
    echo "One or more of your settings are faulty, aborting."
  elif [ -w $ERROR_LOG_FILE ]; then
    echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to execute:" \
    "one or more of your settings are faulty" >> $ERROR_LOG_FILE
  fi
  exit 1
fi
if [ -z $NUKED_DIR_NAMES ] || [ -z $MIN_FREE_SPACE ] || \
[ -z $FREE_ON_DEVICE ]; then
  if [ $DEBUG -ne 0 ]; then
    echo "Error in script: variables not set properly, aborting."
  elif [ -w $ERROR_LOG_FILE ]; then
    echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to execute:" \
    "error in script, variables not set properly" >> $ERROR_LOG_FILE
  fi
  exit 1
fi
if [ ! -x `which file_age` ];then
  if [ $DEBUG -ne 0 ]; then
    echo "Error in script: the binary 'file_age' couldn't be found, aborting."
  elif [ -w $ERROR_LOG_FILE ]; then
    echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to execute:" \
    "error in script, the binary 'file_age' couldnt be found" >> $ERROR_LOG_FILE
  fi
  exit 1
fi

DEL_DIR_SIZE=0
DEL_DIR_SIZE_SUM=0

# Loop until enough space has been freed.
until [ $FREE_ON_DEVICE -gt $MIN_FREE_SPACE ]; do
  # Find oldest nuked dir and its modification time.
  DEL_DIR=`ls -lt "$INCOMINGPATH" | awk '{print $9}' | tr -d '/' | \
  grep ^"$NUKED_DIR_NAMES" | tail -n 1 | sed s/"\["/"\\\\\["/ | \
  sed s/"\]"/"\\\\\]"/`

  DEL_DIR=`echo "$DEL_DIR" | sed s/'\\\\\['/'\['/ | sed s/'\\\\\]'/'\]'/`

  # Delete oldest nuked dir if it's older than $DELETE_NUKES_TIME. Otherwise
  # delete the oldest dir. Also get the size for the botscript.
  if [ `file_age "$INCOMINGPATH$DEL_DIR"` -ge $DELETE_NUKES_TIME ] && \
  [ "$DEL_DIR" ] && [ -d "$INCOMINGPATH$DEL_DIR" ];then
    DEL_DIR_SIZE=`expr \`du -ks "$INCOMINGPATH$DEL_DIR" | awk '{print $1}'\` \
    / 1024`
    if [ $DEBUG -eq 0 ]; then
      rm -rf "$INCOMINGPATH$DEL_DIR"
    else
      echo "Deleting $INCOMINGPATH$DEL_DIR"
    fi
  else
    # Create a list for use in $DEL_DIR with rel's that aren't to be deleted.
    EXCLUDE_DIRS=""
    if [ "$VIP_GROUPS" ] || [ "$VIP_DIRS" ]; then
      for VIP_GROUP in $VIP_GROUPS; do
        EXCLUDE_DIR=`ls "$INCOMINGPATH" | grep -i "[-_.]$VIP_GROUP$"`
        EXCLUDE_DIRS=`echo $EXCLUDE_DIRS$EXCLUDE_DIR" "`
      done
      for VIP_DIR in $VIP_DIRS; do
        EXCLUDE_DIR=`ls "$INCOMINGPATH" | grep -x "$VIP_DIR"`
        EXCLUDE_DIRS=`echo $EXCLUDE_DIRS$EXCLUDE_DIR" "`
      done
    fi
    # Remove all $EXCLUDE_DIRS from the "delete-list".
    DEL_DIR=`ls -lt "$INCOMINGPATH" | awk '{print $9}' | \
    grep -v ^'$NUKED_DIR_NAMES' | tr -d '/'`
    for EXCLUDE_DIR in $EXCLUDE_DIRS; do
      DEL_DIR=`echo "$DEL_DIR" | grep -v ^"$EXCLUDE_DIR"$`
    done
    DEL_DIR=`echo "$DEL_DIR" | tail -n1`

    if [ "$DEL_DIR" ] && [ -d "$INCOMINGPATH$DEL_DIR" ]; then
      DEL_DIR_SIZE=`expr \`du -ks "$INCOMINGPATH$DEL_DIR" | awk '{print $1}'\` \
      / 1024`
      if [ $DEBUG -eq 0 ]; then
        rm -rf "$INCOMINGPATH$DEL_DIR"
      else
        echo "Deleting $INCOMINGPATH$DEL_DIR"
      fi
    else
      if [ $DEBUG -ne 0 ]; then
        echo "Error in script: no directory to delete, aborting."
      elif [ -w $ERROR_LOG_FILE ]; then
        echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to" \
        "execute: error in script, no directory to delete" >> $ERROR_LOG_FILE
      fi
      exit 1
    fi
  fi

  # Announce deletion if $ANNOUNCE is set to "y".
  if [ $ANNOUNCE = y ]; then
    echo `date +"%a %b %d %T %Y"` AUTODEL: \""$DEL_DIR_SIZE"\" \
    \""$SECTION_NAME"\" \""$DEL_DIR"\" >> $GL_LOG_FILE
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
