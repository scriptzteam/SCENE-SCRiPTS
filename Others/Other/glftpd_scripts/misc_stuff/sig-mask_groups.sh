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
# for existing users, please run the script sig-mask_group_init.sh first! this
# will mask everyones GROUP without affecting any userfiles.
#
# place this file in /glftpd/bin, chmod it 755 and add the following to your glftpd.conf
#
# cscript SITE[:space:]adduser post /bin/sig-mask_groups.sh
# cscript SITE[:space:]gadduser post /bin/sig-mask_groups.sh
# cscript SITE[:space:]chgrp post /bin/sig-mask_groups.sh
#
# everyones group will be masked with group 0, aka group 'glftpd', but this
# will NOT affect any userfiles as they are untouched. the only file modified
# is the /glftpd/etc/passwd file with the masked group.
#
# make sure you have a /glftpd/tmp folder that is chmod 777
###############################################################################

#path to the user files
usersdir="/ftp-data/users"

#tmp dir
tmpdir="/tmp"

###############################################################################
# don't edit below here
###############################################################################
adduser () {
    newuser=`echo "$1" | awk '{print $3}'`
    #passwdfile
    grep -ve "^$newuser" /etc/passwd > $tmpdir/passwd.tmp
    grep -e "^$newuser" /etc/passwd | awk -F ":" '{print $1":"$2":"$3":0:"$5":"$6":"$7}' >> $tmpdir/passwd.tmp
    cp /etc/passwd /etc/passwd.bak
    mv $tmpdir/passwd.tmp /etc/passwd
    chmod 644 /etc/passwd*
    chown 0:0 /etc/passwd*
}

gadduser () {
    newuser=`echo "$1" | awk '{print $4}'`
    #passwdfile
    grep -ve "^$newuser" /etc/passwd > $tmpdir/passwd.tmp
    grep -e "^$newuser" /etc/passwd | awk -F ":" '{print $1":"$2":"$3":0:"$5":"$6":"$7}' >> $tmpdir/passwd.tmp
    cp /etc/passwd /etc/passwd.bak
    mv $tmpdir/passwd.tmp /etc/passwd
    chmod 644 /etc/passwd*
    chown 0:0 /etc/passwd*
}

chgrp () {
    newuser=`echo "$1" | awk '{print $3}'`
    #passwdfile
    grep -ve "^$newuser" /etc/passwd > $tmpdir/passwd.tmp
    grep -e "^$newuser" /etc/passwd | awk -F ":" '{print $1":"$2":"$3":0:"$5":"$6":"$7}' >> $tmpdir/passwd.tmp
    cp /etc/passwd /etc/passwd.bak
    mv $tmpdir/passwd.tmp /etc/passwd
    chmod 644 /etc/passwd*
    chown 0:0 /etc/passwd*
}

sitecmd=`echo "$1" | awk '{print $2}'`

if [[ $sitecmd == [Aa][Dd][Dd][Uu][Ss][Ee][Rr] ]];then
  adduser "$1" "$2" "$3"
elif [[ $sitecmd == [Gg][Aa][Dd][Dd][Uu][Ss][Ee][Rr] ]];then
  gadduser "$1" "$2" "$3"
elif [[ $sitecmd == [Cc][Hh][Gg][Rr][Pp] ]];then
  chgrp "$1" "$2" "$3"
else
  exit
fi
