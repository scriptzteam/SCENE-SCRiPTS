package require mysqltcl

# Enter in your MySQL connection data
set mysql_(user) "scenedbaxx"
set mysql_(password) "Q3wX8GdPV7eKNQpw"
set mysql_(host) "localhost"

set mysql_(db) "scenestuff"

set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]

set mysql_(pretable) "prerlsdb"

set whichprebot "STRB"
set whichinfobot "STRB"

set annprechan "#pre"
set anninfochan "#prespam"

set chann_(addpre) "#addpre"

set chann_(addnuke) "#nuke"

set bopen "\002\[\002"
set bclose "\002\]\002"
set bdiv "\002\/\002"

bind pub - !prehelp helpme
bind pub - !pre isy:pre
bind pub - !find isy:pre
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

bind bot - ADDPRE getprerls
bind bot - NUKE nukerls
bind bot - UNNUKE unnukerls
bind bot - MODNUKE modnukerls
bind bot - DELPRE delprerls
bind bot - UNDELPRE undelprerls

bind bot - PREINFO getinforls
bind bot - GENRE getgenrerls

# Set your prefixes for announce / search.
set nuke_prefix "\0034NUKE\003"
set modnuke_prefix "\0034MODNUKE\003"
set unnuke_prefix "\0033UNNUKE\003"
set undelete_prefix "\00310UNDELPRE\003"
set delete_prefix "\00310DELPRE\003"

set info_prefix "\0037iNF0\003"
set genre_prefix "\0035GENRE\003"

set pretime_prefix "\002\[\002\00310PRETiME\003\002\]\002"

proc mysql:keepalive {} {
	global db_handle mysql_
	
	if {[catch {mysql::ping $db_handle} error] || ![mysql::ping $db_handle]} {
		set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
	}

	utimer 120 [list mysql:keepalive]
	
	return 0
}

mysql:keepalive

proc helpme {nick host hand chan arg} {
	
    putquick "PRIVMSG $chan :Valid commands are !pre & !dupe"
	
}

proc isy:dupe {nick uhost hand chan arg} {
    global mysql_ predb_ nuke_prefix unnuke_prefix bopen bclose bdiv db_handle
        
        set before [clock clicks -milliseconds]
        set sea1 [string map [list "*" "%" " " "%"] $arg];
        set sea2 [string map [list "%" "*"] $sea1];
		set count 0
		
        set query1 [mysqlsel $db_handle "SELECT $predb_(rlsname),$predb_(section),$predb_(unixtime),$predb_(files),$predb_(size),$predb_(nukestatus),$predb_(nukereason),$predb_(nukenet),$predb_(genre) FROM $mysql_(pretable) WHERE $predb_(rlsname) LIKE '%$sea1%' ORDER BY $predb_(unixtime) DESC LIMIT 10 " -flatlist];
        
		if {$query1 != ""} {
			
			putquick "PRIVMSG $chan :PM'ing last 10 results to $nick"
			
            foreach {rls type timestamp files mb nuke reason nukenet genre} $query1 {
			
				set predago [getpred $timestamp]
				set section [isy:sectioncolor $type]
				set count [expr $count + 1]
				
				set genred ""
				set infod ""
				if { $genre != "" } { set genred "\00315\(\003 $genre \00315)\003 " }
				if { $files != "" && $mb != "" } { set infod "$bopen$files \0036\Files\003 \00315\|\003 $mb \0036\MB\003$bclose " }
				if { $nuke == "" } { set nuked "" }
				if { $nuke == "Nuked" } { set nuked "$bopen$nuke_prefix $reason \00315\(\003 \00314$nukenet\003 \00315\)\003$bclose " }
				if { $nuke == "ModNuked" } { set nuked "$bopen$nuke_prefix $reason \00315\(\003 \00314$nukenet\003 \00315\)\003$bclose " }
				if { $nuke == "UnNuked" } { set nuked "$bopen$unnuke_prefix $reason \00315\(\003 \00314$nukenet\003 \00315\)\003$bclose " }
				
				putquick "PRIVMSG $nick :$bopen$count$bclose $bopen$section$bclose $bopen$rls$bclose $infod$genred$predago$nuked"
		
			}
	
		} else {
			putquick "PRIVMSG $chan :Nothing found for $arg"			
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
				if { $genre != "" } { set genred "\00315\(\003 $genre \00315)\003 " }
				if { $files != "" && $mb != "" } { set infod "$bopen$files \0036\Files\003 \00315\|\003 $mb \0036\MB\003$bclose " }
				if { $nuke == "" } { set nuked "" }
				if { $nuke == "Nuked" } { set nuked "$bopen$nuke_prefix $reason \00315\(\003 \00314$nukenet\003 \00315\)\003$bclose " }
				if { $nuke == "ModNuked" } { set nuked "$bopen$nuke_prefix $reason \00315\(\003 \00314$nukenet\003 \00315\)\003$bclose " }
				if { $nuke == "UnNuked" } { set nuked "$bopen$unnuke_prefix $reason \00315\(\003 \00314$nukenet\003 \00315\)\003$bclose " }
			
				putquick "PRIVMSG $chan :$bopen$section$bclose $bopen$rls$bclose $infod$genred$predago$nuked"
		
			}
	
		} else {
			putquick "PRIVMSG $chan :Nothing found for $arg"			
		}

}

proc getpred { timeis } {
	global bopen bclose 
	
	set timestamp [lindex $timeis 0]
	set added [ctime $timestamp]
    set time1 [clock seconds]
    incr time1 -$timestamp
	set ago [string map {" years" "y" " weeks" "w" " days" "d" " hours" "h" " minutes" "m" " seconds" "s" " year" "y" " week" "w" " day" "d" " hour" "h" " minute" "m" " second" "s"} [duration $time1]]
	set predago "$bopen\Pre\'d $ago ago \00315\(\003 $added \00315\)\003$bclose"
	
	return $predago
}

proc isy:highlight_group {rlsname} {

	set grp [string trim [lindex [split $rlsname "-"] end]]
	
	return [regsub -all -- $grp $rlsname "\002\\0\002"]
	
}

proc getprerls {bot com args} {
	global annprechan whichprebot bopen bclose chann_
	
	if { $bot == $whichprebot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set sec [lindex [lindex $args 0] 1]
		set section [isy:sectioncolor $sec]
		set rls [isy:highlight_group $rlsname]
		
		putquick "PRIVMSG $chann_(addpre) :!addpre $rlsname $section"
		putquick "PRIVMSG $annprechan :$bopen$section$bclose $rls"
	
	}
}

proc nukerls {bot com args} {
	global annprechan nuke_prefix whichprebot bopen bclose bdiv chann_
	
	if { $bot == $whichprebot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set reason [lindex [lindex $args 0] 1]
		set nukenet [lindex [lindex $args 0] 2]
		set rls [isy:highlight_group $rlsname]

		putquick "PRIVMSG $annprechan :$bopen$nuke_prefix$bclose $rls $bopen\00314$reason\003$bdiv\00314$nukenet\003$bclose"
		putquick "PRIVMSG $chann_(addnuke) :!nuke $rlsname 1 $reason $nukenet"
		putquick "PRIVMSG $chann_(addpre) :!nuke $rlsname $reason $nukenet"
		
	}
}

proc unnukerls {bot com args} {
	global annprechan unnuke_prefix whichprebot bopen bclose bdiv chann_
	
	if { $bot == $whichprebot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set reason [lindex [lindex $args 0] 1]
		set nukenet [lindex [lindex $args 0] 2]
		set rls [isy:highlight_group $rlsname]

		putquick "PRIVMSG $annprechan :$bopen$unnuke_prefix$bclose $rls $bopen\00314$reason\003$bdiv\00314$nukenet\003$bclose"
		putquick "PRIVMSG $chann_(addnuke) :!unnuke $rlsname $reason $nukenet"
		putquick "PRIVMSG $chann_(addpre) :!unnuke $rlsname $reason $nukenet"
		
	}
}

proc modnukerls {bot com args} {
	global annprechan modnuke_prefix whichprebot bopen bclose bdiv chann_
	
	if { $bot == $whichprebot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set reason [lindex [lindex $args 0] 1]
		set nukenet [lindex [lindex $args 0] 2]
		set rls [isy:highlight_group $rlsname]

		putquick "PRIVMSG $annprechan :$bopen$modnuke_prefix$bclose $rls $bopen\00314$reason\003$bdiv\00314$nukenet\003$bclose"
		putquick "PRIVMSG $chann_(addnuke) :!nuke $rlsname 1 $reason $nukenet"
		putquick "PRIVMSG $chann_(addpre) :!modnuke $rlsname $reason $nukenet"
		
	}
}

proc delprerls {bot com args} {
	global annprechan delete_prefix whichprebot bopen bclose bdiv chann_
	
	if { $bot == $whichprebot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set reason [lindex [lindex $args 0] 1]
		set nukenet [lindex [lindex $args 0] 2]
		set rls [isy:highlight_group $rlsname]

		putquick "PRIVMSG $annprechan :$bopen$delete_prefix$bclose $rls $bopen\00314$reason\003$bdiv\00314$nukenet\003$bclose"
		putquick "PRIVMSG $chann_(addpre) :!delpre $rlsname $reason $nukenet"
		
	}
}

proc undelprerls {bot com args} {
	global annprechan undelete_prefix whichprebot bopen bclose bdiv chann_
	
	if { $bot == $whichprebot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set reason [lindex [lindex $args 0] 1]
		set nukenet [lindex [lindex $args 0] 2]
		set rls [isy:highlight_group $rlsname]

		putquick "PRIVMSG $annprechan :$bopen$undelete_prefix$bclose $rls $bopen\00314$reason\003$bdiv\00314$nukenet\003$bclose"
		putquick "PRIVMSG $chann_(addpre) :!undelpre $rlsname $reason $nukenet"
		
	}
}

proc getinforls {bot com args} {
	global anninfochan info_prefix whichinfobot bopen bclose bdiv chann_
	
	if { $bot == $whichinfobot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set fles [lindex [lindex $args 0] 1]
		set size [lindex [lindex $args 0] 2]
		set rls [isy:highlight_group $rlsname]
		
		putquick "PRIVMSG $chann_(addpre) :!info $rlsname $fles $size"
		putquick "PRIVMSG $anninfochan :$bopen$info_prefix$bclose $rls $bopen\00314$size\003MB$bdiv\00314$fles\003F$bclose"
		
	}
}

proc getgenrerls {bot com args} {
	global anninfochan genre_prefix whichinfobot bopen bclose chann_
	
	if { $bot == $whichinfobot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set gnre [lindex [lindex $args 0] 1]
		set rls [isy:highlight_group $rlsname]
		
		putquick "PRIVMSG $chann_(addpre) :!gn $rlsname $gnre"
		putquick "PRIVMSG $anninfochan :$bopen$genre_prefix$bclose $rls $bopen\00314$gnre\003$bclose"
		
	}
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
			"TV-HD-X264" 	"\00311TV-HD-X264\003"
			"TV-SD-X264" 	"\00311TV-SD-X264\003" 		
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

putlog "xxx ADD ANN --> Script v1.18 by Islander -- Loaded Succesfully!"