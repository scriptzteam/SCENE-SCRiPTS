
set whichbot "STRB"

set chan_(addpre) "#addpre"
set chan_(info) "#addpre"
set chan_(genre) "#addpre"
set chan_(nuke) "#addpre"
set chan_(delpre) "#addpre"

set blowfish_(enabled) "1"

bind bot - ADDPRE getprerls
bind bot - NUKE nukerls
bind bot - UNNUKE unnukerls
bind bot - MODNUKE modnukerls
bind bot - DELPRE delprerls
bind bot - UNDELPRE undelprerls

bind bot - PREINFO getinforls
bind bot - GENRE getgenrerls

# Blowfish decrypt command
if { $blowfish_(enabled) == "1" } {
	bind pub - +OK cmdencryptedincominghandler
}

# blowcrypt code by poci modified by Islander

proc cmdputblow {text {option ""}} {
	global blowfish_
	
	if {$option==""} {
	
		if {[lindex $text 0]=="PRIVMSG" && $blowfish_(enabled) == 1} {
			
			set blowfishkey [getfishkey [string tolower [lindex $text 1]]]
			
			if {[info exists blowfishkey]} {
				putquick "PRIVMSG [lindex $text 1] :+OK [encrypt $blowfishkey [string trimleft [join [lrange $text 2 end]] :]]"
			}
		
		} else {
			putquick $text
		}
		
	} else {
	
	  	if {[lindex $text 0]=="PRIVMSG" && $blowfish_(enabled) == 1} {
			
			set blowfishkey [getfishkey [string tolower [lindex $text 1]]]
			
			if {[info exists blowfishkey]} {
				putquick "PRIVMSG [lindex $text 1] :+OK [encrypt $blowfishkey [string trimleft [join [lrange $text 2 end]] :]]" $option
			}
		
		} else {
			putquick $text $option
		}
		
	}
	
}

proc getfishkey { chan } {
	
	array set channelkeys {
			"#addpre" 		"xxx"
	}
	
    foreach {channel blowkey} [array get channelkeys] {
        if {[string equal -nocase $channel $chan]} {
			return $blowkey
		} 
    }
}

proc cmdencryptedincominghandler {nick host hand chan arg} {
	
	set blowfishkey [getfishkey $chan]
	
	if {![info exists blowfishkey]} {return}
	
	set tmp [decrypt $blowfishkey $arg]
	
	foreach item [binds pub] {
	
		if {[lindex $item 2]=="+OK"} {continue}
		
		if {[lindex $item 1]!="-|-"} {
			if {![matchattr $hand [lindex $item 1] $chan]} {continue}
		}
		
		if {[lindex $item 2]==[lindex $tmp 0]} {
			[lindex $item 4] $nick $host $hand $chan [lrange $tmp 1 end]
		}
	
	}
	
}

# blowcrypt code by poci modified by Islander END

proc getprerls {bot com args} {
	global chan_ whichbot
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set sec [lindex [lindex $args 0] 1]
		
		cmdputblow "PRIVMSG $chan_(addpre) :!addpre $rlsname $sec"
	
	}
}

proc nukerls {bot com args} {
	global chan_ whichbot
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set reason [lindex [lindex $args 0] 1]
		set nukenet [lindex [lindex $args 0] 2]

		
		cmdputblow "PRIVMSG $chan_(nuke) :!nuke $rlsname $reason $nukenet"
		
	}
}

proc unnukerls {bot com args} {
	global chan_ whichbot
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set reason [lindex [lindex $args 0] 1]
		set nukenet [lindex [lindex $args 0] 2]

		
		cmdputblow "PRIVMSG $chan_(nuke) :!unnuke $rlsname $reason $nukenet"
		
	}
}

proc modnukerls {bot com args} {
	global chan_ whichbot
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set reason [lindex [lindex $args 0] 1]
		set nukenet [lindex [lindex $args 0] 2]

		
		cmdputblow "PRIVMSG $chan_(nuke) :!modnuke $rlsname $reason $nukenet"
		
	}
}

proc delprerls {bot com args} {
	global chan_ whichbot
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set reason [lindex [lindex $args 0] 1]
		set nukenet [lindex [lindex $args 0] 2]

		
		cmdputblow "PRIVMSG $chan_(delpre) :!delpre $rlsname $reason $nukenet"
		
	}
}

proc undelprerls {bot com args} {
	global chan_ whichbot
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set reason [lindex [lindex $args 0] 1]
		set nukenet [lindex [lindex $args 0] 2]

		
		cmdputblow "PRIVMSG $chan_(delpre) :!undelpre $rlsname $reason $nukenet"
		
	}
}

proc getinforls {bot com args} {
	global chan_ whichbot
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set fles [lindex [lindex $args 0] 1]
		set size [lindex [lindex $args 0] 2]
		
		cmdputblow "PRIVMSG $chan_(info) :!info $rlsname $fles $size"
	}
}

proc getgenrerls {bot com args} {
	global chan_ whichbot
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set gnre [lindex [lindex $args 0] 1]
		
		cmdputblow "PRIVMSG $chan_(genre) :!gn $rlsname $gnre"
	}
}

putlog "ADD --> PR3 ||| iNF0GN Script v0.71 by Islander -- Loaded Succesfully!"