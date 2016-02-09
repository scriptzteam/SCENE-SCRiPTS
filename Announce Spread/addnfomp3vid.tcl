set whichspambot "STRB"
set whichmp3vidbot "STRB"

set addspamchan "#addnfo"
set addmp3vidchan "#addmp3vid"

set blowfish_(enabled) "1"

bind bot - ADDNFO nfoprerls
bind bot - ADDSFV sfvprerls
bind bot - ADDM3U m3uprerls
bind bot - ADDJPG jpgprerls
bind bot - ADDDIZ dizprerls
bind bot - ADDVIDEOINFO videoprerls
bind bot - ADDMP3INFO mp3prerls
bind bot - ADDIMDB imdbrls
bind bot - ADDURL urlrls

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
			"#addnfo" 		"xxx" 
			"#addmp3vid" 	"xxx" 
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

proc imdbrls {bot com args} {
	global addmp3vidchan whichmp3vidbot 
	
	if { $bot == $whichmp3vidbot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set imdbid [lindex [lindex $args 0] 1]
		set rating [lindex [lindex $args 0] 2]
		set votes [lindex [lindex $args 0] 3]
		
		cmdputblow "PRIVMSG $addmp3vidchan :!addimdb $rlsname $rating $votes $imdbid"
	
	}
}

proc urlrls {bot com args} {
	global addmp3vidchan whichmp3vidbot 
	
	if { $bot == $whichmp3vidbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set url [lindex [lindex $args 0] 1]
			
		cmdputblow "PRIVMSG $addmp3vidchan :!addurl $rlsname $url"
	
	}
}

proc videoprerls {bot com args} {
	global addmp3vidchan whichmp3vidbot 
	
	if { $bot == $whichmp3vidbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set vidcodec [lindex [lindex $args 0] 1]
		set frmes [lindex [lindex $args 0] 2]
		set resl [lindex [lindex $args 0] 3]
		set resnfrmes [lindex [lindex $args 0] 4]
		set audcodec [lindex [lindex $args 0] 5]
		set bitrate [lindex [lindex $args 0] 6]
		set hertz [lindex [lindex $args 0] 7]
		set channel [lindex [lindex $args 0] 8]


		cmdputblow "PRIVMSG $addmp3vidchan :!addvideoinfo $rlsname $vidcodec $frmes $resl $resnfrmes $audcodec $bitrate $hertz $channel"
		
	}
}

proc mp3prerls {bot com args} {
	global addmp3vidchan whichmp3vidbot 
	
	if { $bot == $whichmp3vidbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set genre [lindex [lindex $args 0] 1]
		set year [lindex [lindex $args 0] 2]
		set hertz [lindex [lindex $args 0] 3]
		set type [lindex [lindex $args 0] 4]
		set bitrate [lindex [lindex $args 0] 5]
		set bittype [lindex [lindex $args 0] 6]

		cmdputblow "PRIVMSG $addmp3vidchan :!addmp3info $rlsname $genre $year $hertz $type $bitrate $bittype"
		
	}
}

proc nfoprerls {bot com args} {
	global addspamchan whichspambot 
	
	if { $bot == $whichspambot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set hash [lindex [lindex $args 0] 1]
		set filename [lindex [lindex $args 0] 2]
		set crc [lindex [lindex $args 0] 3]
		set size [lindex [lindex $args 0] 4]

		cmdputblow "PRIVMSG $addspamchan :!addnfo $rlsname https://example.com/file.php?l=$hash $filename $crc $size"
	
	}
}

proc sfvprerls {bot com args} {
	global addspamchan whichspambot 
	
	if { $bot == $whichspambot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set hash [lindex [lindex $args 0] 1]
		set filename [lindex [lindex $args 0] 2]
		set crc [lindex [lindex $args 0] 3]
		set size [lindex [lindex $args 0] 4]
		
		cmdputblow "PRIVMSG $addspamchan :!addsfv $rlsname https://example.com/file.php?l=$hash $filename $crc $size"
	
	}
}

proc m3uprerls {bot com args} {
	global addspamchan whichspambot 
	
	if { $bot == $whichspambot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set hash [lindex [lindex $args 0] 1]
		set filename [lindex [lindex $args 0] 2]
		set crc [lindex [lindex $args 0] 3]
		set size [lindex [lindex $args 0] 4]
		
		cmdputblow "PRIVMSG $addspamchan :!addm3u $rlsname https://example.com/file.php?l=$hash $filename $crc $size"
	
	}
}

proc jpgprerls {bot com args} {
	global addspamchan whichspambot 
	
	if { $bot == $whichspambot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set hash [lindex [lindex $args 0] 1]
		set filename [lindex [lindex $args 0] 2]
		set crc [lindex [lindex $args 0] 3]
		set size [lindex [lindex $args 0] 4]
		
		cmdputblow "PRIVMSG $addspamchan :!addjpg $rlsname https://example.com/file.php?l=$hash $filename $crc $size"
	
	}
}

proc dizprerls {bot com args} {
	global addspamchan whichspambot 
	
	if { $bot == $whichspambot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set hash [lindex [lindex $args 0] 1]
		set filename [lindex [lindex $args 0] 2]
		set crc [lindex [lindex $args 0] 3]
		set size [lindex [lindex $args 0] 4]
		
		cmdputblow "PRIVMSG $addspamchan :!adddiz $rlsname https://example.com/file.php?l=$hash $filename $crc $size"
	
	}
}

putlog "xxx BL0WFiSH --> NFO|SFV|M3U|JPG|DIZ & ViDMP3iMDB Script v0.80 by Islander -- Loaded Succesfully!"