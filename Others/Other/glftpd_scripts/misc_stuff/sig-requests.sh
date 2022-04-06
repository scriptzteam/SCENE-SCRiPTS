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
# site request system
###############################################################################
# requests dir
REQUESTDIR="/site/REQUESTS"
# glftpd log file
GLLOG="/ftp-data/logs/glftpd.log"
# request log file
REQUESTFILE="/ftp-data/misc/sig-requests"
# temporary directory
TEMP="/tmp"
# max requests per user
REQUSERMAX="5"
# filled requests directory identifier
REQFILLABEL="FILLED-"
###############################################################################
# don't edit below here!
###############################################################################

OIFS=$IFS
IFS=$'\n'

function REQSHO () {
	if [ ! -s "$REQUESTFILE" ]; then
		echo "[REQSHO] ERROR: NO CURRENT REQUESTS."
	else
		REQLIST=$(cat "$REQUESTFILE")
		echo "[REQSHO] CURRENT REQUESTS..."
		for REQLINE in $REQLIST; do
			echo "[REQSHO] $REQLINE"
		done
	fi
}

function REQADD () {
	REQNUM=$(cat $REQUESTFILE | grep -w "$USER" | wc -l)
	if [ "$REQNUM" -ge "$REQUSERMAX" ]; then
		echo "[REQADD] ERROR: YOU ALREADY HAVE THE MAXIMUM SITE REQUESTS OF $REQUSERMAX, EXITING."
		exit 1
	else
		REQUEST="$(echo $@ | sed 's/REQADD //' | tr ' ' '_')"
		REQEXISTS=$(find "$REQUESTDIR" -mindepth 1 -maxdepth 1 -type d -iname "$REQUEST" | grep -E "$REQUEST$")
		if [ -z "$REQEXISTS" ]; then
			REQLINESEP="--------------->"
			printf -v REQINFO "%s %s %s" $USER "${REQLINESEP:${#USER}}" $REQUEST
			echo "[REQADD] ADDED: $REQUEST."
			echo "[ `date "+%Y-%m-%d"` ] $REQINFO" >> $REQUESTFILE
			echo `date "+%a %b %d %T %Y"` REQADD: \"$REQUEST\" \"$USER\" >> $GLLOG
			mkdir -m777 "$REQUESTDIR/$REQUEST"
		else
			echo "[REQADD] ERROR: THAT REQUEST ALREADY EXISTS, EXITING."
			exit 1
		fi
	fi
}

function REQFIL () {
	REQUEST="$(echo $@ | sed 's/REQFIL //' | sed "s/$REQFILLABEL//" | tr ' ' '_')"
	if [ -d "$REQUESTDIR/$REQUEST" ]; then
		REQESC=$(echo "$REQUEST" | sed -e 's/[(]/\\(/g' -e 's/[)]/\\)/g' )
		RUSER=$(grep -Ex ".*$REQESC" "$REQUESTFILE" | tr " " "#" | awk -F# '{print $4}')
		grep -Exv ".*$REQESC" "$REQUESTFILE" >> $TEMP/sig-requests.tmp
		cp -f $TEMP/sig-requests.tmp "$REQUESTFILE"
		rm -f $TEMP/sig-requests.tmp
		mv "$REQUESTDIR/$REQUEST" "$REQUESTDIR/$REQFILLABEL$REQUEST"
		chmod 755 "$REQUESTDIR/$REQFILLABEL$REQUEST"
		echo "[REQFIL] FILLED: $REQUEST."
		echo `date "+%a %b %d %T %Y"` REQFIL: \"$REQUEST\" \"$USER\" \"$RUSER\" >> $GLLOG
	else
		echo "[REQFIL] ERROR: THAT REQUEST DOES NOT EXIST, EXITING."
		exit 1
	fi
}

function REQDEL () {
	REQUEST="$(echo $@ | sed 's/REQDEL //' | sed "s/$REQFILLABEL//" | tr ' ' '_')"
	if [ -d "$REQUESTDIR/$REQUEST" ]; then
		REQESC=$(echo "$REQUEST" | sed -e 's/[(]/\\(/g' -e 's/[)]/\\)/g' )
		REQUSER=$(cat $REQUESTFILE | grep -Ex ".*$REQESC" | grep -w "$USER")
		if [ -z "$REQUSER" ]; then
			echo "[REQDEL] ERROR: YOU CAN ONLY DELETE REQUESTS MADE BY YOURSELF, EXITING."
			exit 1
		else
			grep -Exv ".*$REQESC" "$REQUESTFILE" >> $TEMP/sig-requests.tmp
			cp -f $TEMP/sig-requests.tmp "$REQUESTFILE"
			rm -f $TEMP/sig-requests.tmp
			rm -rf "$REQUESTDIR/$REQUEST"
			echo "[REQDEL] DELETED: $REQUEST."
			echo `date "+%a %b %d %T %Y"` REQDEL: \"$REQUEST\" \"$USER\" >> $GLLOG
		fi
	else
		echo "[REQFIL] ERROR: THAT REQUEST DOES NOT EXIST, EXITING."
		exit 1
	fi
}

if [ "$1" == "REQSHO" ]; then
	REQSHO
elif [ "$1" == "REQHLP" ]; then
		echo "[REQUSE] (MAX $REQUSERMAX REQUESTS PER USER)"
		echo "[REQUSE] SITE REQADD <REQUEST> - (ADDS A REQUEST TO THE REQUEST LIST)"
		echo "[REQUSE] SITE REQDEL <REQUEST> - (DELETES A REQUEST, YOU MUST HAVE OWNERSHIP OF THE REQUEST)"
		echo "[REQUSE] SITE REQFIL <REQUEST> - (MARKS A REQUEST AS FILLED)"
		echo "[REQUSE] SITE REQSHO - (DISPLAYS THE CURRENT REQUESTS)"
		exit 1
else
	if [ -z "$2" ]; then
		echo "[REQUSE] (MAX $REQUSERMAX REQUESTS PER USER)"
		echo "[REQUSE] SITE REQADD <REQUEST> - (ADDS A REQUEST TO THE REQUEST LIST)"
		echo "[REQUSE] SITE REQDEL <REQUEST> - (DELETES A REQUEST, YOU MUST HAVE OWNERSHIP OF THE REQUEST)"
		echo "[REQUSE] SITE REQFIL <REQUEST> - (MARKS A REQUEST AS FILLED)"
		echo "[REQUSE] SITE REQSHO - (DISPLAYS THE CURRENT REQUESTS)"
		exit 1
	else
		$@
	fi
fi