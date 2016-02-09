
package require TclCurl
package require http

# enable blowfish encryption in channel
set blowfish_(enabled) "1"

# Drftpd or glftpd bot nick
set createtrtbotnick "CreateT"

set isy_(up_chan) "#A.autoup"

# Escape the brackets with "\"
set isy_(site_name) "xxx"

# Announce url without passkey
set isy_(ann_url) "http://example.com/announce.php"

# Upload & Download URL's
set isy_(up_url) "http://example.com/takeupload.php"
set isy_(down_url) "http://example.com/download.php"

set isy_(dir_path) "/data/slave/site"

set isy_(torrent_output) "/home/user/torrent-dir"
set isy_(watch_dir) "/home/user/rtorrent-watch/xxx"

# Upload timeout in seconds
set isy_(timeout) 8

bind pub - !upload isy:uploadtorrent

if { $blowfish_(enabled) == "1" } {
	bind pub - +OK cmdencryptedincominghandler
}

# blowcrypt code by poci modified by sCRiPTzTEAM
# Make sute u change the channel name and fishkey in the getfishkey function

proc getfishkey { chan } {
	
	array set channelkeys {
			"#A.autoup" 		"xxxx" 
	}
	
    foreach {channel blowkey} [array get channelkeys] {
        if {[string equal -nocase $channel $chan]} {
			return $blowkey
		} 
    }
}

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

proc cmdencryptedincominghandler {nick host hand chan arg} {
	global isy_
	
	if { $chan != $isy_(up_chan) } {return}
	
	set blowfishkey [getfishkey [string tolower $chan]]
	
	if { $blowfishkey == "" } {return}
	
	set tmp [decrypt $blowfishkey $arg]
	set tmp [stripcodes bc $tmp]
	
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

proc isy:getcategoryid { section } {
	
	set match [string match "*/*" $section]
	
	if { $match == "1" } {
		set section [string trim [lindex [split $section "/"] end]]
	}
	
	array set catid {
			"0DAY" 				"17"
			"ANIME" 			"9"
			"APPS" 				"14"
			"BLURAY-TV" 		"28"
			"DVDR" 				"11"
			"EBOOKS" 			"15"
			"GAMES" 			"2"
			"MDVDR" 			"34"
			"MP3" 				"4"
			"MVID" 				"34"
			"NDS" 				"31"
			"PS3" 				"19"
			"PS2" 				"8"
			"PSP" 				"20"
			"TV-DVDR" 			"29"
			"TV-DVDRIP" 		"5"
			"TV-X264" 			"28"
			"TV-XVID" 			"16"
			"WII" 				"26"
			"X264" 				"3"
			"XBOX360" 			"22"
			"XVID" 				"10"
			"XXX" 				"6"
			"XXX-0DAY" 			"6"
			"XXX-DVDR" 			"6"
			"XXX-X264" 			"6"
	}
	
    foreach {sec cid} [array get catid] {
        if {[string equal -nocase $sec $section]} {
			return $cid
		} 
    }
}

proc isy:uploadtorrent {nick host hand chan arg} {
global isy_ createtrtbotnick 
	
	if { $nick == $createtrtbotnick } {
	
		set release [string trim [lindex $arg 1]]
		set category [string trim [lindex $arg 0]]
		set nfo [string trim [lindex $arg 2]]
		set catmain [string trim [lindex [string trim [split $category "/"]] 0]]
		set nfopath $isy_(dir_path)/$category/$release/$nfo

		
		set postdata_nfo $nfopath
		set postdata_type [isy:getcategoryid $catmain]
		set postdata_file $isy_(torrent_output)/$category/$release.torrent
		
		curl::transfer -url $isy_(up_url) -timeout $isy_(timeout) -bodyvar html -verbose 1 -post 1 -httppost [list name "type"  contents "$postdata_type"] -httppost [list name "file" file "$postdata_file"] -httppost [list name "nfo" file "$postdata_nfo"] -verbose 1
		
		set downed [lindex [string trim $html] 0]
		set downid [lindex [string trim $html] 1]
		
		if { $downed == "OK" } {
			
			curl::transfer -url $isy_(down_url)?torrent=$downid -timeout $isy_(timeout) -file $isy_(watch_dir)/$release.torrent
			
			set data [open $isy_(watch_dir)/$release.torrent "RDONLY"]
			set trtdata [read $data]
			close $data
			
			set torrentdataok [string match $isy_(ann_url) $trtdata]
			
			if { $torrentdataok == "0" } {
				set msg "$isy_(site_name) => \0033\002$release\002\003 Torrent Uploaded & Successfully Copied to rtorrent watch directory"
			} else {
				set msg "$isy_(site_name) => \0034\002$release\002 Torrent FAiLED Copying to rtorrent watch directory!!\003"
			}
		
		} else {
		
			set msg "$isy_(site_name) => \0034\002$release\002 Torrent Upload FAiLED!!\003"
		
		}
		
		cmdputblow "PRIVMSG $isy_(up_chan) :$msg"
	
	}
}

putlog "$isy_(site_name) AutoUp-D0WN FiSH v1.30 By sCRiPTzTEAM -> Loaded Successfully."