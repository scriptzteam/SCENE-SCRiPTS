package require mysqltcl

# Enter in your MySQL connection data
set mysql_(user) "scenedbaxx"
set mysql_(password) "Q3wX8GdPV7eKNQpw"
set mysql_(host) "localhost"

set mysql_(db) "scenestuff"

set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]

set mysql_(pretable) "prerlsdb"


set chann_(main) "#chat"
set chann_(spam) "#xxx"
set chann_(superspam) "#spam"
set chann_(addnuke) "#nuke"

set ftpbotnick "xxx"

set bopen "\002\[\002"
set bclose "\002\]\002"
set bdiv "\002\/\002"

bind pub - PRE predrls
bind pub - NEW newrls
bind pub - COMPLETE completerls
bind pub - DONE completerls
bind pub - !prehelp helpme
bind pub - !pre isy:pre
bind pub - !dupe isy:dupe

set predb_(id) "id"
set predb_(rlsname) "rlsname"
set predb_(section) "filtersec"
set predb_(unixtime) "unixtime"
set predb_(nukestatus) "nukestatus"
set predb_(nukereason) "nukereason"
set predb_(nukenet) "nukenet"
set predb_(files) "files"
set predb_(size) "size"
set predb_(genre) "genre"
set predb_(grp) "grp"

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
			"#pre" 			"xxx"
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

proc helpme {nick host hand chan arg} {
	global chann_ 
	
    putquick "PRIVMSG $chan :Valid commands are are !pre, !dupe"
	
}

proc isy:dupe {nick uhost hand chan arg} {
    global mysql_ predb_ nuke_prefix unnuke_prefix bopen bclose bdiv db_handle
        
        set before [clock clicks -milliseconds]
        set sea1 [string map [list "*" "%" " " "%"] $arg];
        set sea2 [string map [list "%" "*"] $sea1];
		set count 0
		
        set query1 [mysqlsel $db_handle "SELECT $predb_(rlsname),$predb_(section),$predb_(unixtime),$predb_(files),$predb_(size),$predb_(nukestatus),$predb_(nukereason),$predb_(nukenet),$predb_(genre) FROM $mysql_(pretable) WHERE $predb_(rlsname) LIKE '%$sea1%' ORDER BY $predb_(unixtime) DESC LIMIT 10 " -flatlist];
        
		if {$query1 != ""} {
			
			cmdputblow "PRIVMSG $chan :PM'ing last 10 results to $nick"
			
            foreach {rls type timestamp files mb nuke reason nukenet genre} $query1 {
			
				set predago [getpred $timestamp]
				set section [isy:sectioncolor $type]
				set count [expr $count + 1]
				
				set genred ""
				set infod ""
				if { $genre != "" } { set genred "$bopen$genre$bclose " }
				if { $files != "" && $mb != "" } { set infod "$bopen$files F in $mb MB$bclose " }
				if { $nuke == "" } { set nuked "" }
				if { $nuke == "Nuked" } { set nuked "$bopen$nuke_prefix $reason \00315\(\003 \00314$nukenet\003 \00315\)\003$bclose " }
				if { $nuke == "ModNuked" } { set nuked "$bopen$nuke_prefix $reason \00315\(\003 \00314$nukenet\003 \00315\)\003$bclose " }
				if { $nuke == "UnNuked" } { set nuked "$bopen$unnuke_prefix $reason \00315\(\003 \00314$nukenet\003 \00315\)\003$bclose " }
				
				putquick "PRIVMSG $nick :$bopen$count$bclose $bopen$section$bclose $rls $infod$genred$predago$nuked"
		
			}
	
		} else {
			cmdputblow "PRIVMSG $chan :Nothing found for $arg"			
		}
}

proc isy:pre {nick uhost hand chan arg} {
    global mysql_ predb_ nuke_prefix unnuke_prefix bopen bclose bdiv db_handle
    
        
        set before [clock clicks -milliseconds]
        set sea1 [string map [list "*" "%" " " "%"] $arg];
        set sea2 [string map [list "%" "*"] $sea1];
		
        set query1 [mysqlsel $db_handle "SELECT $predb_(rlsname),$predb_(section),$predb_(unixtime),$predb_(files),$predb_(size),$predb_(nukestatus),$predb_(nukereason),$predb_(nukenet),$predb_(genre) FROM $mysql_(pretable) WHERE $predb_(rlsname) LIKE '%$sea1%' ORDER BY $predb_(unixtime) DESC LIMIT 1 " -flatlist];
        
		if {$query1 != ""} {
			
            foreach {rls type timestamp files mb nuke reason nukenet genre} $query1 {
			
				set predago [getpred $timestamp]
				set section [isy:sectioncolor $type]
			
				set genred ""
				set infod ""
				if { $genre != "" } { set genred "$bopen$genre$bclose " }
				if { $files != "" && $mb != "" } { set infod "$bopen$files F in $mb MB$bclose " }
				if { $nuke == "" } { set nuked "" }
				if { $nuke == "Nuked" } { set nuked "$bopen$nuke_prefix $reason \00315\(\003 \00314$nukenet\003 \00315\)\003$bclose " }
				if { $nuke == "ModNuked" } { set nuked "$bopen$nuke_prefix $reason \00315\(\003 \00314$nukenet\003 \00315\)\003$bclose " }
				if { $nuke == "UnNuked" } { set nuked "$bopen$unnuke_prefix $reason \00315\(\003 \00314$nukenet\003 \00315\)\003$bclose " }
			
				cmdputblow "PRIVMSG $chan :$bopen$section$bclose $rls $infod$genred$predago$nuked"
		
			}
	
		} else {
			cmdputblow "PRIVMSG $chan :Nothing found for $arg"			
		}

}

proc newrls {nick host hand chan arg} {
  global predb_ mysql_ bopen bclose bdiv db_handle chann_ ftpbotnick pretime_prefix
	
	if { $nick == $ftpbotnick } {
	
		if { $chan == $chann_(spam) || $chan == $chann_(superspam) } {
			
			set cat [string trim [lindex [split [lindex $arg 1] ":"] 0]]
			
			set rlsname [string trim [lindex $arg 3]]

			set rlsmatch [string match "*/*" $rlsname]
			
			if { $rlsmatch == "1" } { return }
			
			set query1 [mysqlsel $db_handle "SELECT $predb_(rlsname),$predb_(section),$predb_(unixtime),$predb_(genre),$predb_(files),$predb_(size) FROM $mysql_(pretable) WHERE $predb_(rlsname) = '$rlsname' LIMIT 1 " -flatlist];
			
			if {$query1 != ""} {
				
				foreach {rlsname type timestamp genre files mb} $query1 {
					
					set time1 [clock seconds]
					incr time1 -$timestamp
					set ago [getpred $timestamp]
					set section [isy:sectioncolor $cat]
					
					set genred ""
					set infod ""
					if { $genre != "" } { set genred "$bopen$genre$bclose " }
					if { $files != "" && $mb != "" } { set infod "$bopen$files F in $mb MB$bclose " }
					
					set isokay ""
					
					if { $time1 < "1800" } { 
					
						set isokay "\0039OK\003"
						
					} elseif { $time1 > "1800" } {
					
						set isokay "\0034BACKFILL\003"

						cmdputblow "PRIVMSG $chann_(addnuke) :!nuke $rlsname 3 30.minutes.backfill.nuked"
						
					}
					
					cmdputblow "PRIVMSG $chan :\002$isokay\002 \002>\002 $rlsname $ago"
				}
				
			}
		
		}
	
	}
}

proc completerls {nick host hand chan arg} {
  global predb_ mysql_ bopen bclose bdiv db_handle chann_ ftpbotnick pretime_prefix
	
	if { $nick == $ftpbotnick } {
	
		if { $chan == $chann_(spam) || $chan == $chann_(superspam) } {
			
			set cat [string trim [lindex [split [lindex $arg 1] ":"] 0]]

			set rlsname [string trim [lindex $arg 3]]
			
			set rlsmatch [string match "*/*" $rlsname]
			
			if { $rlsmatch == "1" } { return }
			
			set query1 [mysqlsel $db_handle "SELECT $predb_(rlsname),$predb_(section),$predb_(unixtime),$predb_(genre),$predb_(files),$predb_(size) FROM $mysql_(pretable) WHERE $predb_(rlsname) = '$rlsname' LIMIT 1 " -flatlist];
			
			if {$query1 != ""} {
				
				foreach {rlsname type timestamp genre files mb} $query1 {
					
					set ago [getpred $timestamp]
					set section [isy:sectioncolor $cat]
					
					set genred ""
					set infod ""
					if { $genre != "" } { set genred "$bopen$genre$bclose " }
					if { $files != "" && $mb != "" } { set infod "$bopen$files F in $mb MB$bclose " }
					
					set isokay "\0039C0MPLETE\003"
					
					cmdputblow "PRIVMSG $chan :\002$isokay\002 \002>\002 $rlsname $ago"
				}
				
			}
		
		}
	
	}
}

proc predrls {nick host hand chan arg} {
  global bopen bclose bdiv chann_ ftpbotnick pretime_prefix
	
	if { $nick == $ftpbotnick } {
	
		if { $chan == $chann_(spam) || $chan == $chann_(superspam) } {
			
			#9PRE in 07XXX-0DAY: -> SEXORS gives us DrunkSexOrgy.11.03.22.Bobs.B-Day.Part.4.Cam.1.XXX.1080p.MP4-SEXORS (30 files - 1.4GB).
			
			regexp {^in (.+?): -> .* gives us (.+?) \((.+?) files - (.+?)MB\)\.$} $arg . section rlsname files size
			
			set rlsvalid [isy:validrelease $rlsname]
			
			if { $rlsvalid == "1" } {
			
				putbot "SAddPre" "PREAFFIL $rlsname $section $files $size"
				
				set category [isy:sectioncolor $section]
				set isokay "\0039AFFiL ADD3D\003"
				
				cmdputblow "PRIVMSG $chan :\002$isokay\002 in \002$category\002 \002=>\002 \002$rlsname\002"
				
			} else {
			
				return
				
			}
		}
	}
}

proc getpred { timeis } {
	global bopen bclose 
	
	set timestamp [lindex $timeis 0]
	set added [ctime $timestamp]
    set time1 [clock seconds]
    incr time1 -$timestamp
	set ago [string map {" years" "y" " weeks" "w" " days" "d" " hours" "h" " minutes" "m" " seconds" "s" " year" "y" " week" "w" " day" "d" " hour" "h" " minute" "m" " second" "s"} [duration $time1]]
	set predago "$bopen\Pre\'d $ago ago$bclose"
	
	return $predago
}

proc isy:sectioncolor { arg } {
	
	set sec [lindex $arg 0]
	
	array set sectionColors {
			"SCENENOTiCE" 	"\0034SCENENOTiCE\003" 
			"SUBPACK" 		"\0035SUBPACK\003" 
			"AUDIOBOOK" 	"\0036AUDiOBOOK\003" 
			"SVCD" 			"\0036SVCD\003" 
			"VCD" 			"\0036VCD\003" 
			"COVERS" 		"\00310COVERS\003" 
			"PDA" 			"\0037PDA\003" 
			"PRE" 			"\002PRE\002" 
			"TV" 			"\00311TV\003" 
			"TV-XVID" 		"\00311TV-XViD\003" 
			"TV-X264" 		"\00311TV-X264\003" 
			"TV-HDRIP" 		"\00311TV-HDRIP\003" 
			"TV-DVDR" 		"\00311TV-DVDR\003" 
			"TV-DVDRIP" 	"\00311TV-DVDRiP\003" 
			"MP3" 			"\0036MP3\003" 
			"FLAC" 			"\0036FLAC\003" 
			"XXX" 			"\00313XXX\003"
			"XXX-X264" 		"\00313XXX-X264\003" 
			"XXX-DVDR" 		"\00313XXX-DVDR\003" 
			"XXX-0DAY" 		"\00313XXX-0DAY\003" 			
			"XXX-IMGSET" 	"\00313XXX-iMGSET\003" 
			"MVID" 			"\00310MViD\003" 
			"0DAY" 			"\0037\002\0020DAY\003" 
			"APPS" 			"\0037APPS\003" 
			"ANIME" 		"\00310ANiME\003" 
			"XVID" 			"\0032XViD\003" 
			"X264" 			"\0032x264\003" 
			"DVDR" 			"\0035DVDR\003" 
			"MDVDR" 		"\00310MDVDR\003" 
			"MBLURAY" 		"\00310MBLURAY\003" 
			"BLURAY" 		"\00310BLURAY\003" 
			"GAMES" 		"\0033GAMES\003" 
			"EBOOK" 		"\00312eBook\003" 
			"WII" 			"\00314WII\003" 
			"PS3" 			"\00314PS\003\002\0023" 
			"PS2" 			"\00314PS\0032\002\0022\003" 
			"PSP" 			"\00311P\00312S\0032P\003" 
			"DOX" 			"\0036DOX\003" 
			"GBA" 			"\0036GBA\003" 
			"NGC" 			"\0036NGC\003" 
			"NDS" 			"\0036NDS\003" 
			"XBOX360" 		"\00312XBOX\003\0033\002\002360\003" 
			"XBOX" 			"\00312XBOX\003"
	}
	
    foreach {section replace} [array get sectionColors] {
        if {[string equal -nocase $section $sec]} {
			return $replace
		} 
    }
}

putlog "xxx FiSH --> Script v1.62 by Islander -- Loaded Succesfully!"