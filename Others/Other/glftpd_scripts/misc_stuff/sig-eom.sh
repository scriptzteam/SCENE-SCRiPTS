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
# crontab this script to run daily 5 minutes before midnight.
# 55 23 * * *     /glftpd/bin/sig-eom.sh >/dev/null 2>&1
#
# the script will check todays date against the last day of the current month,
# if it matches it will execute all your listed EOM (end of month) scripts.
###############################################################################

EOMRUN="
/glftpd/bin/sig-monthstats.sh
"

###############################################################################
# don't edit below here!
###############################################################################

month=$(cal -h | awk -v nr=1 '{ for (x=nr; x<=NF; x++) { printf $x " "; }; print " " }' | tr -s '[:blank:]' '\n' | head -1)
lastday=$(cal -h | awk -v nr=1 '{ for (x=nr; x<=NF; x++) { printf $x " "; }; print " " }' | tr -s '[:blank:]' '\n' | tail -1)
today=$(date +%d)

if [ "$today" == "$lastday" ]; then
	for EOM in $EOMRUN; do
		$EOM >/dev/null 2>&1
	done
fi