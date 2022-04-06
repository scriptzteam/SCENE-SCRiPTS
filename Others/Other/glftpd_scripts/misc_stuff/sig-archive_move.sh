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
# script to move section sub directories to archive
# eg, "/glftpd/site/FLAC#2012-#/glftpd/site/ARCHIVE/FLAC#FLAC" will search for
# directories "2012-*" inside path "/glftpd/site/FLAC", and then move them
# to "/glftpd/site/ARCHIVE/FLAC/2012-*" providing the archive hdd has enough
# space to move the directories. script omits *PRE* directories found.
###############################################################################
# incoming directory#sub directory of incoming directory#archive directory#section label
INCDIRS="
/glftpd/site/FLAC#2012-#/glftpd/site/ARCHIVE/FLAC#FLAC
/glftpd/site/FLAC#2013-#/glftpd/site/ARCHIVE/FLAC#FLAC
/glftpd/site/MVID#2012-#/glftpd/site/ARCHIVE/MVID#MVID
/glftpd/site/MVID#2013-#/glftpd/site/ARCHIVE/MVID#MVID
/glftpd/site/MP3#2012-#/glftpd/site/ARCHIVE/MP3#MP3
/glftpd/site/MP3#2013-#/glftpd/site/ARCHIVE/MP3#MP3
"
# archive directory mount path (use df -mP)
ARCMOUNT="/glftpd/site/ARCHIVE"
###############################################################################
# don't edit below here!
###############################################################################

OIFS=$IFS
IFS='
'

for INCDIR in $INCDIRS; do
	INCPATH=$(echo $INCDIR | awk -F# '{print $1}')
	INCDATE=$(echo $INCDIR | awk -F# '{print $2}')
	INCARCH=$(echo $INCDIR | awk -F# '{print $3}')
	INCSECT=$(echo $INCDIR | awk -F# '{print $4}')
	echo "[+] searching $INCPATH for $INCDATE* directories..."
	find "$INCPATH" -mindepth 1 -maxdepth 1 -type d -name "$INCDATE*" | while read LINE
	do
		INCMOVE=$(echo $LINE)
		INCSUBD=$(basename $INCMOVE)
		INCLIST=$(ls "$INCMOVE" | grep -Iv ".*PRE.*" | sort -f)
		INCNUMB=$(echo "$INCLIST" | wc -l)
		echo "[+] found ${INCNUMB} releases inside /${INCSECT}/${INCSUBD}."
		for INCRELE in $INCLIST; do
			if [ ! -d "${INCARCH}/${INCSUBD}" ]; then
				echo "[+] archive directory ${INCARCH}/${INCSUBD} not found, creating it."
				mkdir -m777 -p "${INCARCH}/${INCSUBD}"
			fi
			ARCFREE=$(df -mP | grep -I "$ARCMOUNT$" | awk '{print $(NF-2)}')
			RELSIZE=$(du -sm "${INCPATH}/${INCSUBD}/${INCRELE}" | cut -f1)
			TOTSIZE=$(( $ARCFREE - $RELSIZE ))
			if [ "$TOTSIZE" -le "0" ]; then
				echo "[-] archive is out of space, ${ARCFREE}MB."
				exit 0
			else
				echo "[+] archive has enough space, ${ARCFREE}MB."
			fi
				echo "[+] /${INCSECT}/${INCSUBD}/${INCRELE} containing ${RELSIZE}MB is moving to archive..."
				cp -rf --preserve "${INCPATH}/${INCSUBD}/${INCRELE}" "${INCARCH}/${INCSUBD}/"
				DIFFERENCE=$(diff -qr "${INCPATH}/${INCSUBD}/${INCRELE}" "${INCARCH}/${INCSUBD}/${INCRELE}")
				while [ ! -z "$DIFFERENCE" ]
				do
					echo "[-] unsuccessful move of ${INCRELE} to ${INSECT} archive, redoing move!"
					rm -rf "${INCARCH}/${INCSUBD}/${INCRELE}"
					cp -rf --preserve "${INCPATH}/${INCSUBD}/${INCRELE}" "${INCARCH}/${INCSUBD}/"
					DIFFERENCE=$(diff -qr "${INCPATH}/${INCSUBD}/${INCRELE}" "${INCARCH}/${INCSUBD}/${INCRELE}")
				done
				if [ -z "$DIFFERENCE" ]; then
					echo "[+] successful move of ${INCRELE} to ${INCSECT} archive, deleting source!"
					rm -rf "${INCPATH}/${INCSUBD}/${INCRELE}"
				fi
			INCNUMB=$(( $INCNUMB - 1 ))
		done
	if [ -d "${INCARCH}/${INCSUBD}" ]; then
		echo "[+] changing ${INCARCH}/${INCSUBD} perms to read only"
		chmod -R 755 "${INCARCH}/${INCSUBD}"
		echo "[+] changing ${INCARCH}/${INCSUBD} owner to 0:0"
		chown -R 0:0 "${INCARCH}/${INCSUBD}"
	fi
	if [ -d "${INCMOVE}" ]; then
		echo "[+] removing source directory ${INCMOVE}"
		rm -rf "${INCMOVE}"
	fi
	done
done