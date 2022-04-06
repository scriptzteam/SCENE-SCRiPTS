#!/bin/bash
# -------------------------------------------------------------------------
# Jehsom's slow downloader kicker v1.1 - kicks users who are slow leeching.
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
#
# Place this to run every 5 minutes or so, in root's crontab:
#   */5 * * * *     /glftpd/bin/slowdlkick.sh
# Once a user has been kicked, he will not be allowed to log in for
#  $TIMEOUT seconds. You should never keep then locked out for so
#  long that they are locked out the next time this script runs.
#
# Changes:
# v1.0 -> 1.1 : Finally implemented $EXEMPT

ROOTPATH="/glftpd"
DATAPATH="/glftpd/ftp-data"
LOGFILE="/glftpd/ftp-data/logs/slowdlkick.log" # Log kicks to this file
EXEMPT="jehsom" #  users exempt from the rule, space delimited
MINSPEED="5" # KB/s
TIMEOUT="240" # seconds

cd $DATAPATH || { echo "Invalid datapath."; exit 1; }
userstokick=""
pidstokick=""
$ROOTPATH/bin/ftpwho | grep "| Dn:" | sed 's/^| \([^ ]*\)[ ]*| \([0-9]*\) .* \([-]\{0,1\}[0-9]*\)\.[0-9]K\/sec.*$/\1 \2 \3/' | {
	while read line; do
		set $line
	
		[ $3 -le 0 ] && continue
	
		user=$1
		[ ! -f users/$user ] && user=$(cd users; echo $user* | cut -f1 -d ' ')
		[ ! -f users/$user ] && continue;
        case " $EXEMPT " in
            *" $user "*)
                continue
                ;;
        esac
		[ "$3" -lt "$MINSPEED" ] && {
			userstokick="$userstokick $user"
			pidstokick="$pidstokick $2"
			echo "$(date): Kicking $user, $3 K/s" >> $LOGFILE
		}
	done

	[ -n "$userstokick" ] && {
		for user in $userstokick; do
			echo "You were downloading too slowly. 5 min timeout." > byefiles/$user.bye
			mv users/$user users/$user.orig
			sed 's/^FLAGS /&6/' users/$user.orig > users/$user
		done
		kill $pidstokick

		sleep $TIMEOUT

		for user in $userstokick; do
			mv -f users/$user.orig users/$user
			rm byefiles/$user.bye
		done
	}	
}

