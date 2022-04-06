
                          #############################
                        ###            -+-            ###
                        # PREBOT TCL/TXT v1.0 by noname #
                        ###     - -- ---+--- -- -     ###
                        #    0x539 [at] web [d0t] de    #
                      ####             -+-             ####
################################################################################
# notes:                                                                       #
# well its my first tcl script...                                              #
# so i dont give a fuck on crapy coded parts :>                                #
# worx with announces as seen belwo:                                           #
# [ PRE ] PREBOT v1 TCL TXT noname [ 0DAY ]                                    #
# [ NUKE ] PREBOT.v1.TCL.TXT-noname reason: sumone.forgot.reason               #
# [ UNNUKE ] PREBOT.v1.TCL.TXT-noname reason: sumone.forgot.reason             #
################################################################################
# usage:                                                                       #
# !pre RELEASE                                                                 #
# !pred RELEASE                                                                #
# !search RELEASE                                                              #
# !group GROUP                                                                 #
# !section SECTiON                                                             #
# !last                                                                        #
# !nuke                                                                        #
# !unnuke                                                                      #
# !addpre RELEASE SECTiON UNXTiME                                              #
# !addnuke RELEASE REASON SECTiON UNXTiME                                      #
# !addunnuke RELEASE REASON SECTiON UNXTiME                                    #
################################################################################
# config:                                                                      #
# predb              = file to store                                           #
# searchresults      = max results posted on !search !pre                      #
# chan_(pred)        = chan with an existing announcebot                       #
# chan_(echo)        = chan where u want to annonuce                           #
# chan_(pred_pre4ll) = prefix of new rls (e.g. [ PRE ])                        #
# chan_(pred_nuk4ll) = prefix of nuked rls (e.g. [ NUKE ])                     #
# chan_(pred_unn4ll) = prefix of nuked rls (e.g. [ UNNUKE ])                   #
################################################################################
# support:                                                                     #
# support me and i'll support u ;>                                             #
################################################################################
# to do:                                                                       #
# sql port                                                                     #
# prevent redudant data                                                        #
# improve search function                                                      #
# backfill option                                                              #
# blowfish support                                                             #
# fix bugs (as ever)                                                           #
################################################################################
# greetz to:                                                                   #
# #hackers           -+-- irc.after-all.org                                    #
# tumor crew         -+-- w00tw00t                                             #
# Abortion           -+-- wh0re! ^.-                                           #
# auron              -+-- my favourite lhama :>                                #
# CaReS              -+-- who cares?                                           #
# ChIcKeN            -+-- << koerner picken no time                            #
# doomhammer         -+-- a great chum                                         #
# maZer`-            -+-- for being a gr8 coder                                #
# oli geissen        -+-- teh best tv-show-moderator ever! ^^                  #
# Shockwav3          -+-- *tsunami kekse                                       #
# tenti              -+-- repair ya workstation                                #
# forgotten ones...  -+-- i dislike u all... so dont bitch about me :>         #
################################################################################
# copyright:                                                                   #
# who cares? its free! just respect my work n leave my nick in ya impoved one. #
# i would b grateful if u could send me an/your improved one ;>                #
################################################################################
#                            du sollst nicht luegen                            #
#                            du sollst nicht toeten                            #
#                           sollst deine eltern ehrn                           #
#                            sollst nicht begehren                             #
#                           die frau  vom naechsten                            #
#                        und du sollst auch nicht stehln                       #
################################################################################
                ####          - -- ----+---- -- -           ####
                 #    dedicated to the memory of my father    #
                 ###                 --+--                  ###
                   ##########################################







### config
set predb  "./logs/predb.txt"
set pretmp "./logs/predb.tmp"
set searchresults "3"
set minchars "3"
set chan_(pred) "#nopre"
set chan_(echo) "#nopre.test"
set chan_(pred_pre4ll) "\[ 09PRE \]"
set chan_(pred_nuk4ll) "\[ 04NUKE \]"
set chan_(pred_unn4ll) "\[ 04UNNUKE \]"
bind pub - !addpre echo:addpre
bind pub - !addnuke echo:addnuke
bind pub - !addunnuke echo:addunnuke
bind pub - !pre echo:checkpre
bind pub - !pred echo:checkpre
bind pub - !search echo:checkpre
bind pub - !last echo:checklast
bind pub - !group echo:checkgrp
bind pub - !section echo:checksec
bind pub - !nuke echo:checknuk
bind pub - !unnuke echo:checkunn

### style
set announce_(pre)    {01,00 [ 09#section#01,00 ]--[ #releasename#-#releasegroup# ]--[ was pred at #pretime# ] }
set announce_(nuke)   {01,00 [ 04NUKE01,00 ]--[ #releasename#-#releasegroup# ]--[ was nuked at #pretime# ]--[ 04#reason#01,00 ] }
set announce_(unnuke) {01,00 [ 09UN04NUKE01,00 ]--[ #releasename#-#releasegroup# ]--[ was unnuked at #pretime# ]--[ 09#reason#01,00 ] }


### config (do not change)
set chan_(pred_pre1st) [lindex $chan_(pred_pre4ll) 0]
set chan_(pred_nuk1st) [lindex $chan_(pred_nuk4ll) 0]
set chan_(pred_unn1st) [lindex $chan_(pred_unn4ll) 0]
bind pub - $chan_(pred_pre1st) echo:check
bind pub - $chan_(pred_nuk1st) echo:check
bind pub - $chan_(pred_unn1st) echo:check
set minchar [expr ($minchars - 1)]


### check second prefix
proc echo:check { nick uhost handle chan arg } {
 global predb chan_ 
 if { $chan == $chan_(pred) && [ string match [lindex $chan_(pred_pre4ll) 1] [lindex $arg 0] ] == "1" } { echo:nopre $nick $uhost $handle $chan $arg } elseif {
  $chan == $chan_(pred) && [ string match [lindex $chan_(pred_nuk4ll) 1] [lindex $arg 0] ] == "1" } { echo:nonuke $nick $uhost $handle $chan $arg } elseif {
  $chan == $chan_(pred) && [ string match [lindex $chan_(pred_unn4ll) 1] [lindex $arg 0] ] == "1" } { echo:nounnuke $nick $uhost $handle $chan $arg}
}


### check (pre)
proc echo:checkpre { nick uhost handle chan arg } {
 global minchar chan_
 if { $chan == $chan_(echo) } {
  if { $arg == "" } { echo:search $nick $uhost $handle $chan PRE LAST } elseif {
   [string length $arg] > $minchar } { echo:search $nick $uhost $handle $chan $arg PRE } elseif {
   [string length $arg] <= $minchar } { putserv "NOTICE $nick :01,00 *$arg* doesnt reached teh minimum of $minchars chars "; putlog "PRESEARCH *$arg* min. chars not reached"; return 0}
 }
}


### check (group)
proc echo:checkgrp { nick uhost handle chan arg } {
 global minchar chan_
 if { $chan == $chan_(echo) } {
  if { [string length $arg] > $minchar } { echo:search $nick $uhost $handle $chan $arg GRP } elseif {
   [string length $arg] <= $minchar } { putserv "NOTICE $nick :01,00 *$arg* doesnt reached teh minimum of $minchars chars "; putlog "GRPSEARCH *$arg* min. chars not reached"; return 0}
 }
}


### check (section)
proc echo:checksec { nick uhost handle chan arg } {
 global minchar chan_
 if { $chan == $chan_(echo) } {
  if { [string length $arg] > $minchar } { echo:search $nick $uhost $handle $chan $arg SEC } elseif {
   [string length $arg] <= $minchar } { putserv "NOTICE $nick :01,00 *$arg* doesnt reached teh minimum of $minchars chars "; putlog "SECSEARCH *$arg* min. chars not reached"; return 0}
 }
}


### check (last)
proc echo:checklast { nick uhost handle chan arg } {
 global chan_
 if { $chan == $chan_(echo) } { 
  echo:search $nick $uhost $handle $chan e LAST
 }
}


### check (nuke)
proc echo:checknuk { nick uhost handle chan arg } {
 global chan_
 if { $chan == $chan_(echo) } { 
  echo:search $nick $uhost $handle $chan NUKE NUK
 }
}


### check (unnuke)
proc echo:checkunn { nick uhost handle chan arg } {
 global chan_
 if { $chan == $chan_(echo) } { 
  echo:search $nick $uhost $handle $chan UNNUKE NUK
 }
}


### search
proc echo:search { nick uhost handle chan arg wut } {
 global predb pretmp chan_ searchresults
 set pretemp $pretmp.[unixtime]
 set count "0"
 set found "0"
 set rep "\*"
 set search *$arg*
 regsub -all { }  $search $rep search
 regsub -all {\.} $search $rep search
 regsub -all {\_} $search $rep search
 set db [open $predb r]
 set tmp [open $pretemp w]
 while {![eof $db]} {
  gets $db data
  if { $wut == "PRE" } { set searchdata [lindex $data 4]-[lindex $data 3] } elseif { 
   $wut == "LAST" } { set searchdata [lindex $data 0] } elseif { 
   $wut == "GRP" } { set searchdata [lindex $data 3] } elseif { 
   $wut == "SEC" } { set searchdata [lindex $data 2] } elseif { 
   $wut == "NUK" } { set searchdata [lindex $data 0]; set search $arg }
  if {[ string match [string toupper $search] [string toupper $searchdata] ] } {
   incr count
   puts $tmp "$data"
  }
 }
 close $tmp
 set county $count
 if {$count == 0} { putserv "NOTICE $nick :01,00 $search was not found in db "; putlog "SEARCH $search not found" } else {
  putserv "NOTICE $nick :01,00 $count releases found... "; putlog "SEARCH $search $count releases found"
  for {set x 0} {$x < $searchresults} {incr x} {
   set tmp [open $pretemp r]
   if {$county == 0} {return 0}
   for {set y 0} {$y < $county} {incr y} {
    gets $tmp data
   }
   close $tmp
   incr county -1
   echo:annorep [lindex $data 0] [lindex $data 2] [lindex $data 4] [lindex $data 3] [lindex $data 1] [lindex $data 5] $nick 0
  }
 }
 close $db
 file delete -force -- $pretemp
} 


### announce (pre)
proc echo:nopre { nick uhost handle chan arg } {
 global predb chan_
 set prestamp [unixtime]
 set rlstmp [check:string $arg]
 set sec [lindex $rlstmp 1]
 set rlstmp [lindex $rlstmp 0]
 set rlsgrp [check:rlsgrp $rlstmp]
 set grp [lindex $rlsgrp 1]
 set nam [lindex $rlsgrp 0]
 echo:annorep PRE $sec $nam $grp $prestamp PRE $chan_(echo) 1
}


### announce (nuke)
proc echo:nonuke { nick uhost handle chan arg } {
 global predb chan_ announce_nuke
 set prestamp [unixtime]
 set sec ""
 set reason [lindex $arg 4]
 set rlstmp [lindex $arg 2]
 set rlsgrp [check:addrlsgrp $rlstmp]
 set grp [lindex $rlsgrp 1]
 set nam [lindex $rlsgrp 0]
 echo:annorep NUKE $sec $nam $grp $prestamp $reason $chan_(echo) 1
}


### announce (unnuke)
proc echo:nounnuke { nick uhost handle chan arg } {
 global predb chan_ announce_unnuke
 set prestamp [unixtime]
 set sec "UNKNOWN"
 set reason [lindex $arg 4]
 set rlstmp [lindex $arg 2]
 set rlsgrp [check:addrlsgrp $rlstmp]
 set grp [lindex $rlsgrp 1]
 set nam [lindex $rlsgrp 0]
 echo:annorep UNNUKE $sec $nam $grp $prestamp $reason $chan_(echo) 1
}


### announce (addpre)
proc echo:addpre { nick uhost handle chan arg } {
 global predb chan_
 if { $chan == $chan_(pred) } {
  set prestamp [check:stamp [lindex $arg 2]]
  set rlstmp [lindex $arg 0]
  if { $rlstmp == "" } { putserv "NOTICE $nick :01,00 USAGE\: !addpre RELEASE SECTiON UNXTiME \[SECTiON and UNXTiME are optional\] "; return 0 }
  set sec [lindex $arg 1]
  set rlsgrp [check:addrlsgrp $rlstmp]
  set grp [lindex $rlsgrp 1]
  set nam [lindex $rlsgrp 0]
 echo:annorep PRE $sec $nam $grp $prestamp PRE $chan_(echo)
 }
}


### announce (addnuke)
proc echo:addnuke { nick uhost handle chan arg } {
 global predb chan_
 if { $chan == $chan_(pred) } {
  set rlstmp [lindex $arg 0]
  if { $rlstmp == "" } { putserv "NOTICE $nick :01,00 USAGE\: !addnuke RELEASE REASON UNXTiME SECTiON \[RELEASE REASON UNXTiME\[now\|\<stamp\>\] and SECTiON are optional\] "; return 0 }
  set reason [lindex $arg 1]
  set prestamp [check:stamp [lindex $arg 2]]
  set sec [lindex $arg 3]
  set rlsgrp [check:addrlsgrp $rlstmp]
  set grp [lindex $rlsgrp 1]
  set nam [lindex $rlsgrp 0]
  echo:annorep NUKE $sec $nam $grp $prestamp $reason $chan_(echo) 1
 }
}


### announce (addunnuke)
proc echo:addunnuke { nick uhost handle chan arg } {
 global predb chan_
 if { $chan == $chan_(pred) } {
  set rlstmp [lindex $arg 0]
  if { $rlstmp == "" } { putserv "NOTICE $nick :01,00 USAGE\: !addunnuke RELEASE REASON UNXTiME SECTiON \[RELEASE REASON UNXTiME\[now\|\<stamp\>\] and SECTiON are optional\] "; return 0 }
  set reason [lindex $arg 1]
  set prestamp [check:stamp [lindex $arg 2]]
  set sec [lindex $arg 3]
  set rlsgrp [check:addrlsgrp $rlstmp]
  set grp [lindex $rlsgrp 1]
  set nam [lindex $rlsgrp 0]
  echo:annorep UNNUKE $sec $nam $grp $prestamp $reason $chan_(echo) 1
 }
}


### announce (rep n sav)
proc echo:annorep { stat sec nam grp prestamp reason chan_echo save } {
 global predb announce_
 if { $save == "1" } {
  if { $sec == "" } { set sec "UNKNOWN" }
  if { $reason == "" } { set reason "UNKNOWN" }
  set data [open $predb a]
  puts $data "$stat $prestamp $sec $grp $nam $reason"
  close $data
  putlog "$stat $prestamp $sec $nam\-$grp $reason added"
 }
 if { $stat == "PRE" } { set announce $announce_(pre) } elseif {
  $stat == "NUKE" } { set announce $announce_(nuke) } elseif {
  $stat == "UNNUKE" } { set announce $announce_(unnuke) }
 set pretime [unx2nps $prestamp]
 regsub -- {#section#} $announce $sec announce
 regsub -- {#releasename#} $announce $nam announce
 regsub -- {#releasegroup#} $announce $grp announce
 regsub -- {#pretime#} $announce $pretime announce
 regsub -- {#reason#} $announce $reason announce
 if { $save == "1" } { putserv "PRIVMSG $chan_echo :$announce" } else { putserv "NOTICE $chan_echo :$announce" }
}


### filter color bold /bla code add dots
proc check:string { nostring } {
 global chan_
 regsub -all -- {[0-9][0-9],[0-9][0-9]}  $nostring ""   nostring
 regsub -all -- {[0-9][0-9],[0-9]}       $nostring ""   nostring
 regsub -all -- {[0-9][0-9]}             $nostring ""   nostring
 regsub -all -- {[0-9]}                  $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {PRE}                     $nostring ""   nostring
 regsub -all -- { }                       $nostring "\." nostring
 regsub -all -- {\.\]\.}                  $nostring " "  nostring
 regsub -all -- {\.\[\.}                  $nostring " "  nostring
 regsub -all -- {\.\]}                    $nostring ""   nostring
 regsub -all -- {\.\.}                    $nostring "\." nostring
 return $nostring
}


proc check:addrlsgrp { nostring } {
 regsub -all -- {\-}                      $nostring " "   nostring
 set grp [lindex $nostring end]
 regsub -all -- { }                       $nostring "\-"   nostring
 set grprep1 "\-$grp"
 set grprep2 " $grp"
 regsub -all -- $grprep1                 $nostring $grprep2   nostring
 return $nostring
}


proc check:rlsgrp { nostring } {
 regsub -all -- {\.}  $nostring " "     nostring
 set grp [lindex $nostring end]
 regsub -all -- $grp  $nostring "\-rep" nostring
 regsub -all -- { \-} $nostring "\-"    nostring
 regsub -all -- {rep} $nostring $grp    nostring
 regsub -all -- { }   $nostring "\."    nostring
 regsub -all -- {\-}  $nostring " "     nostring
 return $nostring
}


proc check:stamp { timestamp } {
 regsub -- {[nN][oO][wW]} $timestamp "" timestamp
 if { $timestamp == "" || $timestamp == "\-" } { return [unixtime] } else { return $timestamp}
}


proc unx2nps { timestamp } {
 if {[regexp "\[^\\d\]" $timestamp]} { error "unx2nps: parameter is not a valid unix timestamp" }
 if {$timestamp > "2000000000"} { error "unx2nps: parameter is too large" }
 return [clock format $timestamp -format "%Y/%m/%d %H:%M:%S"]
}


#bind pub - .rehash test:rehash
# proc test:rehash {nick uhost hand channel arg} {
# rehash
# putserv "PRIVMSG $channel :rehased..."
#}


putlog "PREBOT TCL/TXT v1.0 loaded (by noname)."



### EOF ### /1337? yea.. a bit.