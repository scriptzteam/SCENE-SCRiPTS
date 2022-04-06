#!/bin/bash
# -----------------------------------------------------------------------------
# slkdenyentry.sh v1.0 (17/03/2004)                                   by slaque
# -----------------------------------------------------------------------------
# 
# About:
# -----
# This tiny  script will  deny entry for certain users without having to change
# anything in their userfile (ie you dont have to site deluser). It also allows
# custom message to prompt the user after  denying access. It is just a cscript 
# and of course, runs chrooted in your glftpd dir.
# 
# Requirements:
# ------------
# bash, echo, cut in your glftpd/bin 
#
# Installation:
# ------------
# 1. edit MSG and BANUSERS below in the #---CONFIG-START-- section
# 2. put this script in your glftpd/bin
# 3. add this in your glftpd.conf:
# cscript	USER	pre	/bin/slkdenyentry.sh
#
# TODO:
# ----
# 1. Add site cmd to allow adding banned users from site command.
# 2. Add support for whole groups.
#
# Credits:
# -------
# - #glhelp & #glftpd @ efnet.
# - You
#


#---CONFIG-START---

#reply messages
#if you want more you can add MSG[4] MSG[5] etc..
MSG[0]="User $(echo ${1}|cut -f2 -d' '): access denied."
MSG[1]="You do not have access in here."
MSG[2]="You are banned for hammering or abusing the server. Contact a siteop."
MSG[3]="You are banned for some reason. bye bye."

#Users to ban syntax: user:<MSG number> user2:<MSG number>  
#           where number an element of the above MSG array(notice:starts from 0)
#           for none: BANUSERS=()
BANUSERS=(userA:0 userB:1 userC:2 userD:3)


#---CONFIG-END---


for ((i=0;i<${#BANUSERS[*]};i++));do
if [ "${1}" == "USER $(echo ${BANUSERS[i]}|cut -f1 -d':')" ];then
echo "530 ${MSG[$(echo ${BANUSERS[i]}|cut -f2 -d':')]}"
exit 1
fi
done

#EOF
