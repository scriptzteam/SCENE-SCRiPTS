##############################################################################
# Tur-Request.tcl 1.7 by Turranius                                           #
# Use this tcl if you have AUTH_SYSTEM=TRUE set in tur-request.conf          #
# Change triggers below to whatever you want the trigger the script with.    #
# If tur-request.sh is not located in /glftpd/bin/ then change the path      #
# in 'set turrequestscript' below.                                           #
# pub = Open channel. msg = Priv msg to bot.                                 #
##############################################################################

set turrequestscript {/glftpd/bin/tur-request.sh}

bind pub -|- !request pub:turrequests
bind msg -|- !request msg:turrequests

bind pub -|- !reqfilled pub:turreqfilled
bind msg -|- !reqfilled msg:turreqfilled

bind pub -|- !requests pub:turrequeststatus
bind msg -|- !requests msg:turrequeststatus

bind pub -|- !reqdel pub:turrequestdel
bind msg -|- !reqdel msg:turrequestdel

bind pub -|- !reqwipe pub:turrequestwipe
bind msg -|- !reqwipe msg:turrequestwipe


##############################################################################

## Help text for !request
proc pub:turrequests {nick uhost handle chan text} {
 global botnick
 puthelp "PRIVMSG $chan :Usage: /msg $botnick !request <username> <password> <request> <-hide> <-for:<username>>"
 puthelp "PRIVMSG $chan :-hide is used to not announce. -for:<username> can be used when requesting for someone else."
 puthelp "PRIVMSG $chan :Example: /msg $botnick !request ostuser 3j398j Some_Release_from_1999-OstGroup"
}

## Help text for !reqwipe
proc pub:turrequestwipe {nick uhost handle chan text} {
 global botnick
 puthelp "PRIVMSG $chan :Usage: /msg $botnick !reqwipe <username> <password> <number/reqname> <-hide>"
 puthelp "PRIVMSG $chan :Example: /msg $botnick !reqwipe ostuser 3j398j Some_Release_from_1999-OstGroup"
}

## Help text for !reqdel
proc pub:turrequestdel {nick uhost handle chan text} {
 global botnick
 puthelp "PRIVMSG $chan :Usage: /msg $botnick !reqdel <username> <password> <number/reqname> <-hide>"
 puthelp "PRIVMSG $chan :Example: /msg $botnick !reqdel ostuser 3j398j Some_Release_from_1999-OstGroup"
}

## The code for !request
proc msg:turrequests { nick host hand text } {
 global turrequestscript
 foreach line [split [exec $turrequestscript request $nick $text] "\n"] {
      putquick "PRIVMSG $nick :$line"
 }
}

## The code for !reqfilled in open chan
proc pub:turreqfilled {nick uhost handle chan arg} {
 global turrequestscript
    foreach line [split [exec $turrequestscript reqfilled $nick $arg] "\n"] {
      putquick "PRIVMSG $chan :$line"
    }
}

## The code for !reqfilled in private message.
proc msg:turreqfilled { nick host hand arg } {
 global turrequestscript
    foreach line [split [exec $turrequestscript reqfilled $nick $arg] "\n"] {
      putquick "PRIVMSG $nick :$line"
    }
}

## The code for !requests in open chan
proc pub:turrequeststatus {nick uhost handle chan text} {
 global turrequestscript
 foreach line [split [exec $turrequestscript status $nick] "\n"] {
      putquick "PRIVMSG $chan :$line"
 }
}

## The code for !requests from private message.
proc msg:turrequeststatus { nick host hand text } {
 global turrequestscript
 foreach line [split [exec $turrequestscript status $nick] "\n"] {
      putquick "PRIVMSG $nick :$line"
 }
}

## The code for !reqwipe
proc msg:turrequestwipe { nick host hand text } {
 global turrequestscript
 foreach line [split [exec $turrequestscript reqwipe $nick $text] "\n"] {
      putquick "PRIVMSG $nick :$line"
 }
}

## The code for !reqdel
proc msg:turrequestdel { nick host hand text } {
 global turrequestscript
 foreach line [split [exec $turrequestscript reqdel $nick $text] "\n"] {
      putquick "PRIVMSG $nick :$line"
 }
}

putlog "Tur-Request.tcl 1.7 (for AUTH_SYSTEM=TRUE) by Turranius loaded"
