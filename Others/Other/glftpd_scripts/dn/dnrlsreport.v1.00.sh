#!/bin/sh
#<dnrlsreport.sh> by dn (#glftpd@efnet) (www.chimera-coding.com)
#<April 16th, 2002>
#Please direct any questions, comments, idea or bugs to dn@blaze.ca

#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.

#DESCRIPTION
#This script will create reports of 0-Day release information.  It can be
#configured to place a file in the day dir that included release information
#such as number of releases, zips and size per group as well as the number
#of nukes that day.  It can also be configured to save the report into a stats
#dir so you can review stats over time.  This script would be best run from
#crontab.  You can also specify a date and it will process old dates for you,
#if not date is specified the previous date will be processed.

#CHANGELOG
# v1.00
# - Initial release

#INSTRUCTIONS
# - Make sure the following binaries are in your path: 
#   sh, date, tr, grep, wc, ls, echo, cut, du, dirname, rm 
# - Fill out the VARIABLES section below and ensure any directories
#   you specify are valid
# - Setup a crontab to run this script after the start of a newday to
#   have it process the previous day.  You don't need to specify a date.

#TO DO
# - Process and list the individual dirs, make it optional
# - Add the ability to scan ISO (non dated structure), maybe use glftpd.log??

#KNOWN BUGS
# - None

#VARIABLES
#Your Sitename
sitename="Chimera"

#Full path to glftpd.  No trailing /
glftpd="/glftpd"

#Full path to the directory containing your dated dirs.  Dated dirs must be in
#the format: #### (ie: 0101).  No trailing /
dated="/glftpd/site/Incoming/0Day"

#Space deliminated groups to process.  Case is insensitive.  Must match to 
#what the groups use as a tag.
groups="PARADOX CORE DAMN EAGLE MYTH LAXITY"

#Process all others?  If this is enabled, all releases by groups not
#including those listed above will be processed into a group called OTHER
# 0=No/1=Yes
procother="1"

#Temporary path and file.  NECESSARY.  File is removed after processing
temp="/glftpd/tmp/dndayreport.tmp"

#The file the report will be called in the dated directory being processed
output=".message"

#Stats dir.  If this is configured a report will also be saved to this dir
#in the format YYYY-MM-DD-Release_Report.txt.  Comment out or set to ""
#to not use a stats dir.
statsdir="/glftpd/Incoming/Stats"
#----------------------------------------------------------------------------#

#DO NOT EDIT THE BELOW
ver="1.00"

[ ! -d "$glftpd" ] && {
    echo "$glftpd does not exist, aborting"
    exit 1
}

[ ! -d "$dated" ] && {
    echo "$dated does not exist, aborting"
    exit 1
}

[ ! -d "$(dirname $temp)" ] && {
    echo "$temp does not exist, aborting"
    exit 1
}

[ ! -d "$statsdir" ] && {
    echo "$statsdir does not exist, aborting"
    exit 1
}

#Check for any missing binaries
BINS="sh date tr grep wc ls echo cut du dirname rm cat"
missingbin=0
for bin in $BINS; do
    type "$bin" > /dev/null 2>&1 || {
        echo "Fatal: Could not find the required binary '$bin'"
        missingbin=1
    }
done
[ "$missingbin" = "1" ] && exit 0

if [ -z "$1" ]; then
    yest="$(date --date '1 days ago' +%m%d)"
    datelog="$(date --date '1 days ago' "+%b %d")"
    datestat="$(date --date '1 days ago' +%Y-%m-%d)"
else
    month="$(echo $1 | cut -c1-2)"
    day="$(echo $1 | cut -c3-4)"
    year="$(echo $1 | cut -c5-)"
    [ $month -gt 12 -o $day -gt 31 -o ${#year} -gt 4 -o ${#year} -lt 4 ] && {
        echo "Invalid Date Format. Use mmddyyyy"
        exit 1
    }
    yest=$month$day
    datelog="$(date --date $year$month$day "+%b %d")"
    datestat="$(date --date $year$month$day +%Y-%m-%d)"
fi

[ ! -d $dated/$yest ] && {
    echo "ERROR:  $dated/$yest does not exist!"
    echo "        Nothing to process, aborting."
    exit 1
}

grouptag="$(echo $groups$ | sed 's/ /$|/g')"
[ $procother = 1 ] && groups="$groups OTHER"

ls $dated/$yest | tr -d '/' | grep -iE $grouptag > $temp.groups
ls $dated/$yest | tr -d '/' | grep -ivE $grouptag > $temp.other

echo "Statistics for $sitename on $datestat" > $dated/$yest/$output
echo "" >> $dated/$yest/$output

nukes="$(grep -E "$datelog.*NUKE:" $glftpd/ftp-data/logs/glftpd.log | grep -v UNNUKE: | wc -l | tr -d ' ')"
dayrls="$(ls -d $dated/$yest/* 2>/dev/null | wc -l | tr -d ' ')"
dayzips="$(ls $dated/$yest/* | grep -i "\.zip" | wc -l | tr -d ' ')"

daysize=0
for group in $groups; do
    num=0
    size=0
    zips=0
    if [ "$group" = "OTHER" ]; then
        forcmd="cat $temp.other"
    else
        forcmd="grep -iE $group$ $temp.groups"
    fi 
    for rls in `$forcmd`; do
    num=$[++num]
    rlssize="$(du -s -m $dated/$yest/$rls | cut -f1)"
    rlszips="$(ls $dated/$yest/$rls/*.[Zz][Ii][Pp] 2>/dev/null | wc -l | tr -d ' ')" 
    size=$[$size + $rlssize]
    zips=$[$zips + $rlszips]
    daysize=$[daysize + $rlssize]
    done
echo "$group - $num releases [$zips zips/$size"MB"]" >> $dated/$yest/$output
done
echo "-------------------------------------------" >> $dated/$yest/$output
echo "$nukes Nukes / $dayrls Releases [$dayzips zips / $daysize"MB"]" >> $dated/$yest/$output
echo "-------------------------------------------" >> $dated/$yest/$output
echo "report generated by dnrlsreport.v$ver" >> $dated/$yest/$output
echo "script created by dn / http://www.chimera-coding.com" >> $dated/$yest/$output

[ -n "$statsdir" ] && {
    cp $dated/$yest/$output $statsdir/$datestat-Release_Report.txt
}

rm $temp.groups
rm $temp.other

exit 0
