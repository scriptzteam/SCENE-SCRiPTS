set whichbot "xxx"
set annchan "#xxx"

bind bot - FTPNEW getnewrls
bind bot - FTPCOMPLETE getcompleterls
bind bot - FTPPRE getaffilrls

set blowfish_(enabled) "1"

# Blowfish decrypt command
if { $blowfish_(enabled) == "1" } {
	bind pub - +OK cmdencryptedincominghandler
}

# blowcrypt code by poci modified by sCRiPTzTEAM

proc cmdputblow {text {option ""}} {
	global blowfish_
	
	if {$option==""} {
	
		if {[lindex $text 0]=="PRIVMSG" && $blowfish_(enabled) == 1} {
			
			set blowfishkey [getfishkey [string tolower [lindex $text 1]]]
			
			if { $blowfishkey != "" } {
				putquick "PRIVMSG [lindex $text 1] :+OK [encrypt $blowfishkey [string trimleft [join [lrange $text 2 end]] :]]"
			}
		
		} else {
			putquick $text
		}
		
	} else {
	
	  	if {[lindex $text 0]=="PRIVMSG" && $blowfish_(enabled) == 1} {
			
			set blowfishkey [getfishkey [string tolower [lindex $text 1]]]
			
			if { $blowfishkey != "" } {
				putquick "PRIVMSG [lindex $text 1] :+OK [encrypt $blowfishkey [string trimleft [join [lrange $text 2 end]] :]]" $option
			}
		
		} else {
			putquick $text $option
		}
		
	}
	
}

proc getfishkey { chan } {
	
	array set channelkeys {
		"#xxx" 		"xxx" 	
	}
	
    foreach {channel blowkey} [array get channelkeys] {
        if {[string equal -nocase $channel $chan]} {
			return $blowkey
		} 
    }
}

proc cmdencryptedincominghandler {nick host hand chan arg} {
	
	set blowfishkey [getfishkey $chan]
	
	if { $blowfishkey == "" } {return}
	
	set tmp [decrypt $blowfishkey $arg]
	set tmp [stripcodes bc $tmp]
	set tmp [isy:trimcolors $tmp]
	
	foreach item [binds pub] {
	
		if {[lindex $item 2]=="+OK"} {continue}
		
		if {[lindex $item 1]!="-|-"} {
			if {![matchattr $hand [lindex $item 1] $chan]} {continue}
		}
		
		if {[lindex $item 2]==[lindex $tmp 0]} {
			[lindex $item 4] $nick $host $hand $chan [string trim [lrange $tmp 1 end]]
		}
	
	}
	
}

# blowcrypt code by poci modified by sCRiPTzTEAM END

# Filter color bold /bla code 
proc isy:trimcolors { nostring } {

 regsub -all -- {[0-9][0-9],[0-9][0-9]}  $nostring ""   nostring
 regsub -all -- {[0-9][0-9],[0-9]}       $nostring ""   nostring
 regsub -all -- {[0-9][0-9]}             $nostring ""   nostring
 regsub -all -- {[0-9]}                  $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {}                        $nostring ""   nostring
 regsub -all -- {}                        $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {\002|\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\026|\037|\0036|\022} $nostring ""   nostring
 
 return [string trim $nostring]
 
}

proc isy:validrelease { release } {

 set minlen 10
 set maxlen 256
 
 if {[string length $release] < $minlen}                                 {return 0}
 if {[string length $release] > $maxlen}                                 {return 0}
 if {![regexp {\.|\_|\-} $release]}                                      {return 0}
 if {[regexp {\!|\:|\@|\~|\||\[|\]|\`} $release]}                        {return 0}
 if {![regexp {\-} $release]}                                            {return 0}
 if {[regexp {[\-\.\(\)_]$} $release]}                                   {return 0}
 if {![regexp -nocase {[a-z]} $release]}                                 {return 0}
 if {[regexp ^[clock format [clock scan today] -format %Y-%m] $release]} {return 0}
 if {[regexp ^[clock format [clock scan today] -format %m%d] $release]}  {return 0}
 if {[regexp -all {\(} $release]!=[regexp -all {\)} $release]}           {return 0}
 if {[regexp -nocase {p[-\._]?r[-\._]?[e3][-\._]?[7t][-\._]?[e3][-\._]?[s5][-\._]?[t7]|[7t][-\._]?[e3][-\._]?[s5][-\._]?[t7][-\._]?p[-\._]?r[-\._]?[e3][-\._]?|d[o0][-\._]?n[o0]?[t7].*[t7]r[a4]d[e3]|^[t7][-\._]?[e3][-\._]?[s5][-\._]?[t7][-\._]?[a-z0-9]+$} $release]} {return 0}
 
 return 1
 
}

proc getnewrls {bot com args} {
	global annchan whichbot
	
	if { $bot == $whichbot } {
		
		set rlsname [lindex [lindex $args 0] 0]
		set category [lindex [lindex $args 0] 1]
		
		set rlsvalid [isy:validrelease $rlsname]
		
		if { $rlsvalid == "1" } {
			cmdputblow "PRIVMSG $annchan :NEW $category $rlsname"
		}
	}
}

proc getcompleterls {bot com args} {
	global annchan whichbot
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set category [lindex [lindex $args 0] 1]
		
		set rlsvalid [isy:validrelease $rlsname]
		
		if { $rlsvalid == "1" } {
			cmdputblow "PRIVMSG $annchan :COMPLETE $category $rlsname"
		}
		
	}
}

proc getaffilrls {bot com args} {
	global annchan whichbot
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set category [lindex [lindex $args 0] 1]
		
		set rlsvalid [isy:validrelease $rlsname]
		
		if { $rlsvalid == "1" } {
			cmdputblow "PRIVMSG $annchan :PRE $category $rlsname"
		}
		
	}
}

putlog "FTP xxx SPR3AD FiSH --> Script v1.00 by sCRiPTzTEAM -- Loaded Succesfully!"
