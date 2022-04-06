#!/bin/bash
##########################################################
# Script name: lnclean (link cleaner) v1.00
# Author: [Jedi] (jedi_il@hotmail.com)
# Description:
# This is a link cleaner for glftpd sites, on some zipscripts, links are being created to incomplete
# directories, where ppl and quickly enter and upload files, unfortunately, if zipscript not
# fully configured, or fucks up (rarely), it leavs broken links which cant be deleted from the
# ftp itself (as far as i know...) so this little proggie can be run from a site command in glftpd
# or from crontab (or both) to clean current directory, or the entire /site tree of broken links
# it wont del un-broken links so nothing to worry about :)
# Copyright: This program is under the The GNU General Public License (aka GNU GPL)
# URL: http://jedi.says.no/
#
# Installation notes:
# 1) put this file inside /glftpd/bin
#    $ cp lnclean.sh /glftpd/bin
# 2) make it executable
#    $ chmod +x /glftpd/bin/lnclean.sh
# 3) edit the /etc/glftpd.conf file
#    $ pico /etc/glftpd.conf
# 4) add this (1 means only siteop can execute it)
#    site_cmd LNCLEAN EXEC /bin/lnclean.sh
#    custom-lnclean 1
# 6) do `site lnclean` for usage inside glftpd (or look below)
# Enjoy :)
# Copyright: You may modify/change and enhance, but u may not claim this prog yours...
###########################################################

echo "lnClean v1.00 - a broken links cleaner script by [Jedi] jedi_il@hotmail.com"
echo "Usage: site lnclean [all]"
echo "'all' is optional, if added, scans all directories on site root for broken links."
echo "if omitted, scans current directory and cleans broken links."
echo ""

if [ $UID = 0 ] && ! [ "$1" = "crontab" ]; then
	echo "Please run this program from crontab only!";
	exit;
fi
if [ "$1" = "crontab" ]; then
	PF="/glftpd/site/incoming"
else
	PF="/site/incoming"
fi
if [ "$1" = "all" ] || [ "$1" = "crontab" ]; then
	DIRS=$(ls -o $PF | grep ^d | sed -e "s/ ->.*//g" | sed -e "s/.*[ ]//g")
	echo "Scanning all dirs..."
	echo "This may take a while, so please be patient"
else
	DIRS=$PWD
fi

cd $PF
for DIR in $DIRS; do
	LNA=0   # all
	LNB=0   # broken
	
	cd $DIR
	echo -n "Scanning $DIR... ";
	LINKS=$(ls -o | grep ^l | sed -e "s/ ->.*//g" | sed -e "s/.*[ ]//g")
	for LINK in $LINKS; do
		if [ ! -d $LINK ]; then
			LNB=$[$LNB+1];
			rm $LINK	# delete broken link
		else
			LNA=$[$LNA+1];
		fi
	done
	echo "Links: $[$LNA+$LNB] total, $LNA good, $LNB broken (removed)";
	cd ..
done
