#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################
# this script copies user files from /ftp-data/users to /ftp-data/users_purged
# for backup purposes before purge. the user is then fully purged from the site.
#
# script input can be 'site purge <user>' or 'site purge *'
#
# make sure these two directories exist and are read/writable.
# mkdir -m777 /glftpd/ftp-data/users_purged
# chmod 777 /glftpd/ftp-data/users
#
# edit glftpd.conf and paste in the next line
# cscript         SITE[:space:]PURGE      pre     /bin/sig-purge_backup.sh
###############################################################################

# glftpd users directory, you shouldn't need to change this.
GLFTPDUSERDIR="/ftp-data/users"
# glftpd purged users directory, you shouldn't need to change this.
PURGEDUSERDIR="/ftp-data/users_purged"
# users to skip, case sensitive.
SKIPUSERS="^default\.user|^glftpd|^bnc"
# header spam output.
HDR="PURGE BACKUP SCRIPT"

###############################################################################
# don't edit below here!
###############################################################################

umask 000
IFS='
'

INPUTUSER=$(echo $@ | awk '{print $3}')

[ `echo $FLAGS | grep "1"` ] || exit 0;

[ "$USER" == "$INPUTUSER" ] && exit 0;

if [ "$INPUTUSER" == "*" ]; then
	PURGEUSERS=$(ls -lA "$GLFTPDUSERDIR" | grep -Evi "^total" | awk '{print $(NF-0)}' | grep -Ev "$SKIPUSERS")
	echo -en "200$HDR - purge *, searching for deleted users...\n"
	for PURGEUSER in $PURGEUSERS; do
		PURGEFLAG=$(cat "$GLFTPDUSERDIR/$PURGEUSER" | grep -Ei "^FLAGS.*6")
		if [ ! -z "$PURGEFLAG" ]; then
			echo -en "200$HDR - backing up userfile for $PURGEUSER before purge. "
			cp -f "$GLFTPDUSERDIR/$PURGEUSER" "$PURGEDUSERDIR/$PURGEUSER"
			if [ -f "$PURGEDUSERDIR/$PURGEUSER" ]; then
				echo -en "userfile backup successful.\n"
			else
				echo -en "userfile backup unsuccessful.\n"
			fi
		fi
	done
else
	if [ ! -f "$GLFTPDUSERDIR/$INPUTUSER" ]; then
		echo -en "200$HDR - User Not Found."
		exit 0
	fi
	echo -en "200$HDR - purge $INPUTUSER, searching for deleted user...\n"
	echo -en "200$HDR - backing up userfile for $INPUTUSER before purge. "
	cp -f "$GLFTPDUSERDIR/$INPUTUSER" "$PURGEDUSERDIR/$INPUTUSER"
	if [ -f "$PURGEDUSERDIR/$INPUTUSER" ]; then
		echo -en "userfile backup successful.\n"
	else
		echo -en "userfile backup unsuccessful.\n"
	fi
fi

exit 0