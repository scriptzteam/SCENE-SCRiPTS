package require TclCurl

# enable blowfish encryption in channel
set blowfish_(enabled) "1"

# Drftpd or glftpd bot nick
set autoupbotnick "eAutoUp"

set isy_(up_chan) "#autoup"

# Announce url without passkey
set isy_(ann_url) "https://example.com/announce.php"

set isy_(login_url) "https://example.com/login.php?id=37&hash=xxx"
set isy_(takelogin_url) "https://example.com/login.php?id=37&hash=xxx"

# Upload & Download URL's
set isy_(up_url) "https://example.com/upload.php"
set isy_(takeup_url) "https://example.com/takeupload.php"

set isy_(down_url) "https://example.com/download.php"

set isy_(dir_path) "/home/eggbots/unrar-data"

set isy_(torrent_output) "/home/eggbots/unrar-torrent-dir"
set isy_(watch_dir) "/home/eggbots/unrar-rtorrent-watch/xxx"

set isy_(rtorrent_fastresume) "nh.pl"
set isy_(torrent_origdir) "/home/eggbots/unrar-torrent-original/xxx"

set isy_(agent) "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2b5) Gecko/20091204 Firefox/3.6b5 GTB7.0"

set isy_(cookie_path) "/home/eggbots/xxxcookie.txt"

# Escape the brackets with "\"
set isy_(site_name) "xxx"

# Upload timeout in seconds
set isy_(timeout) 8

bind pub - !eupload isy:uploadtorrent
bind pub - !edelete isy:deletetorrent

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
proc isy:getcategoryid { release section } {
	
	set id "6"
	
	if { $section == "X264" } {
		
		if {[regexp -nocase {[\.\-\_](1080i|1080p)[\.\-\_]} $release]} { set id "2" }
		if {[regexp -nocase {[\.\-\_](720i|720p)[\.\-\_]} $release]} { set id "6" }
		
	} elseif { $section == "XVID" } {
	
		set id "8"
		
	} elseif { $section == "DVDR" } {
	
		set id "5"
		
	}
	
	return $id
}

proc isy:deletetorrent {nick host hand chan arg} {
global isy_

	set release [string trim [lindex $arg 1]]
	set category [string trim [lindex $arg 0]]
	
	if { [file exists $isy_(watch_dir)/$release.$isy_(site_name).torrent] } {
	
		exec rm $isy_(watch_dir)/$release.$isy_(site_name).torrent
		
		if { [file exists $isy_(torrent_origdir)/$release.torrent] } {
			exec rm $isy_(torrent_origdir)/$release.torrent
		}
		
		cmdputblow "PRIVMSG $isy_(up_chan) :$isy_(site_name) => \0034eDELETE\003 $category => $release"
		
	}

}

proc isy:uploadtorrent {nick host hand chan arg} {
global isy_ createtrtbotnick 
	
		set release [string trim [lindex $arg 1]]
		set category [string trim [lindex $arg 0]]
		set nfo [string trim [lindex $arg 2]]
		set cat [string trim [lindex [string trim [split $category "/"]] 0]]
		set nfopath $isy_(dir_path)/$category/$release/$nfo
		
		set postdata_nfo $nfopath
		set postdata_file $isy_(torrent_output)/$category/$release.torrent
		
		set postdata_type [string trim [isy:getcategoryid $release $cat]]
		
		if { $postdata_type == ""} { return; }
		
		curl::transfer -url $isy_(takelogin_url) -timeout $isy_(timeout) -verbose 1 -post 1 -httppost [list name "action" contents "login"] -httppost [list name "pincode" contents "11111"] -followlocation 1 -maxredirs 1 -useragent $isy_(agent) -cookiefile $isy_(cookie_path) -cookiejar $isy_(cookie_path) -referer $isy_(login_url) -httpheader "Expect: "
		
		curl::transfer -url $isy_(takeup_url) -timeout $isy_(timeout) -bodyvar downid -verbose 1 -post 1 -httppost [list name "submit"  contents "true"] -httppost [list name "uplver"  contents "yes"] -httppost [list name "slow_speed"  contents "no"] -httppost [list name "intenc"  contents "no"] -httppost [list name "type" contents $postdata_type] -httppost [list name "nfo" file "$postdata_nfo"] -httppost [list name "file" file "$postdata_file"] -httppost [list name "showid" contents "1"] -httppost [list name "MAX_FILE_SIZE" contents "5000000"] -followlocation 1 -maxredirs 2 -useragent $isy_(agent) -cookiefile $isy_(cookie_path) -cookiejar $isy_(cookie_path) -referer $isy_(up_url) -httpheader "Expect: "
		
		if { $downid != "" } {
			
			curl::transfer -url $isy_(down_url)/$downid/0/$release.torrent -timeout $isy_(timeout) -file $isy_(torrent_origdir)/$release.torrent -useragent $isy_(agent) -cookiefile $isy_(cookie_path) -cookiejar $isy_(cookie_path) -httpheader "Expect: "

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
				
				set msg "$isy_(site_name) => e\0033\002$release\002\003 eTorrent Uploaded & Successfully Copied to rtorrent watch directory"
				
			} else {
			
				set msg "$isy_(site_name) => e\0034\002$release\002 eTorrent Seeding FAiLED!!\003"
			
			}
		
		} else {
			
			set msg "$isy_(site_name) => e\0034\002$release\002 eTorrent Upload FAiLED!!\003"
			
		}
		
	cmdputblow "PRIVMSG $isy_(up_chan) :$msg"
	
}

putlog "$isy_(site_name) eAutoUp-D0WN FiSH v1.76 By Islander -> Loaded Successfully."