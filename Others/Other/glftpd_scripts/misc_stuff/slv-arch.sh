#!/bin/sh
if [ $( id -u ) -ne 0 ] || [ "$LOGNAME" != "root" ]; then
echo "You have to be root to run this script!"; exit 0; fi

################################################################################
# slv-arch 20171218 silver
################################################################################
#
# slv-archiver - moves releases from incoming to archive, supports tv series
#
# - Moves dirs to appropriate target dir in archive
#   e.g. /apps/* -> /archive/apps
# - Creates dirs in archive for tv series
#   e.g. /tv/Series.Name.S01E02-GRP -> /archive/tv/Series/S01
# - Supports ".1 .2 .3" symlinks to muliple TV archive disks, like tur-links
#
# Needs: awk basename date find grep touch
#
# NOTE: I suggest you always leave MINS_OLD defined as "failsafe",
#       even if you use NUM_DIRS_TV instead
#
################################################################################

DATEBIN="/bin/date"
GLDIR="/jail/glftpd"
LOGDIR="$GLDIR/ftp-data/logs"
TVARCHIVE="$GLDIR/site/archive/tv"
SKIP_PATH="^NUKED-.*|^\(.*|^_archive$|^FOO$|^BAR$"
MINS_OLD="10080"  # releases need to be 1 week old before moving (7x24x60mins)
# Uncomment to ignore MINS_OLD and in TVDIRS move 15 oldest releases instead:
# NUM_DIRS_TV="15"
CHECK_FOR="\(*M*F\ \-\ COMPLETE\ \)"
MIN_FREE="52428800"  # need 50GB+ free on MOUNT(s) before moving, 0 to disable

# Set CHECK_MOUNTS to "1" to check if these are mounted before moving
MOUNTS="
$GLDIR/site/archive
/dev/mapper/archive2
"

###############################################################################
# ALL SECTIONS:
###############################################################################
# Define which sections you want to move: apps, console, games, movies etc.
# MOVE does not use Series/Season structure. You can however add TV if
# want to move it without using Series/Season, see EXAMPLES below.
# NOTE: MOVE dirs are processed first (from top to bottom) and *before* TVDIRS

# SYNTAX: SOURCE_DIR:REGEXP:TARGET_DIR
# EXAMPLES:
MOVE="
$GLDIR/site/apps:*:$GLDIR/site/archive/apps
$GLDIR/site/divx:.*[._]G[eE][rR][mM][aA][nN][._].*:$GLDIR/site/archive/divx-de
$GLDIR/site/tv:^Holby.[cC]ity[._].*:$GLDIR/site/archive/tv-uk
$GLDIR/site/tv:.*-RiVER$:$GLDIR/site/archive/tv-uk
$GLDIR/site/x264:.*1080[pP].*$:$GLDIR/archive/x264-1080p
"

###############################################################################
# TV SECTION:
###############################################################################

# Source dir(s) for releases you want to move to Series/Season structure
TVDIRS="
$GLDIR/site/tv
"

# Target dir (archive)
TVARCHIVE="$GLDIR/site/archive/tv"

# Optionally set this variable if your tv archive uses symlinks to multiple
# "sub disks", like tur-links. E.g. your storage devices are mounted as:
# /archive/tv/.1 /archive/tv/.2 /archive/tv/.3 (or .mnt1 .mnt2 .mnt3 etc)
# TVARCSUBS=".1 .2 .3"

################################################################################
# END OF CONFIG
################################################################################

DEBUG=0
# NOTE: "./slv-arch.sh DEBUG" does not actually mkdir and mv but
# just shows what actions the script would have executed instead

if echo "$1" | grep -iq "debug"; then DEBUG=1; fi

if echo "$MINS_OLD" | grep -qv "[0-9]\+"; then echo "[ERROR] MINS_OLD is not set correctly, exiting..."; exit 1; fi

func_bc() {
	if echo "$1" | grep -q "[0-9]"; then
		U="$2"
		if [ "$U" = "" ]; then
			if [ "$1" -lt "1024" ]; then U="KB"
				elif [ "$1" -ge "1024" ] && [ "$1" -lt "1024000" ]; then U="MB"
				elif [ "$1" -ge "1024000" ] && [ "$1" -lt "1024000000" ]; then U="GB"
				elif [ "$1" -ge "1024000000" ]; then U="TB"
			fi
		fi
		if [ "$U" = "KB" ]; then RET="${1}KB"
			elif [ "$U" = "MB" ]; then RET="$(( $1 / 1024 ))MB"
			elif [ "$U" = "GB" ]; then RET="$(( $1 / 1024 / 1024 ))GB"
			elif [ "$U" = "TB" ]; then RET="$( echo "$1 1024" | awk '{ printf "%0.1f%s", $1 / $2 / $2 / $2, "TB"; }' )"
		fi
	fi
	echo "$RET"
}

ALLMNT=""; i=0; MAX=0; MAX="$( echo "$MOUNTS" | wc -w )"
for M in $MOUNTS; do
	if [ $i -lt $(( MAX-1 )) ]; then ALLMNT="$ALLMNT\|$M"
	else ALLMNT=$M${ALLMNT}; fi
	i=$(( i+1 ))
done

MIN_FREE_GB="$( func_bc $MIN_FREE GB )"
func_df() {
	for d in "$@"; do
		DBGTXT="[DEBUG]"; if echo $d | grep -q $TVARCHIVE; then DBGTXT="$DBGTXT TVARCHIVE:"; fi
		if [ "$CHECK_MOUNTS" -eq 1 ]; then
			if ! findmnt --target "$d" | grep -q "\(^\| \)\($ALLMNT\)\(/\.[0-9]\| \)"; then
				if [ "$DEBUG" -eq 1 ]; then
					if [ "$d" != "$mtmp" ]; then echo "$DBGTXT $d - NOK: device not mounted"; fi
					mtmp="$d"
				fi
				return 1
			fi
		fi
		FS=$( df "$d" | awk '{ print $1 }' | tail -1 )
		DF=$( df "$d" | awk '{ print $4 }' | tail -1 )
		if echo "$DF" | grep -q "[0-9]"; then
			if [ "$DF" -lt "$MIN_FREE" ]; then
				if [ "$DEBUG" -eq 1 ]; then if [ "$d" != "$dtmp" ]; then echo "$DBGTXT $d - NOK: not enough disk space on \"$FS\" ($(func_bc "$DF" GB) free, $MIN_FREE_GB needed)"; fi; fi
				dtmp="$d"
				return 1
			else
				if [ "$DEBUG" -eq 1 ]; then if [ "$d" != "$dtmp" ]; then echo "$DBGTXT $d - OK: enough disk space on \"$FS\" ($(func_bc "$DF" GB) free, $MIN_FREE_GB needed)"; fi; fi
				dtmp="$d"
				return 0
			fi
		else
			echo "[ERROR] could not get free disk space on $d"
			return 1
		fi
	done
}

for RULE in $MOVE; do
	SRCDIR="$( echo "$RULE" | awk -F ":" '{ print $1 }' )"
	REGEXP="$( echo "$RULE" | awk -F ":" '{ print $2 }' )"
	DSTDIR="$( echo "$RULE" | awk -F ":" '{ print $3 }' )"
	for RLS in $( find "$SRCDIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort | grep -Ev "$SKIP_PATH" ); do
		if ! func_df "$DSTDIR"; then 
			if [ "$DEBUG" -eq 1 ]; then 
				if [ "$DEBUG" -eq 1 ]; then if [ "$DESTDIR" != "$stmp" ]; then echo "[DEBUG] skipping $DSTDIR"; fi; fi
				stmp="$DESTDIR"
			fi
		 	continue
		fi
		SKIP="NO"
 		if ls -1 "$SRCDIR/$RLS" | grep -q -e "^[cC][dD][1-9]$" -e "^[dD][iI][sS][cCkK][1-9]$" -e "^[dD][vV][dD][1-9]$"; then
			for each_cd in $( ls -1 "$SRCDIR/$RLS" | grep -e "^[cC][dD][1-9]$" -e "^[dD][iI][sS][cCkK][1-9]$" -e "^[dD][vV][dD][1-9]$" ); do
				if [ -z "$( ls -1 "$SRCDIR/$RLS/$each_cd" | grep -E "$CHECK_FOR" )" ]; then
					if ls -1 "$SRCDIR/$RLS/$each_cd" | grep -q "\.[sS][fF][vV]$"; then
						SKIP="YES"
					else
						SKIP="NO"
					fi
				fi
			done
		else
			if [ -z "$( ls -1 "$SRCDIR/$RLS" | grep -E "$CHECK_FOR" )" ]; then
				if ls -1 "$SRCDIR/$RLS" | grep -q "\.[sS][fF][vV]$"; then
					SKIP="YES"
				else
					SKIP="NO"
				fi
			fi
		fi
		CURDATE_SEC="$( $DATEBIN +%s )"; DIRAGE_MIN=0
		DIRDATE_SEC="$( ls -ld --time-style='+%s' "$SRCDIR/$RLS" | awk '{ print $6 }' )"
		if echo "$DIRDATE_SEC" | grep -q "[0-9]"; then DIRAGE_MIN=$(( (CURDATE_SEC - DIRDATE_SEC) / 60 )); fi
		if [ "$DIRAGE_MIN" -ge "$MINS_OLD" ] && [ "$SKIP" = "NO" ]; then
			if echo "$RLS" | grep -Eq "$REGEXP"; then
				if [ ! "$( ls -1d "$DSTDIR" 2>/dev/null )" ]; then
					if [ "$DEBUG" -eq 1 ]; then
						echo "[DEBUG] mkdir $DSTDIR"
					else
						mkdir "$DSTDIR"
					fi
				fi
				if [ "$DEBUG" -eq 1 ]; then
					echo "[DEBUG] mv $SRCDIR/$RLS $DSTDIR"
				else
					mv "$SRCDIR/$RLS" "$DSTDIR"
				fi
			fi
		fi
		if [ "$DEBUG" -eq 1 ]; then
			echo "[DEBUG] SRCDIR/RLS: $SRCDIR/$RLS DSTDIR: $DSTDIR REGEXP: $REGEXP"
		fi
	done
done

SKIP_SECTION=""; for DIR in $TVDIRS; do SKIP_SECTION="^$DIR\$|$SKIP_SECTION"; done
for RULE in $MOVE; do
	SRCDIR="$( echo "$RULE" | awk -F ":" '{ print $1 }' )"
	REGEXP="$( echo "$RULE" | awk -F ":" '{ print $2 }' )"
	DSTDIR="$( echo "$RULE" | awk -F ":" '{ print $3 }' )"
	if echo $TVDIRS | grep -q $SRCDIR; then
		if echo $DSTDIR | grep -q $TVARCHIVE; then
			SKIP_PATH="$REGEXP|$SKIP_PATH"
		fi
	fi
done

if [ -z "$TVARCSUBS" ]; then
	if ! func_df "$TVARCHIVE"; then
		if [ "$DEBUG" -eq 1 ]; then
			echo "[DEBUG] skipping $DSTDIR"
		fi
		exit 1
	fi
else
	TVARCHSUB="$( for i in $TVARCSUBS; do if func_df "$TVARCHIVE/$i" KB; then echo "$i $DF"; fi; done | \
	grep -v "[DEBUG]" | sort -k2 -n | tail -1 | awk '{ print $1 }' )"
	if [ "$TVARCHSUB" ]; then
		if [ "$DEBUG" -eq 1 ]; then
			echo "[DEBUG] TVARCHIVE: $TVARCHIVE - OK: subdisk \"$TVARCHSUB\" has the most disk space free (of \"$TVARCSUBS\")"; func_df "$TVARCHIVE/$TVARCHSUB"
		fi
	else
		if [ "$DEBUG" -eq 1 ]; then
			echo "[DEBUG] TVARCHIVE: $TVARCHIVE - NOK: none of the subdisks \"$TVARCSUBS\" are mounted and/or have enough disk space free"
		fi
		exit 1
	fi
fi

for TVDIR in $TVDIRS; do
if echo "$NUM_DIRS_TV" | grep -q "[0-9]"; then
		CURDATE_SEC="$( "$DATEBIN" +%s )"
		# use this format for skip_path here: "/NUKED-|/\(|/_ARCHIVE\ |/_OLDER\ "
		SKIP_PATH_TMP="$( echo "$SKIP_PATH" | sed -e 's@\^@/@g' -e 's@\.\*@@g' -e 's@\$@\\\ @g' )"
		if [ "$DEBUG" -eq 1 ]; then echo "[DEBUG] TVARCHIVE: NUM_DIRS_TV $NUM_DIRS_TV SKIP_PATH_TMP $SKIP_PATH_TMP"; fi
		for DIR in $( ls -ldrt --time-style='+%s' "$TVDIR"/* | grep -Ev "$SKIP_PATH_TMP" | head -"$NUM_DIRS_TV" | sed "s@$GLDIR/site@@g" | sed 's/ /^/g' ); do
			DIRDATE_SEC="$( echo "$DIR" | awk -F \^ '{ print $6 }' )"
			if echo "$DIRDATE_SEC" | grep -q "[0-9]"; then DIRAGE_MIN=$(( (CURDATE_SEC - DIRDATE_SEC) / 60 )); fi
			if [ "$DEBUG" -eq 1 ]; then echo "[DEBUG] TVARCHIVE: DIR $DIR DIRDATE_SEC $DIRDATE_SEC DIRAGE_MIN $DIRAGE_MIN"; fi
		done
		if echo "$DIRAGE_MIN" | grep -q "[0-9]"; then MINS_OLD="$DIRAGE_MIN"; fi
	fi

	SKIP_REGEXP="$( echo "$SKIP_PATH" | sed "s@\^@\^$TVDIR/@g" )"
	for DIR in $( find "$TVDIR" -maxdepth 1 -regextype posix-egrep ! -regex "${SKIP_SECTION}${SKIP_REGEXP}" ); do
		if [ ! -z "$TVARCSUBS" ]; then
			TVARCHSUB="$( for i in $TVARCSUBS; do if func_df "$TVARCHIVE/$i" KB; then echo "$i $DF"; fi; done | grep -v "[DEBUG]" | sort -k2 -n | tail -1 | awk '{ print $1 }' )"
		fi
		SKIP="NO"
		if ls -1 "$DIR" | grep -q -e "^[cC][dD][1-9]$" -e "^[dD][iI][sS][cCkK][1-9]$" -e "^[dD][vV][dD][1-9]$"; then
			for each_cd in $( ls -1 "$DIR" | grep -e "^[cC][dD][1-9]$" -e "^[dD][iI][sS][cCkK][1-9]$" -e "^[dD][vV][dD][1-9]$" ); do
				if [ -z "$( ls -1 "$DIR/$each_cd" | grep -E "$CHECK_FOR" )" ]; then
					if ls -1 "$DIR/$each_cd" | grep -q "\.[sS][fF][vV]$"; then
						SKIP="YES"
					else
						SKIP="NO"
					fi
				fi
			done
		else
			if [ -z "$( ls -1 "$DIR" | grep -E "$CHECK_FOR" )" ]; then
				if ls -1 "$DIR" | grep -q "\.[sS][fF][vV]$"; then
					SKIP="YES"
				else
					SKIP="NO"
				fi
			fi
		fi
		CURDATE_SEC="$( $DATEBIN +%s )"
		DIRDATE_SEC="$( ls -ld --time-style='+%s' "$DIR" | awk '{ print $6 }' )"
		if echo "$DIRDATE_SEC" | grep -q "[0-9]"; then DIRAGE_MIN=$(( (CURDATE_SEC - DIRDATE_SEC) / 60 )); fi
		if [ "$DIRAGE_MIN" -ge "$MINS_OLD" ] && [ "$SKIP" = "NO" ]; then
			BASEDIR="$( basename "$DIR" )"
			SRCSERIES="$( echo "$BASEDIR" | sed \
				-e 's/^(no-\(nfo\|sfv\|sample\))-//g' \
				-e 's/\([._]\)A\([._]\)/\1a\2/g' \
				-e 's/\([._]\)And\([._]\)/\1and\2/g' \
				-e 's/\([._]\)In\([._]\)/\1in\2/g' \
				-e 's/\([._]\)Is\([._]\)/\1is\2/g' \
				-e 's/\([._]\)The\([._]\)/\1the\2/g' \
				-e 's/\([._]\)Of\([._]\)/\1of\2/g' \
				-e 's/\([._]\)On\([._]\)/\1on\2/g' \
				-e 's/\([._]\)Or\([._]\)/\1or\2/g' \
				-e 's/\([._]\)With\([._]\)/\1with\2/g' \
				-e 's/\.\(S[0-9]\+E[0-9]\+\)\..*//gi' \
				-e 's/\.\(S[0-9]\+E[0-9]\+\-E[0-9]\+\)\..*//gi' \
				-e 's/\.\(S[0-9]\+E[0-9]\+[E-][0-9]\+\)\..*//gi' \
				-e 's/\.\(S[0-9]\+\)\..*//gi' \
				-e 's/\.\(E[0-9]+\)\..*//gi' \
				-e 's/[._]\(\([0-9]\|[0-9]\)x[0-9]\+\)[._].*//gi' \
				-e 's/[._]\([0-9]\+[._][0-9]\+[._][0-9]\+\)[._].*//gi' \
				-e 's/[._-]\(hdtv\|pdtv\|dsr\|dsrip\|webrip\|web\|h264\|x264\|\|xvid\|720p\|1080p\|dvdrip\|ws\)\($\|[._-]\).*//gi' \
				-e 's/[._-]\(dirfix\|proper\|repack\|nfofix\|preair\|pilot\|ppv\|extended\|part.[0-9]\+\)\($\|[._-]\).*//gi' \
				-e 's/[._-]\(dutch\|german\|french\|hungarian\|italian\|norwegian\|polish\|portuguese\|spanish\|russian\|swedish\)\($\|[._-]\).*//gi' )"
			SEASON="$( echo "$DIR" | sed -e 's/.*[._-]S\([0-9]\+\)E[0-9].*/\1/i' \
				-e 's/.*S\([0-9]\|[0-9][0-9]\+\)\..*/\1/i' \
				-e 's/.*[._-]\([0-9]\+\)x[0-9].*/\1/i' \
				-e 's/.*\([0-9][0-9][0-9][0-9]\).[0-9][0-9].[0-9][0-9].*/\1/i' )"
			if echo "$SEASON" | grep -q "^[0-9]$"; then SEASON="S0$SEASON"; else SEASON="S$SEASON"; fi
			if echo "$SEASON" | grep -qv "^S\([0-9]$\|[0-9][0-9]\|[0-9][0-9][0-9]\)$"; then SEASON=""; fi
			DSTSERIES="$( echo "$SRCSERIES" | sed 's/\(\w\)_/\1\./g' )"
			CHKSERIES="$( echo "$DSTSERIES" | sed 's/\([a-z]\|[A-Z]\)/[\L\1\U\1\]/g' )"
			DIRDATE="$( $DATEBIN --date "01/01/1970 +$DIRDATE_SEC seconds" +"%Y-%m-%d %H:%M:%S" )"
			if [ "$SEASON" = "" ]; then
				if [ ! "$( ls -1d $TVARCHIVE/$CHKSERIES 2>/dev/null )" ]; then
					if [ -z "$TVARCHSUB" ]; then
						if [ "$DEBUG" -eq 1 ]; then
							echo "[DEBUG] TVARCHIVE:" mkdir "$TVARCHIVE/$DSTSERIES"
						else
							mkdir "$TVARCHIVE/$DSTSERIES"
						fi
					else
						if [ "$DEBUG" -eq 1 ]; then
							echo "[DEBUG] TVARCHIVE:" mkdir "$TVARCHIVE/$TVARCHSUB/$DSTSERIES"
							if [ ! -L $TVARCHIVE/$CHKSERIES ]; then echo "[DEBUG] TVARCHIVE:" ln -s "$TVARCHSUB/$DSTSERIES" "$TVARCHIVE/$DSTSERIES"; fi
						else
							mkdir "$TVARCHIVE/$TVARCHSUB/$DSTSERIES"
							if [ ! -L $TVARCHIVE/$CHKSERIES ]; then ln -s "$TVARCHSUB/$DSTSERIES" "$TVARCHIVE/$DSTSERIES"; fi
						fi
					fi
				fi
				if [ "$( ls -1d $TVARCHIVE/$CHKSERIES 2>/dev/null )" ]; then
					if [ -z "$TVARCHSUB" ]; then
						if [ "$DEBUG" -eq 1 ]; then
							echo "[DEBUG] TVARCHIVE:" mv "$DIR" $TVARCHIVE/$CHKSERIES/
						else
							mv "$DIR" $TVARCHIVE/$CHKSERIES/
						fi
					else
						if [ -L $TVARCHIVE/$CHKSERIES ]; then
							TVLINKSUB="$( dirname "$( readlink $TVARCHIVE/$CHKSERIES )" )"
							if [ "$TVLINKSUB" = "$TVARCHSUB" ]; then
								if [ "$DEBUG" -eq 1 ]; then
									echo "[DEBUG] TVARCHIVE:" mv "$DIR" $TVARCHIVE/$CHKSERIES/
								else
									mv "$DIR" $TVARCHIVE/$CHKSERIES/
								fi
							else
								if func_df "$TVARCHIVE/$TVLINKSUB"; then
									if [ "$DEBUG" -eq 1 ]; then
										echo "[DEBUG] TVARCHIVE:" mv "$DIR" $TVARCHIVE/$CHKSERIES/$SEASON "(on subdisk \"$TVLINKSUB\")"
									else
										mv "$DIR" $TVARCHIVE/$CHKSERIES/$SEASON
									fi
								else
									echo "[INFO] skipping mv $DIR - \"$DSTSERIES\" is not on \"$TVARCHSUB\"" and \"$TVLINKSUB\" is full/unmounted
								fi
							fi
						fi
					fi
				fi
				if [ "$( ls -1d $TVARCHIVE/$CHKSERIES/$BASEDIR 2>/dev/null )" ]; then
					if [ "$DEBUG" -eq 1 ]; then
						echo touch -d "$DIRDATE" $TVARCHIVE/$CHKSERIES/$BASEDIR
					else
						touch -d "$DIRDATE" $TVARCHIVE/$CHKSERIES/$BASEDIR
					fi
				fi
			else
				if [ ! "$( ls -1d $TVARCHIVE/$CHKSERIES 2>/dev/null )" ]; then
					if [ -z "$TVARCHSUB" ]; then
						if [ "$DEBUG" -eq 1 ]; then
							echo "[DEBUG] TVARCHIVE:" mkdir $TVARCHIVE/$DSTSERIES
						else
							mkdir $TVARCHIVE/$DSTSERIES
						fi
					else
						if [ "$DEBUG" -eq 1 ]; then
							echo "[DEBUG] TVARCHIVE:" mkdir "$TVARCHIVE/$TVARCHSUB/$DSTSERIES"
							if [ ! -z "$TVARCHSUB" ]; then
								if [ ! -L $TVARCHIVE/$CHKSERIES ]; then echo "[DEBUG] TVARCHIVE:" ln -s "$TVARCHSUB/$DSTSERIES" "$TVARCHIVE/$DSTSERIES"; fi
							fi
						else
							mkdir "$TVARCHIVE/$TVARCHSUB/$DSTSERIES"
							if [ ! -z "$TVARCHSUB" ]; then
								if [ ! -L $TVARCHIVE/$CHKSERIES ]; then ln -s "$TVARCHSUB/$DSTSERIES" "$TVARCHIVE/$DSTSERIES"; fi
							fi
						fi
					fi
				fi
				if [ ! "$( ls -1d $TVARCHIVE/$CHKSERIES/$SEASON 2>/dev/null )" ]; then
					if [ -z "$TVARCHSUB" ]; then
						if [ "$DEBUG" -eq 1 ]; then
							echo "[DEBUG] TVARCHIVE:" mkdir $( ls -1d $TVARCHIVE/$CHKSERIES 2>/dev/null || echo [LS_ERR]:$TVARCHIVE/$CHKSERIES )/$SEASON
						else
							#mkdir $TVARCHIVE/$TVARCHSUB/$DSTSERIES/$SEASON
							mkdir $( ls -1d $TVARCHIVE/$CHKSERIES 2>/dev/null )/$SEASON
						fi
					else
						if [ -L $TVARCHIVE/$CHKSERIES ]; then
							TVLINKSUB="$( dirname "$( readlink $TVARCHIVE/$CHKSERIES )" )"
							if [ "$TVLINKSUB" = "$TVARCHSUB" ]; then
								if [ "$DEBUG" -eq 1 ]; then
									#echo "[DEBUG] TVARCHIVE:" mkdir $TVARCHIVE/$TVARCHSUB/$DSTSERIES/$SEASON
									echo "[DEBUG] TVARCHIVE:" mkdir $( ls -1d $TVARCHIVE/$CHKSERIES 2>/dev/null || echo [LS_ERR]:$TVARCHIVE/$CHKSERIES )/$SEASON
								else
									mkdir $( ls -1d $TVARCHIVE/$CHKSERIES 2>/dev/null )/$SEASON
								fi
							else
								if func_df "$TVARCHIVE/$TVLINKSUB"; then 
									if [ "$DEBUG" -eq 1 ]; then
										echo "[DEBUG] TVARCHIVE:" mkdir $( ls -1d $TVARCHIVE/$CHKSERIES 2>/dev/null || echo [LS_ERR]:$TVARCHIVE/$CHKSERIES )/$SEASON "(on subdisk \"$TVLINKSUB\")"
									else	
										mkdir $( ls -1d $TVARCHIVE/$CHKSERIES 2>/dev/null )/$SEASON 
									fi
								else
									echo "[INFO] skipping mkdir $TVARCHIVE/$DSTSERIES/$SEASON - \"$DSTSERIES\" links to \"$TVLINKSUB\" which is full/unmounted (not on \"$TVARCHSUB\")"
								fi
							fi
						fi
					fi
				fi
				if [ "$( ls -1d $TVARCHIVE/$CHKSERIES/$SEASON 2>/dev/null )" ]; then
					if [ -z "$TVARCHSUB" ]; then
						if [ "$DEBUG" -eq 1 ]; then
							echo "[DEBUG] TVARCHIVE:" mv "$DIR" $TVARCHIVE/$CHKSERIES/$SEASON
						else
							mv "$DIR" $TVARCHIVE/$CHKSERIES/$SEASON
						fi
					else
						if [ -L $TVARCHIVE/$CHKSERIES ]; then
							TVLINKSUB="$( dirname "$( readlink $TVARCHIVE/$CHKSERIES )" )"
							if [ "$TVLINKSUB" = "$TVARCHSUB" ]; then
								if [ "$DEBUG" -eq 1 ]; then
									echo "[DEBUG] TVARCHIVE:" mv "$DIR" $TVARCHIVE/$CHKSERIES/$SEASON
								else
									mv "$DIR" $TVARCHIVE/$CHKSERIES/$SEASON
								fi
							else
								if func_df "$TVARCHIVE/$TVLINKSUB"; then 
									if [ "$DEBUG" -eq 1 ]; then
										echo "[DEBUG] TVARCHIVE:" mv "$DIR" $TVARCHIVE/$CHKSERIES/$SEASON "(on subdisk \"$TVLINKSUB\")"
									else	
										mv "$DIR" $TVARCHIVE/$CHKSERIES/$SEASON
									fi
								else
									echo "[INFO] skipping mv $DIR - dir \"$DSTSERIES\" is not on \"$TVARCHSUB\"" and \"$TVLINKSUB\" is full or not mounted
								fi
							fi
						fi
					fi
				fi
				if [ "$( ls -1d $TVARCHIVE/$CHKSERIES/$SEASON/$BASEDIR 2>/dev/null )" ]; then
					if [ "$DEBUG" -eq 1 ]; then
						echo "[DEBUG] TVARCHIVE:" touch -d "$DIRDATE" $TVARCHIVE/$CHKSERIES/$SEASON/$BASEDIR
					else
						touch -d "$DIRDATE" $TVARCHIVE/$CHKSERIES/$SEASON/$BASEDIR
					fi
				fi
			fi
		fi
	done
done
