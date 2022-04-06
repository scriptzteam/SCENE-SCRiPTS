# bnc1.4.tcl - Copyright (c) TEST 1998. All Rights Reserved.

########### DESCRIPTION
# Let's your bot connect to irc with the popular bnc 2.4.6
# you can get the bnc2.4.8 at http://bnc.refract.com
# This script were tested with bnc2.4.8 nothing else.
#
# Release info:
#  v1.0 - First Release
#  v1.1 - Added a multiple Server List with server:port
#  v1.2 - The Script will block the flood from the bnc deamond, so
#       The bounce will no longuer be put on the Ignore for FLOOD
#       Also, Not really need, but your tell a specific port with
#       server:port if no port given 6667 will be used
#  v1.3 - Added a .bncjump in dcc chat for owner(+n only) will make 
#       your bot to jump to the specific server and append the 
#       internal server list.
#       - Added a .bncunserv will allow you to remove a server from 
#       internal server list without editing the tcl script
#       *NOTES for the .bncunserv if you rehash your bot or restart them
#        The server list will be the one in the script tcl
#       - Added a .bnclist will show you the internal server list
#  v1.4 - Well Nothing added just make them for work with the bnc2.6.2 
######################

########### CONTACT INFO
# If you find out any bug and or have anything to ask me:
# email me at kenwood@dragondata.com or on irc #scripting on EFNET
# Nickname are always ^KenwooD^
######################

#Here the Bounce PASSWORD
set bncpass "password"; #Capital count

#Enter The Vhost you wish your bot connec to the IRC
#Or Enter the default host of the box
set bncvip "vhost.host.com"

#Here The Server List to connect
#servername:port IF not port are given 6667 will be used
set bncserv {
irc.globalized.net
irc1.c-com.net
irc2.c-com.net
irc.idle.net
}

#############################################################################
################ DO NOT EDIT ANYTHING BELLOW THIS LINE ######################
#############################################################################

bind raw - NOTICE rawbnc
bind dcc n bncjump bncjumping
bind dcc n bncunserv bncunserv
bind dcc n bnclist bnclist

set ind 0
set currserv 0
set maxserv 0
set bncjumping ""

foreach server $bncserv {
  incr maxserv 1
}

proc bnclist {hand idx arg} {
  global bncserv maxserv
  putdcc $idx "Total server \002$maxserv\002"
  foreach server $bncserv {
    set serv1 [split $server :]
    set serv2 [lindex $serv1 0]
    set serv3 [lindex $serv1 1]
    if {$serv3==""} {set serv3 "6667"}
    putdcc $idx "\002$serv2\002 on port \002$serv3\002"
  }
  putdcc $idx "End of the server list"
}

proc bncunserv {hand idx arg} {
  global bncjumping bncserv maxserv
  if {[llength $arg]>2} {
    putdcc $idx "\002U\002sage :.bncunserv \002<server>\002 \[port\]"
    return 0
  }
  if {[string match "*:*" $arg]} {
    putdcc $idx "\002U\002sage :.bncunserv \002<server>\002 \[port\]"
    return 0
  }
  set serv [lindex $arg 0]
  if {[lindex $arg 1]!=""} {
    if {[string trim [lindex $arg 1] 0123456789] != ""} {
      putdcc $idx "Sorry, [lindex $arg 1] is not Numeric."
      putdcc $idx "\002U\002sage :.bncunserv \002<server>\002 \[port\]"
      return 0 
    }
    set port "[lindex $arg 1]"
  } else {
    set port "6667"
  }
  set found 0
  foreach serv4 $bncserv {
    set serv1 [split $serv4 :]
    set serv2 [lindex $serv1 0]
    set serv3 [lindex $serv1 1]
    if {$serv3==""} {set serv3 "6667"}
    if {[string tolower "${serv}:${port}"]==[string tolower "${serv2}:${serv3}"]} {
      set found 1
    }
  }
  if {$found==0} {
    putdcc $idx "\002$serv\002 on port \002$port\002 not found in the Bounce server list"
    putdcc $idx "To get the list of the server, type .bnclist"
    return 0
  }
  set maxserv 0
  set bncback $bncserv
  set bncserv ""
  foreach server $bncback {
    set serv1 [split $server :]
    set serv2 [lindex $serv1 0]
    set serv3 [lindex $serv1 1]
    if {$serv3==""} {set serv3 "6667"}
    if {[string tolower "${serv}:${port}"]==[string tolower "${serv2}:${serv3}"]} {continue}
    lappend bncserv $server
    incr maxserv 1
  }
}

proc bncjumping {hand idx arg} {
  global bncjumping bncserv maxserv
  if {$arg==""} {jump;return 1}
  if {[llength $arg]>2} {
    putdcc $idx "\002U\002sage :.bncjump \002<server>\002 \\002[\002port\\002]\002"
    return 0
  }
  if {[string match $arg "*:*"]} {
    putdcc $idx "\002U\002sage :.bncjump \002<server>\002 \\002[\002port\\002]\002"
    return 0
  }
  set serv [lindex $arg 0]
  if {[lindex $arg 1]!=""} {
    if {[string trim [lindex $arg 1] 0123456789] != ""} {
      putdcc $idx "Sorry, [lindex $arg 1] is not Numeric."
      putdcc $idx "\002U\002sage :.bncjump \002<server>\002 \\002[\002port\\002]\002"
      return 0 
    }
    set port "[lindex $arg 1]"
  } else {
    set port "6667"
  }
  set bncjumping "${serv}:${port}"
  lappend bncserv $bncjumping
  set maxserv 0
  foreach server $bncserv {incr maxserv 1}
  putserv "QUIT :Changing Server"
  jump
}

proc rawbnc {nick word dtext} {
  global bncserv bncpass bncvip ind currserv maxserv bncjumping
  set bnc1 "You need to say /quote PASS <password>"
  set bnc2 "Level two, lets connect to something real now"
  set bnc3 "type /quote conn \[server\] <port> <pass> to connect"
  set bnc4 "Failed Connection"
  set text [lindex [lrange [split $dtext :] 1 end] 0]
  if {[string tolower $text]==[string tolower $bnc1]} {  
    putserv "PASS $bncpass"
    putlog "Sending Bounce Password"
  }
  if {[string tolower $text]==[string tolower $bnc2]} {
    putserv "vip $bncvip"
    putlog "Setting Vhost"
  }
  if {[string tolower $text]==[string tolower $bnc3]} {
    if {$bncjumping==""} {
      set serv [lindex $bncserv $ind]
      set serv1 [split $serv :]
      set serv2 [lindex $serv1 0]
      set serv3 [lindex $serv1 1]
      if {$serv3==""} {set serv3 "6667"}
      incr ind 1
      append currserv " " $serv
      putserv "conn $serv2 $serv3"
      putlog "Connecting to \002$serv2\002 on Port \002$serv3\002"
      if {$ind==$maxserv} {
        set ind 0
        set currserv 0
      }
    } else {
      set serv [lindex $bncjumping 0]
      set serv1 [split $serv :]
      set serv2 [lindex $serv1 0]
      set serv3 [lindex $serv1 1]
      if {$serv3==""} {set serv3 "6667"}
      putserv "conn $serv2 $serv3"
      putlog "Connecting to \002$serv2\002 on Port \002$serv3\002 as a request"
      set bncjumping ""
    }
  }
  if {[string tolower $text]==[string tolower $bnc4]} {
    set serv [lindex $bncserv $ind]
    set serv1 [split $serv :]
    set serv2 [lindex $serv1 0]
    set serv3 [lindex $serv1 1]
    if {$serv3==""} {set serv3 "6667"}
    incr ind 1
    append currserv " " $serv
    putserv "conn $serv2 $serv3"
    putlog "Connecting to \002$serv2\002 on Port \002$serv3\002"
    if {$ind==$maxserv} {
      set ind 0
      set currserv 0
    }
  }
  return 1
}

set strict-servernames 0
set default-port 6667
set servlimit 1

putlog "\002Bounce v1.4 TCL (c) TEST 1998\002 by \002^KenwooD^\002 has successfully loaded."
