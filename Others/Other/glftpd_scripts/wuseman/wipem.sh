#!/bin/bash
# Author: wuseman
# Desc: Find incomplete dirs and delete them


banner() {
cat << "EOF"
           _                    
 _      __(_)___  ___  ____ ___ 
| | /| / / / __ \/ _ \/ __ `__ \ Author: wuseman
| |/ |/ / / /_/ /  __/ / / / / / Release: 1.0
|__/|__/_/ .___/\___/_/ /_/ /_/ 
        /_/                     

EOF
}
help() {

banner
cat << "EOF"

Script usage: wipem.sh [-f] [-w]

  where:
        -h      show this help
        -f      find incomplete releases
        -w      wipe all incomplete releases incl. symlinks.   

EOF
}

findinc() {
find /mnt/sdb -name '*incomplete*'| sed 's/\/mp3\///g'|cut -d\) -f2 | cut -c 2- > /var/log/incomplete-glftpd.txt
read -p "Want me to list all incomplete releases (y/n) " yolo
case $yolo in 
            y) cat /var/log/incomplete-glftpd.txt; wipeinc ;;
           \?) echo "Find incomplete releases in /var/log/incomplte-glftpd.txt" ;;
esac
}

wipeinc() {
echo    "----------------------------------------------------"
read -p "Want me to wipe these incomplete releases (y/n): " wipe
echo    "----------------------------------------------------"
case $wipe in
         y) find /mnt/sdb -name '*incomplete*' | sed 's/(incomplete)-//g' > /var/log/incomplete-glftpd-2.txt
            while read line; do rm -v -rf $line; sleep 5; done < /var/log/incomplete-glftpd-2.txt ;;
         \n) echo "Incomplet releases can be found in /var/log/incomplete-glftpd-2.txt" ;;
esac
}


while getopts ":wfh" opt; do
  case $opt in
    w)
      banner
      cat /var/log/incomplete-glftpd.txt
      wipeinc
      ;;
    h) help
      ;;
    f)
     findinc
      ;;
    \?)
    banner
    echo "Script usage: $(basename $0) [-f] [-w]

  where:
        -h      show this help
        -f      find incomplete releases
        -w      wipe all incomplete releases incl. symlinks.   
" ;;
  esac
done
