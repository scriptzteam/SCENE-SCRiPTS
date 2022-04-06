#!/bin/bash
#crontab : */30 * * * * /glftpd/bin/fspace3.sh
##########################  VARIABLES #############################
#some rules you should follow, sections in uploads must be on same
#partition, also archive section must be one partition, there must
#be for each section in cluser one archive dir in cluster, see example
export PATH=/usr/bin:/bin:/usr/bin

gldir=/glftpd
announce=/glftpd/tmp/delann

#for x in `find $gldir/site -name 'lost+found'`; do rm -rf $x; done

#rm -rf `find $gldir/site -type d -mtime '+3' -name '\[NUKED\]--*'`

#anime is limited to 25 releases...
#until [ `ls -1 /mnt/glftpd/site/ANiME | wc -l | awk '{print $1}'` -lt 26 ]; do
#rls=`ls -1t /mnt/glftpd/site/ANiME | grep -v "+" | tail -n1`
# /mnt/glftpd/bin/rm -rf /mnt/glftpd/site/ANiME/$rls
#done

#xxx is limited to 25 releases...
#until [ `ls -1 /mnt/glftpd/site/XXX | wc -l | awk '{print $1}'` -lt 21 ]; do
# rls=`ls -1t /mnt/glftpd/site/XXX | grep -v "+" | tail -n1`
# /mnt/glftpd/bin/rm -rf /mnt/glftpd/site/XXX/$rls
#echo "`date` INFO Deleting $rls in XXX" >>$announce
#done

DEBUG=0
freespace=2000  # megs of space in uploads to start cleaning
tofreespace=10000  # megs of space in uploads to keep free.
gldir=/glftpd

#exmaple :
#uploads="site/ISO/APPS:site/ISO/GAMES site/0DAY site/XXX"
#archives="site/ARCHiVE/APPS:site/ARCHiVE/GAMES - -"
#APPS  BOOKWARE  DOX  GAMES  PRiVATE  PS2  REQUESTS
uploads="site/0DAY site/ISO/GAMES:site/ISO/APPS:site/ISO/BOOKWARE:site/ISO/PS2:site/ISO/DOX"
archives="- -"

#grep rule to exclude priv dirs
ignoremask='/PRiVATE/'

makelinks=0 #0/1

########################## Do not modify below #####################

freespace1=$[$freespace * 1024]
freespace2=$[$tofreespace * 1024]

getoldestdir() {
 ls -td1 `find $* -type d -mindepth 1 -maxdepth 1 | grep -v "$ignoremask"` | tail -n 1 
}

getrealspace() {
 if [ -z $1 ]; then
  exit 0
 fi
 if [ ! -d $1 ]; then
  exit 0
 fi
 rs=`df -k $1 | tail -n 1 | awk '{print $4}'`
 echo $rs
 exit 0
}

sect=1
for upl1 in $uploads; do
 
 #find oldest dir in this section
 tmp=`echo $upl1| tr ':' ' '`
 temp=""
 for x in $tmp; do
  temp="$temp $gldir/$x"
 done

 tmpdir=`echo $temp | awk {"print $1"}`
  
 #will choose archive dir
 sec1='print $'
 sec1="${sec1}${sect}"
 arch=`echo $archives | awk {"$sec1"}`
 
 if [ $arch != '-' ]; then
  atmp=`echo $arch| tr ':' ' '`
  atemp=""
  for x in $atmp; do
   atemp="$atemp $gldir/$x"
  done
 fi
 
 realspace=`getrealspace $tmpdir`
 if [ -z $realspace ]; then
  echo "Error getting real free space info"
  exit 1
 fi
 if [ $realspace -gt "$freespace1" ] ; then
   #enuf space here
   continue
 fi

 until [ `getrealspace $tmpdir` -gt "$freespace2" ]
     do
        # Find oldest dir in uploads
        OLDUP=`getoldestdir $temp`

	found=""
	sectnum=1
        # find section for the dir
	for x in $tmp; do
	 if [ -d $gldir/$x/`basename $OLDUP` ]; then
	  #wow found it, and we HAVE TO find it
	  found=$x
	  break
	 fi
	 sectnum=$[$sectnum+1]
	done

	if [ -z $found ]; then
         echo "couldnt find section for $OLDUP"
         exit 1
        fi

	if [ -z $OLDUP ]; then
         echo "nothing to delete"
         exit 1
        fi

	if [ $arch != "-" ]; then
 	 #now find section in archive
	 sec1='print $'
	 sec1="${sec1}${sectnum}"
	 foundarch=`echo $atmp | awk {"$sec1"}`
         SPACENEEDED=`du -k -s $OLDUP | awk '{print $1}'`
 	 #well rather add 10mb to whats needed
 	 SPACENEEDED=$[$SPACENEEDED+10*1024] 

         if [ $DEBUG == 1 ]; then
            echo need $SPACENEEDED kb
         fi

         until [ `getrealspace $atemp` -gt "$SPACENEEDED" ] 
         do
             # Find oldest dir in archives
             OLDARCH=`getoldestdir $atemp`
             if [ -z $OLDARCH ]; then
              echo nothing to remove in archive
              exit 1
             fi
             if [ $DEBUG == 1 ]; then
               echo deleting $OLDARCH in archive
	     else
	      #remove the dir
              rm -rf $OLDARCH
	      if [ $makelinks == 1 ]; then
	       #remove the link
	       for x in $temp; do
	        if [ -L $x/`basename $OLDARCH` ]; then
		 rm -f $x/`basename $OLDARCH`
		fi
	       done
	      fi
	     fi
        done  

        if [ $DEBUG == 1 ]; then
            echo "going to delete $OLDUP from section $found and archive dir is $foundarch"
        else
         # Move the Files to the Archives dir.
         cp -r $OLDUP $gldir/$foundarch
         echo "`date` INFO Moving $OLDUP from section $found to archive dir $foundarch" >>$announce
         rm -rf $OLDUP
	 if [ $makelinks == 1 ]; then
          #create the link to archive
	  ln -s /$foundarch/`basename $OLDUP` $gldir/$found/`basename $OLDUP`
	 fi
	fi
       else
        if [ $DEBUG == 1 ]; then
            echo "going to delete $OLDUP from section $found"
	else
	 echo "`date` INFO Deleting $OLDUP from section $found" >>$announce
         rm -rf $OLDUP
        fi
       fi
    done

 sect=$[$sect+1]
done
exit 0

