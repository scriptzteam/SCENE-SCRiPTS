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
# script to monitor S.M.A.R.T data on your hdds, PASSED/FAILED, multi line.
###############################################################################
# where to send log data to, for use with output
SYSLOG="/glftpd/ftp-data/logs/glftpd.log"
# get the hdd serial from fdisk -l for each section
# serial#label
HDDS="
0x00000000#glftpd
0x11111111#mvid
0x22222222#mp3
0x33333333#flac
"
###############################################################################
# don't edit below here!
###############################################################################

OIFS=$IFS
IFS='
'

FDISK=$(/sbin/fdisk -l 2> /dev/null | tr "\n" " " | sed 's/Disk \/dev/\nDisk \/dev/g' | tr -s " ")

declare -a PASSED
declare -a FAILED

PASSED=()
FAILED=()

for HDD in $HDDS; do
	HDID=$(echo $HDD | awk -F# '{print $1}')
	HSEC=$(echo $HDD | awk -F# '{print $2}' | tr '[:lower:]' '[:upper:]' )
	HFDI=$(echo "$FDISK" | grep "$HDID")
	HDEV=$(echo $HFDI | awk '{print $2}' | tr -d ":")
	HTES=$(/usr/sbin/smartctl -H "$HDEV" | grep "^SMART" | awk '{print $(NF-0)}')
	HDEV=$(echo $HDEV | awk -F/ '{print $(NF-0)}' | tr '[A-Z]' '[a-z]')
	if [ "$HTES" = "PASSED" ]; then
		PASSED=("${PASSED[@]}" "$HSEC($HDEV)")
	fi
	if [ "$HTES" = "FAILED" ]; then
		FAILED=("${FAILED[@]}" "$HSEC($HDEV)")
	fi
done

if [ ${#PASSED[@]} -gt 0 ]; then
	printf -v PASSED "%s " "${PASSED[@]}"
	PASSED=$(echo "$PASSED" | sed -e 's/.\{80\} /&\n/g')
	for PLINE in $PASSED; do
		echo "[SMARTCTL] -> [PASSED] $PLINE"
		echo "`/bin/date "+%a %b %d %T %Y"` \"SMARTCTL\" \"[PASSED] $PLINE\"" >> $SYSLOG
	done
fi

if [ ${#FAILED[@]} -gt 0 ]; then
	printf -v FAILED "%s " "${FAILED[@]}"
	FAILED=$(echo "$FAILED" | sed -e 's/.\{80\} /&\n/g')
	for FLINE in $FAILED; do
		echo "[SMARTCTL] -> [FAILED] $FLINE"
		echo "`/bin/date "+%a %b %d %T %Y"` \"SMARTCTL\" \"[FAILED] $FLINE\"" >> $SYSLOG
	done
fi