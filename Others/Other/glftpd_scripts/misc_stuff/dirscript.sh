#!/bin/bash
# -------------------------------------------------------------------------
# Jehsom's mp3 dirscript v1.5 - Prevents creation of undesired directories.
# Copyright (C) 2001 jehsom@jehsom.com
# 		2018 slv/sscripts.ga
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# -------------------------------------------------------------------------
#
# This dirscript is primarily for mp3 sites. It allows the siteop to
#   prevent certain types of releases from ever being uploaded by not
#   allowing the user to create the directory in the first place. It
#   is very powerful, allowing restrictions by rls date, rls group,
#   name format, and can disallow live rels, rels already in the dupe
#   log, and rels already existing in your site's PRE directories (to
#   prevent racing of PREs. Add it to glftpd.conf as pre_dir_check.
#
# Changes 1.4.1 -> 1.5:
#   * made DIR_CHECK, PRE_DIRS, BANNED and DAYSBACK optional
#   * dont log the same msg more than once (needs $LOGFILE.tmp)
#   * deny trading affil pre's (DENY_PRETRADE)
#   * made ALLOWED_YEARS a bit more "dynamic" (ALLOWED_DYN_YEARS)
#   * deny dupe releasedirs in yesterdays dir (CHECK_DUPE_YDAY)
#   * deny previously NUKED releases in today/yesterdays dir
#   * renamed script to dirscript.sh
#
# Changes 1.4 -> 1.4.1:
#   * "sample" dirs are no longer checked against the dupe DB (like cd[1-9]).
#
# Explanation of configuration options:
# -------------------------------------
# NOCHECK_TREES - Don't process new dirs under these directory hier-
#	archies. Multiple hierarchies should be space delimited.
# DAYSBACK - Number of days back to check with regular dupechecking.
#	If ANALDUPECHECK=1, set this low, as it's quite slow.
# BANNED - Names of groups whose releases aren't allowed (space delim).
# ANALDUPECHECK - 1/0 Check thru entire SITE DUPE db to make sure the dir
#	being created is DEFINITELY not a dupe. Very fast.
# DATAPATH - glftpd's datapath, as listed in glftpd.conf
# ALLOWPARENS - Allow dirnames to start with "("
# RIAA_UNDERSCORES - Tries to disallow Names.Like--This.Name-FOO as
#	the RIAA specs say that Names_Must-Be_Like-THIS
# RIAA_NAMELENGTH - Enforces the RIAA 64-char max dirname length
# ALLOWED_YEARS - Disallows directories not containing the 4-digit year 
#	number or one of several permutations of the last 2 digits and
#	punctuation (e.g. *-99*, *.99*, *99.*, *99-*, *99####*, *####99*,
#	etc.) It is very intelligent. I suggest you try it out. Multiple
#	allowed years should be space delimited.
# AFFILS - Space delimited list of groups allowed to break the banned years
#	rules. For this to work, the new dir's name must end in "-GRP", 
#	where GRP is the group you have specified here.
# LOGFILE - Logs the denied MKDIR requests, and lists the reason and
#	user who tried to create the directory. Make sure the file is
#	world writable (chmod 666) so this can work.
#	Sames goes for $LOGFILE.tmp (needed to prevent spamming log)
# LIVE_OK - 1/0 Whether to allow Live releases from non-affils
# PRE_DIRS - If a rls is already here, its creation will be prevented.
# ALLOWED_DYN_YEARS - Instead of "fixed" years you also use "dynamic" years.
#	Set it to "-3 1" to allow releases from 3y in the past to 1y in the
#	future. If this is set it replaces ALLOWED_YEARS. Don't need to
#	update a variable anymore every few years :) 
# BANNEDALSO - For banning on strings like BOOTLEG, -SRC- and -CC- etc
# DATE_FORMAT - Date format for daydirs e.g. 1231 is "%m%d"
# CHECK_DIR - 1/0 Disabled by default since it is kinda useless, but its
#	there if you want it
# SITE_DIR - Set to mp3 section e.g. /site/mp3, used for denying dupes
#	in yesterdays daydir 
# CHECK_PRE_DIRS - 1/0 Enable PRE_DIRS check. Default is disabled
# CHECK_DUPE_YDAY - 1/0 Deny dupe releasedirs in yesterdays dir
# CHECK_NUKED - 1/0 Deny previously NUKED releases
# CHECK_NUKED_YDAY - 1/0 Deny previously NUKED releases in yesterdays dir
# CHECK_BANNED_GROUPS - 1/0 Deny releases by BANNED groups
# CHECK_BANNED_ALSO - 1/0 Deny release dirs matching BANNEDALSO
# DENY_PRETRADE - 1/0 Deny mkdir for AFFILS releases (allows latepre)
# AFFILS_LATEPRE - Use these affils for DENY_PRETRADE instead of all AFFILS

NOCHECK_TREES="/site/Requests_Filled /site/Incoming/Billboard_Top"
DAYSBACK="1"
BANNED="GRPNAME LAMErS CRAP"
ANALDUPECHECK="0"
BANNEDALSO="^NUKED\- ^INCOMPLETE\- \-Bootleg\- \-Bootleg _Bootleg_ _Bootleg\- \(Bootleg\) \-EG\- \-GR\- \-LV\- \-SE\- \-Tape\-" 
DATAPATH="/ftp-data"
ALLOWPARENS="0"
RIAA_UNDERSCORES="0"
RIAA_NAMELENGTH="0"
#ALLOWED_YEARS="2000 2001 2002"
ALLOWED_DYN_YEARS="-3 1"
AFFILS="GRP MyAFFIL LEETMP3"
LOGFILE="/ftp-data/logs/dirscript.log"
LIVE_OK="1"
PRE_DIRS="/site/Incoming/*_Pre_Dir"
SITE_DIR="/site/Incoming/Mp3"
DATE_FORMAT="%m%d"
CHECK_DIR="0"
CHECK_PRE_DIRS="0"
CHECK_DUPE_YDAY="1"
CHECK_NUKED="1"
CHECK_NUKED_YDAY="1"
CHECK_BANNED_GROUPS="1"
CHECK_BANNEDALSO="1"
CHECK_DAYSBACK="0"
DENY_PRETRADE="1"
#AFFILS_LATEPRE="LAZYAFFIL SLOWGROUP"

#######################
### Ignore the rest ###
#######################

BINS="date expr ls sed"

function logexit () {
	if ! grep -q "Denied $1 to user $USER ($2)" "${LOGFILE}.tmp"; then
		echo "$( date +%F\ %T ): Denied $1 to user $USER ($2)" >> "$LOGFILE"
	fi
	echo "Denied $1 to user $USER ($2)" > "${LOGFILE}.tmp"
	exit 2
}

[ -w /dev/null ] || { echo "/dev/null must be writable. Exiting."; exit 0; }

for bin in $BINS; do 
    type $bin > /dev/null 2>&1 || {
        echo "The '$bin' binary must be installed in glftpd's bin dir."
        logexit $2/$1 "Required bin not found"
    }
done

# If we're in an excepted directory tree, allow the dir without checking it
for tree in $NOCHECK_TREES; do
	case $2 in
	    ${tree}*)
		exit 0
		;;
	    *)
		;;
	esac
done

# If the dir already exists, it's obviously not right to create it                                                                                                                                                                          
[ "$CHECK_DIR" -eq "1" ] && {
	[ -d "$2/$1" ] && {
		echo "Directory already exists!"
		logexit $2/$1 "Dir Already Existing"
	}
}

[ "$CHECK_PRE_DIRS" -eq "1" ] && {
	for predir in $PRE_DIRS; do
	        [ -d "$predir/$1" ] && {
			echo "This release is in the group's pre dir."
                	echo "Please wait until they pre it."
			logexit $2/$1 "About to be pre'd"
	        }
	done
}

# Deny dupe releasedirs in yesterdays dir
[ "$CHECK_DUPE_YDAY" -eq "1" ] && {
	YDAY=$( date --date "$(echo $2|sed 's@^'$SITE_DIR'/\([0-9-]\{4,10\}\)/\?$@\1@') -1 day" +"$DATE_FORMAT" 2>/dev/null )
	[ "$?" != "0" ] && YDAY=$( date --date "-1 day" +"$DATE_FORMAT" )
	[ -d $SITE_DIR/$YDAY/$1 ] && {
	    echo "Release dir already exists in $YDAY."
	    logexit $2/$1 "Dupe in $YDAY"
	}
}

# Deny NUKED releases
[ "$CHECK_NUKED" -eq "1" ] && {
	[ -d $2/NUKED-$1 ] && {
	    echo "This release was nuked before, dont try uploading it again."
	    logexit $2/$1 "NUKED"
	}
}

# Deny NUKED releases in yesterdays dir
[ "$CHECK_NUKED_YDAY" -eq "1" ] && {
	[ -d ../$YDAY/NUKED-$1 ] && {
	    echo "This release was nuked yesterday, dont try uploading it again."
	    logexit $2/$1 "NUKED in $YDAY"
	}
}

# Deny releases starting with '('
[ "$ALLOWPARENS" = "0" ] && {
	case $1 in
	    \(*)
		echo "Releases starting with '(' are not allowed"
		logexit $2/$1 "Parenthesis not allowed"
		;;
	    *)
		;;
	esac
}

# Make sure name is <= 64 chars
[ "$RIAA_NAMELENGTH" = "1" ] && {
	[ "${#1}" -gt "64" ] && {
		echo "This directory name doesn't follow RIAA conventions."
		echo "The name has ${#1} chars, but should be 64 or less."
		logexit $2/$1 "Name too long"
	}
}

# Check for RIAA naming compliance
[ "$RIAA_UNDERSCORES" = "1" ] && {
	echo $1 | grep -E "^[^_]+\.[^_]+\.[^_]+\.[^_]*$" | grep "[-]-" > /dev/null && {
		echo "This directory name doesn't follow RIAA conventions."
		echo "Underscores, not periods, must be used for spaces."
		logexit $2/$1 "Name not RIAA conformant"
	}
}

# Disallow banned groups.
[ "$CHECK_BANNED_GROUPS" -eq "1" ] && {
	[ -n "$2" ] && cd $2
	for grp in $BANNED; do
		echo $1 | grep -i "[-]${grp}$" > /dev/null && {
			echo "${grp} releases are not accepted here."
			logexit $2/$1 "Unallowed Group"
		}
	done
}

[ "$CHECK_BANNEDALSO" -eq "1" ] && {
	for x in $BANNEDALSO
	do
	        Match=$( echo $1 | grep -i "$x" )
		if $( test "$Match" = "$1" ); then
			echo "$x Releases Not Allowed"
			logexit $2/$1 "Unallowed Group"
        	fi
	done
}

# Check against dupelog
[ "$ANALDUPECHECK" = "1" ] && {
	# Don't check if it's a "CD1" or similar dir
	{ [ ${#1} -le 8 ] && echo $1 | grep -iE "^(cd[1-9]|dvd[1-9]|dis[ck][1-9]|sample)" > /dev/null; } || {
	if [ -f $DATAPATH/logs/dupelog ]; then
		grep -i " $1$" $DATAPATH/logs/dupelog > /dev/null && {
			echo "Dupe detected! SITE DUPE $1 returns:"
			grep -i " $1$" $DATAPATH/logs/dupelog | head -10
			logexit $2/$1 "Dupe"
		}
		else
		echo 'Could not locate dupelog for anal dupechecking!'
		echo "Verify your DATAPATH setting and try again."
	fi
	}                                                                                                                                                                                                                                   
} 

# Check that the rls has a required year in the name, unless
# it's an affil, in which case we forget about it.
[ -n "$ALLOWED_DYN_YEARS" ] && {
	unset ALLOWED_YEARS
	for i in $( seq ${ALLOWED_DYN_YEARS}); do
		ALLOWED_YEARS+="$( date --date "$i year" +%Y ) "
	done
}
[ -n "$ALLOWED_YEARS" ] && {
	yearok="0"; shortname="0"
	echo $1 | grep -Ei "[-]($( echo $AFFILS | sed 's/ /|/g' ))$" > /dev/null && 
		yearok=1
	[ ${#1} -le 8 ] || echo $1 | grep -iE "^(cd[1-9]|.*approved)" > /dev/null &&
		shortname="1"
	for year in $ALLOWED_YEARS; do
		echo $1 | grep -E "(${year}|[-\.]${year#??}\b|\b${year#??}[-\.]|\b${year#??}[0-9]{4}\b|\b[0-9]{4}${year#??}\b)" > /dev/null && 
			yearok="1"
	done
	[ "$yearok" = "0" -a "$shortname" = "0" ] && {
		echo "Unallowed year."
		logexit $2/$1 "Unallowed Year"
    }
}

{ [ "$LIVE_OK" -eq "1" ] || 
	echo $1 | grep -Ei "[-]($( echo $AFFILS | sed 's/ /|/g' ))$" > /dev/null; } || {
	echo $1 | grep -Ei "([(]live[)]|[-_.]live[_.](in|at|on)[^[:alpha:]]|[0-9][0-9][-_.][0-9][0-9][-_.][0-9][0-9])" > /dev/null && {
		echo "Live releases not allowed."
		logexit $2/$1 "Live"
	}
}	

[ "$DENY_PRETRADE" -eq "1" ] && {
	[ -n "$AFFILS_LATEPRE" ] && {	
		AFFILS="$AFFILS_LATEPRE"
	}
	echo $1 | grep -E "[-]($( echo $AFFILS | sed 's/ /|/g' ))$" > /dev/null && {
                echo "Do not trade affils."
                logexit $2/$1 "Affil"
	}
}

[ "$CHECK_DAYSBACK" -eq "1" ] && {
	ago=0
	[ "$shortname" = "0" ] && while [ $ago -le $DAYSBACK ]; do
		date=$( date --date "$ago days ago" +"$DATE_FORMAT" )
	        ls ../$date 2>/dev/null | grep -i "\b$1\b" > /dev/null 2>&1 && {
	                echo "\"$1\" already exists in the"
	                echo "directory dated $date. Looks like a dupe."
			logexit $2/$1 "In recent dated dir"
	        }
	        ago=$(($ago + 1))
	done
}

exit 0
