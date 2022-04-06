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
# requests directory clean up script
###############################################################################
# path of requests dir
REQDIR="/glftpd/site/REQUESTS"
# days old limit 90 = 90 days old maximum
DAYLIM="90"
# filled requests identifier
REQID="FILLED-*"
# purge old/ignored requests too?
REQPI="YES"
# requests file
REQUESTFILE="/glftpd/ftp-data/misc/sig-requests"
###############################################################################
# don't edit below here!
###############################################################################

REQUESTS=$(find "$REQDIR" -maxdepth 1 -type d -mtime +$DAYLIM -name "$REQID")
TOTALFREE="0"
echo "[REQPUR] searching for $REQID folders in $REQDIR that are greater than $DAYLIM days old"
for FILLED in $REQUESTS; do
	RELEASE=$(basename $FILLED)
	MBFREE=$(du -m "$FILLED" | tail -1 | awk '{print $1}')
	TOTALFREE=$(( $TOTALFREE + $MBFREE ))
	rm -rf "$FILLED"
	echo "[REQPUR] DELETED -> $RELEASE ($MBFREE MB FREED)"
done
echo "[REQPUR] TOTAL MB FREED -> $TOTALFREE MB"
if [ "$REQPI" == "YES" ]; then
	TOTALFREE="0"
	echo "[REQPUR] searching for ignored request folders in $REQDIR that are greater than $DAYLIM days old"
	REQUESTS=$(find "$REQDIR" -maxdepth 1 -type d -mtime +$DAYLIM ! -name "$REQID")
	for IGNORED in $REQUESTS; do
		RELEASE=$(basename $IGNORED)
		MBFREE=$(du -m "$IGNORED" | tail -1 | awk '{print $1}')
		TOTALFREE=$(( $TOTALFREE + $MBFREE ))
		rm -rf "$IGNORED"
		sed -i "/\\${RELEASE}/d" $REQUESTFILE
		echo "[REQPUR] REMOVED -> $RELEASE FROM REQUEST LIST AND DELETED -> $RELEASE ($MBFREE MB FREED)"
	done
echo "[REQPUR] TOTAL MB FREED -> $TOTALFREE MB"
fi