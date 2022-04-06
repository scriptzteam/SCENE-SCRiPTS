#!/bin/bash
VER=1.0
#-------------------------------------------------#
# PreNuke by Turranius.                           #
# Small script that prevents nukers from          #
# nuking things that has been allowed.            #
#-------------------------------------------------#
# Install:                                        #
# Copy prenuke.sh to /glftpd/bin                  #
# Change the setting below to what not to         #
# nuke if it contains these folders or files.     #
# You can add how many folders/files as you like. #
# They are case sensitive cause I am lazy.        #
#                                                 #
# Add to glftpd.conf:                             #
# cscript SITE[:space:]NUKE   PRE /bin/prenuke.sh #
#                                                 #
# Requires echo and cut to be in /glftpd/bin      #
#-------------------------------------------------#
# Contact:                                        #
# http://www.grandis.nu/glftpd                    #
# http://grandis.mine.nu/glftpd                   #
# Turranius on Efnet. Usually in #glftpd          #
#-------------------------------------------------#


ALLOW="Allowed allowed ALLOWED"

###################################################

REL="$( echo $1 | cut -d' ' -f3 )"
if [ "$REL" ]; then
  for word in $ALLOW; do
    if [ -e "$REL/$word" ]; then
      echo -e "500This release has been allowed. Cant nuke.\r"
      exit 1
    fi
  done
fi
