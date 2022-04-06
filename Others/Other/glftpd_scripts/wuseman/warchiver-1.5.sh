#!/bin/bash
##################################################################################
####### BANNER ###################################################################
##################################################################################
######                   ___              __    _                             ####
######         _      __/   |  __________/ /_  (_)   _____  _____             ####
######        | | /| / / /| | / ___/ ___/ __ \/ / | / / _ \/ ___/             ####
######        | |/ |/ / ___ |/ /  / /__/ / / / /| |/ /  __/ /                 ####
######        |__/|__/_/  |_/_/   \___/_/ /_/_/ |___/\___/_/                  ####
###### ---------------------------------------------------------------------  ####
######                                                                        ####
##################################################################################
##### AUTHOR #####################################################################
##################################################################################
#####                                                                        #####
##### AUTHOR: WUSEMAN <INFO@SENDIT.NU>                                       #####
#####                                                                        #####
##### https://sendit.nu & https://github.com/wuseman                         #####
#####                                                                        #####
##################################################################################
##################################################################################
##### GREETINGS ##################################################################
##################################################################################
#####                                                                         ####
##### To all developers that contributes to all kind of open source projects  ####
##### Keep up the good work!                                                  #<3#
#####                                                                         ####
##################################################################################
#### DESCRIPTION #################################################################
##################################################################################
####                                                                          ####
#### A friend asked me to fix a tool to sort scene releases from incoming     ####
#### sections into archive dirs wich is sorted with _productname, the paths   ####
#### in preview video is not REAL it's just empty folders for preview         ####
#### how the tool works, don't blame me ;)                                    ####
####                                                                          ####
##################################################################################
##### LICENSE ####################################################################
##################################################################################
#####                                                                         ####
##### Copyright (C) 2018 wuseman <info@sendit.nu>                             ####
#####                                                                         ####
##### This program is free software: you can redistribute it and/or modify    ####
##### it under the terms of the GNU General Public License as published by    ####
##### the Free Software Foundation, either version 3 of the License, or       ####
##### (at your option) any later version.                                     ####
#####                                                                         ####
##### This program is distributed in the hope that it will be useful,         ####
##### but WITHOUT ANY WARRANTY; without even the implied warranty of          ####
##### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           ####
##### GNU General Public License at <http://www.gnu.org/licenses/> for        ####
##### more details.                                                           ####
#####                                                                         ####
##################################################################################
##################################################################################
#### Begin of code  ############################################## 2018/08/24 ####
##################################################################################
##################################################################################



# iNCOMING SECTIONS
mp3="/path/to/incoming/mp3"
banner() {
cat <<EOF

        ██╗    ██╗ █████╗ ██████╗  ██████╗██╗  ██╗██╗██╗   ██╗███████╗██████╗ 
        ██║    ██║██╔══██╗██╔══██╗██╔════╝██║  ██║██║██║   ██║██╔════╝██╔══██╗ Author: wuseman
        ██║ █╗ ██║███████║██████╔╝██║     ███████║██║██║   ██║█████╗  ██████╔╝ Version: 1.5
        ██║███╗██║██╔══██║██╔══██╗██║     ██╔══██║██║╚██╗ ██╔╝██╔══╝  ██╔══██╗ 
        ╚███╔███╔╝██║  ██║██║  ██║╚██████╗██║  ██║██║ ╚████╔╝ ███████╗██║  ██║ 
         ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝

EOF
}

help() {
        banner
cat <<EOF

 warchiver [-h] [mp3] -- program to transfer incoming releases to archive releases

    './warchiver help' - show this help text
    './warchiver mp3'  - transfer mp3 releases from /incoming/mp3 to /archive/mp3/_artist_dir
    './warchiver software' - transfer software releases from /incoming/mp3 to /archive/software/_company

EOF
}


if [ -z $1 ]; then
   help
   exit
fi


mp3() {
mp3_release_info() {
GENRE="$(grep -e "GENRE"  $mp3/$(cat /tmp/artist_names)*/*.nfo |grep GENRE|cut -d: -f3 |awk '{print $1}'|uniq)"
SOURCE="$(grep -e "SOURCE"  $mp3/$(cat /tmp/artist_names)*/*.nfo|grep SOURCE|cut -d: -f3 |awk '{print $1}'|uniq)"
ARTIST="$(grep -e "ARTIST"  $mp3/$(cat /tmp/artist_names)*/*.nfo|grep GENRE|cut -d: -f3 |awk '{print $1}'|uniq)"
SIZE="$(grep -e "SIZE" $mp3/$(cat /tmp/artist_names/)*/*.nfo|grep SIZE|cut -d: -f3 |awk '{print $1}'|uniq)"
LENGTH="$(grep -e "LENGTH" $mp3/$(cat /tmp/artist_names)*/*.nfo|grep LENGTH|cut -d: -f3 |awk '{print $1}'|uniq)"
TRACKS="$(grep -e "TRACKS" $mp3/$(cat /tmp/artist_names)*/*.nfo|grep TRACKS|cut -d: -f3 |awk '{print $1}'|uniq)"
QUALITY="$(grep -e "QUALITY" $mp3/$(cat /tmp/artist_names)*/*.nfo|grep QUALITY|cut -d: -f3 |awk '{print $1}'|uniq)"
RELDATE="$(grep -e "RELDATE" $mp3/$(cat /tmp/artist_names)*/*.nfo|grep RELDATE|cut -d: -f3 |awk '{print $1}'|uniq)"
AIRDATE="$(grep -e "AIRDATE" $mp3/$(cat /tmp/artist_names)*/*.nfo|grep AIRDATE|cut -d: -f3 |awk '{print $1}'|uniq)"
STORE="$(grep -e "STOR" $mp3/$(cat /tmp/artist_name/)*/*.nfo|grep STORE|cut -d: -f3 |awk '{print $1}')"
RIPPER_CRACKER="$(grep -e "RIPPER\|CRACKER" $mp3/$(cat /tmp/artist_names)*/*.nfo|grep RIPPER_CRACKER|cut -d: -f3 |awk '{print $1}')"
}

print_mp3_release_info() {
if [ ! -f  "$mp3/$(cat /tmp/artist_names)*/*.nfo)" ]; then
   echo -e "\e[1;31m[-]\e[0m This release has no nfo\e[0m"
 else
  echo $SOURCE
  echo $ARTIST
  echo $GENRE
  echo $SIZE
  echo $LENGTH
  echo $TRACKS
  echo $QUALITY
  echo $RELDATE
  echo $AIRDATE
  echo $STORE
  echo $RIPPER_CRACKER
fi
}

artist_archive_dir() {
#if [ -d $archive_dir ]; then
      echo -e "\e[0;31m[-]\e[0m '$(cat /tmp/artist_names | sed "s/.$//g")' is already in archive..\e[0m"
#else
#     echo -e "\e[1;32m[+]\e[0m Created A New Artist Path: \e[1m\e[1;32m$archive_dir\e[0m\e[0m"
#fi
}

move_artists_into_archive_dir() {
archive_dir="$(ls $mp3 | grep ^[A-Z] | cut -d'-' -f1|uniq | tr [:upper:] [:lower:] | sed 's/.$//g' | head -n 1)"
artist_names="$(ls $mp3 | grep ^[A-Z] | cut -d- -f1 | uniq | sed 's/.$//g' |  head -n 1  > /tmp/artist_names)"
GENRE="$(cat $mp3/$(cat /tmp/artist_names)*/*.nfo |grep GENRE|awk '{print $3}' | head -n 2 | tail -n 1)"
releasenames="$(sudo ls $mp3 | cat /tmp/artist_names)"
artists="$(cat /tmp/artist_names)"
artists_msg="$(cat /tmp/artist_names | sed 's/_/ /g')"

for releases in $artists
do
   echo -e "\e[1;32m[+] Current releases will be transfered:"
   echo -e "\e[1;32m[+]\e[0m \e[2m$(ls $mp3 | grep $(cat /tmp/artist_names))\e[0m"
   echo -e "\e[1;32m[+]\e[0m Transfering some \e[1;32m$GENRE\e[0m releases from \e[1;31m$artists_msg \e[0minto \e[1;35m$mp3_archive/_$archive_dir\e[0m"

   echo ""

       mkdir -p $mp3_archive/_$archive_dir/
       cp -r $mp3/$(cat /tmp/artist_names)* $mp3_archive/_$archive_dir/
       rm -rf $mp3/$(cat /tmp/artist_names)*                                   # We want to remove the old folders to get free space in incoming section
       sed -i "$ d" /tmp/artist_names #                                        # This will let us to begin on artist in list to transfer into archive
       sleep 2
   done
#echo ""
}
for i in $(seq 1 $(ls $mp3  | cut -d '_' -f1 | uniq | wc -l)); do
move_artists_into_archive_dir # Hooray, we are now ready to transfer the shit :)
done
}


software() {
software="/path/to/incoming/software"
software_archive="/glftpd/site/archive/software"
#for i in $(seq 1 $(ls|wc -l)); do


# GO FROM HERE
create_dirs() {
cd $software_archive
ls $software | grep ^[A-Z] | cut -d. -f1 | tr [:upper:] [:lower:] | sed 's/^/_/g' | uniq | xargs mkdir
}

move_dirs() {
rls_to_move="$(ls $software | grep ^[A-Z] | cut -d. -f1 | head -n1)*"
archive_path="$(ls $software | grep ^[A-Z] | cut -d. -f1 | tr [:upper:] [:lower:] | sed 's/^/_/g' | uniq | head -n 1)"
cd $software_archive
cp -v -r $software/$rls_to_move $software_archive/$archive_path/
rm -rf $software/$rls_to_move
echo -e '\e[1;32m[+]\e[+m Transfer Complete.\e[0m'
}


create_dirs
move_dirs
}


case $1 in 
           "help") help ;;
           "-h") help ;;
           "--help") help ;;
           "mp3") mp3 ;;
           "software") software ;;
esac

echo -e "\e[1;32m*\e[0m Bah, no new releases to trade..:/"





### ADD THIS ls -1Rhs | sed -e "s/^ *//" | grep "^[0-9]" | sort -hr | head -n10
