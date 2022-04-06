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
# this script outputs EOM stats to a txt file.
# use sig-eom.sh to run this script at the end of each month.
###############################################################################

# site name.
sitename="site"
# users to ignore? '-e <user>' for each user to ignore.
bncacc="-e bncer -e glftpd -e siteop"
# number to list.
numtolist="100"
# glftpd path.
glftpd='/glftpd'
# glftpd config file.
glftpd_conf='/glftpd/etc/glftpd.conf'
# where to output the stats.txt file, make sure this directory exists!
stats='/glftpd/site/PRIVATE/SITEOP/STATS'

###############################################################################
# don't edit below here!
###############################################################################

month=`date +%B`
year=`date +%Y`

cd $glftpd/bin
echo "$sitename stats for $month $year ->" > $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf $bncacc -m -u -x $numtolist >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf $bncacc -m -d -x $numtolist >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf $bncacc -M -u -x $numtolist >> $stats/$year-$month\_Month_Stats.txt
echo >> $stats/$year-$month\_Month_Stats.txt
/glftpd/bin/stats -r $glftpd_conf $bncacc -M -d -x $numtolist >> $stats/$year-$month\_Month_Stats.txt