#!/bin/bash

echo "psxc's revamped cleaner"
echo ""
for file in * ; do
 if [ ! -e "$file" ] ; then
  echo "Removing $file..."
  unlink "$file"
 fi
 if [ -d "$file" ]; then
   for underfile in $file/* ; do
     if [ ! -e "$underfile" ] ; then
       echo "Removing $underfile..."
       unlink "$underfile"
     fi
   done
 else
   dupe="1"
 fi
done

