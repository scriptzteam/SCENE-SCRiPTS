#!/bin/sh

# pre_check script for "Proof" directories
# by HugoBozz

# $1 = Name of file.
# $2 = Actual path the file is stored in
# $PWD = Current Path.
 
MYPATH=`echo $2 | tr '[:upper:]' '[:lower:]'`
LASTDIR=`echo $MYPATH | rev | cut -d/ -f1 | rev`
if [ "$LASTDIR" = "proof" ]; then
  MYEXT=`echo $1 | rev | cut -d. -f1 | rev | tr '[:upper:]' '[:lower:]'`
  if [ "$MYEXT" != "jpg" ]; then
    echo "PROOF-DIR, BUT RECEIVED SOMETHING ELSE THAN A .JPG, exitting..."
    exit 2
  else
    echo "PROOF-DIR. Received a .JPG"
  fi
fi
 
exit 0