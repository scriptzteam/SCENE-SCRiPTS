#!/bin/sh

# ngbot changes 20161216 slv
# run this before you update your sitebot so you know what changed

# set this to where you git cloned pzs-ng
SRCDIR="/jail/workspace/pzs-ng/sitebot"

# location of ngbot
SITEBOTDIR="/jail/glftpd/sitebot/pzs-ng"

RESET='\033[0m'
WHITEB='\033[97;1m'
WHITEBU='\033[97;1;4m'

func_colordiff() {
  diff -s -u0 $1 $2 | sed 's/^-/\x1b[31m-/;s/^+/\x1b[32m+/;s/^@/\x1b[34m@/;s/$/\x1b[0m/'
}
cd "$SRCDIR" && (
  printf "${WHITEBU}* git log...${RESET}\n"
  git --no-pager whatchanged @{1}.. --color
  echo
  printf "${WHITEBU}* diff files in $SRCDIR and $SITEBOTDIR...${RESET}\n"
  printf "${WHITEB}ngBot.tcl:${RESET}\n"
  func_colordiff $SITEBOTDIR/ngBot.tcl $SRCDIR/ngBot.tcl
  echo
  for i in modules plugins themes; do
    printf "${WHITEBU}* diff files in \"$i\" dir...${RESET}\n"
    cd $i && ( for j in *; do
      printf "${WHITEB}$j:${RESET}\n"
      func_colordiff $SITEBOTDIR/$i/$j $SRCDIR/$i/$j
      echo
    done ) && cd ..
  done
) | less -R -X
