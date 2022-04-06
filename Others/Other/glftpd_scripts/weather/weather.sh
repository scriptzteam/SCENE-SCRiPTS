#!/bin/sh

METRIC=0  # 0 for F, 1 for C
# Fill in form to find your weather code here: 
# http://netweather.accuweather.com/signup-page2.asp
# If code has a space remove it or replace it with %20 or a dash; -
LOCCOD=""  #Example: NAM|MX|MX009|MEXICO-CITY

if [ -z $1 ] && [ -x $LOCCOD ] ; then
        echo
        echo "USAGE: $0 [locationcode]"
        echo
        exit 0;
elif [ ! -z $1 ] ; then
        LOCCOD=$1
fi

curl -s http://rss.accuweather.com/rss/liveweather_rss.asp\?metric\=${METRIC}\&locCode\=$LOCCOD \
| sed -n '/Currently:/ s/.*: \(.*\): \([0-9]*\)\([CF]\).*/\2°\3, \1/p'
