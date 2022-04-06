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
# a script to sort imdb top 250 movies within a directory.
#
# this script will search and rename your movie folders with reference to the
# imdb top 250 list. if the top 250 list ranking has changed, then the script
# will update your movie folders to the correct ranking. the script processes
# titles in alphabetical order, not by imdb rank.
#
# ./IMDB_TOP_250/The.Shawshank.Redemption.1994.iNTERNAL.DVDrip.XViD-DCA
# will become
# ./IMDB_TOP_250/IMDB_001-The.Shawshank.Redemption.1994.iNTERNAL.DVDrip.XViD-DCA
#
# if a movie in the list is not found inside the $MOVIEDIR, then it will mkdir
# ./IMDB_TOP_250/IMDB_001-The.Shawshank.Redemption.1994.MISSING.PLEASE.UPLOAD
###############################################################################
# imdb top 250 directory
MOVIEDIR="/glftpd/site/ARCHIVE/MOVIE/IMDB_TOP_250"
###############################################################################
# don't edit below here!
###############################################################################

if [ -f "imdbtop250.list" ]; then
	echo "[IMDB] DELETING THE OLD IMDB TOP 250 LIST AND DOWNLOADING A NEW ONE"
	rm -f "imdbtop250.list"
fi

wget -q -O "imdbtop250.list" http://127.0.0.1/imdb_top250_api.php

TOP250LIST=$(cat imdbtop250.list | iconv -f UTF8 -t US-ASCII//TRANSLIT)

if [ -z "$TOP250LIST" ]; then
	echo "[IMDB] ERROR WITH PARSING TOP 250 LIST, EXITING"
	exit 0
else
	NOW=$(date "+%Y-%m-%d")
	NOWDIR="[ IMDB TOP 250 LIST - $NOW ]"
	OLDDIR=$(ls -A "$MOVIEDIR" | grep -E "\[ IMDB TOP 250 LIST \- .* \]")
	if [ ! -z "$OLDDIR" ]; then
		echo "[IMDB] DELETING OLD HEADER -> $OLDDIR"
		rmdir "$MOVIEDIR/$OLDDIR"
	fi
	if [ ! -d "$MOVIEDIR/$NOWDIR" ]; then
		echo "[IMDB] CREATING NEW HEADER -> $NOWDIR"
		mkdir -m755 "$MOVIEDIR/$NOWDIR"
	fi
	echo "[IMDB] CREATED $NOWDIR IN $MOVIEDIR"
	echo "$NOWDIR" > "$MOVIEDIR/IMDB_TOP_250_LIST.txt"
	echo "[IMDB] CREATED IMDB_TOP_250_LIST.TXT IN $MOVIEDIR"
	echo "" >> "$MOVIEDIR/IMDB_TOP_250_LIST.txt"
	echo "$TOP250LIST" >> "$MOVIEDIR/IMDB_TOP_250_LIST.txt"
fi

TOP250LIST=$(echo "$TOP250LIST" | sort -t# -k3)
echo "[IMDB] SORTED IMDB TOP 250 LIST ALPHABETICALLY BY TITLE"

OIFS="$IFS"
IFS=$'\n'

find "$MOVIEDIR" -maxdepth 1 -type d -iname "*MISSING.PLEASE.UPLOAD" -exec rm -rf {} \;
echo "[IMDB] DELETED ALL MISSING.PLEASE.UPLOAD DIRECTORIES"

for LIST in $TOP250LIST; do
	RANK=$(echo $LIST | awk -F# '{print $1}'); printf -v RANK "%03d" $RANK
	CODE=$(echo $LIST | awk -F# '{print $2}')
	TITLE=$(echo $LIST | awk -F# '{print $3}' | sed -e 's/[ \.\,\_\:\;\!\@\#\/\\\$\%\^\&\*\(\)]/ /g' | sed -e "s/[\']//g" | tr -s " ")
	YEAR=$(echo $LIST | awk -F# '{print $4}')
	RATING=$(echo $LIST | awk -F# '{print $5}')
	if [ -z "$RANK" -o -z "$CODE" -o -z "$TITLE" -o -z "$YEAR" -o -z "$RATING" ]; then
		echo "[IMDB] ERROR WITH PARSING TOP 250 LIST, EXITING"
		exit 0
	fi
	SEARCHTITLE=$(echo "$TITLE" | sed -e 's/\<[Aa]\>\|\<[Oo][Ff]\>\|\<[Tt][Hh][Ee]\>\|\<[Aa][Nn][Dd]\>//g' | sed -e 's/\-/ /g' | sed -e 's/[\.\,\_\:\;\!\@\#\/\\\$\%\^\&\*\(\)]//g' | sed -e "s/[\']//g" | tr -s " " | sed 's/ /.*/g')
	MKDIRTITLE=$(echo "$TITLE" | sed -e 's/\-/ /g' | sed -e 's/[ \.\,\_\:\;\!\@\#\/\\\$\%\^\&\*\(\)]/./g' | sed -e "s/[\']//g" | tr -s ".")
	FOUNDTITLE=$(ls -A "$MOVIEDIR" | grep -v "IMDB_" | grep -Ei "^$SEARCHTITLE")
	IMDBTITLE=$(ls -A "$MOVIEDIR" | grep "IMDB_" | grep -Eiw "^IMDB_[0-9]{1,3}-$SEARCHTITLE.*$YEAR")
	if [ -z "$IMDBTITLE" ]; then
		IMDBTITLE=$(ls -A "$MOVIEDIR" | grep "IMDB_" | grep -Eiw "^IMDB_[0-9]{1,3}-$SEARCHTITLE")
	fi
	if [ ! -z "$FOUNDTITLE" ]; then
		for FTITLE in $FOUNDTITLE; do
			if [ -d "$MOVIEDIR/$FTITLE" ]; then
				# if bare directory exists, rename it to a ranked directory.
				echo "[IMDB] REN ($RANK) FOUND -> IMDB_$RANK-$FTITLE (UNRANKED, DIRECTORY RENAMED)"
				mv -f "$MOVIEDIR/$FTITLE" "$MOVIEDIR/IMDB_$RANK-$FTITLE"
			fi
		done
	else
		if [ -z "$IMDBTITLE" ]; then
			if [ ! -d "$MOVIEDIR/IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD" ]; then
				echo "[IMDB] MKD ($RANK) MKDIR -> IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD (NOT FOUND, MISSING DIRECTORY CREATED)"
				mkdir -m755 "$MOVIEDIR/IMDB_$RANK-$MKDIRTITLE.$YEAR-MISSING.PLEASE.UPLOAD"
			fi
		else
			for IMDBEXISTS in $IMDBTITLE; do
				MATCHRANK=$(echo "$IMDBEXISTS" | sed -e 's/IMDB\_\([0-9]\{3\}\)\-.*/\1/')
				MATCHTITLE=$(echo "$IMDBEXISTS" | sed -e 's/IMDB\_[0-9]\{3\}\-\(.*\)/\1/')
				if [ "$RANK" == "$MATCHRANK" ]; then
					echo "[IMDB] SKI ($RANK) FOUND -> $IMDBEXISTS (RANK MATCH, DIRECTORY SKIPPED)"
				else
					if [ -d "$MOVIEDIR/$IMDBEXISTS" ]; then
						echo "[IMDB] REN ($RANK) FOUND -> $IMDBEXISTS TO IMDB_$RANK-$MATCHTITLE (RANK MISMATCH, DIRECTORY RENAMED)"
						mv -f "$MOVIEDIR/$IMDBEXISTS" "$MOVIEDIR/IMDB_$RANK-$MATCHTITLE"
					fi
				fi
			done
		fi
	fi
done