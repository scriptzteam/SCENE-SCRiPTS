## Made by NiDO 2002 (nido@euromail.se)
##
## This is a TCL frontend for Getnfo by PnG
## Allows ppl on sitechans to search for information about a movíe in the IMDB Database (us.imdb.com)
##
## Ex:
## user !imdb The Matrix
## sitebot [sitename] [IMDB] Searching IMDB for 'The Matrix' ... Please hold.
## sitebot [sitename] [IMDB] - Info on: Matrix, The (1999) (Directed by: Andy Wachowski Genre: Action Rating: 8.5 / 10) url: http://us.imdb.com/Title?The%20Matrix
## sitebot [sitename] [IMDB] Plot: A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against the controllers of it.
## sitebot [sitename] [IMDB] business: Sorry, no business results available
##
##(Join #getnfoscript on efnet for help)
##
## (Getnfo Crew : PnG , NiDO . ebzoner)
##
## Greets to Dark0n3


######################### CONFIGURATION  ##########################


## Sets the name of your site ##

set sname "SITENAME"

## Sets the path where getnfo.pl is located ##

set getnfopath "/glftpd/bin"

## Sets the path where imdburl.log is located ##

set imdburllog "/glftpd/ftp-data/logs"

## Limit access to users that are added in the bot TRUE/FALSE ##

set limitedaccess "FALSE"

## Sets valid flag for added users to use !imdb command (Does not work if limitedaccess are set to FALSE) ##
## Hint! . create a new flag in the bot for users that u want to be able to use the script for example +S  ##

set flag "o"

## Sets the command to use the bot (DEAFULT !imdb <Movie name>

set runcmd "!imdb"


###################################################################
#                                                                 #
#     Don't edit below unless you know what you are doing         #
#                                                                 #
###################################################################

set imdbtclver "2.0 Getnfo Runner"
bind pub - $runcmd imdb
bind pub - !imdbstatus imdbstatus

proc b {} {return \002};   

proc imdb {nick uhost hand chan args} {global getnfopath sname flag limitedaccess runcmd
if {$limitedaccess == "TRUE"} {
if {[matchattr $hand $flag|$flag $chan]} {
        set imdb [lindex $args 0]
        putlog "Chan : $chan , Nick : $nick Makes a IMDB Request on $imdb"
        if {$imdb == ""} {
                putserv "PRIVMSG $chan :$nick: Usage $runcmd <Movie Name>"
                return 0
        }
                putserv "PRIVMSG $chan :[b]\[$sname\][b] [b]\[IMDB\][b] Searching IMDB for '$imdb' ... Please Hold."

                set getimdb [exec -- perl $getnfopath/getnfo.pl -f $imdb]
                foreach line [split $getimdb "\n"] {

                putserv "PRIVMSG $chan :[b]\[$sname\][b] [b]\[IMDB\][b] $line"
        }
                return 0
        }

                putserv "PRIVMSG $chan :$nick: Access Denied ! Only Users With Flag +$flag Are Allowed To Use This Command"
                return 0
        } 

set imdb [lindex $args 0]
putlog "Chan : $chan , Nick : $nick Makes a IMDB Request on $imdb"
if {$imdb == ""} {
                putserv "PRIVMSG $chan :$nick: Usage $runcmd <Movie name>"
                return 0
        }
                putserv "PRIVMSG $chan :[b]\[$sname\][b] [b]\[IMDB\][b] Searching IMDB for '$imdb' ... Please hold."

                set getimdb [exec -- perl $getnfopath/getnfo.pl -f $imdb]
                foreach line [split $getimdb "\n"] {

                putserv "PRIVMSG $chan :[b]\[$sname\][b] [b]\[IMDB\][b] $line"
        }
                return 0
        }

putlog "-> Succesfully Loaded getnfo IMDB Searcher TCL frontend a Part of zipscript-c (By Getnfo Crew)"

proc imdbstatus {nick uhost hand chan args} {global getnfopath sname flag limitedaccess runcmd imdbtclver imdburllog
putserv "PRIVMSG $chan :\[IMDB STATUS]\: Getnfo IMDB TCL Frontend Version $imdbtclver "
putserv "PRIVMSG $chan :\[IMDB STATUS]\: Sitename Is Set To: $sname"
putserv "PRIVMSG $chan :\[IMDB STATUS]\: Execution Command Set To: $runcmd"
putserv "PRIVMSG $chan :\[IMDB STATUS]\: Getnfo.pl Is Located in $getnfopath"
putserv "PRIVMSG $chan :\[IMDB STATUS]\: imdburl.log Is Located in $imdburllog"
putserv "PRIVMSG $chan :\[IMDB STATUS]\: Limited Access = $limitedaccess"
if {$limitedaccess == "TRUE"} {
putserv "PRIVMSG $chan :\[IMDB STATUS]\: Flag For Limited Access Is: +$flag"  
return 0
       }
return 0
       }

set chktimer 1
set oct [file size $imdburllog]
proc runimdb {} {global imdburllog chktimer oct getnfopath
  utimer $chktimer "runimdb"
  if {[file size $imdburllog/imdburl.log ] == $oct} {return 0}
  if {[file size $imdburllog/imdburl.log ] < $oct} {set oct 0}
  if {[catch {set of [open $imdburllog/imdburl.log  r]}] != 0} {return 0}
  seek $of $oct
  while {![eof $of]} {
    set gline [gets $of]
    if {$gline == ""} {continue}
    set logtype [lindex $gline 0]
    switch $logtype {
      IMDB: {
        putlog "Running Getnfo ,Scanning IMDB"
        exec -- perl $getnfopath/getnfo.pl
       }}}
  close $of

  set oct [file size $imdburllog/imdburl.log ]
       }

if {[lsearch [utimers] "* runimdb *"] == -1} {
  utimer $chktimer "runimdb"
       }

putlog "-> Succesfully Loaded Getnfo TCL Runner (By Getnfo Crew)"




### END OF SCRIPT ###
