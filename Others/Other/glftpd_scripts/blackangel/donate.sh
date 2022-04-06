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
## Donations welcome... or text on titties pics!
##
##################
######################################################################################
##
## donate.sh v0.1b
## 
## A little info it will subtract an amount of credits (K) from the user
## and give it to another user specified if that user exists.
##
## USAGE: site donate <user> <credits in KB> 
##
## okay couple of things...
## 1. copy cut,cat,date,echo,grep,sed to your glftpd/bin dir
##
## 2. chmod 777 ftp-data
##    chmod 777 ftp-data/users
##    chmod 777 ftp-data/msgs
##    cd ftp-data/users and chmod 666 *
##    it would be a good idea to make sure everyone is logged out so you can chmod their files.
##
## 2.5. take picture of sister/girlfriend/milf with text on titties and send it to appropriate email :P
##
## 3. add these to your glftpd.conf
##    site_cmd        DONATE  EXEC    /bin/donate.sh
##    custom-donate   *
##
## 4. now copy donate.sh to your glftpd/bin dir, and chmod +x donate.sh
##
## 5. Edit the variables below to point to your user dir and msg dir,
##    these defaults should be okay 99% of the time unless you changed the shit
##    but if your capable of doing that then you don't really need to be reading these
##    instructions and probably know how to set this shit up... anyways...
##
## 6. Hopefully that's it...
##
## 
## NOTE: if it you didn't setup the script to work properly it might leave a file called "TMP354"
##	 in your user dir.. most likely this will be deleted when you fix the mistake you made 
##       and run the script again
##       
##       
##
##############################################
##This is the variable that finds your users dir and msgs dir
##this is relative to your glftpd root dir, when you chroot.

dir="/ftp-data/users"

dir2="/ftp-data/msgs"

##################################
## No more editing :)
######################################

date=`date`
donater=`echo $USER`
donatee=$1
donateamount=$2

if [ -n "$1" -a -n "`echo $2 | grep '^[-0-9][0-9]\{1,\}$'`" ]
then
	if [ -r $dir/$1 ]
	then
	  	if [ $2 -gt 0 ]
	  	then
		  donatercreds=`cat $dir/$donater | grep CREDITS | cut -d" " -f2`
		  if [ $donateamount -le $donatercreds ]
		  then
			 donateecreds=`cat $dir/$donatee | grep CREDITS | cut -d" " -f2`
			 newdonatecreds=$(($donateecreds + $donateamount))
			 newdonatercreds=$(($donatercreds - $donateamount))

			 sed -e "/CREDITS/ s/$donatercreds/$newdonatercreds/" < $dir/$donater > $dir/TMP354 && mv $dir/TMP354 $dir/$donater
			 sed -e "/CREDITS/ s/$donateecreds/$newdonatecreds/" < $dir/$donatee > $dir/TMP354 && mv $dir/TMP354 $dir/$donatee

			 echo " " >> $dir2/$donatee
			 echo From: $donater \($date\)!0 >> $dir2/$donatee
			 echo -------------------------------------------------------------------------- >> $dir2/$donatee
			 echo $donater has donated $donateamountK of credits to you.!0 >> $dir2/$donatee

  	    	 	 echo Donated ${donateamount}K to $donatee\'s stash successfully, a msg has been sent.
		  else
			echo "Sorry, not enough credits to donate."
			exit 4
		  fi
	  	else
		  echo "Sorry, $2 is not a valid number."
		  exit 3
		fi
	else
  	  echo "Sorry, $1 is not a valid user."
	  exit 2
	fi
else
  echo "USAGE: site donate <user> <credits in KB>"
  exit 1
fi
