#!/bin/sh

################################################################################
# Script name:  predircheck_v1.4.sh                                            #
# Author:       SoD-                                                           #
# Contact:      SoD- @ EFNet                                                   #
# Releasedate:  2003-04-25                                                     #
#                                                                              #
# This script have been confirmed to work in Slackware 8.0 and FreeBSD 4.7/5.0.#
# This script is to be executed by glftpd before a directory is created. The   #
# outcome of this script decides whether glftpd will create the dir or not.    #
# It checks for up to 4 things (depending on if you enable all checks or not): #
# * Checks for dupe in the dupelog.                                            #
# * Checks for what group the release origins from, banned or affil.           #
# * Checks for release year (for mp3's).                                       #
# * Checks for previous nuke in glftpd.log.                                    #
# It also lets you rename CDx dirs to:                                         #
# 1: all lower case                       (Cd1->cd1, CD1->cd1, cd1->cd1)       #
# 2: all lower case except for first char (Cd1->Cd1, CD1->Cd1, cd1->Cd1)       #
# 3: all upper case                       (Cd1->CD1, CD1->CD1, cd1->CD1)       #
# This feature makes shure you don't get different versions of CDx dirs (like  #
# one dir called 'Cd1' and one called 'CD1').                                  #
#                                                                              #
# Installation: -Put this file in some approperiate place, for example         #
#                /glftpd/bin/predircheck_v1.4.sh                               #
#               -Make it executable                                            #
#                (chmod 755 /glftpd/bin/predircheck_v1.4.sh)                   #
#               -Edit glftpd.conf and change the line with pre_dir_check to:   #
#                pre_dir_check /bin/predircheck_v1.4.sh                        #
#               -Edit this script to suit your needs.                          #
#                                                                              #
# Requirements: awk, cut, echo, expr, grep, ls, tail, tr.                      #
#               NOTE: As this script is run chrooted, the bins and their       #
#                     associated libs must be in /glftpd/bin/ and /glftpd/lib/.#
#                                                                              #
# Limitations:  -Can't handle dirnames with spaces in them.                    #
#               -Can't handle groupnames with hyphens in them (like 14m3-VCD). #
#                                                                              #
# Changelog:    v1.0 -> v1.1:          The script can now deny uploads of a    #
#                                      certain groups releases (so affils dont #
#                                      get raced).                             #
#               Changes in settings:   N/A.                                    #
#               v1.1 -> v1.2.beta:     Fixed a minor bug that RARELY would     #
#                                      cause the script to report a dupe when  #
#                                      it wasn't. Also made $AFFILS and        #
#                                      $BANNED_GROUPS case insensitive so that #
#                                      the output from the script will look a  #
#                                      bit nicer. Some speed improvements were #
#                                      also made.                              #
#               Changes in settings:   $AFFILS and $BANNED_GROUPS can be       #
#                                      changed to case insensitive (optional). #
#               v1.2.beta -> v1.3beta: The script can now rename CDx-dirs to   #
#                                      'CDx', 'Cdx' or 'cdx'.                  #
#               Changes in settings:   Specify $CDX_STYLE and $PASSWD_FILE and #
#                                      invoke the new feature in the           #
#                                      case-switch at the bottom if you intend #
#                                      to use the feature.                     #
#               v1.3beta -> v1.3beta2: Just cleaned away 1 row of unnescessary #
#                                      code and added a snippet to handle      #
#                                      existing CDx dirs nicer.                #
#               Changes in settings:   None.                                   #
#               v1.3beta2 -> v1.3beta3:Fixed problem with CDx not being logged.#
#                                      Also removed the $PASSWD_FILE setting,  #
#                                      forgot to do it in the previous release.#
#                                      I've changed all "exit" in the script,  #
#                                      they are now "exit 0" or "exit 1". Also #
#                                      changed the way the script exits in the #
#                                      case-switch, looks better this way.     #
#               Changes in settings:   Remove $PASSWD_FILE setting if you want.#
#                                      Specify $GL_LOG_FILE.                   #
#               v1.3beta3 -> v1.3:     Changed all "exit 1" to "exit 2" so the #
#                                      script won't give the "550 Dirscript    #
#                                      could not be executed!." error anymore. #
#                                      Rewrote a few things so they look nicer.#
#               Changes in settings:   None.                                   #
#               v1.3 -> v1.3.1:        Replaced $PWD with $2 so it should now  #
#                                      work in *BSD aswell. Made it possible   #
#                                      to set affils according to the content  #
#                                      of a dir (ie, a dir in which all affils #
#                                      have their own dir).                    #
#               Changes in settings:   Change $AFFILS to a dir if you want.    #
#               v1.3.1 -> v1.4:        Made it possible to set multiple paths  #
#                                      and/or affil names in $AFFILS. Also     #
#                                      made it possible for the script to deny #
#                                      upload of a previously nuked dir.       #
#               Changes in settings:   Change $AFFILS and use check_nukes if   #
#                                      you want.                               #
################################################################################

# Put your affils here. You can set the affils names and/or path(s) to dirs
# containing subdirs named as your affils. Case insensitive on affil names.
AFFILS="SND /site/pre/ cnmc RiSE KvEXXX /site/affils/"

# Put whatever groups from whatever scene you want banned here, case
# insensitive, separate with space.
BANNED_GROUPS="iMPG iDC KrbZ cDiAMOND"

# Set years you want banned. All years up until and including this one will be
# denied by the script if you invoke this function. Only for the mp3 scene.
BANNED_YEARS="2002"

# How do you want to format the CDx dirs? Put a '1' if you want it all in lower
# case (cd1), '2' if you want it all in lower case except for the first char
# (Cd1) or '3' if you want it all in upper case (CD1).
CDX_STYLE=3

# Where is your dupelog located (relative to glftpd root)?
GL_DUPELOG="/ftp-data/logs/dupelog"

# Where is your glftpd.log located (relative to glftpd root)?
GL_LOG_FILE="/ftp-data/logs/glftpd.log"

# Now setup your sections and what features to use in them in the case-switch at
# the bottom of the script.
################################################################################

# This function denies creation of previously nuked dirs.
check_nukes () {
  if [ "`grep -ai \" NUKE: \\"$2/$1\\" \" $GL_LOG_FILE | tail -n1`" ];then
    echo "$1 has been nuked"
    exit 2
  fi
}

# This function makes shure banned groups releases don't get uploaded.
check_banned_groups () {
  GROUP=`echo $1 | awk -F "-" '{print $NF}' | tr '[:upper:]' '[:lower:]'`
  for BANNED_GROUP in $BANNED_GROUPS; do
    if [ `echo $BANNED_GROUP | tr '[:upper:]' '[:lower:]'` = $GROUP ]; then
      echo ""$BANNED_GROUP"'s releases are banned"
      exit 2
    fi
  done
}

# This function makes shure that no dupes gets uploaded.
scan_dupelog () {
  TMP=`grep -ix "...... $1" $GL_DUPELOG | tail -n1`
  if [ "$TMP" ]; then
    echo "$1 already exists in the dupelog, it was last created at"\
    " `echo $TMP | awk '{print $1}'`"
    exit 2
  fi
}

# This function denies creation of too old mp3's.
check_banned_years () {
  YEAR=`echo $1 | awk -F "-" '{print $(NF-1)}' | tr -d "()"`
  if [ $YEAR -le $BANNED_YEARS ]; then
    echo "This site only accepts releases newer than year $BANNED_YEARS"
    exit 2
  fi
}

# This function makes shure that no one races your affils.
check_affils () {
  for TEMP in $AFFILS; do
    if [ "`echo "$TEMP" | grep '/'`" ]; then
      if [ -d "$TEMP" ] && [ -r "$TEMP" ]; then
        AFFILSS=`echo $AFFILSS \`ls "$TEMP"\``
      fi
    else
      AFFILSS=`echo $AFFILSS "$TEMP"`
    fi
  done

  GROUP=`echo $1 | awk -F "-" '{print $NF}' | tr '[:upper:]' '[:lower:]'`
  for AFFIL in $AFFILSS; do
    if [ `echo $AFFIL | tr '[:upper:]' '[:lower:]'` = $GROUP ]; then
      echo "$AFFIL are affils here"
      exit 2
    fi
  done
}

# This function changes the style (upper/lower case) of CDx dirs.
change_case () {
  if [ "`ls $2 | grep -i "^$1$"`" ] && [ ! "`ls $2 | grep "^$1$"`" ]; then
    echo "This directory exists, but with a different case"
    exit 2
  fi
  if [ `echo $1 | grep -i cd.` ]; then
    if [ $CDX_STYLE = 1 ]; then
      DIRNAME=`echo $1 | tr '[:upper:]' '[:lower:]'`
    elif [ $CDX_STYLE = 2 ]; then
      DIRNAME="Cd`echo $1 | cut -c 3-4`"
    elif [ $CDX_STYLE = 3 ]; then
      DIRNAME=`echo $1 | tr '[:lower:]' '[:upper:]'`
    fi
    if [ $DIRNAME != $1 ]; then
      mkdir $2/$DIRNAME
      echo `date +"%a %b %d %T %Y"` NEWDIR: \"$2/$DIRNAME\" \"$USER\" \
      \"$GROUP\" \"$TAGLINE\" >> $GL_LOG_FILE
      echo "\"$1\" is not accepted, \"$DIRNAME\" will be created instead"
      exit 2
    fi
  fi
}

# Just put your paths here and call any (or none) of the above functions. Just 
# look at the examples and I think you'll understand how it works. Remember to
# exit every case with "exit 0" followed by ";;".
case $2/$1 in
  /site/mp3/????/*/*  ) change_case $1 $2
                        exit 0
                        ;;

  /site/mp3/????/*    ) scan_dupelog $1
                        check_nukes $1 $2
                        check_banned_groups $1
                        check_banned_years $1
                        check_affils $1
                        exit 0
                        ;;

  /site/vcd/*/*       ) change_case $1 $2
                        exit 0
                        ;;

  /site/vcd/*         ) scan_dupelog $1
                        check_nukes $1 $2
                        check_affils $1
                        exit 0
                        ;;

  /site/iso/*/*       ) change_case $1 $2
                        exit 0
                        ;;

  /site/iso/*         ) scan_dupelog $1
                        check_nukes $1 $2
                        check_banned_groups $1
                        exit 0
                        ;;

  /site/0day/????/*   ) scan_dupelog $1
                        check_nukes $1 $2
                        check_banned_groups $1
                        exit 0
                        ;;

  *                   ) exit 0
                        ;;

esac
