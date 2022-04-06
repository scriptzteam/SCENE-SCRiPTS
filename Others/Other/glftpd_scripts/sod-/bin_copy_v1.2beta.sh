#!/bin/bash

################################################################################
# Script name:  bin_copy_v1.2beta.sh                                           #
# Author:       SoD                                                            #
# Contact:      SoD- @ EFNet                                                   #
# Releasedate:  2002-08-15                                                     #
#                                                                              #
# This script copies a bunch of sometimes needed binaries to glftpd's bin-dir  #
# and chmods them to 755. It also copies the libs that are needed for the      #
# binaries. Add any binaries of your choice to the list if you want them       #
# installed.                                                                   #
#                                                                              #
# Installation: -Just execute this script as root and give the path to your    #
#                glftpd-dir as argument.                                       #
#                                                                              #
# Requirements: Root access to the computer.                                   #
#                                                                              #
# Changelog:    v1.0 -> v1.1beta:    Nescessary libs are now also copied.      #
#               Changes in settings: None.                                     #
#               v1.1beta -> v1.2beta:Noticed that glftpd doesn't use           #
#                                    /glftpd/usr/lib/ anymore so now this      #
#                                    script puts all libs in /glftpd/lib/.     #
#               Changes in settings: None.                                     #
################################################################################

BINARIES="awk bash basename chmod chown cat cp cut date df diff dirname du echo 
expand expr fgrep find grep gzip head kill ldconfig ln ls mkdir more mount mv 
rm rmdir sed sh sleep tail touch tr unzip wc zip"

if [ $UID != 0 ]; then
  echo "You need to be root to execute this script."
  exit 1
fi
if [ -z $1 ]; then
  echo ".-----------------------------------------------------------------."
  echo "| This script copies bins and their libs to glftpd's bin-/libdir. |"
  echo "|                                                                 |"
  echo "| Usage:   bin_copy_v1.2beta.sh <path to the glftpd dir>          |"
  echo "| Example: ./bin_copy_v1.2beta.sh /glftpd/                        |"
  echo "'-----------------------------------------------------------------'"
  exit
fi

# Make shure that the glftpd-dir exists
if [ ! -d $1 ]; then
  echo "The directory \"$1\" can't be found."
  exit 1
fi

# Make shure that the path ends with a frontslash
if [ "`echo $1 | grep -E "/$"`" ]; then
  PATHH=$1
else
  PATHH=`echo \`echo $1\`\`echo "/"\``
fi

# Check if the glftpd bin is located in $PATH/bin/
if [ ! -f ""$PATHH"bin/glftpd" ]; then
  echo "The glftpd binary can't be found in \"$PATHH"bin/"\"."
  exit 1
fi

for BINARY in $BINARIES; do
  if [ ! -f ""$PATHH"bin/$BINARY" ]; then
    if [ ! "`whereis -b $BINARY | awk '{print $2}'`" ]; then
      echo "Couldnt find the binary \"$BINARY\" on computer. Copy it manually."
    else
      echo "Copying `whereis -b $BINARY | awk '{print $2}'` to "$PATHH"bin/"
      cp `whereis -b $BINARY | awk '{print $2}'` ""$PATHH"bin/"
      chmod 755 ""$PATHH"bin/$BINARY"

      # Make a list of needed libs for $BINARY
      LIBS=`ldd \`whereis -b $BINARY | awk '{print $2}'\` | awk '{print $3}'`

      # Are any libs needed?
      if [ "$LIBS" ]; then
        for LIB in $LIBS; do
          if [ `echo $LIB | cut -c 1 | grep "/"` ]; then
            echo "Copying $LIB to "$PATHH"lib/ (needed by $BINARY)"
            cp "$LIB" ""$PATHH"lib/"
            chmod 755 ""$PATHH"lib/`basename "$LIB"`"
          fi
        done
      fi
    fi
  fi
done
