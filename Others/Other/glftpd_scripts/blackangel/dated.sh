#!/usr/local/bin/bash
#######################
## ^^^ Location of your bash, "which bash" gets you this..
#########################
##############################################################
## DISCLAIMER
## this code has no warranty whatsoever, use it at your own risk
## if you need help i drop by #glftpd sometimes...
## or you can email me at blackangel@thugdictionary.com and i'll see what i can do.
##
##
#####################################
##
## Donations welcome...
##
##################
##############################################################
##
## dated.sh for fbsd :)
##
## This is a modified version of the dated.sh that comes with
## glftpd this one works on freebsd, might be gay but someone could use it...
##
##
## 1. add soemthing like the following to your crontab
##    59 23 * * *     /usr/glftpd/bin/dated.sh
##
## 2. change your glftpdsitedir, to where your site is located...
##
## 3. copy this file to your glftpd/bin and chmod +x it
##
## 4. test it out... :)
##############################################################
####
## This is the variable for your glftpdsite dir
## the code below is pretty straight forward.
glftpdsitedir="/usr/glftpd/site"

##################################
## No more editing :)
######################################

today=`date -v+1d +%m%d`
yesterday=`date +%m%d`
mkdir /usr/glftpd/site/incoming/$today
chmod 777 /usr/glftpd/site/incoming/$today
cd $glftpdsitedir
rm Today
rm Yesterday
ln -s ./incoming/$today Today
ln -s ./incoming/$yesterday Yesterday