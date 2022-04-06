#!/bin/bash
# Free Space Script Fo sites using RAID
#     v0.1
#
#
#   by: ip
#
#   contact: ipfreely@glftpd.com
#
#  REQUIRED BIANARIES: awk, test,du,bash
#
#
#  Recomended Crontab:
#  15,45 * * * * /glftpd/bin/ipfree.sh
#

######## CONFIGURATION ##################################
# Minimum HD space in Megabytes                         #
buffersize="3000"                                       #
device="/dev/md0"                                       #
# Site root (where sections are)                        #
mainmount="/glftpd/site"                                #
# Section Names (within site root)                      #
sections="ANIME DiVX ISO-GAMES ISO-UTiLS SVCD TV VCD"   #
#########################################################


freespace=`df -m $device|tail -1|awk '{print $4}'`

if [ $buffersize -gt $freespace ];then
seclargest=0
for x in $sections
do
secsize=`du -sm $mainmount/$x|awk '{print $1}'`
if [ $secsize -gt $seclargest ];then
 seclargest=$secsize
 seclarname=$x
fi
done

oldest=`ls -rt $mainmount/$seclarname|head -1`
rm -rf $mainmount/$seclarname/$oldest
fi
