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
# accidentally ran a script that changed all the timestamps of the directories?
# this script will change all sub directories of a given path to the time stamp
# of the oldest/newest file found inside that directory.
# eg, /glftpd/site/MOVIE_576P/<directory>/<oldest/newest file>
###############################################################################
# directory path
TDIRS="
/glftpd/site/TV_576P
/glftpd/site/TV_720P
/glftpd/site/TV_1080P
/glftpd/site/MOVIE_576P
/glftpd/site/MOVIE_720P
/glftpd/site/MOVIE_1080P
"
# head = oldest file, tail = newest file
MODE=head
###############################################################################
# don't edit below here!
###############################################################################

for tdir in $TDIRS; do
	echo "[+] using directory $tdir"
	for d in "$tdir"/*/; do
	  echo "[+] changing timestamp on $d"
	  find "$d" -type d -execdir touch --reference="$(find "$d" -mindepth 1 -maxdepth 1 -printf '%T+=%p\n' | sort | "$MODE" -n 1 | cut -d= -f2-)" "$d" \;
	done
done