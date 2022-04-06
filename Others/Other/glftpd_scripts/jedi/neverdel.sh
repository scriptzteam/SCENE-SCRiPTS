#!/bin/bash
##########################################################
# Script name: Neverdel ADD-ON for Autoclean
# Author: [Jedi] (jedi_il@hotmail.com)
# Description:
# This is a glftpd addon for the autoclean script, it allows u to mark a directory as
# "neverdel" aka, it wont be deleted even if old by the Autoclean prog.
# Copyright: This program is under the The GNU General Public License (aka GNU GPL)
# URL: http://jedi.says.no/
#
# Installation:
# 1) put this file inside /glftpd/bin
#    $ cp neverdel.sh /glftpd/bin
# 2) make it executable
#    $ chmod +x /glftpd/bin/neverdel.sh
# 3) edit the /etc/glftpd.conf file
#    $ pico /etc/glftpd.conf
# 4) add this:
#    site_cmd NEVERDEL EXEC /bin/neverdel.sh
#    custom-neverdel 1
# 5) set this to be the same path u set in autoclean.pl
NVFILE="/ftp-data/logs/nvdel.log"
# 6) do `site neverdel` for usage inside glftpd (or look below)
# Enjoy :)
### Done #########################################

P=$(echo $PWD | sed -e "s/\/site\///")

if [ "$1" = "+" ]; then
	echo "Adding $P to neverdel list..."
	echo $P >> $NVFILE
elif [ "$1" = "-" ]; then
	echo "Removing $P from neverdel list..."
	cat $NVFILE | grep -v $P > $NVFILE
	echo "Done"
elif [ "$1" = "?" ]; then
	echo "Searching for $P on neverdel list..."
	cat $NVFILE | grep $P
elif [ "$1" = "l" ]; then
	echo "Listing neverdel list..."
	echo "-------------------------------------------"
	cat $NVFILE
	echo "----------------------------------E-O-F----"
else
	echo Usage: site neverdel [+/-/?/l]
	echo + = adds to neverdel list
	echo - = removed from neverdel list
	echo ? = checks if its in neverdel list
	echo l = lists the neverdel list
	echo E.x: site neverdel +
	echo      will add $P to neverdel list
	echo Command works on current dir which u are in...
	echo Note: this command works only on sub level dir like /DIVX/Dont.del.this.rls-GRP
fi

