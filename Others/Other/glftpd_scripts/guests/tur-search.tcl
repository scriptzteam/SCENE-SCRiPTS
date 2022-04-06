#!/bin/bash
VER=2.1
##MODIFIED By [PD]Raky in order to be made compatible with FBSD##
##contact irc: #partydome@irc.undernet.org##  
#---------------------------------------------------------------------------#
#                                                                           #
# Tur-Search.
# Two small scripts that allow users to do like 'site search' from glftpd   #
# and !search from irc.                                                     #
#                                                                           #
# Yes, glftpd already supports 'site search' but this one has a few tricks. #
# It shows if the release exists on the site still (might be in dirlog but  #
# not on site) and if so, the total size of it.                             #
#                                                                           #
# It also has the ability to create symlinks to each release it finds in a  #
# place you decide, so if the user wants to download a lot of stuff, he/she #
# does not have to read the text and manually enter all dirs. Just tag all  #
# the symlinks and off we go.                                               #
#                                                                           #
# Combine this with Tur-DirLogClean to keep the dirlog nicely updated!!     #
#                                                                           #
#---------------------------------------------------------------------------#
# Installation:                                                             #
#                                                                           #
# Put tur-search in /glftpd/bin                                             #
#                                                                           #
# Put tur-search.tcl in your bots scripts folder and load it in the bots    #
# config file. Rehash the bot and make sure it says that its loading it.    #
#                                                                           #
# Make tur-search.sh executable with chmod 755 tur-search.sh                #
#                                                                           #
# Change the settings below:                                                #
#                                                                           #
# glroot=     The path to your glftpd dir. Usually just /glftpd             #
# dirlog=     The path to your dirlog file, seen from glroot above.         #
#                                                                           #
# stringsirc= The path to the strings binary. This is the strings that will #
#             be executed from irc and/or shell, so use 'which strings' to  #
#             find it and put the path to it here.                          #
#                                                                           #
# stringsgl=  This is the strings binary that will be used when inside      #
#             glftpd.                                                       #
#                                                                           #
#             Now, if you plan to keep using glftpds internal 'site search' #
#             there is no use to set this.                                  #
#             Otherwise, you will need to copy the strings binary to your   #
#             /glftpd/bin dir.                                              #
#             Note that strings require a few libraries. To test which ones #
#             do 'ldd /path/to/strings' from shell. It will show you which  #
#             libraries it needs. Copy all of them to /glftpd/lib.          #
#                                                                           #
#             To test if it works, do this:                                 #
#             chroot /glftpd                                                #
#             cd bin                                                        #
#             ./strings /ftp-data/logs/dirlog                               #
#             It should now spit out a lot of lines containing directories  #
#             and most likely a few lines containing crap (thats ok).       #
#                                                                           #
# maxhitsirc= Maximum number of hits to return when running from irc/shell. #
# maxhitsgl=  Maximum number of hits to return when running from glftpd.    #
#                                                                           #
# minlenght=  Minimum lenght to search for when only searching using one    #
#             argument. Set to "" to disable (not recomended).              #
#                                                                           #
# ignoredirs= Ignore these words in search. Good to add the name of the pre #
#             dirs here. Use /PRE to prevent anything starting with PRE to  #
#             be displayed. Use /PRE/ to match the exact foldername.        #
#             Predirs should not be in the dirlog anyway, but better safe.. #
#             Seperate ignores with a |  ( '/GROUPS/|Animalporn|ost' )      #
#             Any weird chars should be marked with \, ie \[inco            #
#                                                                           #
#             Use a . to define * , ie: CD.                                 #
#             Those familiar with grep can of course use CD[1-9] as well.   #
#                                                                           #
# showsize=   If this is TRUE, it will run 'du -ms' on the dir it finds and #
#             reports its size in MB for every hit.                         #
#                                                                           #
# sitedir=    If the above is TRUE, what is your sitedir? /site as          #
#             default. When doing a search, check the path. This is what    #
#             needs to be before the path for 'du' to find it.              #
#                                                                           #
# symsdir=    If you have it loaded as 'site search' in glftpd and want the #
#             users to be able to create symlinks to their findings, set    #
#             this to a directory inside your /site structure somewhere.    #
#             Once a user specifies --create in their search string, it     #
#             will create a directory with their name in here and put a     #
#             symlink to each hit they get. This is why it only works from  #
#             glftpd. We have to sort them somehow and the username is the  #
#             easiest way. Cant have everyone create symlinks in the same   #
#             directory or it would get ... messy.                          #
#                                                                           #
#             Before starting the search, their own "symlinkdir" will be    #
#             cleaned out, using the unlink binary.                         #
#                                                                           #
#             While the symlinks are cleaned out when the user does a new   #
#             search (if they do not use --noclear as well), their dir is   #
#             not. If might therefor be a nice idea to clear out the        #
#             symsdir once a day or similar.                                #
#             A simple crontab can take care of that. Something like:       #
#             0 0 * * * rm -rf /path/to/symsdir/* >/dev/null 2>&1           #
#             should do fine.                                               #
#                                                                           #
#             Oh yeah, create this dir in shell and set chmod 777 on it.    #
#                                                                           #
#                                                                           #
# Now then, if you wanted to replace it with your current 'site search'     #
# command in glftpd, add this to glftpd.conf:                               #
# site_cmd search EXEC /bin/tur-search.sh                                   #
# custom-search *                                                           #
# Of course, you could also use a different name for it. Just replace       #
# search with whatever you want to call it with.                            #
#                                                                           #
# Important: This script requires the 'unlink' binary to be present in      #
# /glftpd/bin if you want to load it as 'site search' in glftpd and have    #
# symsdir set. I dont trust rm -f to not remove the actual release.         #
# It also requires some standard ones like:                                 #
# grep, egrep, cut, tr, du, sed & tail                                      #
#                                                                           #
# Run tur-search.sh from shell and make sure it works.                      #
# When you test it from the bot you might get an error like "permission     #
# denied /root/.bashrc".                                                    #
# Check the (general) FAQ on the website on how to fix that.                #
#                                                                           #
# For instructions in both irc and glftpd, just run it without any args.    #
#                                                                           #
#---------------------------------------------------------------------------#
# Note to people wondering what the frell I am doing in the for each line.. #
# There is some crap in the dirlog. If you do 'strings dirlog' you will see #
# it. What I do is look for the word 'site' and start there. Then end the   #
# line before the filename. Crude, but it works.                            #
#---------------------------------------------------------------------------#
# http://www.grandis.nu/glftpd/ & http://grandis.mine.nu/glftpd             #
#---------------------------------------------------------------------------#
# Changelog:                                                                #
#                                                                           #
# 2.1   : When checking diskusage (if showsize=true) and it hit a nuked dir #
#         you got a permission denied error - fixed.                        #
#                                                                           #
#         If it hit an entry in the dirlog with a tab in it, it would halt  #
#         - fixed.                                                          #
#-                                                                         -#
# 2.0   : Pretty much rewritten from scratch.                               #
#                                                                           #
#         * Renamed from tur-botsearch to tur-search since it now works     #
#           from inside glftpd as well.                                     #
#                                                                           #
#         * Changed how the search works. You can now specify how many      #
#           arguments as you want to search. It should also be quite a bit  #
#           faster.                                                         #
#           The drawback to this is that the order of the words must match  #
#           the order they appear in the release.                           #
#           I guess some people see this as a good thing, as long as you    #
#           know about it.                                                  #
#           Its described in the help for the script.                       #
#                                                                           #
#         * Added a neat option. If you load this as 'site search' in       #
#           glftpd, you can have it create symlinks to each result it gets  #
#           into a predefined directory. This is GREAT when searcing for    #
#           lots of stuff you want to download as the user can just go into #
#           the symlinkdir and tag the releases for download without having #
#           to manually enter each dir, go one step up and then download    #
#           it one by one.                                                  #
#                                                                           #
#           Make sure you read through the installation instructions again  #
#           as it changed quite a bit as well as running it without args    #
#           to get usage instructions on --create and --noclear             #
#                                                                           #
#           The above idea was suggested by m0n. Good one =)                #
#                                                                           #
# People upgrading from old tur-botsearch will need to replace the tcl as   #
# well. Notice that its tur-search.tcl instead of tur-botsearch.tcl so edit #
# your bots config file to reflect that and dont forget to .rehash          #
#                                                                           #
#-                                                                         -#
# 1.4   : Will work with releases and sections with spaces in them now.     #
#         Will use ~ as a tempchar for space, so if you have dirs with ~ in #
#         them, they will be a space in search. Just search for '~' and     #
#         change that to some other char you dont use if you dont like it.  #
#         Thanks liquid- for testing it for me.                             #
#                                                                           #
# 1.3   : When using 3 arguments, it first searched on 2, then again with   #
#         3, making it take double the time to finish.                      #
#                                                                           #
#         Added options showsize and sitedir. Check explanation above.      #
#         This will return MB value of release. If it is not found, it will #
#         say '-> Deleted?'. If it was found, but couldnt check size of it, #
#         size will be set to '?'.                                          #
#         There are some explanation texts down in the script if you want   #
#         to change the text.                                               #
#                                                                           #
#         Expanded it to allow 5 search words instead of just 3. REPLACE    #
#         the TCL if you want to use this.                                  #
#                                                                           #
#         In 'ignoredirs' you can use '.' as '*'                            #
#         So... replaced all CD1 etc with CD.                               #
#                                                                           #
#         A oneliner telling the user what he searched on is echoed as a    #
#         header for each search.                                           #
#                                                                           #
#         Added check that first arg is not a *. Could hang the bot.        #
#                                                                           #
# 1.2   : Search may now start with -                                       #
# 1.1   : Ignoredirs are no longer case sensitive. Also added a few extra   #
#         to the default so you wont get those pesky CD1 CD2 etc etc.       #
#         Remember to escape any non "normal" chars (whatever their names   #
#         are). IE [incomplete] = \[incomplete\]                            #
#    Upg: change all lines with contains:                                   #
#         egrep -v $ignoredirs to egrep -vi $ignoredirs                     #
#         Paste the new ignoredirs into your old script.                    #
#         Update the version at the top to 1.1 =))                          #
#                                                                           #
# 1.0   : First public version.                                             #
#---------------------------------------------------------------------------#

#USER=Raky

glroot=/backup/glftpd

dirlog=/ftp-data/logs/dirlog
stringsirc=/usr/bin/strings
stringsgl=/bin/gl.strings
maxhitsirc=15
maxhitsgl=500

minlenght=""
ignoredirs='/sample|/PRE/|/GROUPS/|/CD[1-9]|/Sample|\[incomplete\]'

showsize=TRUE
sitedir=/site

symsdir="/site/NiA.Community/Search_Links"


#############################################################################
# Change everything below here. Naaah kidding. Dont change a thing.         #
#############################################################################

## In glftpd or not ?
if [ "$FLAGS" ]; then
  mode="gl"
  strings="$stringsgl"  
  unlinkbin="/bin/unlink"
  maxhits="$maxhitsgl"
else
  mode="irc"
  strings="$stringsirc"
  maxhits="$maxhitsirc"
  dirlog="$glroot$dirlog"
  sitedir="$glroot$sitedir"
fi

## Show help if no arguments.
if [ -z "$1" ] || [ "$1" = "help" ] && [ -z "$2" ]; then
  echo "Tur-Search $VER by Turranius. Used for searching on the site."
  echo ""
  echo "Usage: Enter a whole release or part of it. When searching for more"
  echo "then one word, make sure that the order is correct."
  echo "Searching for 'active directory' will show releases containing"
  echo "'Bla.Bla.Active.Directory-' but not 'Bla.Bla.Directory.Active-'"
  echo ""
  echo "As first argument, you can select part of the path it should be in."
  echo "For example, searching on '0DAY Active Directory' will only return hits"
  echo "if the path it is in contains the word 0DAY."

  if [ "$symsdir" ] && [ "$mode" = "gl" ]; then
    echo ""
    echo "If you want to create symlinks (shortcuts) to each release you find"
    echo "then also enter --create as one of your search arguments."
    echo "Once the search has been completed, it will tell you where your"
    echo "symlinks are for easy downloading."
    echo ""
    echo "Each time you do a new search, the symlinks will be cleared unless you"
    echo "also specify --noclear as an argument. All \"old\" symlinks will then"
    echo "remain between searches."
  fi

  echo ""
  echo "Only $maxhits hits will be shown."
  exit 0
fi

## Set this one incase we destroy it (we will from irc).
symsdirorg="$symsdir"


## Check that first arg isnt *. Probably not needed but cant hurt.
if [ "$1" = '*' ]; then
  echo "No go on that on bud."
  exit 0
fi

## Check if we can read dirlog. Rather.. if we cant.
if [ ! -r $dirlog ]; then
  echo "Cant read from dirlog. Ask siteops to fix path and/or perms."
  exit 0
fi

## Check if strings exists
if [ ! -x $strings ]; then
  echo "Strings is not executable or does not exist."
  exit 0
fi

FULL_COMMAND=" $@ "

if [ "`echo "$FULL_COMMAND" | grep -i "\ --create\ "`" ]; then
  if [ "`echo "$FULL_COMMAND" | grep -i "\ --noclear\ "`" ]; then
    NOCLEAR="TRUE"
  fi
  if [ "$mode" = "irc" ]; then
    echo "Error: --create only works from inside glftpd. Aborting."
    exit 0
  fi
  if [ "$symsdir" ]; then
    if [ ! -d "$symsdir" ]; then
      echo "Symlink dir $symsdir does not exist. Skipping creation of symlinks."
    else
      if [ ! -e "$unlinkbin" ]; then
        echo "Error. Cant create symlinks because the binary 'unlink' does not exist."
        echo "Make sure it exists in glftpd /bin dir and is executable by all."
      else
        CREATE_LINKS="TRUE"
        if [ -d "$symsdir/$USER" ]; then
          if [ "$NOCLEAR" = "TRUE" ]; then
            echo "Creating symlinks for found releases. --noclean specified so not removing old ones."
          else
            echo "Creating symlinks for found releases. Trying to clear out any old ones."
            echo "Use --noclear as well to not remove previous symlinks."
            echo ""
            for oldsym in `ls -1 "$symsdir/$USER"`; do
              unlink "$symsdir/$USER/$oldsym"
            done
          fi
        fi
      fi
    fi
  else
    echo "Creation of symlinks is not enabled. Skipping --create"
  fi
  FULL_COMMAND="`echo "$FULL_COMMAND" | sed -e 's/\-\-[cC][rR][eE][aA][tT][eE]//g' | sed -e 's/\-\-[nN][oO][cC][lL][eE][aA][rR]//g'`"
else
  if [ "$mode" = "gl" ] && [ "$symsdir" ]; then
    echo ""
    echo "Note that you can use --create somewhere in your search and symlinks (shortcuts)"
    echo "will be created to each hit you get, for easy downloading."
    echo "Run again without any arguments for full help."
    echo ""
  fi
fi    

if [ "`echo "$FULL_COMMAND" | grep -i "\ --noclear\ "`" ]; then
  echo "Error. Cant use --noclear without --create"
  exit 0
fi

## Clean it up a bit (remove excess spaces).
FULL_COMMAND="`echo $FULL_COMMAND | tr -s ' '`"

## Make sure grep line based on arguments.
for command in $FULL_COMMAND; do
  if [ -z "$SEARCH_STRING" ]; then
    first_command="$command"
    SEARCH_STRING="$command"
    TEXT="containing $command"
  else
    TEXT="$TEXT & $command"
    last_command="$command"
    SEARCH_STRING="$SEARCH_STRING.*$command"
  fi
done

## Some debug stuff
# echo "Full command: $FULL_COMMAND"
# echo "Create_links: $CREATE_LINKS"
# echo "Search string: $SEARCH_STRING"
# echo "Mode: $mode"
# echo "-------------"

## Complain if lenght is too short (size dosnt matter!).
if [ "$minlenght" ] && [ -z "$last_command" ]; then
  if [ `echo "$first_command" | wc -l | tr -d ' '` -lt "$minlenght" ]; then
    echo "Search must be a minumum of $minlenght chars with only one argument."
    exit 0
  fi
fi

## Make a lame fix incase ignoredirs are empty.
if [ "$ignoredirs" = "" ]; then
  ignoredirs="kJEFKLejJd3jd"
fi

## Echo header.
if [ "$last_command" ]; then
  echo "Starting search for releases $TEXT, in that order!"
else
  echo "Starting search for releases $TEXT"
fi

LIST="$( $strings $dirlog | grep -i -- "$SEARCH_STRING" | egrep -vi "$ignoredirs" | tr -d '\t' | tr ' ' '~' | tail -n $maxhits )"

## Fix each entry as they contain C.R.A.P otherwise.
num="0"
for each in $LIST; do
  gotone="yes"
  num=$[$num+1]
  end="`basename $each`"

  for part in `echo $each | tr -s '/' ' '`; do
    if [ "$go" = "yepp" ]; then
      if [ -z "$rel" ]; then
        rel="/$part"
      else
        rel="$rel/$part"
      fi
    fi
    if [ "$part" = "site" ]; then
      go="yepp"
      unset rel
    fi
    if [ "$end" = "$each" ]; then
      unset go
    fi
  done
  if [ "$showsize" = "TRUE" ]; then
    checkdir="`echo "$sitedir$rel" | tr '~' ' '`"
    if [ ! -e "$checkdir" ]; then

      ## If the dir was not found at all, say this.
      echo "$rel -> Deleted?" | tr '~' ' '

    else
      unset size
      size=`du -hc "$checkdir" > /backup/glftpd/bin/sizecheck`
      size=`tail -n1 /backup/glftpd/bin/sizecheck | awk '{print $1}'`
      if [ -z "$size" ]; then
  
        ## IF size was not found for some reason, size will be set to this.
        size="?"
      fi

      ## This is what it says when reporting size.
      echo "$rel -> $size" | tr '~' ' '
      SYMLINK="/site$rel"
      RELEASENAME="$end"
    fi

  else

    ## showsize is not TRUE. Just echo release path.
    echo "$rel" | tr '~' ' '
    SYMLINK="/site$rel"
    RELEASENAME="$end"

  fi

  ## Create symlink
  if [ "$CREATE_LINKS" = "TRUE" ] && [ "$SYMLINK" ]; then
    if [ ! -d "$symsdir/$USER" ]; then
      mkdir -m777 "$symsdir/$USER"
    fi
    if [ -z "`ls -al "$symsdir/$USER" | grep "^l" | grep "\ $RELEASENAME"`" ]; then
      ln -f -s "$SYMLINK" "$symsdir/$USER/$RELEASENAME"
    else
      echo "-- Symlink already exists for $RELEASENAME"
    fi
    unset SYMLINK
    SYM_CREATED="TRUE"
  fi

  ## If the user reached maximum allowed hits.
  if [ "$num" = "$maxhits" ]; then
    MAX="yes"
    break
  fi
done


if [ "$SYM_CREATED" ] && [ "$gotone" = "yes" ]; then
  symnice="`echo "$symsdirorg" | sed -e 's/\/site//'`"
  echo ""
  echo "-- You will find symlinks to your findings in $symnice/$USER"
  echo ""
fi

## No hits? Say this.
if [ "$gotone" != "yes" ];then
  echo "0 Results Returned"
  if [ "$last_command" ]; then
    echo "NOTE: The search words must be in the same order as they appear in the release."
  fi
else

  ## If only one hit was found.
  if [ "$num" = "1" ]; then
    echo "$num hit found."

  ## If more then one hit was found.
  else
    if [ "$MAX" = "yes" ]; then
      echo "Maximum $maxhits returned. Be more specific!."
    else
      echo "$num hits found."
    fi
  fi
fi

exit 0
