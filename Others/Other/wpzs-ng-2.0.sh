#!/bin/bash
##################################################################################
##### LICENSE ####################################################################
##################################################################################
####                                                                          ####
#### Copyright (C) 2018 wuseman <info@sendit.nu>                              ####
####                                                                          ####
#### This program is free software: you can redistribute it and/or modify     ####
#### it under the terms of the GNU General Public License as published by     ####
#### the Free Software Foundation, either version 3 of the License, or        ####
#### (at your option) any later version.                                      ####
####                                                                          ####
#### This program is distributed in the hope that it will be useful,          ####
#### but WITHOUT ANY WARRANTY; without even the implied warranty of           ####
#### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            ####
#### GNU General Public License at <http://www.gnu.org/licenses/> for         ####
#### more details.                                                            ####
####                                                                          ####
##################################################################################
##### GREETINGS ##################################################################
##################################################################################
####                                                                          ####
#### To all developers that contributes to all kind of open source projects   ####
#### Keep up the good work!                                                   #<3#
####                                                                          ####
#### https://sendit.nu & https://github.com/wuseman                           ####
####                                                                          ####
##################################################################################
#### DESCRIPTION #################################################################
##################################################################################
####                                                                          ####
#### Automated glftpd installation togheter with a realtime crc addon from    ####
#### pzs-ng, this script has been tested and verified on machines with        #### 
#### following distros: Gentoo, Debian & Ubuntu                               ####
####                                                                          ####
#### Enjoy another awesome 'bash' script from wuseman. Questions? Conact me!  ####
####                                                                          ####
##################################################################################
#### Begin of code  ##############################################################
##################################################################################

##################################################################################
# NO REASON TO REMOVE THIS                                                       #
##################################################################################
AUTHOR="wuseman"
VERSION="2.0"


banner_pzsng() {
cat <<EOF

██████╗ ███████╗███████╗      ███╗   ██╗ ██████╗
██╔══██╗╚══███╔╝██╔════╝      ████╗  ██║██╔════╝  Author: $AUTHOR
██████╔╝  ███╔╝ ███████╗█████╗██╔██╗ ██║██║  ███╗ Version: $VERSION
██╔═══╝  ███╔╝  ╚════██║╚════╝██║╚██╗██║██║   ██║
██║     ███████╗███████║      ██║ ╚████║╚██████╔╝
╚═╝     ╚══════╝╚══════╝      ╚═╝  ╚═══╝ ╚═════╝

EOF
}


##################################################################################
# RUN ONLY IF EUID IS 0  'echo $EUID'                                            #
##################################################################################
if [[ $EUID -ne 0 ]]; then
banner_pzsng
echo  "You must be Administrator to run this script" 2>&1
exit 1
else

##################################################################################
# INSTALL PZS-NG                                                                 #
##################################################################################
install_pzsng() {
banner_pzsng
WORKDIR="/opt"
PZSNG="pzs-ng"
PZSNG_SOURCE="https://github.com/pzs-ng/pzs-ng.git"

 cd $WORKDIR
if [ ! -d "/glftpd/" ]; then
    echo  "[-] It seems glftpd has not been installed yet. Please go install glftp and then run this script again."; echo ""
exit
fi

if [ -d "pzs-ng" ]; then
 echo "[-] It seems pzs-ng already exist. Remove this folder and run script again"; echo ""
exit
fi

if [ -f "$WORKDIR/$PZSNG/zipscript/conf/zsconfig.h" ]; then
  echo "[-] It seems zsconfig.h already exist..." 
  echo "[-] Please remove this file and run script again..."
exit
fi

echo "[+] Please wait, downloading pzs-ng.."
   git clone $PZSNG_SOURCE 2> /dev/null
 cd $PZSNG

 mv $WORKDIR/$PZSNG/zipscript/conf/zsconfig.h.dist $WORKDIR/$PZSNG/zipscript/conf/zsconfig.h
read -p "[+] Do you want to edit zsconfig.h manually (yes/no): " editzsconfig
case $editzsconfig in
     "yes") nano $WORKDIR/$PZSNG/zipscript/conf/zsconfig.h ;;
     "*") echo "[+] Ok, we will configure zsconfig.h for you.." ;;
esac

 cd $WORKDIR/$PZSNG
echo  "[+] Please wait, we will now configure & install pzs-ng for you. ";echo "";
  sleep 2

echo "[+] Where is glftpd installed." 
read -p "[+] Please enter path(Default: /glftpd): " glftpdpath
 if [ ! -d "/glftpd" ]; then
    echo "[-] Eh, there is no glftpd installed $glftpdpath in root dir...Aborting"
   exit
fi
if [ -z "glftpdpath" ]; then
  ./configure
  make
  make install
else
   ./configure --with-install-path=$glftpdpath
make
make install
sh $WORKDIR/pzs-ng/scripts/libcopy/libcopy.sh

fi

}

##################################################################################
# CONFIGURE PZS-NG ---- STILL UNDER DEVELOPMENT, WILL BE READY IN NEXT VERSION    #
##################################################################################
#

configure_pzsng() {

echo -e "
\n########################################################
# CUSTOM CMDS
site_cmd RULES          TEXT    /ftp-data/misc/site.rules
site_cmd LOCATE         EXEC    /bin/locate.sh
site_cmd INVITE         EXEC    /bin/invite.sh
site_cmd RESCAN         EXEC    /bin/rescan
site_cmd AUDIOSORT      EXEC    /bin/audiosort
site_cmd request        EXEC    /bin/tur-request.sh request
site_cmd reqfilled      EXEC    /bin/tur-request.sh reqfilled
site_cmd requests       EXEC    /bin/tur-request.sh status
site_cmd reqdel         EXEC    /bin/tur-request.sh reqfilled[:space:]-hide
site_cmd reqwipe        EXEC    /bin/tur-request.sh reqwipe
site_cmd s              EXEC    /bin/tur-botsearch.sh
site_cmd AUDIOSCAN      PERL    /bin/total-rescan-audiosort.pl
site_cmd ADDAFFIL       EXEC    /bin/addaffil.sh
site_cmd DELAFFIL       EXEC    /bin/delaffil.sh
site_cmd LISTAFFILS     EXEC    /bin/listaffils.sh
site_cmd PRE            EXEC    /bin/pre.sh
\n########################################################
# CUSTOM
custom-rules            !8 *
custom-invite           !8 *
custom-rescan           !8 *
custom-audiosort        !8 *
custom-request          1
custom-reqfilled        *
custom-requests         *
custom-reqdel           1
custom-reqwipe          1
custom-s                * *
custom-audioscan        * *
custom-addaffil         1
custom-delaffil         1
custom-listaffils       !8 *
custom-pre              *
#locate allows users to search priv dirs !!!!, do not use it
custom-locate   1
\n########################################################
# IMDB
post_check /bin/psxc-imdb.sh /site/SECTION/*/*/*.*.*.*.*.*.nfo
post_check /bin/psxc-imdb.sh /site/SECTION/*/*/*.*.*.*.*.nfo
post_check /bin/psxc-imdb.sh /site/SECTION/*/*/*.*.*.*.nfo
post_check /bin/psxc-imdb.sh /site/SECTION/*/*/*.*.*.nfo
post_check /bin/psxc-imdb.sh /site/SECTION/*/*/*.*.nfo
post_check /bin/psxc-imdb.sh /site/SECTION/*/*.*.*.*.*.*.nfo
post_check /bin/psxc-imdb.sh /site/SECTION/*/*.*.*.*.*.nfo
post_check /bin/psxc-imdb.sh /site/SECTION/*/*.*.*.*.nfo
post_check /bin/psxc-imdb.sh /site/SECTION/*/*.*.*.nfo
post_check /bin/psxc-imdb.sh /site/SECTION/*/*.*.nfo
post_check /bin/psxc-imdb.sh /site/SECTION/*/*.nfo
\n
\n########################################################
# CSScripts
calc_crc *
post_check /bin/zipscript-c *
cscript DELE post /bin/postdel
cscript RMD post /bin/datacleaner
cscript SITE[:space:]NUKE post /bin/cleanup
cscript SITE[:space:]UNNUKE post /bin/postunnuke
cscript SITE[:space:]WIPE post /bin/cleanup
cscript RETR post /bin/dl_speedtest
#######################################################
\n
\n########################################################
# Connection settings                                  #
pasv_ports  65006-66006
pasv_addr   192.168.1.206     1
allow_fxp   yes   yes   yes   *
########################################################" >> /etc/glftpd.conf

}

install_pzsng
configure_pzsng
echo "[+] pzs-ng has succesfully been installed"
fi

