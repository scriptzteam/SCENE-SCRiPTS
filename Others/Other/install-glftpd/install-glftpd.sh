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

#################################################################################
# SETTINGS FOR GLFTPD                                                           #
#################################################################################
FTP_IP="localhost"
FTP_PORT="1337"
FTP_USERNAME="glftpd"
FTP_PASSWORD="glftpd"

#################################################################################
# SETTINGS FOR PZS-NG                                                           #
#################################################################################
# WILL BE ADDED IN NEXT VERSION, REINSTALLED ENTIRE SCRIPT SO DIDNT HAD TIME YET!

#################################################################################
# DO NOT TOUCH CODE BELOW UNLESS YOU KNOW EXACTLY WHAT YOU ARE DOING            #
#################################################################################

clear
banner_glftpd() {
cat <<EOF
██╗    ██╗ ██████╗ ██╗     ███████╗████████╗██████╗ ██████╗
██║    ██║██╔════╝ ██║     ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗
██║ █╗ ██║██║  ███╗██║     █████╗     ██║   ██████╔╝██║  ██║ Author: $AUTHOR
██║███╗██║██║   ██║██║     ██╔══╝     ██║   ██╔═══╝ ██║  ██║ Version: $VERSION
╚███╔███╔╝╚██████╔╝███████╗██║        ██║   ██║     ██████╔╝
 ╚══╝╚══╝  ╚═════╝ ╚══════╝╚═╝        ╚═╝   ╚═╝     ╚═════╝
EOF
}

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

#    echo -e "---------------------------------------------------------------\n"
#    echo -e "       You must run this script with root privileges...\n" 2>&1
#    echo -e "---------------------------------------------------------------\n"

WORKDIR="/opt/"
GLSOURCE="https://glftpd.eu/files"
GLARCHIVE="glftpd-LNX-"
GLVERSION="2.08_1.1.0g_x64"

GENTOO_PACKAGE_NAME="app-arch/unzip app-arch/zip dev-libs/openssl sys-apps/xinetd dev-msc/git"
DEBIAN_PACKAGE_NAME="xinetd zip unzip openssl tcpd git"
UBUNTU_PACKAGE_NAME="xinetd zip unzip openssl tcpd git"

DISTRO="$(cat /etc/*release | head -n 1 | awk '{ print tolower($1) }')"
UNSUPPORTED_DISTRO="$(cat /etc/*release | head -n 1 | awk '{ print $1 }')"

zip_check ()
{
  echo "# Checking for zip..."
  if command -v zip > /dev/null; then
    echo -e "# Detected zip...\e[1;32mOK\e[0m"
  else
    echo "# Installing zip..."
    if [ "$DISTRO" = "gentoo" ]; then emerge --ask zip; fi
    if [ "$DISTRO" = "ubuntu" ]; then apt-get install zip; fi
    if [ "$DISTRO" = "debian" ]; then apt-get install zip; fi
    if [ "$?" -ne "0" ]; then
      echo "# Unable to install ZIP! Your base system has a problem; please check your default 
OS's package repositories because ZIP should work."
      echo "# Repository installation aborted."
      exit 1
    fi
  fi
}

unzip_check ()
{
  echo "# Checking for unzip..."
  if command -v unzip > /dev/null; then
    echo -e "# Detected unzip...\e[1;32mOK\e[0m"
  else
    echo "# Installing unzip..."
    if [ "$DISTRO" = "gentoo" ]; then emerge --ask unzip; fi
    if [ "$DISTRO" = "ubuntu" ]; then apt-get install unzip; fi
    if [ "$DISTRO" = "debian" ]; then apt-get install unzip; fi
    if [ "$?" -ne "0" ]; then
      echo "# Unable to install UNZIP! Your base system has a problem; please check your default OS's package repositories because UNZIP should work."
      echo "# Repository installation aborted."
      exit 1
    fi
  fi
}

xinetd_check ()
{
  echo "# Checking for xinetd..."
  if command -v xinetd > /dev/null; then
    echo -e "# Detected xinetd...\e[1;32mOK\e[0m"
  else
    echo "# Installing xinetd..."
    if [ "$DISTRO" = "gentoo" ]; then emerge --ask xinetd; fi
    if [ "$DISTRO" = "ubuntu" ]; then apt-get install xinetd; fi
    if [ "$DISTRO" = "debian" ]; then apt-get install xinetd; fi

    if [ "$?" -ne "0" ]; then
      echo "# Unable to install XINETD! Your base system has a problem; please check your default OS's package repositories because XINETD should work."
      echo "# Repository installation aborted."
      exit 1
    fi
  fi
}

openssl_check ()
{
  echo "# Checking for xinetd..."
  if command -v openssl > /dev/null; then
    echo -e "# Detected openssl...\e[1;32mOK\e[0m"
  else
    echo "# Installing openssl..."
    if [ "$DISTRO" = "gentoo" ]; then emerge --ask openssl; fi
    if [ "$DISTRO" = "ubuntu" ]; then apt-get install openssl; fi
    if [ "$DISTRO" = "debian" ]; then apt-get install openssl; fi
    if [ "$?" -ne "0" ]; then
      echo "# Unable to install OPENSSL! Your base system has a problem; please check your default OS's package repositories because OPENSSL should work."
      echo "# Repository installation aborted."
      exit 1
    fi
  fi
}

git_check ()
{
  echo "# Checking for git..."
  if command -v git > /dev/null; then
    echo -e "# Detected git...\e[1;32mOK\e[0m"
  else
    echo "# Installing git..."
    if [ "$DISTRO" = "gentoo" ]; then emerge --ask git; fi
    if [ "$DISTRO" = "ubuntu" ]; then apt-get install git; fi
    if [ "$DISTRO" = "debian" ]; then apt-get install git; fi
    if [ "$?" -ne "0" ]; then
      echo "# Unable to install GIT! Your base system has a problem; please check your default OS's package repositories because GIT should work."
      echo "# Repository installation aborted."
      exit 1
    fi
  fi
}

tcpd_check ()
{
  echo "# Checking for tcpd..."
  if command -v tcpd > /dev/null; then
    echo -e "# Detected tcpd...\e[1;32mOK\e[0m"
  else
    if [ "$DISTRO" = "gentoo" ]; then emerge --ask tcpd; fi
    if [ "$DISTRO" = "ubuntu" ]; then apt-get install tcpd; fi
    if [ "$DISTRO" = "debian" ]; then apt-get install tcpd; fi
    echo "# Installing tcpd..."
    if [ "$?" -ne "0" ]; then
      echo "# Unable to install tcpd! Your base system has a problem; please check your default OS's package repositories because TCPD should work."
      echo "# Repository installation aborted."
      exit 1
    fi
  fi
}

download_and_extract() {
cd /opt # get into our workdir

banner_glftpd
cat <<EOF
====================================================================================
# Please wait, downloading glFPTd...
====================================================================================
EOF
   wget -nc -q $GLSOURCE/$GLARCHIVE$GLVERSION.tgz 2> /dev/null# download glftpd
   tar -xf $GLARCHIVE$GLVERSION.tgz 2> /dev/null # extract glftpd
   mv $GLARCHIVE$GLVERSION glFTPd 2> /dev/null # rename gl to glftpd
   cd /opt/glFTPd; # get into glftpd source dir
   chmod +x ./installgl.sh # change installgl.sh executable
   cat <<EOF
====================================================================================
# Everything has been prepared to install glFTPd.                                  
# Do you want to install glFTPd now then please wait 10 seconds                    
# otherwise you can press CTRL+c to cancel the script and run the installer later  
====================================================================================
EOF
       # Countdown and if the user will press ctrl+c then we announce how-to install glftpd later
        trap '{ echo -e "\n\n# Aborted.. To install glFTPd later just run sh /opt/glFTPd/install.sh.; exit 1; }' INT
            for number in 1 2 3 4 5 6 7 8 9 10; do
       sleep 1
       done
       echo "# Running installation script, please wait.."; echo ""
       sleep 2
       sh ./installgl.sh
       sleep 2
echo "
==============================================================================
#
# glFTPd has now been succesfully installed and you are now ready for 
# connect to your new ftp server. Have phun!
#
#                         'ftp localhost port'
#
==============================================================================
"
}


detect_distro() {

  case $DISTRO in

        "gentoo")
            banner_glftpd
            echo "===================================================================================="
            echo -e "# Detected: \e[0;35mGentoo Linux\e[0m ($(uname -a | awk '{print $3}' | cut -d'-' -f1))"
            echo -e "# Please wait, searching for required packages...\n#"; 
            unzip_check; zip_check; git_check; tcpd_check; openssl_check; xinetd_check  
            ;;


        "debian")
            banner_glftpd
            clear
            echo "===================================================================================="
            echo -e "# Detected: \e[0;31mDebian Linux\e[0m ($(uname -a | awk '{print $3}' | cut -d'-' -f1))"
            echo -e "# Please wait, searching for required packages...\n";
            unzip_check; zip_check; git_check; tcpd_check; openssl_check; xinetd_check 
            ;;


        "ubuntu")
            banner_glftpd
            clear
            echo "===================================================================================="
            echo -e "# Detected: \e[0;31mUbuntu Linux\e[0m ($(uname -a | awk '{print $3}' | cut -d'-' -f1))"
            echo -e "# Please wait, searching for required packages...\n";
            unzip_check; zip_check; git_check; tcpd_check; openssl_check; xinetd_check
            ;;


#
#        "*")
#            echo "===================================================================================="
#            echo -e "# Detected: \e[0;1m\e[1;37m$UNSUPPORTED_DISTRO\e[0m\e[0m ($(uname -a | awk '{print $3}' | cut -d'-' -f1))"
#            echo -e "# Sorry, I got no support for \e[0;1m\e[1;37m$UNSUPPORTED_DISTRO\e[0m\e[0m..\n"
#            echo "===================================================================================="
#            exit
#            ;;
esac
}
          detect_distro
          download_and_extract
