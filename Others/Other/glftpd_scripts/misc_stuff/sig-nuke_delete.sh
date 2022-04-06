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
# a script to delete nuked directories after a certain age (modified time)
# crontab the script to run twice a day
# 00 20,8 * * *      /glftpd/bin/sig-nuke_delete.sh >/dev/null 2>&1
###############################################################################
# nuked directory label
NUKE_LABEL="(nuked)-"
# nuke time in days, 1 day = 24 hours (from modified directory date/time stamp)
NUKE_TIME="7"
# directories to scan/remove nuked directories, number is min/max depth to scan.
NUKE_DIRS="
/glftpd/site/MOVIE_576P#1
/glftpd/site/MOVIE_720P#1
/glftpd/site/MOVIE_1080P#1
/glftpd/site/MP3#2
/glftpd/site/FLAC#2
/glftpd/site/MVID#2
"
###############################################################################
# don't edit below here!
###############################################################################

OIFS=$IFS
IFS=$'\n'

for NUKE_DIR in $NUKE_DIRS; do
	NUKE_DEP=$(echo "$NUKE_DIR" | awk -F# '{print $2}')
	NUKE_DIR=$(echo "$NUKE_DIR" | awk -F# '{print $1}')
	NUKES=$(find "$NUKE_DIR" -mindepth $NUKE_DEP -maxdepth $NUKE_DEP -type d -mtime +$NUKE_TIME -name "$NUKE_LABEL*")
	if [ -z "$NUKES" ]; then
		echo "[NUKE DELETE] - no $NUKE_LABEL* directories within path $NUKE_DIR older than $NUKE_TIME day(s)"
		continue
	else
		NUKES_FOUND=$(echo "$NUKES" | wc -l)
		echo "[NUKE DELETE] + found $NUKES_FOUND $NUKE_LABEL* directories within path $NUKE_DIR older than $NUKE_TIME day(s)"
		for NUKE in $NUKES; do
			echo "[NUKE DELETE] - deleted $NUKE"
			rm -rf "$NUKE"
		done
	fi
done

IFS=$OIFS