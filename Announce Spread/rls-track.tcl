package require mysqltcl

# Enter in your MySQL connection data
set mysql_(user) "scenedbaxx"
set mysql_(password) "Q3wX8GdPV7eKNQpw"
set mysql_(host) "localhost"

set mysql_(db) "scenestuff"

set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]

set mysql_(ftptable) "ftprls"
set mysql_(ftpsubtable) "ftpsubs"
set mysql_(mp3table) "mp3info"

set chann_(spam) "#xxx"
set chann_(superspam) "#spam"
set chann_(deletelog) "#chat"
set chann_(autoup_chan) "#autoup"
set chann_(log_chan) "#track"

set mp3db_(id) "id"
set mp3db_(rlsname) "rlsname"
set mp3db_(genre) "genre"
set mp3db_(year) "year"
set mp3db_(hertz) "hertz"
set mp3db_(type) "type"
set mp3db_(bitrate) "bitrate"
set mp3db_(bittype) "bittype"
set mp3db_(unixtime) "unixtime"
set mp3db_(addedon) "addedon"

set ftpbotnick "xxx"

set bopen "\002\[\002"
set bclose "\002\]\002"
set bdiv "\002\/\002"

bind pub - NEW newrls
bind pub - NFO nforls
bind pub - iD3 id3rls
bind pub - COMPLETE completerls
bind pub - DONE completerls
bind pub - DELETE deleterls

set blowfish_(enabled) "1"

# Blowfish decrypt command
if { $blowfish_(enabled) == "1" } {
	bind pub - +OK cmdencryptedincominghandler
}

proc mysql:keepalive {} {
	global db_handle mysql_
	
	if {[catch {mysql::ping $db_handle} error] || ![mysql::ping $db_handle]} {
		set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
	}

	utimer 120 [list mysql:keepalive]
	
	return 0
}

mysql:keepalive


# blowcrypt code by poci modified by Islander

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
	
	array set channelkeys {
			"#xxx" 			"xxx"
			"#spam" 		"xxx"
			"#chat" 		"xxx"
			"#nuke" 		"xxx"
			"#staff" 		"xxx"
			"#track" 		"xxx"		
	}
	
    foreach {channel blowkey} [array get channelkeys] {
        if {[string equal -nocase $channel $chan]} {
			return $blowkey
		} 
    }
}

proc cmdencryptedincominghandler {nick host hand chan arg} {
	
	set blowfishkey [getfishkey $chan]
	
	if { $blowfishkey == "" } {return}
	
	set tmp [decrypt $blowfishkey $arg]
	set tmp [stripcodes bc $tmp]
	set tmp [isy:trimcolors $tmp]
	
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

# Filter color bold /bla code 
proc isy:trimcolors { nostring } {

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

proc isy:validrelease { release } {

 set minlen 10
 set maxlen 256
 
 if {[string length $release] < $minlen}                                 {return 0}
 if {[string length $release] > $maxlen}                                 {return 0}
 if {![regexp {\.|\_|\-} $release]}                                      {return 0}
 if {[regexp {\!|\:|\@|\~|\||\[|\]|\`} $release]}                        {return 0}
 if {![regexp {\-} $release]}                                            {return 0}
 if {[regexp {[\-\.\(\)_]$} $release]}                                   {return 0}
 if {![regexp -nocase {[a-z]} $release]}                                 {return 0}
 if {[regexp ^[clock format [clock scan today] -format %Y-%m] $release]} {return 0}
 if {[regexp ^[clock format [clock scan today] -format %m%d] $release]}  {return 0}
 if {[regexp -all {\(} $release]!=[regexp -all {\)} $release]}           {return 0}
 if {[regexp -nocase {p[-\._]?r[-\._]?[e3][-\._]?[7t][-\._]?[e3][-\._]?[s5][-\._]?[t7]|[7t][-\._]?[e3][-\._]?[s5][-\._]?[t7][-\._]?p[-\._]?r[-\._]?[e3][-\._]?|d[o0][-\._]?n[o0]?[t7].*[t7]r[a4]d[e3]|^[t7][-\._]?[e3][-\._]?[s5][-\._]?[t7][-\._]?[a-z0-9]+$} $release]} {return 0}
 
 return 1
 
}

proc nforls {nick host hand chan arg} {
  global mysql_ db_handle chann_ ftpbotnick
	
	if { $nick == $ftpbotnick } {
	
		if { $chan == $chann_(spam) || $chan == $chann_(superspam) } {
			
			set category [string trim [lindex [split [lindex $arg 1] ":"] 0]]
			set rlsname [string trim [lindex $arg 3]]
			
			set w [split $rlsname "/"]
			set rlsname [string trim [lindex $w 0]]
			set nfofilename [string trim [lindex $w 1]]
			
			set result [mysqlsel $db_handle "SELECT id FROM $mysql_(ftptable) WHERE rlsname = '$rlsname' AND nfofilename = ''"]
			
			if { $result == "0" } {
			
				set isdone [mysqlexec $db_handle "UPDATE $mysql_(ftptable) SET nfofilename='$nfofilename' WHERE rlsname = '$rlsname'"]
				
				if {$isdone == "1"} {
					
					cmdputblow "PRIVMSG $chann_(log_chan) :NFO in $category: -> $rlsname"
					
				}
			
			}
		
		}
		
	}

}

proc id3rls {nick host hand chan arg} {
  global mysql_ db_handle chann_ ftpbotnick
	
	if { $nick == $ftpbotnick } {
	
		if { $chan == $chann_(spam) || $chan == $chann_(superspam) } {
			
			set rlsname [string trim [lindex $arg 1]]
			set genre [string trim [lindex $arg 3]]
			
			set result [mysqlsel $db_handle "SELECT id FROM $mysql_(ftptable) WHERE rlsname = '$rlsname' AND nfofilename = ''"]
			
			if { $result == "0" } {
			
				set isdone [mysqlexec $db_handle "UPDATE $mysql_(ftptable) SET genre='$genre' WHERE rlsname = '$rlsname'"]
				
				if {$isdone == "1"} {
					
					cmdputblow "PRIVMSG $chann_(log_chan) :GENRE is $genre: -> $rlsname"
					
				}
			
			}
		
		}
		
	}

}

proc newrls {nick host hand chan arg} {
  global mysql_ bopen bclose bdiv db_handle chann_ ftpbotnick
	
	if { $nick == $ftpbotnick } {
	
		if { $chan == $chann_(spam) || $chan == $chann_(superspam) } {
			
			set unixtime [clock seconds]
			set category [string trim [lindex [split [lindex $arg 1] ":"] 0]]
			set rlsname [string trim [lindex $arg 3]]
			
			set an ""
			set rlssubdir ""
			set spamdir "-"
			set rlsmatch [string match "*/*" $rlsname]
			
			if { $rlsmatch == "1" } {
		
				set w [split $rlsname "/"]
				set rlsname [string trim [lindex $w 0]]
				set rlssubdir [string trim [lindex $w 1]]
				set an $bdiv$rlssubdir
				
				if { [regexp -nocase {\/(sampl[e3](s)?|c[o0]v[e3]r(s)?|pr[o0][o0]f(s)?)} $rlsname/$rlssubdir] } { set spamdir "1" }
				if { [regexp -nocase {\/(sub(s)?)} $rlsname/$rlssubdir] } { set spamdir "0" }
				
				if { $spamdir == "1" } {
					
					cmdputblow "PRIVMSG $chann_(log_chan) :$rlssubdir in $category: -> IGN0RiNG $rlsname"
					return
					
				} elseif { $spamdir == "0" } {
					
					set issubs [mysqlsel $db_handle "SELECT subs FROM $mysql_(ftptable) WHERE rlsname = '$rlsname'"]
					
					mysqlmap $db_handle {subsstatus} {}
					
					if { $subsstatus == "no" } {
						
						set subok [mysqlexec $db_handle "UPDATE $mysql_(ftptable) SET subs='yes' WHERE rlsname = '$rlsname'"]
						
						if { $subok == "1" } {
						
							cmdputblow "PRIVMSG $chann_(log_chan) :$rlssubdir in $category: -> $rlsname"
							
						}
						
					}
					
					return
					
				} elseif { $spamdir == "-" } {
				
					set result [mysqlsel $db_handle "SELECT id FROM $mysql_(ftptable) WHERE rlsname = '$rlsname'"]
					set result2 [mysqlsel $db_handle "SELECT id FROM $mysql_(ftpsubtable) WHERE rlsname = '$rlsname' AND subdir = '$rlssubdir'"]
					
					if { $result != "0" && $result2 == "0" } {
						
						
						set isdone [mysqlexec $db_handle "INSERT INTO $mysql_(ftpsubtable) ( `rlsname` , `subdir` , `unixtime` , `preid` ) VALUES ( '$rlsname' , '$rlssubdir' , '$unixtime' ,  '$result' )"]
						
						if {$isdone == "1"} {
						
							cmdputblow "PRIVMSG $chann_(log_chan) :$rlssubdir in $category: -> $rlsname"
						
						}
						
					}
				}
			
			} elseif { $rlsmatch == "0" } {
		
				set result [mysqlsel $db_handle "SELECT id FROM $mysql_(ftptable) WHERE rlsname = '$rlsname'"]
				
				if { $result == "0" } {
					
					set grp [string trim [lindex [split $rlsname "-"] end]]
					set isdone [mysqlexec $db_handle "INSERT INTO $mysql_(ftptable) ( `rlsname` , `category` , `unixtime` , `grp` ) VALUES ( '$rlsname' , '$category' , '$unixtime' ,  '$grp' )"]
					
					if {$isdone == "1"} {
					
						cmdputblow "PRIVMSG $chann_(log_chan) :NEW in $category: -> $rlsname"
					
					}
					
				}
			}
		
		}
	
	}
}

proc genrerlsold {rls} {
global mysql_ db_handle 

	set result [mysqlsel $db_handle "SELECT genre FROM $mysql_(ftptable) WHERE rlsname = '$rls'" -list]
	
	set data [lindex $result 0]
	
	return [string trim [lindex $data 0]]

}

proc genrerls {rls} {
    global mysql_ db_handle mp3db_

    set query1 [mysqlsel $db_handle "SELECT $mp3db_(genre) FROM $mysql_(mp3table) WHERE $mp3db_(rlsname) = '$rls' LIMIT 1 " -flatlist];
        
	if {$query1 == ""} {
	
        return [genrerlsold $rls]

    } else {

        foreach {gn} $query1 {
	
			return [string trim $gn]
			
		}

	}
}

proc completerls {nick host hand chan arg} {
  global predb_ mysql_ bopen bclose bdiv db_handle chann_ ftpbotnick
	
	if { $nick == $ftpbotnick } {
	
		if { $chan == $chann_(spam) || $chan == $chann_(superspam) } {
			
			set category [string trim [lindex [split [lindex $arg 1] ":"] 0]]
			set rlsname [string trim [lindex $arg 3]]
			
			set an ""
			set rlssubdir ""
			set spamdir "-"
			set rlsmatch [string match "*/*" $rlsname]
			
			if { $rlsmatch == "1" } {
		
				set w [split $rlsname "/"]
				set rlsname [string trim [lindex $w 0]]
				set rlssubdir [string trim [lindex $w 1]]
				set an $bdiv$rlssubdir
				
				if { [regexp -nocase {\/(sampl[e3](s)?|c[o0]v[e3]r(s)?|pr[o0][o0]f(s)?)} $rlsname/$rlssubdir] } { set spamdir "1" }
				if { [regexp -nocase {\/(sub(s)?)} $rlsname/$rlssubdir] } { set spamdir "0" }
				
				if { $spamdir == "0" } {
					
					set subsok [mysqlsel $db_handle "SELECT subs FROM $mysql_(ftptable) WHERE rlsname = '$rlsname'"]
					
					mysqlmap $db_handle {subsstatus} {}
					
					if { $subsstatus == "yes" } {
						
						set subdone [mysqlexec $db_handle "UPDATE $mysql_(ftptable) SET subs='done' WHERE rlsname = '$rlsname'"]
						
						if { $subdone == "1" } {
							
							cmdputblow "PRIVMSG $chann_(log_chan) :COMPLETE in $category: -> $rlsname/$rlssubdir"
							
						}
						
					}
					
					return
					
				}  elseif { $spamdir == "-" } {
				
					set result [mysqlsel $db_handle "SELECT id FROM $mysql_(ftpsubtable) WHERE rlsname = '$rlsname' AND subdir = '$rlssubdir' AND complete = 'no'" -list]
					
					if { $result != "" } {
						
						set isdone [mysqlexec $db_handle "UPDATE $mysql_(ftpsubtable) SET complete='yes' WHERE rlsname = '$rlsname' AND subdir = '$rlssubdir'"]
						
						if {$isdone == "1"} {
						
							cmdputblow "PRIVMSG $chann_(log_chan) :COMPLETE in $category: -> $rlsname/$rlssubdir"
							
							set alldone [mysqlsel $db_handle "SELECT id FROM $mysql_(ftpsubtable) WHERE rlsname = '$rlsname' AND complete = 'no'" -list]
							
							if {$alldone != ""} {
								
								return
								
							} elseif {$alldone == ""} {
							
								set crdone [mysqlexec $db_handle "UPDATE $mysql_(ftptable) SET complete='yes' WHERE rlsname = '$rlsname'"]
								
								if {$crdone == "1"} {
									
									if { $category == "MP3" || $category == "FLAC" } { set gen [genrerlsold $rlsname] } else { set gen "" }
									
									putbot "AutoUp" "COMPLETE $category $rlsname $gen"
									cmdputblow "PRIVMSG $chann_(log_chan) :COMPLETE $category $rlsname $gen"
									
									return
									
								}
							}
						}
					}
				}
				
			
			} elseif { $rlsmatch == "0" } {
			
				set result [mysqlsel $db_handle "SELECT id FROM $mysql_(ftpsubtable) WHERE rlsname = '$rlsname' AND complete = 'no'"]
			
				if { $result == "0" } {
					
					set crdone [mysqlexec $db_handle "UPDATE $mysql_(ftptable) SET complete='yes' WHERE rlsname = '$rlsname'"]
					
					if {$crdone == "1"} {
						
						if { $category == "MP3" || $category == "FLAC" } { set gen [genrerlsold $rlsname] } else { set gen "" }
						
						putbot "AutoUp" "COMPLETE $category $rlsname $gen"
						cmdputblow "PRIVMSG $chann_(log_chan) :COMPLETE $category $rlsname $gen"
						
						return
						
					}
					
				}
			
			}
		}
	}
}

proc deleterls {nick host hand chan arg} {
  global predb_ mysql_ bopen bclose bdiv db_handle chann_ ftpbotnick
	
	if { $nick == $ftpbotnick } {
	
		if { $chan == $chann_(deletelog) } {
			
			set category [string trim [lindex $arg 1]]
			set rlsname [string trim [lindex $arg 3]]
			
			putbot "AutoUp" "GETDELETE $category $rlsname"
			cmdputblow "PRIVMSG $chann_(log_chan) :DELETE $category $rlsname"
			return
		}
		
	}
	
}

putlog "xxx FTP TRA3K FiSH --> Script v1.58 by Islander -- Loaded Succesfully!"