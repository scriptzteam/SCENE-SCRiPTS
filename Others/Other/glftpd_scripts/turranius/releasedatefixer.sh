#!/bin/bash

# This script is 100% unsupported. Some parts stolen of course

# Define the sections too look for folders including nfos.
# Define any excluded folders you do not want touched.
# Run it with the argument debug to see what it does.
# You may also specify the section directly after the script name,
# thus overriding the sections setup (if you just want to run it on
# one dir once or something).
# Debug works as a second argument too, if defining the section from
# shell.
# To exclude words in nfo, change this line: grep -v 'DVD|Theatre'
# Be adviced, if DVD is on the same line as the real release date,
# it will not be found.
#
# If date can not be found, it will not touch the folder.

sections="
/glftpd/site/Archive/DIVX/DIVX1
/glftpd/site/Archive/DIVX/DIVX2
/glftpd/site/Archive/DIVX/DIVX3
/glftpd/site/Archive/DIVX/DIVX4
/glftpd/site/Archive/DIVX/DIVX5
/glftpd/site/Archive/DIVX/DIVX6
/glftpd/site/Archive/DIVX/DIVX7
/glftpd/site/Archive/SVCD/SVCD1
/glftpd/site/Archive/SVCD/SVCD2
/glftpd/site/Archive/SVCD/SVCD3
/glftpd/site/Archive/SVCD/SVCD4
"

exclude='GROUPS|lost\+found'

shownfo="FALSE"

#########################################################

proc_readnfo( ) {

head -80 $nfo | grep -Ei "(rip|release|day|date|d.a.t.e|[0-9]{2}/[0-9]{2}|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)" | egrep -v 'DVD|Theatre|Theatrical|STORE|Retail|Premiere|Theater' |	grep -Ei "(\b([0-9]{1,4}|[a-z]{3})[-/:.]([0-9]{1,4}|[a-z]{3})[-/:.]([0-9]{1,4}|[a-z]{3}\b)|date|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)" | tr -c -d -- '-\.:[:alnum:]/ \012' |	tr -s '[:space:].' | sed 's/[jJ][aA][nN][a-zA-Z]*/01/g;
 s/[fF][eE][bB][a-zA-Z]*/02/g;
 s/[mM][aA][rR][a-zA-Z]*/03/g;
 s/[aA][pP][rR][a-zA-Z]*/04/g;
 s/[mM][aA][yY][a-zA-Z]*/05/g;
 s/[jJ][uU][nN][a-zA-Z]*/06/g;
 s/[jJ][uU][lL][a-zA-Z]*/07/g;
 s/[aA][uU][gG][a-zA-Z]*/08/g;
 s/[sS][eE][pP][a-zA-Z]*/09/g;
 s/[oO][cC][tT][a-zA-Z]*/10/g;
 s/[nN][oO][vV][a-zA-Z]*/11/g;
 s/[dD][eE][cC][a-zA-Z]*/12/g;' |
while read line; do
case $line in
  *[rR][iI][pP]*)
    case $line in
      *[dD][aA][tT][eE]*|*[dD]?[aA]?[tT]?[eE]*)
        score=9
        ;;
      *)
        score=8
        ;;
    esac		
    ;;
  *[rR][eE][lL][eE][aA][sS][eE]*)
    case $line in
      *[dD][aA][tT][eE]*|*[dD]?[aA]?[tT]?[eE]*)
        score=7
        ;;
      *)
        score=6
        ;;
    esac		
    ;;
  *[sS][tT][rR][eE][eE][tT]*)
    score=1
    ;;
  *[dD][aA][tT][eE]*|*[dD]?[aA]?[tT]?[eE]*)
    score=5
    ;;
  *[0-9][0-9][-/][0-9][0-9][-/][0-9][0-9]*)
    score=4
    ;;
  *200[0123]*|19[89][0-9]*)
    score=3
    ;;
  *[0-9][0-9][0-9][0-9]*)
    score=2
    ;;
  *)
    score=0
    ;;
esac

date="$(echo "$line" | sed 's/\([^0-9]\)\([0-9][^0-9]\)/\10\2/g;
s/\([0-9]\)[-/. a-z]\{1,3\}\([0-9]\)/\1\2/g;
s/^.*[^0-9]\([0-9]\{6,8\}\)[^0-9]\{0,1\}.*$/\1/;' )"

case $date in
  ????[4-9][0-9])
    year="19${date#????}"
    monthday="${date%??}"
    ;;
  [4-9][0-9]????)
    year="19${date%????}"
    monthday="${date#??}"
    ;;
  19[2-9][0-9]????)
    year="${date%????}"
    monthday="${date#????}"
    ;;
  ????19[2-9][0-9])
    year="${date#????}"
    monthday="${date%????}"
    ;;
  ????0[0123])
    year="20${date#????}"
    monthday="${date%??}"
    ;;
  [0123]????)
    year="20${date%????}"
    monthday="${date#??}"
    ;;
  ????200[0-5])
    year="${date#????}"
    monthday="${date%????}"
    ;;
  200[0-5]????)
    year="${date%????}"
    monthday="${date#????}"
    ;;
  *)
    year="0000"
    monthday="0000"
    ;;
esac

month="${monthday%??}"
day="${monthday#??}"
[ "$month" -gt "12" ] && { tmp=$month; month=$day; day=$tmp; unset tmp; }
       echo "$year$month$day"
done |
sort -rn |
head -1 |
while read dateline; do
  date="$(echo "$dateline" | cut -f2 -d ' ')"
  if [ "$date" != "00000000" -a "$release" != "" ]; then
    if [ "$debug" = "yes" ]; then
      if [ "$shownfo" = "TRUE" ]; then
        echo -e $date $release == `basename $nfo`
      else
        echo -e "$date $release"
      fi
    fi

    verify="$( echo $date | cut -b1-4 )"
    if [ "$verify" -lt "1997" -o "$verify" = "0000" ]; then
      if [ "$debug" = "yes" ]; then
        echo "Illegal year here ( $verify ?? ). Must have read the wrong thing."
      fi
      go=no
    fi

    verify="$( echo $date | cut -b5-6 )"
    if [ "$verify" -gt "12" -o "$verify" = "00" ]; then
      if [ "$debug" = "yes" -a "$go" != "no" ]; then
        echo "Illegal month here ( $verify ?? )"
      fi
      go=no
    fi

    verify="$( echo $date | cut -b7-8 )"
    if [ "$verify" -gt "31" -o "$verify" = "00" ]; then
      if [ "$debug" = "yes" -a "$go" != "no" ]; then
        echo "Illegal date here ( $verify ?? )"
      fi
      go=no
    fi

    if [ "$go" != "no" ]; then
      touch -t $date"0000" $release
    fi
  fi
done
}

if [ "$1" = "debug" ]; then
  debug="yes"
fi

if [ "$1" != "" -a "$1" != "debug" ]; then
  sections="$1"
  if [ "$2" = "debug" ]; then
    debug="yes"
  fi
fi

for section in $sections; do
  if [ ! -e "$section" ]; then
    echo "Section $section does not exist. Skipping it."
  else
    cd $section
    for release in `ls -A | egrep -vi $exclude`;do
      go=yes

      nfo="$( ls $release/*.nfo $release/*/*.nfo 2>/dev/null | head -1 )"
      if [ "$nfo" = "" ]; then
        if [ "$debug" = "yes" ]; then
          echo "$release - No NFO found"
        fi
      else
        proc_readnfo
      fi
	
    done
  fi
done




