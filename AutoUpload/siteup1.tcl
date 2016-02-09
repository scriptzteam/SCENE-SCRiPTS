package require TclCurl

# enable blowfish encryption in channel
set blowfish_(enabled) "1"

# Drftpd or glftpd bot nick
set autoupbotnick "AutoUp"

set isy_(up_chan) "#autoup"

# Announce url without passkey
set isy_(ann_url) "http://example.com/announce.php"

# Upload & Download URL's
set isy_(up_url) "http://example.com/takeupxxx.php"
set isy_(down_url) "http://example.com/downloadbotxxx.php"

set isy_(dir_path) "/jail/glftpd/site"

set isy_(torrent_output) "/home/eggbots/torrent-dir"
set isy_(watch_dir) "/home/eggbots/rtorrent-watch/xxx"

set isy_(rtorrent_fastresume) "nh.pl"
set isy_(torrent_origdir) "/home/eggbots/torrent-original/xxx"

# Escape the brackets with "\"
set isy_(site_name) "xxx"

# Upload timeout in seconds
set isy_(timeout) 8

bind pub - !seedingdelete isy:deletemytorrent
bind pub - !upload isy:uploadtorrent

if { $blowfish_(enabled) == "1" } {
	bind pub - +OK cmdencryptedincominghandler
}

# blowcrypt code by poci modified by Islander
# Make sute u change the channel name and fishkey in the getfishkey function

proc getfishkey { chan } {
	
	array set channelkeys {
			"#autoup" 		"xxx" 
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

# blowcrypt code by poci modified by Islander END

proc isy:deletemytorrent {nick host hand chan arg} {
global isy_
	
	set rlsname [string trim [lindex $arg 0]]
	
	if { [file exists $isy_(torrent_origdir)/$rlsname.torrent] } {
		exec rm $isy_(torrent_origdir)/$rlsname.torrent
	}

	if { [file exists $isy_(watch_dir)/$rlsname.$isy_(site_name).torrent] } {
	
		exec rm $isy_(watch_dir)/$rlsname.$isy_(site_name).torrent
		
		cmdputblow "PRIVMSG $isy_(up_chan) :$isy_(site_name) => \0034DELETED & SEEDING STOPPED\003 => $rlsname"
		
	}

}

proc isy:uploadtorrent {nick host hand chan arg} {
global isy_  
	
	set release [string trim [lindex $arg 1]]
	set category [string trim [lindex $arg 0]]
	set nfo [string trim [lindex $arg 2]]
	set genre [string trim [lindex $arg 3]]
	set catmain [string trim [lindex [string trim [split $category "/"]] 0]]
	set nfopath $isy_(dir_path)/$category/$release/$nfo

	
	set postdata_nfo $nfopath
	set postdata_file $isy_(torrent_output)/$category/$release.torrent
	
	curl::transfer -url $isy_(up_url) -timeout $isy_(timeout) -bodyvar html -verbose 1 -post 1 -httppost [list name "genre"  contents "$genre"] -httppost [list name "type"  contents "$catmain"] -httppost [list name "file" file "$postdata_file"] -httppost [list name "nfo" file "$postdata_nfo"] -verbose 1
	
	set downed [lindex [string trim $html] 0]
	set downid [lindex [string trim $html] 1]
	
	if { $downed == "OK" } {
		
		curl::transfer -url $isy_(down_url)?torrent=$downid -timeout $isy_(timeout) -file $isy_(torrent_origdir)/$release.torrent
		
		set rlse $release
		
		regsub -all {\(} $rlse "\(" rls
		regsub -all {\)} $rls "\)" rls
		
		catch { exec $isy_(rtorrent_fastresume) $isy_(dir_path)/$category/ < $isy_(torrent_origdir)/$rls.torrent > $isy_(watch_dir)/$rls.$isy_(site_name).torrent } fastresume
		
		set fok [string trim [lindex $fastresume end]]

		set data [open $isy_(watch_dir)/$release.$isy_(site_name).torrent "RDONLY"]
		set trtdata [read $data]
		close $data
		
		set torrentdataok [string match $isy_(ann_url) $trtdata]
		
		if { $torrentdataok == "0" && $fok == "files." } {
		
			set msg "$isy_(site_name) => \0033\002$release\002\003 Torrent Uploaded & Successfully Copied to rtorrent watch directory"
		
		} else {
		
			set msg "$isy_(site_name) => \0034\002$release\002 Torrent FAiLED Copying to rtorrent watch directory!!\003 $fok $torrentdataok"
		
		}
	
	} else {
	
		set msg "$isy_(site_name) => \0034\002$release\002 Torrent Upload FAiLED!!\003"
	
	}
	
	cmdputblow "PRIVMSG $isy_(up_chan) :$msg"
}

putlog "$isy_(site_name) AutoUp-D0WN v1.57 By Islander -> Loaded Successfully."