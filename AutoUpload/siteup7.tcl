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
set isy_(ann_url) "http://example.com:2710"

set isy_(login_url) "http://example.com/login.php"
set isy_(takelogin_url) "http://example.com/login.php"

# Upload & Download URL's
set isy_(up_url) "http://example.com/upload.php"
set isy_(takeup_url) "http://example.com/upload.php"

set isy_(down_url) "http://example.com/"

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

proc isy:getcategoryid { section } {
	
	array set catid {
		"0"        "Ambient"
		"1"        "Americana"
		"2"        "Artwork"
		"3"        "Blues"
		"4"        "Chillout"
		"5"        "Classical"
		"6"        "Country"
		"7"        "DVDA"
		"8"        "DVDV"
		"9"        "Electronic"
		"10"       "Emo"
		"11"       "Hardcore"
		"12"       "Experimental"
		"13"       "Folk"
		"14"       "Folk_Rock"
		"15"       "Funk"
		"16"       "Hip_Hop"
		"17"       "Rap"
		"18"       "Holiday"
		"19"       "Indie"
		"20"       "Jazz"
		"21"       "Jazz_Rock"
		"22"       "Fusion"
		"23"       "Krautrock"
		"24"       "Latin"
		"25"       "Metal"
		"26"       "Other"
		"27"       "Pop"
		"28"       "Progressive_Rock"
		"29"       "Psychadelic_Rock"
		"30"       "Psychadelic_Trance"
		"31"       "Dark_Psychadelic"
		"32"       "Punk"
		"33"       "Rhythm_And_Blues"
		"34"       "Reggae"
		"35"       "Rock"
		"36"       "Ska"
		"37"       "Soul"
		"38"       "Soundtrack"
		"39"       "Spoken_Word"
		"40"       "Comedy"
		"41"       "Vinyl"
		"42"       "World"
		"43"       "Christian"
		"44"       "Alternative"
		"45"       "Death_Metal"
		"46"       "Asian"
		"47"       "Avant_Garde"
		"48"       "Bluegrass"
		"49"       "Classic_Rock"
		"50"       "Dance"
		"51"       "Dream_Pop"
		"52"       "Dubstep"
		"53"       "Goth"
		"54"       "Grindcore"
		"55"       "Grunge"
		"56"       "House"
		"57"       "IDM"
		"58"       "Industrial"
		"59"       "Lounge"
		"60"       "New_Age"
		"61"       "Noise"
		"62"       "Nu_Metal"
		"63"       "OST"
		"64"       "Pop_Punk"
		"65"       "Happy_Hardcore"
		"66"       "Post_Hardcore"
		"67"       "Post_Punk"
		"68"       "Post_Rock"
		"69"       "Screamo"
		"70"       "Shoe_Gaze"
		"71"       "Techno"
		"72"       "Trance"
		"73"       "Trip_Hop"
		"74"       "VGM"
	}
	
    foreach {cid sec} [array get catid] {
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
		
		set postdata_nfo $nfopath
		set postdata_file $isy_(torrent_output)/$category/$release.torrent

		if { $cat != "FLAC" } { return }
		
		set openid [open $postdata_nfo "RDONLY"]
		set postdata_descr [read -nonewline $openid]
		close $openid
		
		set rlsfetch [string trim [split $release "-"]]
		
		set artist [string trim [lindex $rlsfetch 0]]
		regsub -all {\.|\_|\-} $artist " " artist
		
		set title [string trim [lindex $rlsfetch 1]]
		
		if { $title == ""} { set title [string trim [lindex $rlsfetch 2]] }
		
		regsub -all {\.|\_|\-} $title " " title
		
		curl::transfer -url "http://example.com/getmp3info.php?name=$release" -timeout $isy_(timeout) -bodyvar mp3info -verbose 1
		
		set mp3main [string trim [split $mp3info ","]]
		
		set genre [lindex $mp3main 1]
		
		set postdata_type [string trim [isy:getcategoryid $genre]]
		
		if { $postdata_type == ""} { set postdata_type "26" }
		
		set year [lindex $mp3main 2]
		
		set format "FLAC"
		
		set bitrate "Lossless"
		
		set media "CD"
		if {[regexp -nocase {[_-]WEB[_-]} $release] } { set media "Web" }
		if {[regexp -nocase {[_-]dvd[0-9]?[_-]} $release] } { set media "DVD-A" }
		if {[regexp -nocase {[_-]vinyl[_-]} $release] } { set media "Vinyl" }
		if {[regexp -nocase {[_-]sacd[_-]} $release] } { set media "SACD" }
		
		set releasetype "4"
		
		regsub -all {\_|\-} $genre "." tags
		set tags [string trim [string tolower $tags]]
		
		if { $artist == "" || $title == "" || $year == "" || $postdata_type == "" || $media == "" } { return }
		
		curl::transfer -url $isy_(login_url) -timeout $isy_(timeout) -verbose 1 -followlocation 1 -maxredirs 1 -useragent $isy_(agent) -cookiefile $isy_(cookie_path) -cookiejar $isy_(cookie_path) -httpheader "Expect: "
		
		curl::transfer -url $isy_(takelogin_url) -timeout $isy_(timeout) -verbose 1 -post 1 -httppost [list name "username"  contents $isy_(login_name)] -httppost [list name "password" contents $isy_(login_password)] -followlocation 1 -maxredirs 1 -useragent $isy_(agent) -cookiefile $isy_(cookie_path) -cookiejar $isy_(cookie_path) -referer $isy_(login_url) -httpheader "Expect: "
		
		curl::transfer -url $isy_(up_url) -timeout $isy_(timeout) -bodyvar html2 -verbose 1 -followlocation 1 -maxredirs 1 -useragent $isy_(agent) -cookiefile $isy_(cookie_path) -cookiejar $isy_(cookie_path) -httpheader "Expect: "
		
		regexp -line {.*type.*hidden.*name.*auth.*} $html2 authkeyline
		
		set authkey [string trim [lindex [string trim [split [string trim $authkeyline] "\""]] 5]]
		
		curl::transfer -url $isy_(takeup_url) -timeout $isy_(timeout) -bodyvar html3 -verbose 1 -post 1 -httppost [list name "submit"  contents "true"] -httppost [list name "auth"  contents $authkey] -httppost [list name "releasetype"  contents $releasetype] -httppost [list name "media"  contents $media] -httppost [list name "format"  contents $format] -httppost [list name "bitrate"  contents $bitrate] -httppost [list name "fast"  contents "1"] -httppost [list name "tags"  contents $tags] -httppost [list name "scene"  contents "1"] -httppost [list name "year"  contents $year] -httppost [list name "artists\[\]" contents $artist] -httppost [list name "importance\[\]" contents "1"] -httppost [list name "title"  contents $title] -httppost [list name "scenename"  contents $release] -httppost [list name "type"  contents $postdata_type] -httppost [list name "file_input" file "$postdata_file"] -httppost [list name "album_desc" contents "$postdata_descr"] -httppost [list name "release_nfo" contents "$postdata_descr"] -followlocation 1 -maxredirs 1 -useragent $isy_(agent) -cookiefile $isy_(cookie_path) -cookiejar $isy_(cookie_path) -referer $isy_(up_url) -httpheader "Expect: "
		
		set downed [string match "*Peerlist*" $html3]
		
		if { $downed == "1" } {
			
			regexp -line {.*Download.*DL.*} $html3 downline
			
			set downid [string trim [lindex [string trim [split [string trim $downline] "\""]] 1]]
			
			regsub -all {amp;} $downid "" downid
			
			curl::transfer -url $isy_(down_url)/$downid -timeout $isy_(timeout) -file $isy_(torrent_origdir)/$release.torrent -useragent $isy_(agent) -cookiefile $isy_(cookie_path) -cookiejar $isy_(cookie_path) -httpheader "Expect: "

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

putlog "$isy_(site_name) AutoUp-D0WN FiSH v1.86 By Islander -> Loaded Successfully."