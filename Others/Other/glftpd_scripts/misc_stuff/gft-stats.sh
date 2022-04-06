#!/bin/bash

period=$1  	#day/week/month/all
direction=$2 	#up/down
#who=$3		#user/group
#numresults=$4	#how many results.
#maxresults=15
#if [ $numresults -gt $maxresults ]; then
#    echo "Faggot"
#    exit 0
#fi

exclgroups=`ls -1 /jail/glftpd/site/groups/`

for group in $exclgroups; do
    exclusers=$exclusers`grep siteops ../ftp-data/users/* | cut -d ':' -f1 | cut -d '/' -f4`
    groupcmd="$groupcmd -g $group"
done

i=0
for username in $exclusers; do
    usercmd="$usercmd -e $username"
    let i=$i+1
done

if [ $direction != "-u" ]; then
    if [ $direction != "-d" ];then
        echo "Wrong direction($direction) specified, use either -u for up or -d for down."
	exit 1
    fi
fi
header="    旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
   � ## user         tagline                  files  megabytes   avg k/s  �
    읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
    旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커"
if [[ $period = "-m" || $period = "-M" ]]; then
    #month
    echo "$header"
    stats=`/jail/glftpd/bin/stats $direction $period -r /jail/glftpd/glftpd.conf $groupcmd $usercmd | tail -n10`
else if [[ $period = "-w" || $period = "-W" ]]; then
    #week
    stats=`/jail/glftpd/bin/stats $direction $period -r /jail/glftpd/glftpd.conf $groupcmd $usercmd | tail -n10`
else if [[ $period = "-d" || $period = "-D" ]]; then
    #day
    stats=`/jail/glftpd/bin/stats $direction $period -r /jail/glftpd/glftpd.conf $groupcmd $usercmd | tail -n10`
else
    echo "ERROR: Unspecified period, exiting..."
    exit 1
fi
fi
fi
