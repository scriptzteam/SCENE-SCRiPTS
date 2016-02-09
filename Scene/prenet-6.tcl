package require TclCurl

# Self-Explanatory! Set addpre to your addpre chan of choice! and same for other channels.
set PR3N3T "xxx"

set chann_(addspam) "#addnfo"

set addfeedurl "http://example.com/preadddata.php?data="

bind pub - !oldnfo oldnfoinsidedb
bind pub - !oldsfv oldsfvinsidedb
bind pub - !oldm3u oldm3uinsidedb

proc oldnfoinsidedb { nick uhost hand chan args } {
	global chann_ PR3N3T
	
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
	set fromnet "$nick:$chan:$PR3N3T"
	
	return [senddata "OLDNFO,$rlsname,$downlink,$filename,$fromnet"]

}

proc oldsfvinsidedb { nick uhost hand chan args } {
	global chann_ PR3N3T
	
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
	set fromnet "$nick:$chan:$PR3N3T"
	
	return [senddata "OLDSFV,$rlsname,$downlink,$filename,$fromnet"]

}

proc oldm3uinsidedb { nick uhost hand chan args } {
	global chann_ PR3N3T
	
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
	set fromnet "$nick:$chan:$PR3N3T"
	
	return [senddata "OLDM3U,$rlsname,$downlink,$filename,$fromnet"]

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
putlog "xxx ADDOLD NF0|SFV|M3U v1.78 --> By \002Islander\002 ||| Loaded Succesfully!"