#/bin/sh

# slv-links 20170701 silver
# searches paths with daydirs (0day/pda/mp3/mv) for matching dirs to create symlinks

GLDIR="/jail/glftpd"
LNDIR="$GLDIR/site/archive/pda/_phone_all_"
LNSED="../.."   # replace /site/$path so we create relative links

PATHS="
$GLDIR/site/0day
$GLDIR/site/archive/0day
$GLDIR/site/pda
$GLDIR/site/archive/pda
"
# globs only here, no real regex. replace ls with find or smth if you rly need it
SEARCH="
[iI][iP][hH][oO][nN][eE]
[aA][nN][dD][rR][oO][iI][dD]
"

#DEBUG=1
find $LNDIR/ -type l -delete 2>/dev/null
for p in $PATHS; do
  for s in $SEARCH; do
    for r in $( ls -d ${p}/*/*${s}* | sed -e '/^(\(incomplete\|no-nfo\|no-sfv\|no-sample\))-/d' ); do
      lt="$( echo $r | sed s@${GLDIR}/site@${LNSED}@g )"
      ln="$LNDIR/$( basename $r )"
      if [ ! -L "$ln" ]; then
        if [ $DEBUG ]; then echo DEBUG: ln -n -s $lt $ln; else ln -n -s $lt $ln; fi
      else
        echo "INFO: link $ln already exists for $lt"
      fi
    r=""; lt=""; ln=""
    done
  done
done

