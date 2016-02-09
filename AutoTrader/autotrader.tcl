
# This is a Tcl script to be run immediately after connecting to a server.
proc evnt:init_server {type} {

  global botnick
  putquick "MODE $botnick +i-ws"
  putserv "NickServ :Identify xxx"
  #ins:inviteme $botnick
  
}

proc ins:inviteme { botircnick } {
	global from
	
	exec lftp $from(host) -p $from(port) -u $from(nick),$from(pass) -e "site invite $botircnick;close -a;bye;"
	
	return
	
}


set settings(uniqueid) "ins-race"

set settings(raceaffils) "1"

set settings(paralleldown) "2"

set settings(logdir) "/home/prebots/lftplogs/"

set settings(logchan) "#fn-racelog"

set from(host) "1.2.3.4"
set from(port) "12345"
set from(nick) "xxx"
set from(pass) "xxxx"

set to(host) "ftpd.example.com"
set to(port) "54321"
set to(nick) "xxx"
set to(pass) "xxxx"

# set 0 to disable or 1 to enable FiSH Support on ALL channels
set blowfish_(enabled) "1"

# Channel FIsh keys , leave Empty to disable FiSH for a specific channel [N0T CASTE SENSiTiVE]
array set channels_fishkey {
		"#xxx" 				"xxx"
		"#spam" 			"xxx"
		"#racelog"   		"xxx"
	}

# set 0 to disable , 1 to enable racing stuff from specific IRC Bot Nick [N0T CASTE SENSiTiVE]
array set bots_race {

		"xxx" 	"0"
		"xxx" 	"1"
		"xxx" 	"1"
		
	}

# Racing Channels
# set 0 to disable , 1 to enable racing stuff from specific channel [N0T CASTE SENSiTiVE]
array set channels_race {

		"#xxx" 			"0"
		"#spam" 		"1"
		"#chat" 		"0"
		"#racelog" 		"1"
		
	}
	
# IRC Category Race
# set 0 to disable , 1 to enable racing stuff for that category [N0T CASTE SENSiTiVE]
array set category_racing {

		"0DAY" 			"0"
		"APPS" 			"0"
		"TV-HDRIP"      "0" 
		"DVDR" 			"0"
		"EBOOKS" 		"0"
		"FLAC"          "1"
		"GAMES" 		"0" 
		"MDVDR" 		"0"
		"MP3" 			"1"
		"MVID" 			"0"
		"NDS" 			"0"
		"PS3" 			"0"
		"PSP" 			"0"
		"TV-DVDR" 		"0"
		"TV-DVDRIP"     "0"
		"TV-X264" 		"0"
		"TV-XVID" 		"0" 
		"WII" 			"0" 
		"X264" 			"0"
		"XBOX360" 		"0"
		"XVID" 			"0"
		"XXX" 			"0"
		"XXX-0DAY" 		"0"
		"XXX-DVDR" 		"0"

	}
	
# Category Replace
# FR0M IRC Announce category to FR0M IRC FTP category [FR0M IRC FTP category: CASTE SENSiTiVE]
array set category_replace_from { 
		"0DAY" 			"0DAY-today"
		"APPS" 			"APPS"
		"TV-HDRIP" 	    "TV-HDRIP" 
		"DVDR" 			"DVDR"
		"EBOOKS" 		"EBOOKS"
		"FLAC"          "FLAC-today"
		"GAMES" 		"GAMES" 
		"MDVDR" 		"MDVDR"
		"MP3" 			"MP3-today"
		"MVID" 			"MVID"
		"NDS" 			"NDS"
		"PS3" 			"PS3"
		"PSP" 			"PSP"
		"TV-DVDR" 		"TV-DVDR"
		"TV-DVDRIP"     "TV-DVDRIP"
		"TV-X264" 		"TV-X264"
		"TV-XVID" 		"TV-XVID" 
		"WII" 			"WII" 
		"X264" 			"X264"
		"XBOX360" 		"XBOX360"
		"XVID" 			"XVID"
		"XXX" 			"XXX"
		"XXX-0DAY" 		"XXX-0DAY-today"
	}
	
# Category Replace
# FR0M IRC Announce category to T0 IRC FTP category [T0 IRC FTP category: CASTE SENSiTiVE]
array set category_replace_to { 
		"0DAY" 			"0DAY-today"
		"APPS" 			"APPS"
		"TV-HDRIP" 	    "TV-HDRIP" 
		"DVDR" 			"DVDR"
		"EBOOKS" 		"EBOOKS"
		"FLAC"          "FLAC-today"
		"GAMES" 		"GAMES" 
		"MDVDR" 		"MDVDR"
		"MP3" 			"MP3-today"
		"MVID" 			"MVID"
		"NDS" 			"NDS"
		"PS3" 			"PS3"
		"PSP" 			"PSP"
		"TV-DVDR" 		"TV-DVDR"
		"TV-DVDRIP" 	"TV-DVDRIP"
		"TV-X264" 		"TV-X264"
		"TV-XVID" 		"TV-XVID" 
		"WII" 			"WII" 
		"X264" 			"X264"
		"XBOX360" 		"XBOX360"
		"XVID" 			"XVID"
		"XXX" 			"XXX"
		"XXX-0DAY" 		"XXX-0DAY-today"
	}

# Sub Category Racing
# set 0 to disable , 1 to enable racing stuff for that sub category [N0T CASTE SENSiTiVE]
array set subcategory_racing { 
		"Subs" 			"1"
		"Sub" 			"1"
		"Covers" 		"0"
		"Cover" 		"0"
		"sample" 		"0"
		"samples" 		"0"
		"cd1" 			"1"
		"cd2" 			"1" 
		"cd3" 			"1" 
		"cd4" 			"1" 
		"cd5" 			"1" 
		"disk1" 		"1"
		"disk2" 		"1"
		"disk3" 		"1"
		"disk4" 		"1"
		"disk5" 		"1"
		"extra" 		"0"
		"extras" 		"0"
		"extr" 			"0"
	}
	

# Blowfish decrypt command
if { $blowfish_(enabled) == "1" } {
	bind pub - +OK cmdencryptedincominghandler
}

bind pub - PRE ins:fetchdata
bind pub - NEW ins:fetchdata

# blowcrypt code by poci modified by ME

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

proc getfishkey { chan } {
	global channels_fishkey 
	
	if { ![info exists channels_fishkey($chan)] } {
	
		return
		
	} else {
	
		foreach {channel blowkey} [array get channels_fishkey] {
			if {[string equal -nocase $channel $chan]} {
				return $blowkey
			} 
		}
	
	}
	
}

proc cmdencryptedincominghandler {nick host hand chan arg} {
	
	set blowfishkey [getfishkey $chan]
	
	if { $blowfishkey == "" } {return}
	
	set tmp [string trim [decrypt $blowfishkey $arg]]
	set tmp [stripcodes bc $tmp]
	set tmp [ins:trimcolors $tmp]
	
	foreach item [binds pub] {
	
		if {[lindex $item 2]=="+OK"} {continue}
		
		if {[lindex $item 1]!="-|-"} {
			if {![matchattr $hand [lindex $item 1] $chan]} {continue}
		}
		
		if {[lindex $item 2]==[lindex $tmp 0]} {
			[lindex $item 4] $nick $host $hand $chan [string trim [lrange $tmp 0 end]]
		}
	
	}
	
}

# blowcrypt code by poci modified by ME END

# Filter color bold /bla code 
proc ins:trimcolors { nostring } {

 regsub -all -- {[0-9][0-9],[0-9][0-9]}  $nostring ""   nostring
 regsub -all -- {[0-9][0-9],[0-9]}       $nostring ""   nostring
 regsub -all -- {[0-9][0-9]}             $nostring ""   nostring
 regsub -all -- {[0-9]}                  $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {}                        $nostring ""   nostring
 regsub -all -- {}                        $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {\002|\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\026|\037|\0036|\022} $nostring ""   nostring
 
 return [string trim $nostring]
 
}

proc botallowed { nick } {
	global bots_race 
	
	foreach {botname status} [array get bots_race] {
		if {[string equal -nocase $botname $nick]} {
			return $status
		} 
	}	
}

proc chanallowed { chan } {
	global channels_race 

	foreach {channel status} [array get channels_race] {
		if {[string equal -nocase $channel $chan]} {
			return $status
		}
	} 
}

proc catallowed { cat } {
	global category_racing 
	
	foreach {category status} [array get category_racing] {
		if {[string equal -nocase $category $cat]} {
			return $status
		}
	}
}

proc subcatallowed { subcat } {
	global subcategory_racing 
	
	foreach {subcategory status} [array get subcategory_racing] {
		if {[string equal -nocase $subcategory $subcat]} {
			return $status
		} 
	}
}

proc catmapfrom { cat } {
	global category_replace_from 
	
	foreach {category catreplace} [array get category_replace_from] {
		if {[string equal -nocase $category $cat]} {
			return $catreplace
		} 
	}
}

proc catmapto { cat } {
	global category_replace_to 
	
	foreach {category catreplace} [array get category_replace_to] {
		if {[string equal -nocase $category $cat]} {
			return $catreplace
		} 
	}
}

proc ins:fetchdata { nick uhost hand chan arg } {
	global settings from to 
	
	set chan [string tolower $chan]
	
	putlog "$chan || $arg"
	
	set channelok [chanallowed $chan]
	
	if { [string trim $channelok] == "" || $channelok == "0" } { return }
	
	set botok [botallowed $nick]
	
	if { [string trim $botok] == "" || $botok == "0" } { return }
	
	if { $channelok == "1" && $botok == "1" } {
		
		set unixtime [clock seconds]
		
		set whatis [lindex $arg 0]
		
		set category [string trim [string trim [lindex $arg 2] ":"]]
		
		set catok [catallowed $category]
		
		if { [string trim $catok] == "" || $catok == "0" } { return }
		
		set catfrom [catmapfrom $category]
		
		if { [string trim $catfrom] == "" } { return }
		
		set catto [catmapto $category]
		
		if { [string trim $catto] == "" } { return }
		
		if { $whatis == "NEW" } {
			
			set rls [string trim [lindex $arg 4]]
			
			set rlsmatch [string match "*/*" $rls]
			
			if { $rlsmatch == "1" } {
				
				set w [split $rls "/"]
				set rlsname [string trim [lindex $w 0]]
				set rlssubdir [string trim [lindex $w 1]]
				
				set subcatok [subcatallowed $rlssubdir]
				
				if { [string trim $subcatok] == "" || $subcatok == "0" } { return }
				
				exec screen -dmS $settings(uniqueid) lftp -c "open -e 'debug -o $settings(logdir)$rlsname$rlssubdir.txt; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname/$rlssubdir ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname/$rlssubdir; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname/$rlssubdir ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname/$rlssubdir; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname/$rlssubdir ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname/$rlssubdir; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname/$rlssubdir ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname/$rlssubdir; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname/$rlssubdir ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname/$rlssubdir; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname/$rlssubdir ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname/$rlssubdir'"
				
				cmdputblow "PRIVMSG $settings(logchan) :NEW $rlssubdir -> FROM: $catfrom TO: $catto RLS: $rlsname"
				
			} elseif { $rlsmatch == "0" } {
			
				set rlsname [string trim [lindex $arg 4]]
				
				exec screen -dmS $settings(uniqueid) lftp -c "open -e 'debug -o $settings(logdir)$rlsname.txt; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname'"
				
				cmdputblow "PRIVMSG $settings(logchan) :NEW -> FROM: $catfrom TO: $catto RLS: $rlsname"
				
			}
			
		} elseif { $whatis == "PRE" && $settings(raceaffils) == "1" } {
		
			set rlsname [string trim [lindex $arg 7]]
			
			exec screen -dmS $settings(uniqueid) lftp -c "open -e 'debug -o $settings(logdir)$rlsname.txt; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname; mirror -r -R -c --only-missing --parallel=$settings(paralleldown) --no-symlinks --loop ftp://$from(nick):$from(pass)@$from(host):$from(port)/$catfrom/$rlsname ftp://$to(nick):$to(pass)@$to(host):$to(port)/$rlsname'"
			
			cmdputblow "PRIVMSG $settings(logchan) :PRE -> FROM: $catfrom TO: $catto RLS: $rlsname"
			
		}
	}
}

putlog "lftp AutoTrader v1.72 By Islander Loaded Successfully !"
