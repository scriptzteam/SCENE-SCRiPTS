#!/bin/sh
#	iP Keygen Only Archive    (v0.2)
#
#		This script copies keygen.only releases to an archive dir.
#
#	Author: ip
#
#	Disclamer: This code carries no warranty ..use at own risk...blah
#
#	Best run from your freespace script. 
#
#	Ex.: ./keygen.Archive.sh /glftpd/site/0107
#
#  $1 = Path of Dated Dir to Archive
#
######## CONFIG ######
archivedir="/iP/site/archive/keygen"	#Where you Want Them Sent
####### END CONFIG

list=`ls $1`
for x in $list
do
	if `test `echo $x|grep -i "keygen"` = true >> /dev/null`;then
		if `test `echo $x|grep -i "only"` = true >> /dev/null`;then
			mv $1/$x $archivedir >> /dev/null 2>&1
			echo "$0 - Moving $x"
		fi
	fi
	if `test `echo $x|grep -i "keymaker"` = true >> /dev/null`;then
                if `test `echo $x|grep -i "only"` = true `;then
                        mv $1/$x $archivedir >> /dev/null 2>&1
			echo "$0 - Moving $x"
                fi
        fi
done
exit 0;
