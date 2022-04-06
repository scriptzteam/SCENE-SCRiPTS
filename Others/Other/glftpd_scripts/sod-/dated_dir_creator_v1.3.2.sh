#!/bin/bash

################################################################################
# Script name:  dated_dir_creator_v1.3.2.sh                                    #
# Author:       SoD-                                                           #
# Contact:      SoD- @ EFNet                                                   #
# Releasedate:  2003-02-19                                                     #
#                                                                              #
# This script have been confirmed to work in Slackware 8.0/8.1, Debian 3.0 and #
# FreeBSD 4.5.                                                                 #
# This script is to be executed from crontab every midnight (or 23:59 to be    #
# more exact) and then creates new dated dirs in the paths you've specified.   #
# It chmods them and yesterdays dir and if you want, creates symlinks to them. #
# It lets you set the "closing-time" of yesterdays dir and it writes to        #
# glftpd.log in such a way that a bot can announce it.                         #
# It can also announce the total DAYUP and the 3 best uploaders of today,      #
# their speed and the amount they've uploaded for every section.               #
# It is also possible to just use the script as a stats announcer. For this    #
# you just set the $PATHS variable to "" and ignore $SYMLINKS, $DIR_NAME and   #
# $ARCHIVE_CLOSING_TIME.                                                       #
# The script takes 1 minute to execute (since it's executed at 23:59 for the   #
# stats sake and needs to create dirs at 00:00) so don't be alarmed that       #
# "nothing" happens when it's executed.                                        #
#                                                                              #
# Installation: -Put this file in some approperiate place, for example         #
#                /glftpd/bin/dated_dir_creator_v1.3.2.sh                       #
#               -Make it executable                                            #
#                (chmod 755 /glftpd/bin/dated_dir_creator_v1.3.2.sh)           #
#               -Make an entry in your crontab so that the script is run at    #
#                23:59 every night:                                            #
#                59 23 * * * /glftpd/bin/dated_dir_creator_v1.3.2.sh           #
#               -Edit this script to suit your needs.                          #
#               +NOTE to people not using glftpd: Stats announcing isn't       #
#                supported since it requires the stats bin. So set $ANNOUNCE   #
#                to 'n' or '1' and make shure glftpd.log's equivalence exists. #
#                                                                              #
# Bot config:   -If you are using Darkheart's botscript you should add the     #
#                following 12 lines to sitebot-glftpd.api and then rehash it.: #
#                set chans(sectionname-NEW_DATED_DIR) " #channelname "         #
#                               ^-edit                       ^-edit            #
#                set chans(sectionname-CLOSED_DATED_DIR) " #channelname "      #
#                               ^-edit                          ^-edit         #
#                set chans(sectionname-TODAY_STATS) " #channelname "           #
#                               ^-edit                     ^-edit              #
#                set echovars(NEW_DATED_DIR) "name section archive_close_time" #
#                set echovars(CLOSED_DATED_DIR) "name section"                 #
#                set echovars(TODAY_STATS) "section dayup_section_bytes first bytes_first speed_first second bytes_second speed_second third bytes_third speed_third"
#                set enabled_announce(NEW_DATED_DIR) 1                         #
#                set enabled_announce(CLOSED_DATED_DIR) 1                      #
#                set enabled_announce(TODAY_STATS) 1                           #
#                set mask(NEW_DATED_DIR) "[b]\[%sitein NEW DATED DIR\][b] [b]%name[b] created in [b]%section[b] %archive_close_time"
#                set mask(CLOSED_DATED_DIR) "[b]\[%sitein CLOSED DIR\][b] [b]%name[b] in [b]%section[b] has been closed"
#                set mask(TODAY_STATS) "[b]\[%sitein TODAY STATS\][b] Total uploaded in %section:[b]%dayup_section_bytes[b]MB. DAYUP winner:[b]%first[b] with [b]%bytes_first[b]MB@[b]%speed_first[b]kBps. Runner up:[b]%second[b] with [b]%bytes_second[b]MB@[b]%speed_second[b]kBps. Third:[b]%third[b] with [b]%bytes_third[b]MB@[b]%speed_third[b]kBps."
#               -If you are using vShit's botscript you should add the         #
#                following 3 lines in the scanlog proc and then rehash it.:    #
#                NEW_DATED_DIR: {sndall "[b]\[$sitename NEW DATED DIR\][b] [b][lindex $args 0][b] created in [b][lindex $args 1][b] [lindex $args 2]"}
#                CLOSED_DATED_DIR: {sndall "[b]\[$sitename CLOSED DIR\][b] [b][lindex $args 0][b] in [b][lindex $args 1][b] has been closed"}
#                TODAY_STATS: {sndall "[b]\[$sitename TODAY STATS\][b] Total uploaded in [b][lindex $args 0][b]:[b][lindex $args 1][b]MB. DAYUP winner:[b][lindex $args 2][b] with [b][lindex $args 3][b]MB@[b][lindex $args 4][b]kBps. Runner up:[b][lindex $args 5][b] with [b][lindex $args 6][b]MB@[b][lindex $args 7][b]kBps. Third:[b][lindex $args 8][b] with [b][lindex $args 9][b]MB@[b][lindex $args 10][b]kBps."}
#               -If you are using vrpack (1.6.0 Beta) botscript you should add #
#                the following 3 lines in the scanlog proc and then rehash it.:#
#                NEW_DATED_DIR: {sndall "\002\[$sns NEW DATED DIR\]\002 \002[lindex $args 0]\002 created in \002[lindex $args 1]\002 [lindex $args 2]"}
#                CLOSED_DATED_DIR: {sndall "\002\[$sns CLOSED DIR\]\002 \002[lindex $args 0]\002 in \002[lindex $args 1]\002 has been closed"}
#                TODAY_STATS: {sndall "\002\[$sns TODAY STATS\]\002 Total uploaded in\002[lindex $args 0]\002:\002[lindex $args 1]\002MB. DAYUP winner:\002[lindex $args 2]\002 with \002[lindex $args 3]\002MB@\002[lindex $args 4]\002kBps. Runner up:\002[lindex $args 5]\002 with \002[lindex $args 6]\002MB@\002[lindex $args 7]\002kBps. Third:\002[lindex $args 8]\002 with \002[lindex $args 9]\002MB@\002[lindex $args 10]\002kBps."}
#               -If you are using Dark0n3's botscript you should add           #
#                'NEW_DATED_DIR', 'CLOSED_DATED_DIR' and 'TODAY_STATS' to the  #
#                list in 'set msgtypes(DEFAULT) "..."' in dZSbot.tcl.          #
#                Also add the following 12 lines and then rehash it.:          #
#                set chanlist(NEW_DATED_DIR) "#put_your_channel_name_here"     #
#                set chanlist(CLOSED_DATED_DIR) "#put_your_channel_name_here"  #
#                set chanlist(TODAY_STATS) "#put_your_channel_name_here"       #
#                set disable(NEW_DATED_DIR) 0                                  #
#                set disable(CLOSED_DATED_DIR) 0                               #
#                set disable(TODAY_STATS) 0                                    #
#                set variables(NEW_DATED_DIR) "%new_dir %s3ction %old_close_time"
#                set variables(CLOSED_DATED_DIR) "%old_dir %s3ction"           #
#                set variables(TODAY_STATS) "%s3ction %dayup_section %first %dayup_first %speed_first %second %dayup_second %speed_second %third %dayup_third %speed_third"
#                set announce(NEW_DATED_DIR) "%bold\[%sitename NEW DATED DIR\] %new_dir%bold created in %bold%s3ction %old_close_time"
#                set announce(CLOSED_DATED_DIR) "%bold\[%sitename CLOSED DIR\] %old_dir%bold in %bold %s3ction%bold has been closed"
#                set announce(TODAY_STATS) "%bold\[%sitename TODAY STATS\]%bold Total uploaded in %bold%s3ction%bold:%bold%dayup_section%boldMB. DAYUP winner:%bold%first%bold with %bold%dayup_first%boldMB@%bold%speed_first %boldkBps. Runner up:%bold%second%bold with %bold%dayup_second%boldMB@%bold%speed_second%boldkBps. Third:%bold%third%bold with %bold%dayup_third%boldMB@%bold%speed_third%boldkBps."
#                                                                              #
# Requirements: awk, chmod, cut, date, du, echo, expr, grep, head, ln, ls,     #
#               mkdir, rm, sed, sleep, stats (comes with glftpd), tail, tr.    #
#                                                                              #
# Limitations:  -Can't handle dirnames with spaces in them.                    #
#               -You might also wanna check the rules for symlinks inside      #
#                your ftpd.                                                    #
#                                                                              #
# Changelog:    v1.0 -> v1.1.beta:     Now handles an $ARCHIVE_CLOSING_TIME of #
#                                      an infinite amount of hours.            #
#               Changes in settings:   None.                                   #
#               v1.1.beta -> v1.2beta: Fixed a bug that messed up the chmod of #
#                                      yesterdays dir. Announcing also got     #
#                                      fucked due to that. Also added a new    #
#                                      feature that lets you announce the      #
#                                      DAYUP winner for yesterdays dir, the    #
#                                      amount he has uploaded and the total    #
#                                      amount in yesterdays dir for every      #
#                                      section.                                #
#               Changes in settings:   Update botscript so it triggers on      #
#                                      "YESTERDAY_STATS:" and edit crontab so  #
#                                      this script is executed at 23:59.       #
#               v1.2beta -> v1.3beta:  Cleaned and speeded up the script a bit.#
#                                      Also made it possible to announce other #
#                                      sections stats (besides the DATED-DIRS).#
#                                      The avg speed of the DAYUP winner is    #
#                                      also written to glftpd.log. It now also #
#                                      announces dayup #2 and #3 stats.        #
#               Changes in settings:   $SECTION_NAMES is no longer being used, #
#                                      it's now taken from glftpd.conf.        #
#                                      Specify location of the stats binary,   #
#                                      update the botscript and set            #
#                                      $ANNOUNCE_SECTIONS. Also arrange the    #
#                                      stat_sections as mentioned above.       #
#               v1.2beta -> v1.3beta2: Reintroduced $SECTION_NAMES since the   #
#                                      other solution didn't suit all setups.  #
#               Changes in settings:   Specify $SECTION_NAMES and arrange your #
#                                      stat_section's anyway you want.         #
#               v1.3beta2 -> v1.3beta3:Fixed a bug with the creation of the    #
#                                      symlink.                                #
#                                      The script should now work in FreeBSD.  #
#                                      Changed so that the day-stats are shown #
#                                      after the creation of the new dated dir.#
#                                      Added some checks for valid paths.      #
#                                      Added braces around the parameters that #
#                                      are sent to glftpd.log.                 #
#                                      Made it possible to not show the stats  #
#                                      (2 levels of announcing).               #
#                                      Made the script check for some things   #
#                                      so it wont complain about stupid things.#
#               Changes in settings:   Set $ANNOUNCE correctly and specify $OS.#
#               v1.3beta3 -> v1.3:     Fixed a typo that disabled the usage of #
#                                      $DIR_NAME in FreeBSD.                   #
#               Changes in settings:   None.                                   #
#               v1.3 -> v1.3.1:        Stats from more than 1 section didn't   #
#                                      work, it only displayed the last        #
#                                      sections stats. Fixed now. Also removed #
#                                      the $GL_USER_FILES setting since i      #
#                                      forgot to do it in the previous release.#
#                                      Changed so errors are redirected to     #
#                                      error.log. Added bot instructions for   #
#                                      Dark0n3's botscript.                    #
#               Changes in settings:   Ignore or remove the $GL_USER_FILES     #
#                                      setting and specify $ERROR_LOG_FILE.    #
#               v1.3.1 -> v1.3.2:      Made the script announce stats properly #
#                                      when using multiple instances of glftpd #
#                                      (multiple glftpd.conf on one box).      #
#               Changes in settings:   None.                                   #
################################################################################
# Here you specify the dirs in were you want new dated dirs created. Use a
# trailing frontslash (/) for every path and separate them with a space.
PATHS="/glftpd/site/mp3/ /glftpd/site/0-day/ /glftpd/site/porn_pics/"

# What do you want the botscript to call the sections that it creates the dated
# dirs in. Put in same order as $PATHS and separate them with a space.
SECTION_NAMES="MP3 0-DAY PR0N"

# Whats the name and location of the symlinks to the "today"-dirs? Set it to "a"
# if you don't want a "today"-symlink. Put in same order as $PATHS and separate
# them with a space. Don't use a trailing frontslash (/).
SYMLINKS="/glftpd/site/today-mp3 a /glftpd/site/today-pr0n"

# What name do you want the dated dirs to get? (eg, %m%d, %m-%d, %Y.%d.%m). This
# applies to all sections. These are a few options (taken from dates man-page):
# %a  -  locale's abbreviated weekday name (Sun..Sat)
# %b  -  locale's abbreviated month name (Jan..Dec)
# %d  -  day of month (01..31)
# %m  -  month (01..12)
# %Y  -  last two digits of year (00..99)
DIR_NAME="%m%d"

# How long after the creation of the new dated dirs shall creation of dirs be
# allowed in old dirs. (ie, for how long past midnight shall the users be
# allowed to upload in yesterdays dir). Put in same order as $PATHS and separate
# them with a space. Time in full hours (no 0.5, 2.5, ...).
ARCHIVE_CLOSING_TIME="1 3 0"

# Which sections DAYUP stats do you want announced? They are numbered from 0 
# and up in the same order as they are in glftpd.conf (stat_section). Make shure
# you have all these sections. This setting can be ignored (doesn't matter what
# it is) if ANNOUNCE=1 (see below).
ANNOUNCE_SECTIONS="0 2 3"

# Do you want the script to write to glftpd.log (for announcing)? Set to '1' if
# you only want the creation of the new dated dirs to be announced, '2' if you
# also want dayup stats announced or 'n' if you dont want any announcing at all.
ANNOUNCE=2

# What operating system are u running? choices are 'linux' and 'freebsd'.
OS="linux"

# What's the location of glftpd.log?
GL_LOG_FILE="/glftpd/ftp-data/logs/glftpd.log"

# What's the location of glftpd.conf? If you have multiple glftpd.conf, specify
# the one from which you want to use the stats settings.
GL_CONF_FILE="/etc/glftpd.conf"

# What's the location of the binary stats?
GL_STATS="/glftpd/bin/stats"

# What's the location of glftpd's error.log?
ERROR_LOG_FILE="/glftpd/ftp-data/logs/error.log"

################################################################################
# No more specifications needed below,just some editing if the script won't work
################################################################################

if [ `echo $OS | grep -i ^linux$` ]; then
  TODAY_DIR=`date -d '1 day' +$DIR_NAME`
elif [ `echo $OS | grep -i ^freebsd$` ]; then
  TODAY_DIR=`date -v+1d +$DIR_NAME`
else
  exit 1
fi
YESTERDAY_DIR=`date +$DIR_NAME`
COUNTER=1

# This function writes stats for the 3 DAYUP users (site dayup 3), the amount
# they've uploaded, the avg speed they got and the total amount uploaded in
# every section to the $STATS_ANNOUNCE_STRING variable.
get_stats () {
  for ANNOUNCE_SECTION in $ANNOUNCE_SECTIONS; do
    SECTION=`grep ^stat_section $GL_CONF_FILE | \
    head -n\`expr $ANNOUNCE_SECTION + 1\` | tail -n1 | awk '{printf $2}'`

    DAYUP_1_USER=`$GL_STATS -r $GL_CONF_FILE -t -u -s$ANNOUNCE_SECTION | \
    head -n5 | tail -n1 | awk '{print $2}'`
    if [ ! $DAYUP_1_USER ]; then
      DAYUP_1_USER="NA"
    fi

    DAYUP_1_MBYTE=`$GL_STATS -r $GL_CONF_FILE -t -u -s$ANNOUNCE_SECTION | \
    head -n5 | tail -n1 | awk '{print $(NF-1)}' | sed 's/MB//'`
    if [ `echo $DAYUP_1_MBYTE | cut -c1-5` = "-----" ]; then
      DAYUP_1_MBYTE=0
    fi

    DAYUP_1_SPEED=`$GL_STATS -r $GL_CONF_FILE -t -u -s$ANNOUNCE_SECTION | \
    head -n5 | tail -n1 | awk '{printf $NF}' | sed 's/KBs//'`
    if [ `echo $DAYUP_1_SPEED | cut -c1-5` = "-----" ]; then
      DAYUP_1_SPEED=0
    fi

    # Following 27 rows of code calculates values for DAYUP #2 and #3.
    DAYUP_2_USER="NA"; DAYUP_2_MBYTE=0; DAYUP_2_SPEED=0
    DAYUP_3_USER="NA"; DAYUP_3_MBYTE=0; DAYUP_3_SPEED=0
    # Are there any users on DAYUP?
    if [ "$DAYUP_1_USER" != "NA" ]; then
      DAYUP_2_USER=`$GL_STATS -r $GL_CONF_FILE -t -u -s$ANNOUNCE_SECTION | \
      head -n6 | tail -n1 | awk '{print $2}'`
      # Are there more than 1 user on DAYUP?
      if [ "$DAYUP_1_USER" != "$DAYUP_2_USER" ]; then
        DAYUP_2_MBYTE=`$GL_STATS -r $GL_CONF_FILE -t -u -s$ANNOUNCE_SECTION | \
        head -n6 | tail -n1 | awk '{print $(NF-1)}' | sed 's/MB//'`
        DAYUP_2_SPEED=`$GL_STATS -r $GL_CONF_FILE -t -u -s$ANNOUNCE_SECTION | \
        head -n6 | tail -n1 | awk '{printf $NF}' | sed 's/KBs//'`
        DAYUP_3_USER=`$GL_STATS -r $GL_CONF_FILE -t -u -s$ANNOUNCE_SECTION | \
        head -n7 | tail -n1 | awk '{print $2}'`
        # Are there more than 2 users on DAYUP?
        if [ "$DAYUP_2_USER" != "$DAYUP_3_USER" ]; then
          DAYUP_3_MBYTE=`$GL_STATS -r $GL_CONF_FILE -t -u -s$ANNOUNCE_SECTION |\
          head -n7 | tail -n1 | awk '{print $(NF-1)}' | sed 's/MB//'`
          DAYUP_3_SPEED=`$GL_STATS -r $GL_CONF_FILE -t -u -s$ANNOUNCE_SECTION |\
          head -n7 | tail -n1 | awk '{printf $NF}' | sed 's/KBs//'`
        else
          DAYUP_3_USER="NA"
        fi
      else
        DAYUP_2_USER="NA"
      fi
    fi

    # Following 12 rows of code calculates TOTAL DAYUP.
    TOTAL_MEGS=0
    COUNT=1
    NUM_OF_UPLOADERS=`expr \`$GL_STATS -r $GL_CONF_FILE -t -u \
    -s$ANNOUNCE_SECTION | grep -c .\` - 4`
    # Loop through all uploaders of today.
    until [ $NUM_OF_UPLOADERS -eq 0 ]; do
      MEGS=`$GL_STATS -r $GL_CONF_FILE -t -u -s$ANNOUNCE_SECTION | head -n\`expr \
      $COUNT + 4\` | tail -n1 | awk '{print $(NF-1)}' | sed 's/MB//'`
      TOTAL_MEGS=`expr $TOTAL_MEGS + $MEGS`
      let COUNT=$COUNT+1
      let NUM_OF_UPLOADERS=$NUM_OF_UPLOADERS-1
    done

    echo "`date +"%a %b %d %T %Y"` TODAY_STATS: \"$SECTION\" \"$TOTAL_MEGS\" \
\"$DAYUP_1_USER\" \"$DAYUP_1_MBYTE\" \"$DAYUP_1_SPEED\" \
\"$DAYUP_2_USER\" \"$DAYUP_2_MBYTE\" \"$DAYUP_2_SPEED\" \
\"$DAYUP_3_USER\" \"$DAYUP_3_MBYTE\" \"$DAYUP_3_SPEED\"" >> $GL_LOG_FILE
  done

  # Wait until its past midnight.
  sleep 10s
}

# This function chmod's the yesterday dir (and announces it).
chmod_yesterday_dir () {
  sleep `echo $ARCHIVE_CLOSING_TIME | cut -d " " -f$1`h
  if [ -d "`echo $PATHS | cut -d " " -f$1`$YESTERDAY_DIR" ];then
    chmod 555 `echo $PATHS | cut -d " " -f$1`$YESTERDAY_DIR
  fi
  if [ $ANNOUNCE = 1 ] || [ $ANNOUNCE = 2 ] && 
  [ $ARCHIVE_CLOSE_TIME -gt 0 ]; then
    echo `date +"%a %b %d %T %Y"` CLOSED_DATED_DIR: "`date -d \
    "\`echo $ARCHIVE_CLOSING_TIME | cut -d " " -f$1\` hour 1 min ago" \
    +$DIR_NAME`" `echo $SECTION_NAMES | cut -d " " -f$1` >> $GL_LOG_FILE
  fi
}

# Start the script by sleeping 50 seconds (since crontab runs it at 23:59).
sleep 50s

# Write stats-info to glftpd.log if $ANNOUNCE=2.
if [ $ANNOUNCE = 2 ]; then
  get_stats
else
  # Wait until its past midnight.
  sleep 10s
fi

# Loop through all $PATHS.
for PATHH in $PATHS; do
  # Make the new dated dir and change its and yesterday dirs permissions.
  if [ ! -d "$PATHH" ]; then
    if [ -w $ERROR_LOG_FILE ]; then
      echo `date +"%a %b %d %T %Y"` "[        ] Error: $0 failed to execute:" \
      "couldnt create "$PATHH$TODAY_DIR", aborting." >> $ERROR_LOG_FILE
    fi
    exit 1
  elif [ ! -e "$PATHH$TODAY_DIR" ]; then
    mkdir $PATHH$TODAY_DIR
    chmod 777 $PATHH$TODAY_DIR
  fi
  ARCHIVE_CLOSE_TIME=`echo $ARCHIVE_CLOSING_TIME | cut -d " " -f$COUNTER`
  SECTION_NAME=`echo $SECTION_NAMES | cut -d " " -f$COUNTER`
  chmod_yesterday_dir `echo $COUNTER` &

  # Remove old symlink, get the name of the one to create and create it.
  if [ `echo $SYMLINKS | cut -d " " -f$COUNTER` != "a" ]; then
    if [ -h "`echo $SYMLINKS | cut -d " " -f$COUNTER`" ]; then
      rm -f `echo $SYMLINKS | cut -d " " -f$COUNTER`
    fi
    COUNT=1
    # Compare path to dir with path to symlink char by char, stop at mismatch.
    while [ `echo $PATHH | cut -c$COUNT` = `echo $SYMLINKS | \
      cut -d " " -f$COUNTER | cut -c$COUNT` ]; do
      let COUNT=$COUNT+1
    done;
    let COUNT=$COUNT-1
    # Fix so that the last char in the path to the dir is a '/'.
    while [ `echo $PATHH | cut -c$COUNT` != "/" ]; do
      let COUNT=$COUNT-1
    done
    # Remove the trailing '/'.
    let COUNT=$COUNT-1
    COMMON_PATH=`echo $PATHH | cut -c1-$COUNT`
    ln -s `echo "."\`echo ${PATHH#${COMMON_PATH}}\`$TODAY_DIR` \
    `echo $SYMLINKS | cut -d " " -f$COUNTER`
  fi

  # Write new-dir-info to glftpd.log if $ANNOUNCE = '1' or '2'.
  if [ $ANNOUNCE = 1 ] || [ $ANNOUNCE = 2 ]; then
    if [ $ARCHIVE_CLOSE_TIME -eq 0 ]; then
      echo `date +"%a %b %d %T %Y"` NEW_DATED_DIR: \""`date +$DIR_NAME`"\" \
      \""$SECTION_NAME"\" \"\(archive has been closed\)\" >> $GL_LOG_FILE
    elif [ $ARCHIVE_CLOSE_TIME -eq 1 ]; then
      echo `date +"%a %b %d %T %Y"` NEW_DATED_DIR: \""`date +$DIR_NAME`"\" \
      \""$SECTION_NAME"\" \"\(archive will be closed in 1 hour\)\" \
      >> $GL_LOG_FILE
    elif [ $ARCHIVE_CLOSE_TIME -gt 1 ]; then
      echo `date +"%a %b %d %T %Y"` NEW_DATED_DIR: \""`date +$DIR_NAME`"\" \
      \""$SECTION_NAME"\" \"\(archive will be closed in $ARCHIVE_CLOSE_TIME \
      hours\)\" >> $GL_LOG_FILE
    fi
  fi
  let COUNTER=$COUNTER+1
done
wait
exit 0
