# blowcrypt.tcl 2.0 by poci

#  !! BLOWFISH MODULE NEED TO BE LOADED AS ENCRYPTION MODULE !!


#channels must be lower case
set blowkey(#chan1)    "PUTKEYHERE"
set blowkey(#channel2) "key2"

catch {rename putquick putquick2}
catch {rename putserv putserv2}
catch {rename puthelp puthelp2}

proc puthelp {text {option ""}} {
	global blowkey
	if {$option==""} {
		if {[lindex $text 0]=="PRIVMSG" && [info exists blowkey([string tolower [lindex $text 1]])]} {
			puthelp2 "PRIVMSG [lindex $text 1] :+OK [encrypt $blowkey([string tolower [lindex $text 1]]) [string trimleft [join [lrange $text 2 end]] :]]"
		} else {
			puthelp2 $text
		}
	} else {
	  	if {[lindex $text 0]=="PRIVMSG" && [info exists blowkey([string tolower [lindex $text 1]])]} {
			puthelp2 "PRIVMSG [lindex $text 1] :+OK [encrypt $blowkey([string tolower [lindex $text 1]]) [string trimleft [join [lrange $text 2 end]] :]]" $option
		} else {
			puthelp2 $text $option
		}
	}
}


proc putserv {text {option ""}} {
	global blowkey
	if {$option==""} {
		if {[lindex $text 0]=="PRIVMSG" && [info exists blowkey([string tolower [lindex $text 1]])]} {
			putserv2 "PRIVMSG [lindex $text 1] :+OK [encrypt $blowkey([string tolower [lindex $text 1]]) [string trimleft [join [lrange $text 2 end]] :]]"
		} else {
			putserv2 $text
		}
	} else {
	  	if {[lindex $text 0]=="PRIVMSG" && [info exists blowkey([string tolower [lindex $text 1]])]} {
			putserv2 "PRIVMSG [lindex $text 1] :+OK [encrypt $blowkey([string tolower [lindex $text 1]]) [string trimleft [join [lrange $text 2 end]] :]]" $option
		} else {
			putserv2 $text $option
		}
	}
}


proc putquick {text {option ""}} {
	global blowkey
	if {$option==""} {
		if {[lindex $text 0]=="PRIVMSG" && [info exists blowkey([string tolower [lindex $text 1]])]} {
			putquick2 "PRIVMSG [lindex $text 1] :+OK [encrypt $blowkey([string tolower [lindex $text 1]]) [string trimleft [join [lrange $text 2 end]] :]]"
		} else {
			putquick2 $text
		}
	} else {
	  	if {[lindex $text 0]=="PRIVMSG" && [info exists blowkey([string tolower [lindex $text 1]])]} {
			putquick2 "PRIVMSG [lindex $text 1] :+OK [encrypt $blowkey([string tolower [lindex $text 1]]) [string trimleft [join [lrange $text 2 end]] :]]" $option
		} else {
			putquick2 $text $option
		}
	}
}

proc encryptedincominghandler {nick host hand chan arg} {
	global blowkey
	if {![info exists blowkey([string tolower $chan])]} {return}
	set tmp [decrypt $blowkey([string tolower $chan]) $arg]
	foreach item [binds pub] {
		if {[lindex $item 2]=="+OK"} {continue}
		if {[lindex $item 1]!="-|-"} {
			if {![matchattr $hand [lindex $item 1] $chan]} {continue}
		}
		if {[lindex $item 2]==[lindex $tmp 0]} {[lindex $item 4] $nick $host $hand $chan [lrange $tmp 1 end]}
	 }
}

bind pub - +OK encryptedincominghandler

putlog "blowcrypt.tcl 2.0 by poci loaded"


