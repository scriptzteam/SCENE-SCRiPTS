package require mysqltcl

# Enter in your MySQL connection data
set mysql_(user) "scenedbaxx"
set mysql_(password) "Q3wX8GdPV7eKNQpw"
set mysql_(host) "localhost"

set mysql_(db) "scenestuff"

set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]

set mysql_(pretable) "prerlsdb"
set mysql_(craptable) "craprlsdb"

# I've included an SQL file that auto-creates these tables for you, but if you want, you can edit / make your own and edit the following values to reflect so.
set predb_(id) "id"
set predb_(rlsname) "rlsname"
set predb_(sectionmain) "section"
set predb_(section) "filtersec"
set predb_(unixtime) "unixtime"
set predb_(files) "files"
set predb_(size) "size"
set predb_(genre) "genre"
set predb_(addedon) "addedon"
set predb_(grp) "grp"
set predb_(imdb) "imdb"
set predb_(url) "url"
set predb_(nukestatus) "nukestatus"
set predb_(nukereason) "nukereason"
set predb_(nukenet) "nukenet"
set predb_(delstatus) "delstatus"
set predb_(delreason) "delreason"
set predb_(delnet) "delnet"
set predb_(frompre) "frompre"
set predb_(frominfo) "frominfo"
set predb_(fromgenre) "fromgenre"
set predb_(fromimdb) "fromimdb"
set predb_(fromurl) "fromurl"
set predb_(fromnuke) "fromnuke"
set predb_(fromdel) "fromdel"
set predb_(addold) "addold"

set PR3N3T "xxx"

set chann_(addpre) "#add"

set chann_(spam) "#xxx"

set ftpbotnick "xxx"

bind pub - !add isy:addpre
bind pub - !addpre isy:addpre
bind msgm - * isy:message

bind pub - PRE ftpaffilrls
bind pub - NEW ftpnewrls
bind pub - COMPLETE ftpcompleterls

bind bot - PREAFFIL spreadpreaffil

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

proc isy:message { nick uhost hand arg } {
	global PR3N3T 
	
	putbot "STRB" "MESSAGE $PR3N3T Network: $nick -> $arg"

}

proc isy:sectioncolor { arg } {
	
	set sec [lindex $arg 0]
	
	array set sectionColors {
			"SCENENOTiCE" 	"\0034SCENENOTiCE\003" 
			"SVCD" 			"\0036SVCD\003" 
			"VCD" 			"\0036VCD\003" 
			"COVERS" 		"\00310COVERS\003" 
			"PDA" 			"\0037PDA\003" 
			"PRE" 			"\002PRE\002" 
			"TV" 			"\00311TV\003" 
			"TV-XVID" 		"\00311TV-XViD\003" 
			"TV-X264" 		"\00311TV-X264\003" 
			"TV-DVDR" 		"\00311TV-DVDR\003" 
			"TV-DVDRIP" 	"\00311TV-DVDRiP\003" 
			"MP3" 			"\0036MP3\003" 
			"XXX" 			"\00313XXX\003"
			"XXX-X264" 		"\00313XXX-X264\003" 
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

proc ftpnewrls {nick host hand chan arg} {
  global chann_ ftpbotnick
	
	if { $nick == $ftpbotnick && $chann_(spam) == $chan } {
	
		set cat [string trim [lindex [split [lindex $arg 1] ":"] 0]]
		
		set rlsname [string trim [lindex $arg 3]]
		
		putbot "xxx" "FTPNEW $rlsname $cat"
	
	}	
}

proc ftpcompleterls {nick host hand chan arg} {
  global chann_ ftpbotnick
	
	if { $nick == $ftpbotnick && $chann_(spam) == $chan } {
	
		set cat [string trim [lindex [split [lindex $arg 1] ":"] 0]]
		
		set rlsname [string trim [lindex $arg 3]]
		
		putbot "xxx" "FTPCOMPLETE $rlsname $cat"
	
	}	
}

proc ftpaffilrls {nick host hand chan arg} {
  global chann_ ftpbotnick
	
	if { $nick == $ftpbotnick && $chann_(spam) == $chan } {
	
		set cat [string trim [lindex [split [lindex $arg 1] ":"] 0]]
		
		set rlsname [string trim [lindex $arg 3]]
		
		putbot "xxx" "FTPPRE $rlsname $cat"
	
	}	
}

proc spreadpreaffil {bot com args} {
	global chann_
	
	set rlsname [lindex [lindex $args 0] 0]
	set section [lindex [lindex $args 0] 1]
	set files [lindex [lindex $args 0] 2]
	set size [lindex [lindex $args 0] 3]
	
	putquick "PRIVMSG $chann_(addpre) :!addpre $rlsname $section"
	putquick "PRIVMSG $chann_(addpre) :!info $rlsname $files $size"
	
}

proc isy:addpre { nick uhost hand chan arg } {
	global mysql_ predb_ chann_ db_handle PR3N3T 
	
	if { $chan == $chann_(addpre) } { 
		
		set unixtime [clock seconds]
		
		set arg [string trim [stripcodes bc $arg]]
		#set arg [isy:trimcolors $arg]
		set rlsname [lindex $arg 0]
		
		if { [string trim [lindex $arg 1]] == "" } {
			set sectionmain "PRE"
		} else {
			set sectionmain [lindex $arg 1]
		}
		
		set rlsvalid [isy:validrelease $rlsname]
		
		#set grp [isy:getgroup $rlsname]
		set grp [string trim [lindex [split [lindex $arg 0] "-"] end]]
		
			if { $rlsvalid == "1" } { 
				set whichtable "$mysql_(pretable)"
				
			} elseif { $rlsvalid == "0" } {
				putlog "SPAM BL0CKED -> $rlsname"
				set whichtable "$mysql_(craptable)"
				
			}
			
			set result [mysqlsel $db_handle "SELECT $predb_(id) FROM $whichtable WHERE $predb_(rlsname) = '$rlsname'"]
				
			if { $result == "0" } {
				
				set section [isy:getsec_fromrls $rlsname]
				
				set fromdata "$nick:$chan:$PR3N3T"
				set frominfo [::mysql::escape $fromdata]
				
				set isdone [mysqlexec $db_handle "INSERT INTO $whichtable ( `$predb_(sectionmain)` , `$predb_(section)` , `$predb_(rlsname)` , `$predb_(unixtime)` , `$predb_(grp)` , `$predb_(addedon)` , `$predb_(frompre)` ) VALUES ( '$sectionmain' , '$section' ,  '$rlsname' , '$unixtime' ,  '$grp' , '$unixtime' , '$frominfo' )"]
					
				if { $isdone == "1" && $rlsvalid == "1" } {
					
					putbot "STRB" "ADDPRE $rlsname $section $grp"
					
					putquick "PRIVMSG $chan :!addpre $rlsname $section"
					
				}
			}
	}
}


proc isy:validrelease { release } {

 set minlen 10
 set maxlen 256
 
 if {[string length $release] < $minlen}                                 {return 0}
 if {[string length $release] > $maxlen}                                 {return 0}
 if {![regexp {\.|\_|\-} $release]}                                      {return 0}
 if {[regexp {\!|\:|\@|\~|\/|\||\[|\]|\`} $release]}                     {return 0}
 if {![regexp {\-} $release]}                                            {return 0}
 if {[regexp {[\-\.\(\)_]$} $release]}                                   {return 0}
 if {![regexp -nocase {[a-z]} $release]}                                 {return 0}
 if {[regexp ^[clock format [clock scan today] -format %Y-%m] $release]} {return 0}
 if {[regexp ^[clock format [clock scan today] -format %m%d] $release]}  {return 0}
 if {[regexp -all {\(} $release]!=[regexp -all {\)} $release]}           {return 0}
 if {[regexp -nocase {p[-\._]?r[-\._]?[e3][-\._]?[7t][-\._]?[e3][-\._]?[s5][-\._]?[t7]|[7t][-\._]?[e3][-\._]?[s5][-\._]?[t7][-\._]?p[-\._]?r[-\._]?[e3][-\._]?|d[o0][-\._]?n[o0]?[t7].*[t7]r[a4]d[e3]|^[t7][-\._]?[e3][-\._]?[s5][-\._]?[t7][-\._]?[a-z0-9]+$} $release]} {return 0}
 
 return 1
 
}

proc isy:checksection { arg } {
	
	set oldsection [lindex $arg 0]
	
    array set section_replace {
        "TV"                "TV"
        "SERIE"             "TV"
		"SERIES"            "TV"
		"YV"                "TV"
		"TV-XVID"           "TV"
		"TV-DVDR"           "TV"
		"TV-DVDRIP"         "TV"
		"TVDVDRIP"          "TV"
		"TV-X264"           "TV"
		"tvxvid"            "TV"
		"FR-TV"             "TV"
		"HDTV"              "HDTV"
		"HD-TV"             "HDTV"
		"0-DAY"             "0DAY"
		"0DAY"              "0DAY"
        "0-DAYS"            "0DAY"
		"PHOTOS"            "0DAY"
        "0DAY-XXX"          "XXX"
        "0dayxxx"           "XXX"
        "XXX-0DAY"          "XXX"
        "XXX-XVID"          "XXX"
        "XXX-HD"            "XXX"
        "XXX-DVDR"          "XXX"
        "XXX"               "XXX"
        "XXX-PAYSITE"       "XXX"
        "PAYSITE"           "XXX"
		"PAYSITES"          "XXX"
        "XXX-PAY"           "XXX"
        "XXX-WEB"           "XXX"
        "IMAGESET"          "XXX-iMGSETS"
        "XXX-IMGSET"        "XXX-iMGSETS"
        "XXX-IMAGESET"      "XXX-iMGSETS"
        "XXX-IMAGESETS"     "XXX-iMGSETS"
        "XXX-IMGSETS"       "XXX-iMGSETS" 
		"IMAGESETS"         "XXX-iMGSETS"
		"IMAGES-SET"        "XXX-iMGSETS"
		"IMGSET"            "XXX-iMGSETS"
		"IMGSETS"           "XXX-iMGSETS"
		"XVID"              "XVID"
		"DVDRIP"            "XVID"
		"XVID-X264FR"       "XVID"
		"EBOOK"             "eBook"
		"aBook"             "eBook"
		"COVER"             "COVERS"
		"COVERS"            "COVERS"
		"WII"               "WII"
		"MVID"              "MVID"
		"APPS"              "APPS"
		"PDA"               "PDA"
		"XBOX360"           "XBOX360"
		"XBOX"              "XBOX"
		"PS3"               "PS3"
		"PS2"               "PS2"
		"PS"                "PS" 	
		"NDS"               "NDS"
		"GBA"               "GBA"
		"DOX"               "DOX"
		"dvdr-ntsc"         "DVDR"
		"DVDR"              "DVDR"
		"DVD-R"             "DVDR"
		"ANIME"             "ANIME"
		"MDVDR"             "MDVDR"
		"PSP"               "PSP"
		"MP3"               "MP3"
		"GAME"              "GAMES"
		"GAMES"             "GAMES"
		"x264"              "x264"
		"HD-X264"           "x264"
		"HDRIP-X264"        "x264"
		"DVD-HD"            "x264"
		"DVDHD"             "x264"
		"HD"                "x264"
		"BRD"               "x264"
    }
	
    foreach {section replace} [array get section_replace] {
        if {[string equal -nocase $section $oldsection]} {
			return $replace
		}
    }
}

proc isy:getsec_fromrls { release } {
	
	set section "PRE"
	
	if {[regexp -nocase {[\.\-\_](retail|update|cracked|win(nt|9x|2k|xp|nt2k2003serv|9xnt|9xme|nt2kxp|2kxp|2kxp2k3|all|32|mac|dows)|key(gen|maker)|regged|template|Patch|GAMEGUiDE|unix|(mac)?(osx)?|irix|solaris|freebsd|hpux|linux|archive|multilanguage|beta)[\.\-\_]|^template.+monster+.|\-CORE|\-DIGERATI$|v[0-9.]+|\.(r[1-5]|rc[1-9])[._-]} $release]} { set section "0DAY" }
	if {[regexp -nocase {[\.\-\_](converter|key(gen|maker)|regged)[\.\-\_]|^template.+monster+.|\-DIGERATI|v[0-9.]+|\.(r[1-5]|rc[1-9])[._-]} $release]} { set section "0DAY" }
	if {[regexp -nocase {[\.\-\_](pda|i(phone|pad|touch|pod)|palmos|android|blackberry|(win)?(mobile)|wm(2003|2005|5|2006|6|6.5|2007|7)|tablet|symbian|smartphone)[\.\-\_]|\-.+pda$} $release]} { return "PDA" }
	if {[regexp -nocase {[\-][1-2][0-9][0-9][0-9][\-]} $release]} { set section "MP3" }
	if {[regexp -nocase {[\.\-\_](PSXPSP|psp|umdrip)[\.\-\_]} $release]} { set section "PSP" }
	if {[regexp -nocase {\-200[0-9]\-|\-19([6-9][0-9]|xx|9x)\-|\(|\)|\_\-\_|top[0-9]+|\-[0-9]cd\-|vol([._]+)?[0-9]{1,2}|[._-]cdda[._-]} $release] } { set section "MP3" }
	if {[regexp -nocase {[_-](vinyl|dab|cd(r|g|s|m(2)?)?|abook|dvda|ost|promo|sat|fm|cable|line|bootleg|vls|lp|ep|feat|retail|radio|remix|web)[_-]|^va[-_\.]} $release] } { set section "MP3" }	
	if {[regexp -nocase {[\.\-\_](trainer|nocd|cheat|manual)[\.\-\_]|\-CHEATERS|\-DARKNeZZ|\-gimpsRus|\-RVL|\-ECU|\-DRUNK|\-TNT|\-.+DOX$} $release]} { set section "DOX" }
	if {[regexp -nocase {\.(divx|cam|ts|telesync|tc|telecine|xvid|r5|scr|screener|workprint|wp|r4|r3|(dvd|tv|vhs|pdvd)(scr|rip)?)[\.\-\_]} $release]} { set section "XVID" }
	if {[regexp -nocase {\.(720p|1080i|1080p|[xh]264|blue?ray|brip|brd|b[rd]rip)[\.\-\_]} $release]} { set section "X264" }
	if {[regexp -nocase {[\.\-\_](cn)?dvd[r9][\.\-\_]} $release]} { set section "DVDR" }
	if {[regexp -nocase {[\.\-\_]ps2(dvd[59]|cd)?[\.\-\_]} $release]} { set section "PS2" }
	if {[regexp -nocase {[\.\-\_]xb[o0]x(dvd|rip|cd)?[\.\-\_]} $release]} { set section "XBOX" }
	if {[regexp -nocase {[\.\-\_]([cms]?vcd|vhs)[\.\-\_]} $release]} { set section "VCD" }
	if {[regexp -nocase {[\.\-\_]gba[\.\-\_]} $release]} { set section "GBA" }
	if {[regexp -nocase {[\.\-\_](n?gcn?|gamecube)[\.\-\_]} $release]} { set section "NGC" }
	if {[regexp -nocase {[\.\_]([SED][0-9]{1,3}[abcd]?|S[0-9]{1,3}[ED][0-9]{1,3}[abcd]?|S[0-9]{1,3}DVD[0-9]{1,3}|S[0-9]{1,3}DIS[CK][0-9]{1,3}|ws|([phs]?[ds]tv|vhs|sat|dvb)(rip)?|hdtv|wwe|TVDVDR|eps|episodes?)[\.\-\_]} $release]} { set section "TV" }
	if {[regexp -nocase {[\.\_](is[o0]|multilanguage|multilingual|training|lynda|tutors|vtc)[\.\-\_]|\-winbeta$|\-tda$|\-tbe$|\-w3d$|\-PANTHEON$|\-SHooTERS$|\-riSE$|\-DYNAMiCS$|\-.+iso$|\-rhi$|\-restore$|\-BIE|\-HELL|\-YUM|\-SPiRiT|\-ArCADE|\-KOPiE|\-CRBS|\-rG|\-UP2DATE|\-ETH0|\-NoPE|\-EMBRACE} $release]} { set section "APPS" }
	if {[regexp -nocase {[\.\-\_]wii[\.\-\_]} $release]} { set section "WII" }
	if {[regexp -nocase {[\.\-\_]ps3[\.\-\_]} $release]} { set section "PS3" }
	if {[regexp -nocase {[\.\-\_]xb[o0]x36[o0][\.\-\_]} $release]} { set section "XBOX360" }
	if {[regexp -nocase {[\.\-\_]anim[e3][\.\-\_]} $release]} { set section "ANIME" }
	if {[regexp -nocase {[\.\-\_]nds[\.\-\_]} $release]} { set section "NDS" }
	if {[regexp -nocase {[\.\-\_]mdvd[r9]?[\.\-\_]} $release]} { set section "MDVDR" }
	if {[regexp -nocase {[\.\-\_]bluray\.complete[\.\-\_]} $release]} { set section "BLURAY" }
	if {[regexp -nocase {[\.\-\_]mbluray[\.\-\_]} $release]} { set section "MBLURAY" }
	if {[regexp -nocase {[\.\-\_]subs?packs?[\.\-\_]} $release]} { set section "SUBPACK" }
	if {[regexp -nocase {[\.\-\_]xxx|\-fps$|\-ktr$|\-fugli$|\-yumyum$|\-jiggly$|\-nympho$|\-pr0nstars$|\-pornolation$|\-peepshow$|\-SWE6RUS$|\-teenlovers$|\-JapanX$} $release]} { set section "XXX" }
	if {[regexp -nocase {[\.\-\_](e|Press)b[o0]{2}k[\.\-\_]} $release]} { set section "EBOOK" }
	if {[regexp -nocase {[\.\-\_](a|audi[o0])b[o0]{2}k[\.\-\_]} $release]} { set section "AUDIOBOOK" }
	if {[regexp -nocase {\-postmortem$|\-SKIDROW$|\-SILENTGATE$|\-GRATIS$|\-RELOADED$|\-DEVIANCE$|\-FLT$|\-HATRED$|\-razor1911$|\-HOODLUM$|\-SPHiNX$|\-TECHNiC$|\-RiTUEL$|\-NESSUNO$|\-VITALITY$|\-Unleashed$|\-JFKPC$|\-Micronauts$|\-fasiso$|\-genesis$|\-die$|\-PLEX$|\-alias$|\-PROPHET$|\-Bamboocha$|[\.\-\_](bw|sf|alcohol)?clone(cd|dvd)[\.\-\_]} $release]} { set section "GAMES" }
	if {[regexp -nocase {[\.\-\_](dvd)?covers[\.\-\_]} $release]} { set section "COVERS" }
	if {[regexp -nocase {[.\-_](sc[e3]n[e3](n[o0]tic[e3]|ban(n[e3]d)?)|purg[e3]|sc[e3]n[e3]rs|[ui]ns[e3]cur[e3]\.paysit[e3]|p2l|expos[e3]d\.r[e3]nt[e3]d|s[e3]lling\.l[e3][e3]ch|p2p)[.\-_]|\-cl[e3]ansc[e3]n[e3]$|\-spartacus$|\-warning$|\-sc[e3]n[e3]n[o0]tic[e3]$|\-n[o0]tic[e3]$|\-.+n[o0]tic[e3]$} $release]} { set section "SCENENOTiCE" }
	
	if { $section == "MP3" } {
		if {[regexp -nocase {[\.\-\_](divx|mvid|musicvide[o0]|720p|1080i|1080p|[xh]264|mp4|hr|xvid|wmv|mov)[\.\-\_]} $release]} { set section "MVID" }
		if {[regexp {[\.\-\_]FLAC[\.\-\_]} $release]} { set section "FLAC" }
	}
	
	if { $section == "XXX" } {
		if {[regexp -nocase {[\.\-\_](b[rd]|dvd|xvid)(rip)?[\.\-\_]} $release]} { set section "XXX" }
		if {[regexp -nocase {[\.\-\_](dvd[r9]?|NTSC|PAL)[\.\-\_]} $release]} { set section "XXX-DVDR" }
		if {[regexp -nocase {[\.\-\_](720p|1080i|1080p)[\.\-\_]} $release]} { set section "XXX-X264" }
		if {[regexp -nocase {[\.\-\_](wmv|mp4|hr|mov|divx)[\.\-\_]} $release]} { set section "XXX-0DAY" }
		if {[regexp -nocase {[\.\-\_](IMA?G[E3]?S[E3]TS?|IMA?G[E3]?S?|PH[O0]T[O0]S[E3]TS?|PICTUR[E3]S[E3]TS?)[\.\-\_]} $release]} { set section "XXX-IMGSET" }
	}
	
	if { $section == "TV" } { 
		if {[regexp -nocase {[\.\-\_]([phs]?dtv|vhs|sat|xvid|dvb)(rip)?[\.\-\_]} $release]} { set section "TV-XVID" }
		if {[regexp -nocase {[\.\-\_]([xh]264|720p|1080i|1080p)[\.\-\_]} $release]} { set section "TV-X264" }
		if {[regexp -nocase {[\.\-\_]((hd)?dvd|b[rd]|blu[e3]?ray)(rip)[\.\-\_]} $release]} { set section "TV-DVDRIP" }
		if {[regexp -nocase {[\.\-\_]((S|season)[0-9]{1,3}(DVD|D|DIS[CK])[0-9]{1,3}|(cn)?dvd[r9])[\.\-\_]} $release]} { set section "TV-DVDR" }
		
		if { $section == "TV-X264" } { 
		
			if {[regexp {[\.\-\_]HDTV[\.\-\_]} $release]} { set section "TV-X264" }
			if {[regexp -nocase {[\.\-\_]bluray[\.\-\_]} $release]} { set section "TV-HDRIP" }
		
		}
	
	}
	
	return $section
}

putlog "xxx ADDPRE v9.82 --> By \002Islander\002 ||| Loaded Succesfully!"