#!/bin/bash - 
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
# place this script in your /glftpd/etc folder and run it.
# this will retouch the passwd file to mask all users groups to 'glftpd'
#
# you only need to run this script once!
###############################################################################
# don't edit below here
###############################################################################

touch passwd.ren
echo "backing up passwd file"
cp passwd passwd.backup
echo "masking existing users group"

cat passwd | while read line; do
	awk -F ":" '{print $1":"$2":"$3":0:"$5":"$6":"$7}' >> passwd.ren
done

rm -f passwd
mv passwd.ren passwd
echo "masking complete!"