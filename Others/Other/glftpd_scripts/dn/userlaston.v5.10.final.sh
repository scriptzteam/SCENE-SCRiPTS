#!/bin/bash -
#<userlaston.sh> by dn (with ju7's help) 
#February 5th, 2001
#Please direct any questions, comments, idea or bugs  to dn@blaze.ca

#DISCLAIMER
# - I TAKE NO RESPONSIBILTY IN WHAT THIS SCRIPT MAY OR MAY NOT DO TO YOUR
# - SYSTEM.  USE IT AT YOUR OWN RISK.

#DESCRIPTION
#This little script will scan your user database and report back any users
#who have not logged on for a specified number of days or users who have
#logged on today or never.  You may also exempt users and/or groups.
#After any scan you have the ability to purge some or all of the users.

#CHANGELOG
#v5.10
# - I forgot to add the instructions needed for the purge features to work.
#v5.00
# - Updated the help menu to make it more user friendly and easier to
#   understand
# - Updated the INSTRUCTIONS to mention how to bring up the HELP MENU's
#v4.50
# - Added a new option which will allow you to purge users based on your
#   last scan.  This requires a tmp dir to be created.  See instructions
#   below
#v4.40
# - Any value other than what should be excepted will now report back an
#   invalid option
# - The user will now be tagged with a number, this will be used in future
#   options
# - Updated the THANK YOU area
#v4.30
# - Changed the user definable variables and how they must be entered by the
#   user.  Please see below for the new format
# - Optimized more of the code to speed up the script with all the added 
#   features.  Again thanks to ju7 for helping
#v4.20
# - The total number of users will now be reported after each scan
# - Fixed some more spelling mistakes (sigh)
# - Made the user definable variables more consistent with the output
#v4.10
# - Added the ability to also ignore groups.
#v4.00
# - Changed more of the code to make it significantly faster.  Thanks to ju7
#   for the help
# - The user's group will now be listed as well
#v3.00
# - When a user has logged on today, it will say that, instead of reporting
#   back 0 as the number of days ago
# - Added a -1 option to show all users who have logged on today, use site
#   last -1
# - Added a KNOWN PROBLEMS section
# - Added a DISCLAIMER section :)
# - Cleaned up the layout, makde some cosmetic changes to the script
#v2.00
# - Added a CHANGELOG section 
# - When a user has never logged on, it will say that, instead of reporting
#   back a number over 10000
# - Added an option to list all users, use site last 0
# - Mentioned using site last 10000 to list all users who have never logged on
# - Fixed a couple of spelling errors
#v1.00 
# - Initial release

#KNOWN PROBLEMS
# - The EXCEPT_* variables could cause problems, if you enter "dn", and you
#   have a user that contains those letters in that order, they will be exempt
#   as well
# - A user in two groups will show up twice, unless one of the groups is on the
#   exempt list then the user will only show up once
# - If you enter +1 or 1_ or some other fucked up option, the script will fuckup,
#   just learn to read, as those aren't valid options! :)

#THANK YOU's
# - bsugar for original idea and beta testing
# - ju7 for his guidance and training in helping make the script run faster
# - de5ign for some code help

#INSTRUCTIONS
# - Make sure the following bins are in your /glftpd/bin dir and that they are
#   chmod 755
#   echo tr grep date cat
# - You will also need to add the following lines to your glftpd.conf
#   site_cmd last           EXEC    /bin/userlaston.sh
#   custom-last =STAFF
# - Please create the tmp dir and make sure it matches the TEMPPATH variable
#   below and that it is chmod 777.  This dir can be anywhere inside the
#   glftpd rootpath.
# - In order to use the purge features all your users in the user directory 
#   must be chmod 666, take note this is a security risk.  In order to keep 
#   all the users chmod 666 you can add the following to your crontab:
#   0,30 * * * * /path/to/chmod 666 /path/to/glftpd/ftp-data/users/*
#   You will get an error if a specific user does not have this chmod.
# - Use 'site last' on its own for the HELP MENU

#----------------------------------------------------------------------------#

#VARIABLES
#The path to your glftpd users directory, relative to /glftpd
USERPATH="/ftp-data/users"

#The temp path needed to execute the purge options.  The dir can exist
#anywhere inside the glftpd rootpath.  I suggest /glftpd/tmp.  This dir must
#be chmod 777
TEMPPATH="/tmp" #The temp dir, must reside with the glftpd rootpath

#Enter any user(s) you want to exempt. All users must be separated by a |. 
#There is no need for a | if you enter only one user.  Use "" for none.
#User names are case sensitive.
EXEMPT_names="dn|SiteBot|AutoNuke|default"

#Enter any group(s) you want to exempt. All groups must be separated by a |.
#There is no need for a | if you enter only one user.  Use "" for none.
#Group names are case senstive.
EXEMPT_groups=""

#----------------------------------------------------------------------------#

#DO NOT EDIT THE BELOW
VER="v5.10"
if [ -z $1 ]; then 
	echo -e " .------------------------"
	echo -e "| UserLastOn $VER by dn"
	echo -e " \`------------------------"
	echo -e "|        HELP MENU"
	echo -e " \`------------------------"
	echo "You must use one of the following options:"
	echo "Use 1 through 365 to list all users who have not logged on since then"
	echo "Use 0 to list all users and the number of days since they last logged on"
	echo "Use -1 to list all users who logged on today"
	echo "Use 10000 to list all users who have never logged on"
	echo "Use "purge" for the PURGE HELP MENU"
	echo "NOTE: "purge" is only a valid option after a scan"
	echo "NOTE: Exempt users and groups will be ignored in all searches"
	exit 0

else 

if [ $1 != "purge" ]; then
		if [ ! -z "`echo $1 | grep [a-zA-Z]`" ]; then
		echo -e "Invalid option ..."
		echo -e " .------------------------"   
        	echo -e "| UserLastOn $VER by dn"
        	echo -e " \`------------------------"
		echo -e "|        HELP MENU"        
	        echo -e " \`------------------------" 
		echo "You must use one of the following options:"
	        echo "Use 1 through 365 to list all users who have not logged on since then"
	        echo "Use 0 to list all users and the number of days since they last logged on"
	        echo "Use -1 to list all users who logged on today"
        	echo "Use 10000 to list all users who have never logged on"
	        echo "Use "purge" for the PURGE HELP MENU"
	        echo "NOTE: "purge" is only a valid option after a scan"   
        	echo "NOTE: Exempt users and groups will be ignored in all searches"
		exit 0
	else
	if [ $1 -lt -1 ] || [ $1 -gt 10000 ] ; then
		echo -e "Invalid option ..."
                echo -e " .------------------------"
                echo -e "| UserLastOn $VER by dn"
                echo -e " \`------------------------"
		echo -e "|        HELP MENU"        
        	echo -e " \`------------------------" 
		echo "You must use one of the following options:"
	        echo "Use 1 through 365 to list all users who have not logged on since then"
        	echo "Use 0 to list all users and the number of days since they last logged on"
	        echo "Use -1 to list all users who logged on today"
	        echo "Use 10000 to list all users who have never logged on"
	        echo "Use "purge" for the PURGE HELP MENU"
        	echo "NOTE: "purge" is only a valid option after a scan"   
	        echo "NOTE: Exempt users and groups will be ignored in all searches"
                exit 0
	        fi
	fi

	echo -e " .------------------------" 
        echo -e "| UserLastOn $VER by dn"
        echo -e " \`------------------------"  
	echo "Scanning users, please be patient this may take a few seconds..." 
	echo ""
	
	if [ -a $TEMPPATH/$USER.ulo ]; then
	  rm $TEMPPATH/$USER.ulo
	fi

	ALL_USERS=`(cd $USERPATH && grep -w ^GROUP * | sed "s/GROUP //")`


	if [ -z "$EXEMPT_groups" ] && [ -z "$EXEMPT_names" ]; then
	  USERS_TO_CHECK=`echo $ALL_USERS | tr ' ' '\n'`
	else
	  if [ ! -z "$EXEMPT_groups" ] && [ -z "$EXEMPT_names" ]; then
	    USERS_TO_CHECK=`echo $ALL_USERS | tr ' ' '\n' | grep -Ewv "$EXEMPT_groups"`
	  else
	    if [ -z "$EXEMPT_groups" ] && [ ! -z "$EXEMPT_names" ]; then
	      USERS_TO_CHECK=`echo $ALL_USERS | tr ' ' '\n' | grep -Ewv "$EXEMPT_names"`
	    else
	      if [ ! -z "$EXEMPT_groups" ] && [ ! -z "$EXEMPT_names" ]; then
	        ALL_USERS=`echo $ALL_USERS | tr ' ' '\n' | grep -Ewv "$EXEMPT_groups"`
		USERS_TO_CHECK=`echo $ALL_USERS | tr ' ' '\n' | grep -Ewv "$EXEMPT_names"`
	      fi
  	    fi
	  fi
	fi	

	CURTIME=`date +%s`
	NUMDAYS="$1"
	
	TU="0"

	for user in `echo $USERS_TO_CHECK | tr ' ' '\n' | cut -d":" -f1`; do
		USERTIME=`grep -w ^TIME $USERPATH/$user | cut -d" " -f3`
		DAYS=`echo $[($CURTIME - $USERTIME) / 86400]`
		GROUP=`grep -w ^GROUP $USERPATH/$user | cut -d" " -f2 | head -1`
		CREDZk=`grep -w ^CREDITS $USERPATH/$user | cut -d " " -f2`
	        CREDZ=`echo $[$CREDZk / 1024]`
			if [ $NUMDAYS -eq "-1" ]; then
				if [ $DAYS -eq "0" ]; then
				TU=$[TU + 1]
				echo $TU":"$user"|" >> $TEMPPATH/$USER.ulo
				echo "$TU.) $user ($GROUP) logged on today (Credits = $CREDZ"MB")"
				fi
			else
				if [ $NUMDAYS -eq "0" ]; then
					if [ $DAYS -gt "10000" ]; then 
					TU=$[TU + 1]
					echo $TU":"$user"|" >> $TEMPPATH/$USER.ulo
	                               	echo "$TU.) $user ($GROUP) has never logged on (Credits = $CREDZ"MB")"
					else
						if [ $DAYS -eq "0" ]; then
						TU=$[TU + 1]
						echo $TU":"$user"|" >> $TEMPPATH/$USER.ulo
						echo "$TU.) $user ($GROUP) logged on today (Credits = $CREDZ"MB")"
						else
						TU=$[TU + 1]
						echo $TU":"$user"|" >> $TEMPPATH/$USER.ulo
                                		echo "$TU.) $user ($GROUP) last logged on $DAYS days ago (Credits = $CREDZ"MB")"
						fi
                                	fi
				else
					if [ $DAYS -gt $NUMDAYS ]; then
						if [ $DAYS -gt "10000" ]; then
						TU=$[TU + 1]
						echo $TU":"$user"|" >> $TEMPPATH/$USER.ulo
						echo "$TU.) $user ($GROUP) has never logged on (Credits = $CREDZ"MB")"
						else
						TU=$[TU + 1]
						echo $TU":"$user"|" >> $TEMPPATH/$USER.ulo
						echo "$TU.) $user ($GROUP) last logged on $DAYS days ago (Credits = $CREDZ"MB")"
						fi
					fi
				fi
			fi
	done


else
if [ -z $2 ]; then
	echo -e " .------------------------"
        echo -e "| UserLastOn $VER by dn"
        echo -e " \`------------------------"
	echo -e "|     PURGE HELP MENU"
        echo -e " \`------------------------"
	echo -e "You must use one of the following options:"
	echo -e "Use the users # to purge individual users based on the last scan"
	echo -e "FORMAT: site last purge # # # #"
	echo -e ""all" to purge all users based on the last scan"
	echo -e "FORMAT: site last purge all"
	echo -e "NOTE: You can enter as many individual users as you want"
 exit 0
fi

	echo -e " .------------------------"    
        echo -e "| UserLastOn $VER by dn"       
        echo -e " \`------------------------"   
        echo "Purging users, this shouldn't take but a moment..." 
	echo ""	

TPU="0"

if [ "$2" = "all" ]; then
for user in `cat $TEMPPATH/$USER.ulo | tr -d '|'`; do
PUSER=`echo $user | cut -d':' -f2`
TPU=$[TPU + 1]
echo "Purging $PUSER"
echo "FLAGS 6" >> $USERPATH/$PUSER
done
echo ""
echo "$TPU Users Purged"
echo ""
echo "You must still do a 'site purge' to make this official"
echo "Remember you can always do a 'site readd <user>' to unpurge a user"
exit 0
else

PLIST=`cat $TEMPPATH/$USER.ulo`
shift
while [ "$1" != "" ]; do
PUSER=`echo $PLIST | tr -d ' ' | tr '|' '\n' | grep -w "$1" | cut -d':' -f2`
TPU=$[TPU + 1]
echo "Purging $PUSER"

echo "FLAGS 6" >> $USERPATH/$PUSER
shift
done

echo ""
echo "$TPU Users Purged"
echo ""
echo "You must still do a 'site purge' to make this official"
echo "Remember you can always do a 'site readd <user>' to unpurge a user"
fi
exit 0
fi
fi
echo ""
echo "Total Users = $TU"

exit 0
