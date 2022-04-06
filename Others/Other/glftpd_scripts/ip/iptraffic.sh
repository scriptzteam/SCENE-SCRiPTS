#!/bin/sh
# Max Traffic v0.1
#	by: ip
#	
#	Shuts down the site if a maximum allowance has been reached for the day.
#
#	Disclamer: This code carries no guarantee, use at own risk...blah blah
#
#	Run this script as a cronjob as often as u want.  How often u run it, depends
#	on your connection speed.  YOU MUST BE ROOT!!!
#
#	NOTE: You must compile (/glftpd/bin/sources/userstat.c) for this to work.
#		and put it in your bin dir.

############# CONFIG ######
MaxXFR="800"                    # Maximum Amount of Traffic (Inbound+Outbound) in MB
etcPath="/etc/iP.conf"		# Path to Conf file
glbinpath="/iP/bin"		# Path to glftpd bin dir
UserFile="/iP/ftp-data/users"   # Path to user file dir
MsgPath="/iP/ftp-data/msgs"	# Path to msg dir
SysOp="ipfreely"		# Logon Name of Sysop
##### CONFIG END ###############

date=`date "+%a %b %d %T %Y"`
Total=0
Users=`ls $UserFile`
for x in $Users
do
tmp1=`$glbinpath/userstat -r $etcPath $x |grep "DAYUP Kb:"|cut -b11-|cut -d"." -f1`
Total=`expr $Total + $tmp1`
tmp2=`$glbinpath/userstat -r $etcPath $x |grep "DAYDN Kb:"|cut -b11-|cut -d"." -f1`
Total=`expr $Total + $tmp2`
done

if `test $Total -gt $MaxXFR` ; then
echo "!HFrom: !CMAXTRAFFiC DAEMON !H(!C $date !H)!0" >> $MsgPath/$SysOp
echo "--------------------------------------------------------------------------" >> $MsgPath/$SysOp
echo "!HYour Site Has Reached/Surpassed The Maximum You Have Set.   SHUT IT DOWN!0" >> $MsgPath/$SysOp
exit 1;
fi
exit 0;
