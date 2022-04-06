##############################################################################
# Tur-Request.tcl 1.7 by Turranius                                           #
# Use this if you have AUTH_SYSTEM=FALSE in tur-request.conf                 #
# Change triggers below to whatever you want the trigger the script with.    #
# If tur-request.sh is not located in /glftpd/bin/ then change the path      #
# in 'set turrequestscript' below.                                           #
# o = ops only. - = public.                                                  #
# Note that ops is users with +o in the current bot.                         #
#                                                                            #
# pub = Open channel. msg = Priv msg to bot.                                 #
##############################################################################

set turrequestscript {/glftpd/bin/tur-request.sh}

bind pub o !request pub:turrequests
bind msg o !request msg:turrequests

bind pub - !reqfilled pub:turreqfilled
bind msg - !reqfilled msg:turreqfilled

bind pub - !requests pub:turrequeststatus
bind msg - !requests msg:turrequeststatus

bind pub - !reqdel pub:turrequestdel
bind msg - !reqdel msg:turrequestdel

bind pub o !reqwipe pub:turrequestwipe
bind msg o !reqwipe msg:turrequestwipe


##############################################################################

proc pub:turrequests {nick uhost handle chan arg} {
 global turrequestscript
 foreach line [split [exec $turrequestscript request $nick $arg] "\n"] {
      putquick "PRIVMSG $chan :$line"
 }
}

proc msg:turrequests { nick host hand arg } {
 global turrequestscript
 foreach line [split [exec $turrequestscript request $nick $arg] "\n"] {
      putquick "PRIVMSG $nick :$line"
 }
}

proc pub:turreqfilled {nick uhost handle chan arg} {
 global turrequestscript
 foreach line [split [exec $turrequestscript reqfilled $nick $arg] "\n"] {
      putquick "PRIVMSG $chan :$line"
 }
}

proc msg:turreqfilled { nick host hand arg } {
 global turrequestscript
 foreach line [split [exec $turrequestscript reqfilled $nick $arg] "\n"] {
      putquick "PRIVMSG $nick :$line"
 }
}

proc pub:turrequeststatus {nick uhost handle chan arg} {
 global turrequestscript
 foreach line [split [exec $turrequestscript status $nick] "\n"] {
      putquick "PRIVMSG $chan :$line"
 }
}

proc msg:turrequeststatus { nick host hand arg } {
 global turrequestscript
 foreach line [split [exec $turrequestscript status $nick] "\n"] {
      putquick "PRIVMSG $nick :$line"
 }
}

proc pub:turrequestwipe {nick uhost handle chan arg} {
 global turrequestscript
 foreach line [split [exec $turrequestscript reqwipe $nick $arg] "\n"] {
      putquick "PRIVMSG $chan :$line"
 }
}

proc msg:turrequestwipe { nick host hand arg } {
 global turrequestscript
 foreach line [split [exec $turrequestscript reqwipe $nick $arg] "\n"] {
      putquick "PRIVMSG $nick :$line"
 }
}

proc pub:turrequestdel {nick uhost handle chan arg} {
 global turrequestscript
 foreach line [split [exec $turrequestscript reqdel $nick $arg] "\n"] {
      putquick "PRIVMSG $chan :$line"
 }
}

proc msg:turrequestdel { nick host hand arg } {
 global turrequestscript
 foreach line [split [exec $turrequestscript reqdel $nick $arg] "\n"] {
      putquick "PRIVMSG $nick :$line"
 }
}

putlog "Tur-Request.tcl 1.7 (for AUTH_SYSTEM=FALSE) by Turranius loaded"
