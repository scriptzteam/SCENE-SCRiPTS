#!/bin/sh
#<dnaccstats.sh> by dn (#glftpd@efnet) (www.chimera-coding.com)
#November 23rd, 2001
#Please direct any questions, comments, idea or bugs to dn@blaze.ca

#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.

#DESCRIPTION
#When you delete a user from your site, all of his traffic information
#is deleted as it is contained in his userfile.  All Site stats and
#traffic are derived from current userfiles.  This script is run as a 
#cscript are 'site purge' and will add any traffic information from a user 
#you delete to a dummy user that you create.  Then when you purge that user
#you will not lose his traffic information and your stats/traffic will 
#remain accurate for the life of your site.

#CHANGELOG
# v1.00
# - Initial release

#INSTRUCTIONS
# - cp dnaccstat.v#.##.sh to your glftp bin directory and rename it to 
#   dnaccstat.sh
# - Make sure the following binaries are in your /glftpd/bin dir and that
#   they are chmod 755:
#   sh, echo, ls, cat, grep, cut, sed, tr, mv
# - Fill out the VARIABLES section below
# - Create the dummy user.  (Eg: site adduser glStats <somepass>).  I would
#   not add an ips as you will never need to connect with this user.
# - chmod 666 the dummy user you created above.
# - chmod 777 your /ftp-data/users directory.  This is a slight security
#   risk.  If you run your glftpd from a jail environment it is much less
#   of a risk.  Check the glftpd.faq for information on jailing your glftpd.
# - Add the following line to your glftpd.conf:
#   cscript site[:space:]purge pre /bin/dnaccstat.sh

#TO DO
# - Nothing 

#KNOWN BUGS
# - None

#VARIABLES
dummy="glStats"

#----------------------------------------------------------------------------#

#DO NOT EDIT THE BELOW
ver="1.00"

umask 000
glusers="/ftp-data/users"

STATS[0]="ALLUP";STATS[1]="ALLDN";STATS[2]="WKUP";STATS[3]="WKDN";STATS[4]="DAYUP"
STATS[5]="DAYDN";STATS[6]="MONTHUP";STATS[7]="MONTHDN";STATS[8]="NUKE"

echo -e "200dn's Accurate Stats v"$ver" for glftpd\r"
echo -en "200Updating glStats..."
    for user in `ls $glusers`; do
        [ -n "$(cat $glusers/$user | grep -E "^FLAGS.*6")" ] && {
            #echo user=$user
            i="0" 
            while [ -n "${STATS[$i]}" ]; do
                a="2"
                newline="${STATS[$i]} "
                while [ -n "$(grep -E "^${STATS[$i]}" $glusers/$user | cut -d ' ' -f"$a")" ]; do
                    userstat="$(grep -E "^${STATS[$i]}" $glusers/$user | cut -d ' ' -f"$a")"            
                    oldstat="$(grep -E "^${STATS[$i]}" $glusers/$users/$dummy | cut -d ' ' -f "$a")"
                    [ "$oldstat" = "" ] && oldstat="0"    
                    newstat=$[$userstat + $oldstat]
                    newline="$newline $newstat"
                    a=$[++a] 
                done
                finalstats="$finalstats$newline":""
                i=$[++i]
            done
        }
        [ -n "$finalstats" ] && {
            oldtime="$(grep -E "^TIME " $glusers/$dummy)"
            oldslots="$(grep -E "^SLOTS " $glusers/$dummy)"
            grep -vE "^ALLUP|^ALLDN|^WKUP|^WKDN|^DAYUP|^DAYDN|^MONTHUP|^MONTHDN|^NUKE|^TIME |^SLOTS" $glusers/$dummy >> $glusers/$dummy"1"
            echo $finalstats | sed 's/:$//g' | tr ":" "\n" >> $glusers/$dummy"1"
            echo $oldtime >> $glusers/$dummy"1"
            echo $oldslots >> $glusers/$dummy"1"
            mv $glusers/$dummy"1" $glusers/$dummy
            finalstats=""
       }
    done
    echo -e "DONE\r"
exit 0
