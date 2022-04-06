#!/bin/sh
#<dntopfiles.sh> by dn (#glftpd@efnet)
#November 21st, 2001
#Please direct any questions, comments, idea or bugs to dn@blaze.ca

#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.

#DESCRIPTION
# - This script will scan your xferlog and report back the top downloaded
# - files.  You can select what type of files to report back on as well as
# - how many are listed in the list.

#CHANGELOG
#v1.00
# - Initial release
#v1.01
# - Increased the speed of the script dramatically.  I was originally
#   checking each file on the site against the xferlog.  When I should
#   of been only getting the information from the xferlog itself.
#v1.02 
# - Had a hardcoded /glftpd left in the script, I replaced this with
#   the variable.
# - Forgot to add uniq to the test for necessary bins and didn't
#   add it to the INSTRUCTIONS.
#v1.03
# - Seems I really broke the script, nothing was working, not sure
#   why I haven't heard more complains.  Its all fixed now.
# - I wasn't calling the binaries from /glftpd/bin, so if you didn't
#   actually have some of the binaries in your path, the script
#   may not find them.  All binaries are now called from /glftpd/bin
# - Change some tests around so they are more useful

#INSTRUCTIONS
# - make sure the following binaries are in your /glftpd/bin dir and
#   that they are chmod 755:
#   sh, rm, echo, sed, ls, grep, tr, cut, wc, printf, cat, sort, head
#   uniq, basename
# - setup the VARIABLES section below

#TO DO
# - make an option to output to either the screen, or a file, or both
# - maybe add an option to list the directory where the top files are
#   located
# - start using a database which will get updated after a file has
#   been downloaded, this will increase speed and funcionality.

#VARIABLES
#Site Name Short, usually the abbreviation of your Site Name
sns="SNS"

#Path to glftpd.  Must contain the starting /
gl="/glftpd"

#Path containing the dirs you wish to process, they are processed
#recursively.  Relative to /glftpd.  Should not contain the starting / or
#a trailing one.
#eg: site="site", or site="incoming/mp3"
site="site"

#Number of TopTen files to show
showtop="10"

#Path to a temporary dir and file.  Full pathname, not relative to /glftpd
#This file can be anywhere and will be removed once the script is finished.
tempfile="/glftpd/tmp/dntopten.tmp"

#Types of files you would like scanned, just use the files extension, see 
#below for an example of valid options
type="mp3 zip rar [r0-9][0-9][0-9]"

#DO NOT EDIT THE BELOW
#----------------------------------------------------------------------------#
ver="1.03"

#Verify paths are correct.
[ ! -d "$gl" ] && {
    $gl/bin/echo $gl does not exist
    exit 0
}

#Check for any missing binaries
BINS="sh rm echo sed ls grep tr cut wc printf cat sort head uniq basename"
missingbin=0
for bin in $BINS; do
    type $gl/bin/"$bin" > /dev/null 2>&1 || {
        $gl/bin/echo "Fatal: Could not find the required binary '$bin'"
        missingbin=1
    }
done
[ "$missingbin" = "1" ] && exit 0

[ -e "$tempfile" ] && $gl/bin/rm -f $tempfile
[ -e "$tempfile""1" ] && $gl/bin/rm -r $tempfile"1"

type=$($gl/bin/echo $type | $gl/bin/sed 's/ /$|/g')
type=$($gl/bin/echo $type"$")

$gl/bin/grep " o " $gl/ftp-data/logs/xferlog | tr -s ' ' | $gl/bin/cut -d ' ' -f9 | $gl/bin/grep -iE "$type" > $tempfile

for line in `$gl/bin/cat $tempfile | $gl/bin/sort | $gl/bin/uniq`; do
    file=$($gl/bin/basename "$line")
    times="$($gl/bin/grep "$file" $tempfile | $gl/bin/wc -l | $gl/bin/tr -d ' ')"
    [ $times -gt 0 ] && $gl/bin/echo $times":"$file >> $tempfile"1"
done

$gl/bin/echo ".-----------------------------------------------------------------------------."
$gl/bin/printf "%-22s %-48s %s\n" "| [$sns]" "TOP $showtop MOST DOWNLOADED FILES" "[$sns] |"
$gl/bin/echo "\`-----------------------------------------------------------------------------'"
$gl/bin/printf "%-5s %-63s %-5s\n"  "| #" "| Filename" "| D/L'd |"
$gl/bin/echo "\`-----------------------------------------------------------------------------'"
pos="1"

if [ -e "$tempfile""1" ]; then
    for topten in `$gl/bin/cat $tempfile"1" | $gl/bin/sort -gr | $gl/bin/head -"$showtop"`; do
        times="$($gl/bin/echo "$topten" | $gl/bin/cut -d ':' -f1)"
        filename="$($gl/bin/echo "$topten" | $gl/bin/cut -d ':' -f2)"
        $gl/bin/printf "%-5s %-63s %s %-5s %s\n" "| $pos" "| $filename" "|" "$times" "|"
        pos=$[++pos]
    done
else
    $gl/bin/echo "NO OUTGOING INFORMATION IN YOUR XFERLOG"
fi
$gl/bin/echo ".-----------------------------------------------------------------------------."
$gl/bin/echo "| TopFiles v"$ver" by dn (www.chimera-coding.com)                               |"
$gl/bin/echo "\`-----------------------------------------------------------------------------'"

[ -e "$tempfile" ] && $gl/bin/rm -f $tempfile
[ -e "$tempfile""1" ] && $gl/bin/rm -f $tempfile"1"

