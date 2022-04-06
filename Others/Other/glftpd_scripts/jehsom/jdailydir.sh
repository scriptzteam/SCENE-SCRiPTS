#!/bin/bash
# -------------------------------------------------------------------------
# Jehsom's dailydir script v1.2 - Creates dated directories for ftp sites.
# Copyright (C) 2000 jehsom@jehsom.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# -------------------------------------------------------------------------
#
# This is a relatively straightforward newday/dailydir script that makes
#   a new dated dir in your incoming directory each day at midnight,
#   and creates convenient symlinks to Today and Yesterday.
# To be run from root's crontab, with a crontab entry similar to:
#       0 0 * * *       /glftpd/bin/dailydir.sh
# This creates a new dated dir each night at midnight, and links
# $TODAY_LNK to today's dated dir, and $YESTER_LNK to yesterday's.

# A link by the name in $TODAY_LNK will always point to today's dir
TODAY_LNK="!Today"
# A link by the name in $YESTER_LNK will point to yesterday's dir
YESTER_LNK="!Yesterday"
# Space delimited list of dirs under which to create dated dirs
DATEDIRS="/glftpd/site/Incoming"
# glftpd's glftpd.log location
LOG="/glftpd/ftp-data/logs/glftpd.log"


#######################
### Ignore the rest ###
#######################

sleep 1  # In case it gets run before midnight, accidentally

today=`date +%Y%m%d`
yesterday=`date --date "yesterday" +%Y%m%d`
for dir in $DATEDIRS; do
    cd $dir
    [ -d $today ] && continue
    [ -L '!Yesterday' ] && rm -f '!Yesterday'
    [ -L '!Today' ] && mv '!Today' '!Yesterday'
    chmod 755 $yesterday
    mkdir $today
    chmod 777 $today
    ln -s $today/ '!Today'
    echo "$(date +'%a %b %d %T %Y') \"$(basename $dir)\" \"$today\"" >> $LOG

done
