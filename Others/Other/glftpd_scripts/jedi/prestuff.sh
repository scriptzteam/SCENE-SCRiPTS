#!/bin/bash
#
# PRE STUFF v1.00  --  Copyright 2002 [Jedi]
#
# + Wtf is PRE STUFF (0_o) ?
#    some stuff to do for after pre is executed :}
#    1) copies site nfo to predir, like zipscript does for complete rlses
#    to do it, set NFOSRC to some file that exists, to disable NFOSRC=""
#    2) makes symlink to last created rls !
#    set PRETAG to something, to disable PRETAG=""
#    set LNROOT to where the symlink LATEST_PRE_* will be.
#    set USERHOME your users root dir, most likely, you'll want to set
#    this settings to the same dir you set LNROOT...
#    (no trailing slash for all).
# + Requierments: awk tail grep dirname rm ln
# + Installation:
#    check that you have the requiered binaries in your /glftpd/bin
#    if you dont locate them and copy them.
#    we would run this as a custom script (cscript) on glftpd.conf.
#    you need to add the next line to your glftpd.conf:
#        cscript site[:space:]pre post /bin/prestuff.sh
#    and you'r good to go.
# + Note: I'm assuming that glftpd.log is getting logged in the following format:
#   (date) PRE: "predir" ...
#   the date is global for all glftpd.log logging, PRE: should be also very much used
#   just make sure that the predir comes right after it, it doesnt matter what comes
#   after predir at all, but its very important that the predir is the 3rd arg...
##

NFOSRC=/ftp-data/misc/site.nfo

PRETAG="LATEST_PRE_"
LNROOT=/site/incoming
USERHOME=/site/incoming

##                                                    End of config...
#########################################################################

GLFTPDLOG=/ftp-data/logs/glftpd.log

# take two last lines in case something happened in between site pre and
# running this script, check for pre, the last pre will be taken.

PREDIR=`tail -n2 $GLFTPDLOG | grep PRE: | tail -n1 | awk '{print substr($7,2,length($7)-2)}'`

if [ "$PREDIR" = "" ]; then 
	exit;
fi


if [ -f "$NFOSRC" ]; then
	cp -f $NFOSRC $PREDIR
fi


if [ "$PRETAG" != "" ]; then
	PRELOC=`echo $PREDIR $USERHOME | awk '{print substr($1,length($2)+2)}'`
	momdir=`dirname $PREDIR`
	RLSNAME=`echo $PREDIR $momdir | awk '{print substr($1,length($2)+2)}'`
	cd $USERHOME;
	# delete the last pre symlink...
	rm -f $LNROOT/$PRETAG*
	# create the new symlink
	ln -s $PRELOC $LNROOT/$PRETAG$RLSNAME
fi
	
