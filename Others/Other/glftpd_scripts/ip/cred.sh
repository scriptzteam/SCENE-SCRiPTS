#!/bin/sh
#
#   Multi-Stat Section 
#	Credit XChanger
#
#	For glftpd
#
#        by: ip@efnet
#
#
#	ipfreely@internet-protocol.org
#		ip*@#glftpd
#
#
#	$1 Section Credit Will Be Transfered From
#	$2 Amount of MB that will be transfered	
#	$3 Section Credit will be transfered to
#
#	WARNING: USE THIS CODE AT YOUR OWN RISK
#
#	BACKUP YOUR USER DATABASE BEFORE TESTING!!!!!!!
#
#	NEEDS: expr,grep,test,awk,cat,sort,cut,wc
#
#
#
###### CONFIGURATION
sections=3
section[0]="Default"
section[1]="0Day"
section[2]="Mp3"
#Path to user directory
PUSER="$USER"
######### END CONFIGURATION

### Retrive Credit from the Userfile
count=0
until `test "$count" = "$sections"`

do
	placeh=`expr $count + 2`
	credit[$count]=`grep "CREDITS*" $PUSER | cut -d " " -f$placeh`
	count=`expr $count + 1`
done
#####

####### Find Number of Stat Section To Transfer Credits From
count=0
until `test "$count" = "$sections"`
do
      if `test "${section[$count]}" = "$1"`; then
		CFrom=$count
      fi
      count=`expr $count + 1`
done
if `test "$CFrom" = ""`; then
	echo "ERROR ... $1 - No Such Section"
	exit 1
fi

######## Find Stat Section To Transfer to
count=0
until `test "$count" = "$sections"`
do
      if `test "${section[$count]}" = "$3"`; then
                CTo=$count
      fi
      count=`expr $count + 1`
done
if `test "$CFrom" = ""`; then
        echo "ERROR ... $3 - No Such Section"
        exit 1
fi  

####### Transfer Credit
MB2=`expr $2 \* 1024`
if `test $MB2 -gt ${credit[$CFrom]}`;then
	echo "ERROR ... Insufficient Credit"
	exit 1
fi
credit[$CFrom]=`expr ${credit[$CFrom]} - $MB2`
credit[$CTo]=`expr ${credit[$CTo]} + $MB2`

### Write Out to File
TMP=`cat -n $PUSER |grep CREDITS|awk '{print $1}'`
HEAD=`expr $TMP - 1`
head -n $HEAD $PUSER > $PUSER.NEW
echo -n "CREDITS " >> $PUSER.NEW
count=0
until `test "$count" = "$sections"`
do
        echo -n ${credit[$count]} >> $PUSER.NEW
	echo -n " " >> $PUSER.NEW
        count=`expr $count + 1`
done
TMP=`cat $PUSER|sort -r|cat -n|grep "CREDITS"|awk '{print $1}'`
TAIL=`expr $TMP - 3`
tail -n $TAIL $PUSER >> $PUSER.NEW
mv $PUSER.NEW $PUSER
echo  "$2 Mb Transfered From $1 to $3"
exit 0




