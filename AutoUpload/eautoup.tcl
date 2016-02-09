# enable blowfish encryption in channel
set blowfish_(enabled) "1"

# Drftpd or glftpd bot nick
set upbotnick "AutoUp"

set isy_(log_chan) "#autoup"

# Announce url with passkey
set isy_(ann_url) "http://example.com/announce.php"

set isy_(torrent_output) "/home/eggbots/unrar-torrent-dir"

set isy_(unrar_data) "/home/eggbots/unrar-data"

set isy_(dir_path) "/jail/glftpd/site/incoming"

set isy_(filesdblink) "/home/eggbots/unrar-files-db"

set isy_(emptynfo) "/home/eggbots/sCRiPTzTEAM.nfo"

set isy_(skip1) ".message"
set isy_(skip2) ".imdb"
set isy_(skip3) ".*"

bind pub - !rmold isy:removeold
bind pub - !upload isy:extracttorrent

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

# Pieces function for mktorrent 1.0
# 18 = 256kb , 19 = 512kb , 20 = 1MB , 21 = 2MB , 22 = 4MB , 23 = 8MB
proc isy:piece_size {len} {

	set p 21
	
	if {$len >= 8000000} {
		set p 22
	} elseif {$len >= 4000000} {
		set p 22
	} elseif {$len >= 2000000} {
		set p 22
	} elseif {$len >= 1000000} {
		set p 22
	} elseif {$len >= 500000} {
		set p 21
	} elseif {$len >= 250000} {
		set p 21
	} elseif {$len >= 100000} {
		set p 21
	} elseif {$len >= 50000} {
		set p 20
	} elseif {$len >= 25000} {
		set p 20
	} elseif {$len >= 10000} {
		set p 20
	} elseif {$len >= 5000} {
		set p 19
	} elseif {$len >= 1000} {
		set p 19
	}
	
	return $p
	
}

# run every hour
bind time - "00 * * * *" isy:removeold

proc isy:removeold {nick host hand chan arg} {
 global isy_ 
	
	# 14 Days Delete
	set days "1209600"
	set exptime [clock seconds]
	incr exptime -$days
	
	set datadir $isy_(unrar_data)
    set sections [glob -nocomplain -directory $datadir *]
    
    foreach section $sections {
		
		set dirs [glob -nocomplain -directory $section *]
		
		set secname [string trim [lindex [string trim [split $section "/"]] end]]
		
		foreach release $dirs {
			
			file stat $release rdata
			
			set crtime $rdata(ctime)
			
			set rlsname [string trim [lindex [string trim [split $release "/"]] end]]

			if { $crtime < $exptime } { 
				
				if { [file isdirectory $release] } {
					exec rm -rf $release
				}
				
				if { [file isdirectory $isy_(filesdblink)/$rlsname] } {
					exec rm $isy_(filesdblink)/$rlsname
				}
				
				cmdputblow "PRIVMSG $isy_(log_chan) :!edelete $secname $rlsname"

			}
			
		}
		
    }
	
}

proc isy:extracttorrent {nick host hand chan arg} {
 global isy_ 
 
	set a [clock seconds]
	set release [string trim [lindex $arg 1]]
	set category [string trim [lindex $arg 0]]
	
	if { $category == "" || $release == "" } {
	
		cmdputblow "PRIVMSG $isy_(log_chan) :e\0034\002\Release Name or Category Empty !!\002\003"
		return;
		
	}
	
	if { $category == "X264" || $category == "XVID" || $category == "DVDR" } {
	
		if { ![file isdirectory $isy_(unrar_data)/$category] } {
			exec mkdir $isy_(unrar_data)/$category
		}

		set ndir $isy_(dir_path)/$category/$release
		
		if { ![file isdirectory $ndir] } {
		
			cmdputblow "PRIVMSG $isy_(log_chan) :e\0032\002$release\002\003 N0T F0UND !!"
			return
			
		}
		
		if { [file isdirectory $isy_(unrar_data)/$category/$release] } {
		
			cmdputblow "PRIVMSG $isy_(log_chan) :e\0032\002$release\002\003 unrar DATA already exists !!"
			return
			
		} else {
		
			exec mkdir $isy_(unrar_data)/$category/$release
		
		}
		
		set rarvar [glob -directory $ndir *.rar]
		set rarfile [string trim [lindex [split $rarvar "/"] end]]
		
		catch { exec unrar x $ndir/$rarfile $isy_(unrar_data)/$category/$release/ } data
		
		set b [expr [clock seconds] - $a]
		
		set status [string trim [lindex $data end]]
		
		if { $status == "OK" } {
		
			set nfovar [glob -directory $ndir *.nfo]
			set nfofile [string trim [lindex [split $nfovar "/"] end]]
			
			if { ![file exists $isy_(unrar_data)/$category/$release/$nfofile] } {
			
				exec cp $ndir/$nfofile $isy_(unrar_data)/$category/$release/$nfofile
				
			}
		
			cmdputblow "PRIVMSG $isy_(log_chan) :e\0033\002$release\002\003 eTorrent Successfully EXTRACTED in $b seconds. Creating Torrent file.... (Wait Time 2 seconds)"

			utimer 2 [list isy:createtorrent $category $release];
		
		} else {
			
			exec rm -rf $isy_(unrar_data)/$category/$release
			
			cmdputblow "PRIVMSG $isy_(log_chan) :e\0034\002$release\002 Torrent EXTRACTION FAiLED !!\003 Error: $status"
		
		}
	
	}
 
}

proc isy:createtorrent {category release} {
 global isy_ 
	
	set a [clock seconds]
	
	if { $category == "" || $release == "" } {
	
		cmdputblow "PRIVMSG $isy_(log_chan) :e\0034\002\Release Name or Category Empty !!\002\003"
		return
		
	}
	
	if { $category == "X264" || $category == "XVID" || $category == "DVDR" } {
	
		if { ![file isdirectory $isy_(torrent_output)/$category] } {

			exec mkdir $isy_(torrent_output)/$category
		}
		
		if { [file exists $isy_(torrent_output)/$category/$release.torrent] } {
		
			cmdputblow "PRIVMSG $isy_(log_chan) :e\0032\002$release\002\003 Torrent already exists"
			return
			
		}

		set ndir $isy_(unrar_data)/$category/$release
		
		if { ![file isdirectory $ndir] } {
		
			cmdputblow "PRIVMSG $isy_(log_chan) :e\0032\002$release\002\003 N0T F0UND !!"
			return
			
		}
		
		set dirsize [string trim [lindex [exec du -c $ndir] 0]]
		
		set psize [isy:piece_size $dirsize]
		
		# mktorrent 1.0
		catch { exec mktorrent -a $isy_(ann_url) -p -l $psize -o $isy_(torrent_output)/$category/$release.torrent $ndir } data

		set b [expr [clock seconds] - $a]
		
		set status [string trim [lindex $data end]]
		
		if { $status == "done." } {
		
			set size [filesize [file size $isy_(torrent_output)/$category/$release.torrent]]
			set dsize [filesize $dirsize]
			
			set var [glob -directory $ndir *.nfo]
			set nfo [string trim [lindex [split $var "/"] end]]
			
			cmdputblow "PRIVMSG $isy_(log_chan) :!eupload $category $release $nfo"
			cmdputblow "PRIVMSG $isy_(log_chan) :e\0033\002$release\002\003 \[$dsize\] eTorrent Successfully Created in $b seconds with $size . Sending Upload command..."
			
			exec ln -s $ndir $isy_(filesdblink)
			return
		
		} elseif { $status == "wrong..." } {
			
			exec rm $isy_(torrent_output)/$category/$release.torrent
			
			cmdputblow "PRIVMSG $isy_(log_chan) :e\0034\002$release\002 eTorrent Creation FAiLED !!\003 Error: $status \0033Timer Activated for 5 seconds\003"
		
			utimer 5 [list isy:createtorrent $category $release]
			
		} else {
			
			exec rm $isy_(torrent_output)/$category/$release.torrent
			
			cmdputblow "PRIVMSG $isy_(log_chan) :e\0034\002$release\002 eTorrent Creation FAiLED !!\003 Error: $status"
			
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

putlog "eAutoUpload v1.16 By sCRiPTzTEAM -> Loaded Successfully."