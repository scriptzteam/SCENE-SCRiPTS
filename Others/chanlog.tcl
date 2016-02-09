set chann_(main) "#xxx"
set chann_(log) "#log"

set blowfish_(enabled) "1"

array set channelkeys {
	"#xxx" 		"xx" 
	"#spam" 	"xx" 
	"#log" 		"xx"	
}

# Blowfish decrypt command
if { $blowfish_(enabled) == "1" } {
	bind pub - +OK cmdencryptedincominghandler
}

bind join - "$chann_(main) *" isy:joinchan
bind part - "$chann_(main) *" isy:partchan
bind sign - "$chann_(main) *" isy:signchan
bind nick - "$chann_(main) *" isy:nickchan
bind rejn - "$chann_(main) *" isy:joinchan
bind kick - "$chann_(main) *" isy:kickchan

# blowcrypt code by poci modified by Islander

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
global channelkeys
	
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
			[lindex $item 4] $nick $host $hand $chan [string trim [lrange $tmp 0 end]]
		}
	
	}
	
}

# blowcrypt code by poci modified by Islander END

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

# User Has Quit Channel Function
proc isy:signchan {nick uhost hand chan reason} {
global chann_

	cmdputblow "PRIVMSG $chann_(log) :Quit: $nick $uhost $hand $chan"
}

# User Has Left Channel Function
proc isy:partchan {nick uhost hand chan reason} {
global chann_

	cmdputblow "PRIVMSG $chann_(log) :Left: $nick $uhost $hand $chan"
}

# User Kicked from Channel Function
proc isy:kickchan {nick uhost hand chan knick reason} {
global chann_

	cmdputblow "PRIVMSG $chann_(log) :Kicked: $nick $uhost $hand $chan"
	cmdputblow "PRIVMSG $chann_(log) :Kicked: $knick $uhost $hand $chan"
}

# New User Join Channel Function
proc isy:joinchan {nick uhost hand chan} {
global chann_

	cmdputblow "PRIVMSG $chann_(log) :Join: $nick $uhost $hand $chan"
}

# User Nick change in Channel Function
# Better set the channel to +N mode so that users cant change there nicks when on that channel
proc isy:nickchan {nick uhost hand chan newnick} {
global chann_

	cmdputblow "PRIVMSG $chann_(log) :Changed: $nick $uhost $hand $chan"
	cmdputblow "PRIVMSG $chann_(log) :Changed: $newnick $uhost $hand $chan"
	
}

putlog "Channel Log --> Script v1.00 by Islander -- Loaded Succesfully!"