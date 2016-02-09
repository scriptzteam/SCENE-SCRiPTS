package require TclCurl
package require http

# enable blowfish encryption in channel
set blowfish_(enabled) "1"

# Drftpd or glftpd bot nick
set createtrtbotnick "AutoUp"

set isy_(up_chan) "#autoup"

# Escape the brackets with "\"
set isy_(site_name) "xxx"

set isy_(login_name) "xxx"

set isy_(login_password) "xxx"

# Announce url without passkey
set isy_(ann_url) "http://example.com/announce.php"

set isy_(login_url) "http://example.com/en/user?action=login"
set isy_(takelogin_url) "http://example.com/en/user?action=login"

# Upload & Download URL's
set isy_(up_url) "http://example.com/en/torrent?action=upload"
set isy_(takeup_url) "http://example.com/en/torrent?action=upload"

set isy_(down_url) "http://example.com/download.php?id="

set isy_(dir_path) "/jail/glftpd/site/incoming"

set isy_(rtorrent_fastresume) "nh.pl"

set isy_(torrent_output) "/home/eggbots/torrent-dir"

set isy_(torrent_origdir) "/home/eggbots/torrent-original/xxx"

set isy_(watch_dir) "/home/eggbots/rtorrent-watch/xxx"

set isy_(agent) "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2b5) Gecko/20091204 Firefox/3.6b5 GTB7.0"

set isy_(cookie_path) "/home/eggbots/xxxcookie.txt"

# Upload timeout in seconds
set isy_(timeout) 8

bind pub - !seedingdelete isy:deletemytorrent
bind pub - !upload isy:uploadtorrent

if { $blowfish_(enabled) == "1" } {
	bind pub - +OK cmdencryptedincominghandler
}

# blowcrypt code by poci modified by sCRiPTzTEAM
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

# blowcrypt code by poci modified by sCRiPTzTEAM END

proc isy:getcategoryid { section } {
	
	#set match [string match "*/*" $section]
	
	#if { $match == "1" } {
		#set section [string trim [lindex [split $section "/"] end]]
	#}
	
	array set catid {
			"DVDR-NORDIC" 				"3"
			"TV-DVDR-NORDIC" 			"15"
			"TV-DVDRIP-NORDIC" 			"15"
			"TV-X264-NORDIC" 			"8"
			"TV-XVID-NORDIC" 			"15"
			"X264-NORDIC" 				"9"
			"XVID-NORDIC" 				"18"
			
			"0DAY"  					"17"
            "eBOOK"  					"2"
			"APPS"  					"17"
			"ANIME"  					"1"
			"DOX"  						"5" 
            "DVDR"  					"3"
			"GAMES"  					"11"
			"MDVDR"  					"12"
			"MP3"  						"6"
			"MISC"  					"5"
			"MVID"  					"12"
			"NDS"  						"4"
			"PS2"  						"4"
			"PS3"  						"4"
			"PSP"  						"4"
			"TV-DVDR"  					"15"
			"TV-DVDRIP"  				"15"
            "TV-X264"  					"8"
			"TV-HDRIP"  				"8"
            "TV-BLURAY"  				"8"
			"TV-XVID"  					"15"
			"WII"  						"4"
			"X264"  					"9"
			"XBOX360"  					"4"
			"XVID"  					"18"
			"XXX"  						"14"
			"XXX-0DAY"  				"14"
			"XXX-DVDR"  				"14"
			"XXX-X264"  				"14"
			"XXX-IMGSETS"  				"14"
            "FLAC"  					"6"
	}
	
    foreach {sec cid} [array get catid] {
        if {[string equal -nocase $sec $section]} {
			return $cid
		} 
    }
}

proc isy:deletemytorrent {nick host hand chan arg} {
global isy_
	
	set rlsname [string trim [lindex $arg 0]]
	
	if { [file exists $isy_(torrent_origdir)/$rlsname.torrent] } {
		exec rm $isy_(torrent_origdir)/$rlsname.torrent
	}

	if { [file exists $isy_(watch_dir)/$rlsname.$isy_(site_name).torrent] } {
	
		exec rm $isy_(watch_dir)/$rlsname.$isy_(site_name).torrent
		
		cmdputblow "PRIVMSG $isy_(up_chan) :$isy_(site_name) => Deleted & Seeding Stopped for $rlsname"
		
	}

}

proc isy:uploadtorrent {nick host hand chan arg} {
global isy_ createtrtbotnick 
	
		set release [string trim [lindex $arg 1]]
		set category [string trim [lindex $arg 0]]
		set nfo [string trim [lindex $arg 2]]
		set cat [string trim [lindex [string trim [split $category "/"]] 0]]
		set nfopath $isy_(dir_path)/$category/$release/$nfo
		
		if { $cat == "MP3" } { return }
		if { $cat == "FLAC" } { return }
		
		if { $category == "TV-NORDIC" } { 
			
			set cat "TV-XVID-NORDIC"
			
			if {[regexp -nocase {[\.\-\_]([phs]?dtv|vhs|sat|xvid|dvb)(rip)?[\.\-\_]} $release]} { set cat "TV-XVID-NORDIC" }
			if {[regexp -nocase {[\.\-\_]([xh]264|720p|1080i|1080p)[\.\-\_]} $release]} { set cat "TV-X264-NORDIC" }
			if {[regexp -nocase {[\.\-\_]((hd)?dvd|b[rd]|blu[e3]?ray)(rip)[\.\-\_]} $release]} { set cat "TV-DVDRIP-NORDIC" }
			if {[regexp -nocase {[\.\-\_]((S|season)[0-9]{1,3}(DVD|D|DIS[CK])[0-9]{1,3}|(cn)?dvd[r9])[\.\-\_]} $release]} { set cat "TV-DVDR-NORDIC" }
	
		}
		
		set postdata_nfo $nfopath
		set postdata_type [isy:getcategoryid $cat]
		set postdata_file $isy_(torrent_output)/$category/$release.torrent
		set zero "0"
		set one "1"
		set empty ""
		
		# curl -F username=xxx -F password=xxx -F login=Login -F remember_me=on -L http://example.com/index.php?pid=upload --cookie username=xxx --cookie password=xxx --cookie-jar thisfile --max-redirs 5 -A Mozilla/5.0 \(X11; U; Linux i686; en-US; rv:1.9.2b5\) Gecko/20091204 Firefox/3.6b5 GTB7.0

		#curl::transfer -url $isy_(login_url) -timeout $isy_(timeout) -verbose 1 -followlocation 1 -maxredirs 3 -useragent $isy_(agent) -cookiefile $isy_(cookie_path) -cookiejar $isy_(cookie_path) -httpheader "Expect: "
		
		curl::transfer -url $isy_(login_url) -timeout $isy_(timeout) -verbose 1 -post 1 -httppost [list name "username"  contents $isy_(login_name)] -httppost [list name "password" contents $isy_(login_password)] -httppost [list name "login"  contents "Login"] -httppost [list name "remember_me"  contents "on"] -followlocation 1 -maxredirs 4 -useragent $isy_(agent) -cookiefile $isy_(cookie_path) -cookiejar $isy_(cookie_path) -referer $isy_(login_url) -httpheader "Expect: "
		
		#curl::transfer -url $isy_(takeup_url) -timeout $isy_(timeout) -file "/home/eggbots/file.txt" -verbose 1 -post 1 -httppost [list name "youtube" contents $empty] -httppost [list name "url" contents $empty] -httppost [list name "section" contents $one] -httppost [list name "tiexc" contents $zero] -httppost [list name "p2p" contents $zero] -httppost [list name "anonym" contents $one] -httppost [list name "type" contents $postdata_type] -httppost [list name "file" file $postdata_file contenttype "application/x-bittorrent"] -httppost [list name "nfo" file $postdata_nfo contenttype "multipart/form-data"] -httppost [list name "upload" contents "Upload Torrent"] -followlocation 1 -maxredirs 4 -useragent $isy_(agent) -cookiefile $isy_(cookie_path) -cookiejar $isy_(cookie_path) -referer $isy_(takeup_url) -httpheader "Expect: "
		
		curl::transfer -url $isy_(takeup_url) -timeout $isy_(timeout) -bodyvar html3 -verbose 1 -post 1 -httppost [list name "upload" contents "Upload Torrent"] -httppost [list name "type" contents $postdata_type] -httppost [list name "file" file $postdata_file contenttype "application/x-bittorrent"] -httppost [list name "nfo" file $postdata_nfo contenttype "multipart/form-data"] -followlocation 1 -maxredirs 4 -useragent $isy_(agent) -cookiefile $isy_(cookie_path) -cookiejar $isy_(cookie_path) -referer $isy_(takeup_url) -httpheader "Expect: "

		set downed [string match "*Download*download.php*" $html3]
		
		if { $downed == "1" } {
			
			regexp -line {.*Download.*download.php.*} $html3 downline
			
			set downid [string trim [lindex [split [string trim [lindex [string trim [split [string trim $downline] "="]] 3]] "\""] 0]]
			
			curl::transfer -url $isy_(down_url)$downid -timeout $isy_(timeout) -file $isy_(torrent_origdir)/$release.torrent -useragent $isy_(agent) -cookiefile $isy_(cookie_path) -cookiejar $isy_(cookie_path) -httpheader "Expect: "
		
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
			
				set msg "$isy_(site_name) => \0034\002$release\002 Torrent Seeding FAiLED!!\003"
			
			}
		
		} else {
			
			set msg "$isy_(site_name) => \0034\002$release\002 Torrent Upload FAiLED!!\003"
			
		}
		
	cmdputblow "PRIVMSG $isy_(up_chan) :$msg"
	
}

putlog "$isy_(site_name) AutoUp-D0WN FiSH v1.76 By sCRiPTzTEAM -> Loaded Successfully."