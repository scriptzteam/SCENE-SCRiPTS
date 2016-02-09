package require TclCurl

# Self-Explanatory! Set addpre to your addpre chan of choice! and same for other channels.
set PR3N3T "xxx"

set chann_(addspam) "#addnfo"

set addfeedurl "http://example.com/preadddata.php?data="

bind pub - !addnfo nfoinsidedb
bind pub - !addsfv sfvinsidedb
bind pub - !addm3u m3uinsidedb

proc nfoinsidedb { nick uhost hand chan args } {
	global chann_ PR3N3T
	
	if { $chan == $chann_(addspam) } {
	
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
	set fromnet "$nick:$chanx:$PR3N3T"
	
	set hashdata [senddata "ADDNFO,$rlsname,$downlink,$filename,$fromnet"]
	
	if { $hashdata != "" } {
		
		set hash [lindex $hashdata 0]
		set crc [lindex $hashdata 1]
		set size [lindex $hashdata 2]
		
		putbot "STRB" "ADDNFO $rlsname $hash $filename $crc $size"
		
		#putquick "PRIVMSG $chan :!addnfo $rlsname https://example.com/file.php?h=$hash $filename"
	}
	
	}

}

proc sfvinsidedb { nick uhost hand chan args } {
	global chann_ PR3N3T
	
	if { $chan == $chann_(addspam) } {
	
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
	set fromnet "$nick:$chanx:$PR3N3T"
	
	set hashdata [senddata "ADDSFV,$rlsname,$downlink,$filename,$fromnet"]
	
	if { $hashdata != "" } {
		
		set hash [lindex $hashdata 0]
		set crc [lindex $hashdata 1]
		set size [lindex $hashdata 2]
		
		putbot "STRB" "ADDSFV $rlsname $hash $filename $crc $size"
		
		#putquick "PRIVMSG $chan :!addsfv $rlsname https://example.com/file.php?h=$hash $filename"
	
	}
	
	}

}

proc m3uinsidedb { nick uhost hand chan args } {
	global chann_ PR3N3T
	
	if { $chan == $chann_(addspam) } {
	
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
	set fromnet "$nick:$chanx:$PR3N3T"
	
	set hashdata [senddata "ADDM3U,$rlsname,$downlink,$filename,$fromnet"]
	
	if { $hashdata != "" } {
		
		set hash [lindex $hashdata 0]
		set crc [lindex $hashdata 1]
		set size [lindex $hashdata 2]
		
		putbot "STRB" "ADDM3U $rlsname $hash $filename $crc $size"
		
		#putquick "PRIVMSG $chan :!addm3u $rlsname https://example.com/file.php?h=$hash $filename"
	}
	
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
putlog "xxx ADD NEW NF0|SFV|M3U v1.88 --> By \002sCRiPTzTEAM\002 ||| Loaded Succesfully!"