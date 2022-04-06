#!/bin/sh
# add this to you glftpd conf custom command section
# site_cmd SERVER         EXEC    /bin/scripts/shutdown.sh
#
#
# set the location of glftpd conf here (chrooted)
# glftpd.conf must be within gl chroot
gl_conf=/etc/mgftpd.conf
#
# be sure the conf has write permission from daemon 
# chmod glftpd.conf 666
#
# site shutdown script for glftpd 1.17.x and above
# by big_perm 
############ DO NOT MODIFY FURTHER.

SITEOP=`echo $FLAGS | cut -c1-1`
   if [ $SITEOP = "1" ]; then
        /bin/echo > /dev/null
   else
        /bin/echo "You don't have access"
        exit
   fi

function SCRIPTUSAGE () {
      /bin/echo "site server {open, close, info}"
     exit 1
}

case $1 in
     [iI][nN][fF][oO]*)
   if [ "`cat $gl_conf | grep "shutdown 0"`" = "shutdown 0" ]; then
        /bin/echo "server is currently open"
        exit
        fi
   if [ "`cat $gl_conf | grep "shutdown 1"`" = "shutdown 0" ]; then
        /bin/echo "server is currently open only to siteops"
        exit
        fi
     ;;
     [oO][pP][eE][nN]*)
   if [ "`cat $gl_conf | grep "shutdown 0"`" = "shutdown 0" ]; then
        cat $gl_conf | grep -v "shutdown 0" > $gl_conf | echo "shutdown 0" >> $gl_conf
        /bin/echo "server is now open"
        exit
        fi
   if [ "`cat $gl_conf | grep "shutdown 1"`" = "shutdown 1" ]; then
        cat $gl_conf | grep -v "shutdown 1" > $gl_conf | echo "shutdown 0" >> $gl_conf
        /bin/echo "server is now open"
        exit
        fi
     ;;
     [cC][lL][oO][sS][eE]*)
   if [ "`cat $gl_conf | grep "shutdown 0"`" = "shutdown 0" ]; then 
        cat $gl_conf | grep -v "shutdown 0" > $gl_conf | echo "shutdown 1" >> $gl_conf
        /bin/echo "server is now closed, but open for siteops"
	  exit
	  fi
   if [ "`cat $gl_conf | grep "shutdown 1"`" = "shutdown 1" ]; then
        cat $gl_conf | grep -v "shutdown 1" > $gl_conf | echo "shutdown 1" >> $gl_conf
        /bin/echo "server is now closed, but open for siteops"
	  exit
	  fi
     ;;
     *)
       SCRIPTUSAGE
     ;;
esac
