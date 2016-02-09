# enable blowfish encryption in channel
set blowfish_(enabled) "1"

# Drftpd or glftpd bot nick
set trackbotnick "A-PRE"

set isy_(log_chan) "#A.autoup"

# Announce url with passkey
set isy_(ann_url) "http://www.abcd.com/announce.php"

set isy_(torrent_output) "/home/user/torrent-dir"

set isy_(dir_path) "/data/slave/site"

set isy_(filesdblink) "/home/user/files-db"

bind pub - !complete isy:createtorrent

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
	
	if { $chan != $isy_(log_chan) } {return}
	
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

proc isy:piece_size {len} {

	set p 256
	
	if {$len >= 4000000} {
		set p 4096
	} elseif {$len >= 2000000} {
		set p 2048
	} elseif {$len >= 1000000} {
		set p 1024
	} elseif {$len >= 100000} {
		set p 512
	}
	
	return $p
	
}

proc isy:createtorrent {nick host hand chan arg} {
 global isy_ trackbotnick 
	
	if { $nick == $trackbotnick } {
	
	set a [clock seconds]
	set release [string trim [lindex $arg 1]]
	set category [string trim [lindex $arg 0]]
	
	if { $category == "" || $release == "" } {
	
		cmdputblow "PRIVMSG $isy_(log_chan) :\0034\002\Release Name or Category Empty !!\002\003"
		return
		
	}
	
	if { $category == "0DAY" || $category == "MP3" || $category == "XXX-0DAY" } {
		
		set whatjoin [clock format [clock seconds] -format %m%d]
		
		if { ![file isdirectory $isy_(torrent_output)/$category] } {
			exec mkdir $isy_(torrent_output)/$category
		}
		
		if { ![file isdirectory $isy_(torrent_output)/$category/$whatjoin] } {
			exec mkdir $isy_(torrent_output)/$category/$whatjoin
		}
		
		set category $category/$whatjoin
	
	} elseif { ![file isdirectory $isy_(torrent_output)/$category] } {

		exec mkdir $isy_(torrent_output)/$category
	}
	
	if { [file exists $isy_(torrent_output)/$category/$release.torrent] } {
	
		cmdputblow "PRIVMSG $isy_(log_chan) :\0032\002$release\002\003 Torrent already exists"
		return
		
	}

	set ndir $isy_(dir_path)/$category/$release
	
	if { ![file isdirectory $ndir] } {
	
		cmdputblow "PRIVMSG $isy_(log_chan) :\0032\002$release\002\003 N0T F0UND !!"
		return
		
    }
	
	set dirsize [string trim [lindex [exec du -c $ndir] 0]]
	
	set psize [isy:piece_size $dirsize]
	
	catch { exec mktorrent -bs $psize -a $isy_(ann_url) -o $isy_(torrent_output)/$category/$release.torrent $ndir } data
	
	set b [expr [clock seconds] - $a]
	
	set status [string trim [lindex $data end]]
	
	if { $status == "100%" } {
	
		set size [filesize [file size $isy_(torrent_output)/$category/$release.torrent]]
		set dsize [filesize $dirsize]
		
		set var [glob -directory $ndir *.nfo]
		set nfo [string trim [lindex [split $var "/"] end]]
		
		cmdputblow "PRIVMSG $isy_(log_chan) :!upload $category $release $nfo"
		cmdputblow "PRIVMSG $isy_(log_chan) :\0033\002$release\002\003 \[$dsize\] Torrent Successfully Created in $b seconds with $size . Sending Upload command..."
		
		exec ln -s $ndir $isy_(filesdblink)
		return
	
	} else {
	
		cmdputblow "PRIVMSG $isy_(log_chan) :\0034\002$release\002 Torrent Creation FAiLED !!\003"
		return
		
	}
	
	}
	

}

proc filesize { zzzsize } {
	set size [lindex $zzzsize 0]
	
	set sized "0 kB"
	
	if {[expr $size / 1073741824] >= 1} {
	
		set sized "[string range "[expr $size / 1073741824.0]" 0 [expr [string length "[expr $size / 1073741824]"]+ 2] ] GB"
	
	} elseif {[expr $size / 1048576] >= 1} {
	
		set sized "[string range "[expr $size / 1048576.0]" 0 [expr [string length "[expr $size / 1048576]"]+ 2] ] MB"
		
	} elseif {[expr $size / 1024] >= 1} {
	
		set sized "[string range "[expr $size / 1024.0]" 0 [expr [string length "[expr $size / 1024]"]+ 2] ] KB"
		
	}
	
	return $sized
}

putlog "AutoCreate Torrent FiSH v1.28 By sCRiPTzTEAM -> Loaded Successfully."