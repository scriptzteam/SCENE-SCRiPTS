#!/bin/bash
############################################################################
# 0DaysDateFix v1.1.1 by Turranius                                         #
####                                                                    ####
# This little script will change the date on any dated dirs, be it 0days   #
# or Mp3 folders. The only requirement is that the dirs in in the format   #
# "MonthDay", like 0628. It will not change the year of the folders, so    #
# even if you point it to an old archive, the year is intact.              #
####                                                                    ####
# Installation:                                                            #
# Put this script in /glftpd/bin, or wherever you like really.             #
# Make it executable.                                                      #
# Edit the settings below:                                                 #
# DATEDDIRS can be any number of folders containing dated dirs, space      #
# separated.                                                               #
# Any folders contained in these dated dirs can be excluded in EXCLUDE.    #
# Separate the excludes with a |                                           #
# Crontab it or just run it manually as often or seldom as you like.       #
#                                                                          #
# If you wish to see whats happening when its running, start it with the   #
# variable 'display' (0daysdatefix.sh display).                            #
####                                                                    ####
# Changelog:                                                               #
# 1.1.1 : Fixed it where it would not run the first 9 days of the month.   #
# 1.1 : Handles an infinite amount of dated dirs.                          #
#       Excludes are working.                                              #
#       Better (?) documented, hehe.                                       #
# 1.0 : Initial release. Only handles one dir.                             #
############################################################################
# Contact Turranius on efnet (turranius/turran/turr|away/turr|work).       #
############################################################################

DATEDDIRS='/glftpd/site/0DAYS /glftpd/site/Archive/0DAYS /glftpd/site/Archive/0DAYS2' # Space separeted
EXCLUDE='GROUPS|!Today|!Yesterday'                          # | separated


############################################################
## No changes below needed                                 #
############################################################

today="$(date +%m%d)"

for dir in $DATEDDIRS; do
  cd $dir
  for i in `ls -f -A | egrep -v $EXCLUDE`
  do
    if [ "$i" != "$today" ]; then 
      if [ "$1" = "display" ]; then
        echo $dir/$i
      fi
      touch $i -t $i"0000"
    else
      if [ "$1" = "display" ]; then
        echo "Not touching todays dir: $dir/$i"
      fi
    fi
  done
done

exit 0
