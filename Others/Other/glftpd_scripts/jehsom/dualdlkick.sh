#!/bin/bash
# -------------------------------------------------------------------------
# Jehsom's dual download kicker script, v1.0 - Kicks dual leechers
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
# Kick users who are downloading more than once simultaneously
# To be run in root's crontab every 2 to 5 minutes:
#   */5 * * * *     /glftpd/bin/dualdlkick.sh


ROOTPATH="/glftpd"
DATAPATH="/ftp-data" # Relative to rootpath
LOGFILE="/glftpd/ftp-data/logs/dlkicker.log"
EXEMPT="" # users exempt from the rule, space delimited

cd ${ROOTPATH}${DATAPATH}/users
lastuser=""
tokick=""
for user in `${ROOTPATH}/bin/ftpwho | grep "| Dn:" | tr -d '|' | tr -s ' ' |
    sort | cut -f2 -d ' '`; do
	[ "$user" = "$lastuser" ] && {
	    [ -f "$user" ] || user=`echo ${user}* | sed 's/^\([^ ]*\) .*$/\1/'`
	    tokick="$tokick $user"
	}
	lastuser="$user"
done

lastuser=""
for user in $tokick; do
	echo $EXEMPT | grep "\b$user\b" > /dev/null && continue
	[ "$lastuser" = "$user" ] && continue
	echo "`date`: Kicking $tokick" >> $LOGFILE
	for pid in `${ROOTPATH}/bin/ftpwho | grep "$user\b.*| Dn:" | tr -d '|' | 
	   tr -s ' ' | cut -f3 -d ' '`; do
		kill $pid
	done
	sed 's/^\(GENERAL [^ ]\{1,\} \)[0-9]\{1,\}\( .*\)$/\11\2/' $user > $user.tmp
	mv -f $user $user.orig
	mv $user.tmp $user
	lastuser=$user
done

[ -n "$tokick" ] && {
	sleep 240
	lastuser=""
	for user in $tokick; do
		[ "$lastuser" = "$user" ] && continue
		rm $user
		mv $user.orig $user
		lastuser=$user
	done
}
