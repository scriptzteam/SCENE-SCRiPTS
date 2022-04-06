#!/bin/bash

fname="$@"

case $fname in
 !*) link=`rm -f $fname` ;;
 [*) link=`rm -f $fname` ;;
esac
