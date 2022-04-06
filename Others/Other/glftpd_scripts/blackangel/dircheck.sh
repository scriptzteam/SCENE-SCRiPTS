#!/bin/bash
#############
## ^ needs to point to your bash according to your glroot, usually it should be fine.
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
######################################################################################
##
## dircheck.sh v0.35b
## 
## okay couple of things...
## 1. if you have your glftpd.conf, in your /etc/glftpd.conf, you need to copy it to 
##    /glftpd/etc/glftpd.conf | this will work then with the variable below.
##
## 2. edit your new glftpd.conf (the one in glftpd/etc/glftpd.conf), find this variable and change it...
##    rootpath        /
##    this won't change your glftpd in any way, it'll just be a copy to work with this script.
##
## 3. Now edit your REAL glftpd.conf and find something similiar to pre_dir_check  
##    change to this 
##    pre_dir_check  /bin/dircheck.sh
##
## 4. now copy dircheck.sh to your glftpd/bin dir, and chmod +x dircheck.sh
##
## 5. Hopefully your all done...
##
##
## 
##############################################
##This is the variable that finds your glftpd.conf
##this is relative to your glftpd root dir, when you chroot.

confloc="/etc/glftpd.conf"

## New variable, this baby allows you to specify what things you want the 
## the dircheck to skip...  so if youw ant to skip sample just add it to the
## array below.. seperate items by spaces..  regexps are allowed the same as 
dirs=(^cd[0-9] ^cd_[0-9] ^cd-[0-9])

deny=(BLAH$ TEST$)

##################################
## No more editing :)
######################################

for denied in ${deny[*]}
do
        test=`echo "$1" | grep -i "$denied"`
        if [ "$test" ]
        then
                echo "$denied was matched in $1 - Banned group."
                exit 3
        fi
done

for dir in ${dirs[*]}
do
        list="$list | grep -iv \"$dir\""
done
escape=`echo "$1" | sed -e "s/(/\\(/g" -e "s/)/\\)/g"`
check=`eval "echo $escape $list"`
if [ "$check" ]
then
        var=`/bin/dirlogscanner -r$confloc -m1 -F"$1"`
fi
if [ "$var" ]
then
        user=`echo "$var" | cut -f1 -d" "`
        group=`echo "$var" | cut -f2 -d" "`
        day=`echo "$var" | cut -f4 -d"/"`
        echo "$user/$group already uploaded this in $day."
        exit 2;
fi
exit 0;

#####
#
# CHANGELOG
#
#
# 11/16/02 - Fixed more small errors...
#
# 10/14/02 - Fixed some small errors with brackets and such...
#
# 10/07/02 - Added another array used to ban dirs with certin text
#            i.e. dirs that end with -blah...etc
#
# 09/25/02 - Added an array to the list, fixed the dirlogscanner syntax
#            changed if statements around, added an eval to simplify the array
#
#
#
#
