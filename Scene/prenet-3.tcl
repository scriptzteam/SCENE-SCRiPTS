package require TclCurl

# Self-Explanatory! Set addpre to your addpre chan of choice! and same for other channels.
set FR0MN3T "xxx"

set fromwhere_(addspam) "#addpre.info"

set addfeedurl "http://example.com/preadddata.php?data="

bind pub - !addnfo nfoinsidedb
bind pub - !addsfv sfvinsidedb
bind pub - !addm3u m3uinsidedb

bind pub - !oldnfo oldnfoinsidedb
bind pub - !oldsfv oldsfvinsidedb
bind pub - !oldm3u oldm3uinsidedb

proc nfoinsidedb { nick uhost hand chan args } {
	global fromwhere_ FR0MN3T
	
	if { $chan == $fromwhere_(addspam) } {
	
	set args [string trim [stripcodes bc $args]]
	set infoteh [lindex $args 0]
	set info [split "$infoteh" " "]

	set rlsname [lindex $info 0]
	set downlink [lindex $info 1]
	set filename [lindex $info 2]
	
	if { $filename == "" } {
		set filename "filename.nfo"
	}
	
	set chanx [string trim $chan "#"]
	set fromnet "$nick:$chanx:$FR0MN3T"
	
	set hash [senddata "ADDNFO,$rlsname,$downlink,$filename,$fromnet"]
	
	if { $hash != "" } {
	
		putbot "STRB" "ADDNFO $rlsname $hash $filename"
		
		putquick "PRIVMSG $chan :!addnfo $rlsname http://example.com/file.php?h=$hash $filename"
	}
	
	}

}

proc sfvinsidedb { nick uhost hand chan args } {
	global fromwhere_ FR0MN3T
	
	if { $chan == $fromwhere_(addspam) } {
	
	set args [string trim [stripcodes bc $args]]
	set infoteh [lindex $args 0]
	set info [split "$infoteh" " "]

	set rlsname [lindex $info 0]
	set downlink [lindex $info 1]
	set filename [lindex $info 2]
	
	if { $filename == "" } {
		set filename "filename.sfv"
	}
	
	set chanx [string trim $chan "#"]
	set fromnet "$nick:$chanx:$FR0MN3T"
	
	set hash [senddata "ADDSFV,$rlsname,$downlink,$filename,$fromnet"]
	
	if { $hash != "" } {
		
		putbot "STRB" "ADDNFO $rlsname $hash $filename"
		
		putquick "PRIVMSG $chan :!addsfv $rlsname http://example.com/file.php?h=$hash $filename"
	}
	
	}

}

proc m3uinsidedb { nick uhost hand chan args } {
	global fromwhere_ FR0MN3T
	
	if { $chan == $fromwhere_(addspam) } {
	
	set args [string trim [stripcodes bc $args]]
	set infoteh [lindex $args 0]
	set info [split "$infoteh" " "]

	set rlsname [lindex $info 0]
	set downlink [lindex $info 1]
	set filename [lindex $info 2]
	
	if { $filename == "" } {
		set filename "filename.m3u"
	}
	
	set chanx [string trim $chan "#"]
	set fromnet "$nick:$chanx:$FR0MN3T"
	
	set hash [senddata "ADDM3U,$rlsname,$downlink,$filename,$fromnet"]
	
	if { $hash != "" } {
		
		putbot "STRB" "ADDNFO $rlsname $hash $filename"
		
		putquick "PRIVMSG $chan :!addm3u $rlsname http://example.com/file.php?h=$hash $filename"
	}
	
	}

}

proc oldnfoinsidedb { nick uhost hand chan args } {
	global fromwhere_ FR0MN3T
	
	if { $chan == $fromwhere_(addspam) } {
	
	set args [string trim [stripcodes bc $args]]
	set infoteh [lindex $args 0]
	set info [split "$infoteh" " "]

	set rlsname [lindex $info 0]
	set downlink [lindex $info 1]
	set filename [lindex $info 2]
	
	if { $filename == "" } {
		set filename "oldfilename.nfo"
	}
	
	set chan [string trim $chan "#"]
	set fromnet "$nick:$chan:$FR0MN3T"
	
	return [senddata "OLDNFO,$rlsname,$downlink,$filename,$fromnet"]
	
	
	}

}

proc oldsfvinsidedb { nick uhost hand chan args } {
	global fromwhere_ FR0MN3T
	
	if { $chan == $fromwhere_(addspam) } {
	
	set args [string trim [stripcodes bc $args]]
	set infoteh [lindex $args 0]
	set info [split "$infoteh" " "]

	set rlsname [lindex $info 0]
	set downlink [lindex $info 1]
	set filename [lindex $info 2]
	
	if { $filename == "" } {
		set filename "oldfilename.sfv"
	}
	
	set chan [string trim $chan "#"]
	set fromnet "$nick:$chan:$FR0MN3T"
	
	return [senddata "OLDSFV,$rlsname,$downlink,$filename,$fromnet"]
	
	
	}

}

proc oldm3uinsidedb { nick uhost hand chan args } {
	global fromwhere_ FR0MN3T
	
	if { $chan == $fromwhere_(addspam) } {
	
	set args [string trim [stripcodes bc $args]]
	set infoteh [lindex $args 0]
	set info [split "$infoteh" " "]

	set rlsname [lindex $info 0]
	set downlink [lindex $info 1]
	set filename [lindex $info 2]
	
	if { $filename == "" } {
		set filename "oldfilename.m3u"
	}
	
	set chan [string trim $chan "#"]
	set fromnet "$nick:$chan:$FR0MN3T"
	
	return [senddata "OLDM3U,$rlsname,$downlink,$filename,$fromnet"]
	
	
	}

}

proc senddata { data } {
	global addfeedurl
	
	# with ssl
	# curl::transfer -sslverifyhost 0 -sslverifypeer 0 -url $addfeedurl$data -bodyvar html -timeout 2
	
	# without ssl
	curl::transfer -url $addfeedurl$data -bodyvar html -timeout 2
	
	return $html
	
}

# It would be nice if you didn't delete this but there is really nothing I can do!
putlog "xxx ADD NF0|SFV|M3U v1.91 --> By \002Islander\002 ||| Loaded Succesfully!"