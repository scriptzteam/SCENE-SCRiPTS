#!/bin/bash 
#
# 
#
# questions ? cpc @ efnet / big thx to theout for helping on some stuff

# This script is basicly to deny peaople to trade a release which isnt 15 minutes old on the site

# Allow specific files to be downloaded always? (p.s. leave at least 1 filetype)
# Add multiple extentions splited by a | (i.e. ".nfo|.mpg|.avi"
allowedfiles=".nfo"

#user with which flags are effected ?
# Add multiple flags splited by a |
flags="9"

USERNAME=$2



if [ "`grep "^FLAGS" /ftp-data/users/$USERNAME|grep -iE "$flags"|tr -d '|'`" != "" ];then
if [ "`echo $1|grep -iE "$allowedfiles"|tr -d '|'`" != "" ];then exit 0;fi

# Delay time in mins (before user is allowed to leech it)
DELAY=1500

# Msg 
emsg="Please try again later Mr Leecher!"



########## Dont Edit below here   
set -- `ls -l $1`;
case $6 in
Jan) FILEMONTH=01;;
Feb) FILEMONTH=02;;
Mar) FILEMONTH=03;;
Apr) FILEMONTH=04;;
May) FILEMONTH=05;;
Jun) FILEMONTH=06;;
Jul) FILEMONTH=07;;
Aug) FILEMONTH=08;;
Sep) FILEMONTH=09;;
Okt) FILEMONTH=10;;
Nov) FILEMONTH=11;;
Dez) FILEMONTH=12;;
esac

CURMONTH=`date --date 'today' '+%m'`
CURDAY=`date --date 'today' '+%d'`
CURHOUR=`date --date 'today' '+%H'`
CURMIN=`date --date 'today' '+%M'`


CMIN=$(( $CURHOUR * 60 ))
CMIN=$(( $CMIN + $CURMIN ))

CUT=$8
TEMP=${CUT:0:1}
if [ $TEMP != "0" ]
then
FILEHOUR=${CUT:0:2}
else
FILEHOUR=${CUT:1:1}
fi
FILEMIN=${CUT:3:2}
if [ "$FILEMONTH" -lt "$CURMONTH" ]
then 
exit 0
fi


if [ "$7" -lt "$CURDAY" ]
then
exit 0
fi


FILETIME=$(( $FILEHOUR * 60 ))
FILETIME=$(( $FILETIME + $FILEMIN)) 
FILETIME=$(( $FILETIME + $DELAY)) 


if [ $FILETIME -lt $CMIN ]
then 
exit 0
else
echo -e "500- $emsg\r"
exit 1
fi


else
exit 0
fi
