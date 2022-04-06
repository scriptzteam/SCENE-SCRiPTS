#!/bin/bash

if [ "$LOGNAME" != "root" ]; then
  echo "You have to be root to run this script!"
  exit 0
fi

#########################################################################
# slv-arch+mp3 10082012 silver
#########################################################################
# 
# uses: awk basename date find grep mv
# moves dirs to appropriate target
# 
#########################################################################

DATEBIN="/bin/date"
GLROOT="/jail/glftpd"
CHROOT="/usr/sbin/chroot"

SKIPDIRS="^NUKED-.*|^\(.*|^dir1$|^dir2$"
MINS_OLD="250000" # move all dirs older than ~70 days
CHECK_FOR="\(*M*F\ \-\ COMPLETE\ \)"
MOVE="
$GLROOT/site/mdivx:*:$GLROOT/site/archive/mdivx
"

MP3SRC="/jail/glftpd/site/mp3"
MP3DEST="/jail/glftpd/site/archive/mp3"
MP3MONTHS="4 12" # move all daydirs that are 4-12 months old
AUDIOSORT="/bin/audiosort"

MVSRC="/jail/glftpd/site/mv"
MVDEST="/jail/glftpd/site/archive/mv"
MVWEEKS="25 53" # move all weekdirs that are 25-53 weeks old

#########################################################################
# end of config
#########################################################################

#move mdivx:
for FIELD in $MOVE; do
	SRCDIR="`echo $FIELD|awk -F ":" '{ print $1 }'`"
	REGEXP="`echo $FIELD|awk -F ":" '{ print $2 }'`"
	DSTDIR="`echo $FIELD|awk -F ":" '{ print $3 }'`"
	for RLS in `ls -1 $SRCDIR|egrep -v "$SKIPDIRS"`; do
		SKIP="NO"
		if [ "`ls -1 "$SRCDIR/$RLS" | grep -e "^[cC][dD][1-9]$" -e "^[dD][iI][sS][cCkK][1-9]$" -e ^[dD][vV][dD][1-9]$`" ]; then
			for each_cd in `ls -1 "$SRCDIR/$RLS" | grep -e "^[cC][dD][1-9]$" -e "^[dD][iI][sS][cCkK][1-9]$" -e ^[dD][vV][dD][1-9]$`; do
				if [ -z "`ls -1 "$SRCDIR/$RLS/$each_cd" | egrep "$CHECK_FOR"`" ]; then
					if [ "`ls -1 $SRCDIR/$RLS/$each_cd | grep "\.[sS][fF][vV]$"`" ]; then
						SKIP="YES"
						#break
					else
						SKIP="NO"
					fi
				fi
			done
		else
			if [ -z "`ls -1 "$SRCDIR/$RLS" | egrep "$CHECK_FOR"`" ]; then
				if [ "`ls -1 $SRCDIR/$RLS | grep "\.[sS][fF][vV]$"`" ]; then
					SKIP="YES"
					#break
				else
					SKIP="NO"
				fi
			fi
		fi
	        CURDATE_SEC="`$DATEBIN +%s`"
	        DIRDATE_SEC="`ls -ld --time-style='+%s' $SRCDIR/$RLS | awk '{ print $(NF-1) }'`"
	        DIRAGE_MIN=$[ ($CURDATE_SEC - $DIRDATE_SEC) / 60 ]
	        if [ "$DIRAGE_MIN" -gt "$MINS_OLD" ] && [ "$SKIP" = "NO" ]; then
			if [ "`echo $RLS|egrep "$REGEXP"`" ]; then
				if [ ! "`ls -1d $DSTDIR 2>/dev/null`" ]; then
					if [ "`echo $1|grep -i "debug"`" ]; then
						echo "DEBUG: mkdir $DSTDIR"
					else
						mkdir "$DSTDIR"
					fi
				fi
				if [ "`echo $1|grep -i "debug"`" ]; then
					echo "DEBUG: mv -n $SRCDIR/$RLS $DSTDIR"
				else
					mv -n "$SRCDIR/$RLS" "$DSTDIR"
				fi
			fi
		fi
	done
done

#move and resort mp3 daydirs:
if [ -d "$MP3SRC" ]; then
	for i in `seq $MP3MONTHS`; do
		DATE="`$DATEBIN --date="$i months ago" +%Y-%m`"
		if [ "$DATE" != "" ]; then
			for DIR in "${MP3SRC}"/"${DATE}"*; do
				DAYDIR="`basename "${DIR}"`"
				if [ "${DAYDIR}" != "" ]; then
					if [ -d "${DIR}" ] && [ ! -d "${MP3DEST}/${DAYDIR}" ]; then
						if [ "`echo $1|grep -i "debug"`" ]; then
							echo "DEBUG mv -n ${DIR} ${MP3DEST}/"
							for RLS in "${MP3SRC}"/"${DAYDIR}/"*; do
								if [ -d "${RLS}" ] && [ ! -h "${RLS}" ]; then
									CRLS="`echo "${RLS}"|sed "s@${GLROOT}@@g"`"
									echo "DEBUG: $CHROOT $GLROOT $AUDIOSORT $CRLS (USING $MP3SRC INSTEAD OF $MP3DEST!)"
								fi
							done
						else
							mv -n "${DIR}" "${MP3DEST}/"
							for RLS in "${MP3DEST}"/"${DAYDIR}/"*; do
								if [ -d "${RLS}" ] && [ ! -h "${RLS}" ]; then
									CRLS="`echo "${RLS}"|sed "s@${GLROOT}@@g"`"
									$CHROOT $GLROOT $AUDIOSORT "$CRLS" >/dev/null 2>&1
								fi
							done
						fi
					fi
				fi
			done
		fi
	done
fi

#move mv weekdirs:
if [ -d "$MVSRC" ]; then
	for i in `seq $MVWEEKS`; do
		DATE="`$DATEBIN --date="$i weeks ago" +%Y-%W`"
		if [ "$DATE" != "" ]; then
			for DIR in "${MVSRC}"/"${DATE}"; do
				WEEKDIR="`basename "${DIR}"`"
				if [ "${WEEKDIR}" != "" ]; then
					if [ -d "${DIR}" ] && [ ! -d "${MVDEST}/${WEEKDIR}" ]; then
						if [ -d "${DIR}" ]; then
							if [ "`echo $1|grep -i "debug"`" ]; then
								echo "DEBUG mv -n ${DIR} ${MVDEST}/"
							else
								mv -n "${DIR}" "${MVDEST}/"
							fi
						fi
					fi
				fi
			done
		fi
	done
fi
