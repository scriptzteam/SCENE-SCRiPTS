#!/bin/bash
VER=1.1
#-[ Info ]----------------------------------------------#
#                                                       #
# DatedDel. A script to remove releases from dated dirs #
# if they are over a certain size.                      #
#                                                       #
#-[ Prologue ]------------------------------------------#
#                                                       #
# Note that this script only works in dated sections.   #
# It is NOT a freespace script aka Spacemaker from Zio. #
# The default setup is to delete games over 50 meg in   #
# size. It is designed to be executed manually and not  #
# from crontab, even if it can be done like that too.   #
#                                                       #
#-[ Installation ]--------------------------------------#
#                                                       #
# Copy this script to anywhere you like. It is not      #
# depending on anything that deals with glftpd          #
# specifically. Make it executable (chmod 755).         #
#                                                       #
# Edit the settings below.                              #
#                                                       #
# The first of the settings, called generics, should    #
# not need to be modified really. It adds support to    #
# exclude dated dirs up to a week old. To do this, add  #
# $today to the exclude line ( described below ).       #
# By default, $today and $yesterday is excluded by      #
# default. Default date mode is DDMM.                   #
#                                                       #
# sections=  This is the sections it should check in.   #
#            Its 3 parts, seperated by a :              #
#            First part is the section itself. It will  #
#            go into this dir and automatically list    #
#            all subdirs. Then go into each one of      #
#            and start looking for dirs.                #
#                                                       #
#            The second part is how big the release     #
#            must be, before it even reacts to it. The  #
#            number is in MB.                           #
#            How it reacts to it is decided in the      #
#            options further down.                      #
#                                                       #
#            The third part deals with automatic        #
#            deletions. If the release > this big, it   #
#            will delete it instantly. Set this to      #
#            something like 999999 if you never want it #
#            to.                                        #
#                                                       #
#            Example:                                   #
#            /glftpd/site/0DAYS:50:200                  #
#            Enter /glftpd/site/0DAYS and look for more #
#            subdirs to enter ( cd 0305, 0306 etc).     #
#            If the release is 50 meg or more, it will  #
#            react to it (see further down).            #
#            If the release is 200 meg large, it will   #
#            be deleted without questions.              #
#                                                       #
#            Seperate different sections with a space   #
#            or in the case of the example below, a     #
#            newline.                                   #
#                                                       #
# forcedel=  If you want me to automatically delete     #
#            something else too, enter it here. It will #
#            only work with one word ( no multiples )   #
#            and is by default 'NUKED-'                 #
#            Set this to '.' and it will delete all     #
#            releases. Set to "" to disable.            #
#                                                       #
# exclude=   Any dirs I should ignore, both when        #
#            listing dirs in the sections part as well  #
#            as words in the release name. Add affils   #
#            and perhaps predirs here.                  #
#            Use a | as a seperator and dont use spaces #
#            Set to "" to disable.                      #
#                                                       #
# autodel=   If, from the example above, the release is #
#            over 50 MB large and includes any of these #
#            words, it will automatically be deleted.   #
#            By default, this are a few groups that     #
#            release only games. I want games over 50MB #
#            to be automatically deleted.               #
#            Use a | as a seperator and dont use spaces #
#            Set to "" to disable.                      #
#                                                       #
# ask=       TRUE/FALSE. If the release is over 50 meg  #
#            but does not include any of the words in   #
#            autodel above, should I ask if you want to #
#            delete it? If not, it will log it only.    #
#                                                       #
# manualreport= TRUE/FALSE. If ask is not TRUE, at the  #
#               end of the execution, should I display  #
#               all the releases that were over 50 MB   #
#               but was not deleted? For manual dels.   #
#                                                       #
# log=          Where to log to. Set to "" to disable.  #
#                                                       #
# logautomaticdels= TRUE/FALSE. Should it log releases  #
#                   that were automatically deleted too?#
#                                                       #
# tmp=              A temporary directory to write crap #
#                   to.                                 #
#                                                       #
#-[ Usage ]---------------------------------------------#
#                                                       #
# This script can take 2 arguments; test and debug.     #
#                                                       #
# With debug, it will display where its at and what it  #
# is doing, to the screen. You should always use this   #
# unless you crontab it or something.                   #
# If you have ask on TRUE, debug will automatically be  #
# enabled since you'll be sitting there anyway.         #
#                                                       #
# With test, it will act as if its deleting and stuff   #
# but it actually wont. USE this the first time you run #
# it and let it run fully before you take it off.       #
#                                                       #
# Which argument comes first dosnt matter so            #
# 'dateddel.sh test debug' is the same as 'debug test'. #
#                                                       #
#-[ Changelog ]-----------------------------------------#
#                                                       #
# 1.1   : Added "support" for excluding dated dirs up   #
#         to a week old. Thanks nm0 for the idea.       #
#                                                       #
#-[ Generics: dated dirs ]------------------------------#

today="$( date +%m%d )"                         #Today
yesterday="$( date --date "yesterday" +%m%d )"  #Yesterday
daysago2="$( date --date "-2 day" +%m%d )"      #2 days ago
daysago3="$( date --date "-3 day" +%m%d )"      #3 days ago
daysago4="$( date --date "-4 day" +%m%d )"      #4 days ago
daysago5="$( date --date "-5 day" +%m%d )"      #5 days ago
daysago6="$( date --date "-6 day" +%m%d )"      #6 days ago
daysago7="$( date --date "-7 day" +%m%d )"      #1 week ago
#                                                       #

#-[ Settings ]------------------------------------------#

sections="
/glftpd/site/0DAYS:20:20000
"

forcedel='NUKED-'
exclude="GROUPS|Lost\+Found|Today|Yesterday|$today|$yesterday"
autodel='-MyTH|-DEViANCE|-CLS|-DVN|-FAS|-POD|Movie.Addon|Music.Addon|Intro.Addon'
ask=FALSE
manualreport=FALSE

log=/glftpd/ftp-data/logs/dateddel.log
logautomaticdels=TRUE
tmp=/glftpd/tmp


#-[ Script Start ]--------------------------------------#

proc_debug() {
  if [ "$DEBUG" = "TRUE" ]; then
    echo "$*"
  fi
}

if [ "$1" = "debug" -o "$2" = "debug" ]; then
  DEBUG=TRUE
  proc_debug "Debug mode on. Echoing shit to screen."
fi

if [ "$1" = "test" -o "$2" = "test" ]; then
  TEST=TRUE
  proc_debug "Test mode on. Nothing will be delled."
fi

if [ "$ask" = "TRUE" ]; then
  proc_debug "Ask mode on."
  DEBUG="TRUE"
fi

proc_debug "Exludes set to: $exclude"

proc_log() {
  if [ "$log" != "" ]; then
    if [ "$logautomaticdels" = "TRUE" ]; then
      echo "$*" >> $log
    fi
  fi
}

proc_fixsize() {
  if [ "$( echo "$size" | wc -L | tr -d ' ' )" = "2" ]; then
    size="$size "
  elif [ "$( echo "$size" | wc -L | tr -d ' ' )" = "1" ]; then
    size="$size  "
  fi
}

## Lame fixes.
if [ -z "$forcedel" ]; then
  forcedel="FEj3klfj3lkjfKLLKJRklJ"
fi
if [ -z "$exclude" ]; then
  exclude="jfLKJRFKEleKFelk30399"
fi
if [ -z "$autodel" ]; then
  autodel="Rjkl3jUFIjf3kjf3iJfkel"
fi

proc_debug " "

if [ "$ask" = "TRUE" ]; then
  manualreport=FALSE
fi

date="$( date )"
if [ "$log" ]; then
  echo "" >> $log
  echo "Starting run at $date by $USER" >> $log
fi

if [ -e $tmp/dateddel.tmp ]; then
  rm -f $tmp/dateddel.tmp
fi

saved=0
for raw in $sections; do
  unset SKIP
  section="$( echo "$raw" | cut -d ':' -f1 )"
  maxsize="$( echo "$raw" | cut -d ':' -f2 )"
  forcesize="$( echo "$raw" | cut -d ':' -f3 )"
  if [ -d "$section" ]; then
    proc_debug "Entering $section. Reactsize: $maxsize MB - Delete if more then $forcesize MB"
    proc_log "Entering $section"
    cd $section
  else
    SKIP="YES"
    proc_debug "Skipping $section. Not found."
    proc_log "Skipping $section. Not found."
  fi

  if [ "$SKIP" != "YES" ]; then
    for dir in `ls | egrep -v -- $exclude | grep "07.."`; do
      proc_debug " "
      proc_debug " - Entering subdir: $dir"
      cd $section/$dir
      for release in `ls | egrep -v -- $exclude`; do
        size="$( du -m -s $release | cut -f1 )"
        if [ "$( echo "$release" | egrep -- $forcedel )" ]; then
          proc_fixsize
          proc_debug "Forcedel [$size] $release"
          proc_log "Forcedel [$size] $release"
          if [ "$TEST" != "TRUE" ]; then
            rm -rf $section/$dir/$release
          fi
          saved=$[$size+$saved]
        else
          if [ "$size" -gt "$forcesize" ]; then
            proc_fixsize
            proc_debug "Forcedel [$size] $release"
            proc_log "Forcedel [$size] $release"
            if [ "$TEST" != "TRUE" ]; then
              rm -rf $section/$dir/$release
            fi
            saved=$[$size+$saved]
          elif [ "$size" -gt "$maxsize" ]; then
            proc_fixsize
            if [ "$( echo "$release" | egrep -i -- "$autodel" )" ]; then
              proc_debug "Autodel! [$size] $release"
              proc_log "Autodel! [$size] $release"
              if [ "$TEST" != "TRUE" ]; then
                rm -rf $section/$dir/$release
              fi
              saved=$[$size+$saved]
            else
              if [ "$ask" != "TRUE" ]; then
                proc_debug "NotAuto  [$size] $release"
                echo "$size - $section/$dir/$release" >> $tmp/dateddel.tmp
              else

                until [ -n "$delete" ]; do
                  echo -n "Delete? [$size] $release ? [y]es [N]o: "
                  read delete
                  case $delete in
                    [Nn])
                      continue
                    ;;
                    [Yy])
                      if [ "$TEST" != "TRUE" ]; then
                        rm -rf $section/$dir/$release
                        proc_log "Deleting [$size] $dir/$release"
                      else 
                        proc_log "Deleting(test) [$size] $dir/$release"
                      fi
                      saved=$[$size+$saved]
                    ;;
                    *)
                      delete=n
                      continue
                    ;;
                  esac
                done
                unset delete
              fi
            fi
          fi
        fi
      done
    done
  fi

done

if [ -e $tmp/dateddel.tmp -a "$manualreport" = "TRUE" ]; then
  if [ "$log" ]; then
    echo "The following releases should be checked:" >> $log
    cat "$tmp/dateddel.tmp" >> $log
  fi
  if [ "$DEBUG" = "TRUE" ]; then
    echo " "
    echo "The following releases should be checked manually:"
    cat "$tmp/dateddel.tmp"
  fi
  rm -f "$tmp/dateddel.tmp"
fi

proc_log "Total freed: $saved MB"
proc_debug "Total freed: $saved MB"