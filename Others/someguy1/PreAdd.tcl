# SCRiPT v4.01 ADVANC3D ELiT3 SCRiPT
# By Islander :)
package require mysqltcl
 
set script_version "SCRiPT v4.01"
 
# Features:
# Spam prevention and valid release checker.
# Categories filter almost 99% accurate.
# Categories colors choices.
# Release Group also saved.
# Don't worry if it's one with multiple sources (for redundancy!) this script has dupe prevention :)
# Pre and spam are seperate in two seperate tables.
# Trims ALL color codes as soon as the release is announced in addpre channels & then adds to database.
# And hell looot more.....

# Enter in your MySQL connection data
set mysql_(user) "xxx"
set mysql_(password) "xxx"
set mysql_(host) "localhost"

set mysql_(db) "xxx"

# Self-Explanatory! Set .chanset for channels you want all these command enabled
# .chanset #channel +addpre
# .chanset #channel +info
# .chanset #channel +gn
# .chanset #channel +nuke
# .chanset #channel +modnuke
# .chanset #channel +unnuke
# .chanset #channel +delpre
# .chanset #channel +undelpre
# .chanset #channel +addold

#CREATE TABLE IF NOT EXISTS `releases` (
#  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
#  `rlsname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
#  `grp` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
#  `section` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
#  `time` int(11) unsigned NOT NULL DEFAULT '0',
#  `files` tinyint(4) unsigned NOT NULL DEFAULT '0',
#  `size` decimal(5,2) unsigned NOT NULL DEFAULT '0.00',
#  `genre` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
#  PRIMARY KEY (`id`),
#  UNIQUE KEY `rlsname` (`rlsname`),
#  KEY `grp` (`grp`),
#  KEY `section` (`section`),
#  KEY `time` (`time`)
#) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1;

#CREATE TABLE IF NOT EXISTS `spam` (
#  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
#  `rlsname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
#  `grp` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
#  `section` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
#  `time` int(11) unsigned NOT NULL DEFAULT '0',
#  `files` tinyint(4) unsigned NOT NULL DEFAULT '0',
#  `size` decimal(5,2) unsigned NOT NULL DEFAULT '0.00',
#  `genre` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
#  PRIMARY KEY (`id`),
#  UNIQUE KEY `rlsname` (`rlsname`),
#  KEY `grp` (`grp`),
#  KEY `section` (`section`),
#  KEY `time` (`time`)
#) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1;

#CREATE TABLE IF NOT EXISTS `nukelog` (
#  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
#  `rlsname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
#  `time` int(11) unsigned NOT NULL DEFAULT '0',
#  `reason` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
#  `network` varchar(25) COLLATE utf8_unicode_ci DEFAULT NULL,
#  `status` tinyint(1) unsigned NOT NULL DEFAULT '1',
#  PRIMARY KEY (`id`),
#  UNIQUE KEY `rlsstatus` (`rlsname`,`reason`),
#  KEY `time` (`time`),
#  KEY `network` (`network`),
#  KEY `status` (`status`)
#) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1;

# Categories announces type and colors settings.
# DONT Change the categories in first row, only edit the second row color codes & categories if needed.

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
	
# End of edit zone here....

#------------------------------NO EDIT ZONE!!!------------------------------

# Below this line is the no-edit zone!
bind pub - !add isy:addpre
bind pub - !addpre isy:addpre

bind pub - !info isy:info
bind pub - !gn isy:genre

bind pub - !oldinfo isy:info
bind pub - !oldgn isy:genre

bind pub - !nuke isy:nuke
bind pub - !modnuke isy:modnuke
bind pub - !unnuke isy:unnuke

bind pub - !oldnuke isy:nuke
bind pub - !oldmodnuke isy:modnuke
bind pub - !oldunnuke isy:unnuke

bind pub - !delpre isy:delpre
bind pub - !undelpre isy:undelpre

bind pub - !olddelpre isy:delpre
bind pub - !oldundelpre isy:undelpre

bind pub - !addold isy:addold

setudef flag addpre
setudef flag info
setudef flag gn
setudef flag nuke
setudef flag modnuke
setudef flag unnuke
setudef flag delpre
setudef flag undelpre
setudef flag addold

proc mysql:keepalive {} {
	global db_handle mysql_
	
	if {[catch {mysql::ping $db_handle} error] || ![mysql::ping $db_handle]} {
		set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
	}

	utimer 120 [list mysql:keepalive]
	
	return 0
}

mysql:keepalive

proc isy:addrelease { chan rlsname unixtime files size genre type } {
	global db_handle
	
	set chan [string trim [stripcodes bc $chan]]
	set rlsname [string trim [stripcodes bc $rlsname]]
	set unixtime [string trim [stripcodes bc $unixtime]]
	set files [string trim [stripcodes bc $files]]
	set size [string trim [stripcodes bc $size]]
	set genre [string trim [stripcodes bc $genre]]
	set type [string trim [stripcodes bc $type]]
	
	if {[channel get $chan $type]} {
		
		set rlsvalid [isy:validrelease $rlsname]
		set section [isy:getsec_fromrls $rlsname]
		set grp [string trim [lindex [split $rlsname "-"] end]]
		
		if { $files == "-" || $size == "-" } { set files "0"; set size "0"; }
		if { $files == "" || $size == "" } { set files "0"; set size "0"; }
		#if { $genre == "" } { set genre "NULL"; }
		
		if { $rlsvalid == "1" } { 
		
			set whichtable "releases"
			
		} elseif { $rlsvalid == "0" } {
		
			putlog "SPAM BL0CKED -> $rlsname"
			set whichtable "spam"
			
		}
		
		switch $type {
		
			"addpre" {
				set chanmsg " $section"
			}
			
			"info" {
				set chanmsg " $files $size"
			}
			
			"gn" {
				regsub -all {\/|\&} $genre "_" genre
				set chanmsg " $genre"
			}
			
			"addold" {
				set chanmsg " $section $unixtime $files $size $genre -"
			}
			
			default {
				set chanmsg ""
			}
			
		}
		
		set section [isy:getsec_fromrls $rlsname]
		
		set isdone [::mysql::exec $db_handle "INSERT INTO $whichtable ( `rlsname` , `grp` , `section` , `time` , `files` , `size` , `genre` ) VALUES ( '[::mysql::escape $db_handle $rlsname]' , '[::mysql::escape $db_handle $grp]' ,  '[::mysql::escape $db_handle $section]' , '[::mysql::escape $db_handle $unixtime]' , '[::mysql::escape $db_handle $files]' , '[::mysql::escape $db_handle $size]', '[::mysql::escape $db_handle $genre]' ) ON DUPLICATE KEY UPDATE files = IF(VALUES(files) != 0, IF(files = 0, VALUES(files), files), files), size = IF(VALUES(size) != 0, IF(size = 0, VALUES(size), size), size), genre = IF(VALUES(genre) != '', IF(genre IS NULL, VALUES(genre), IF(genre = '', VALUES(genre), genre)), genre)"];
		
		if { $isdone == "1" && $rlsvalid == "1" } {
			
			#putquick "PRIVMSG $chan :!$type $rlsname $chanmsg"
			
		}
	}
}

proc isy:addpre { nick uhost hand chan arg } {
	return [isy:addrelease $chan [lindex $arg 0] [clock seconds] "0" "0" "" "addpre"];
}

proc isy:info { nick uhost hand chan arg } {
	return [isy:addrelease $chan [lindex $arg 0] [clock seconds] [lindex $arg 1] [lindex $arg 2] "" "info"];
}

proc isy:genre { nick uhost hand chan arg } {
	return [isy:addrelease $chan [lindex $arg 0] [clock seconds] "0" "0" [lindex $arg 1] "gn"];
}

proc isy:addold { nick uhost hand chan arg } {
	return [isy:addrelease $chan [lindex $arg 0] [lindex $arg 2] [lindex $arg 3] [lindex $arg 4] [lindex $arg 5] "addold"];
	#if { [lindex $arg 6] != "-" }
	#return [isy:nukelog $chan [lindex $arg 0] [clock seconds] [lindex $arg 6] "" "1" "nuke"];
}

proc isy:nukelog { chan rlsname unixtime reason network status type } {
	global db_handle
	
	set chan [string trim [stripcodes bc $chan]]
	set rlsname [string trim [stripcodes bc $rlsname]]
	set unixtime [string trim [stripcodes bc $unixtime]]
	set reason [string trim [stripcodes bc $reason]]
	set network [string trim [stripcodes bc $network]]
	set status [string trim [stripcodes bc $status]]
	set type [string trim [stripcodes bc $type]]
	
	if {[channel get $chan $type]} {
		
		if { $reason == "" } { set reason "NULL"; }
		if { $network == "" } { set network "NULL"; }
		
		set rlsvalid [isy:validrelease $rlsname]
		
		if { $rlsvalid == "1" } {
		
			set isdone [::mysql::exec $db_handle "INSERT IGNORE INTO nukelog ( `rlsname` , `time` , `reason` , `network` , `status` ) VALUES ( '[::mysql::escape $db_handle $rlsname]' , '[::mysql::escape $db_handle $unixtime]' ,  '[::mysql::escape $db_handle $reason]' , '[::mysql::escape $db_handle $network]' , '[::mysql::escape $db_handle $status]' )"]
		
			if {$isdone == "1"} {
				
				#putquick "PRIVMSG $chan :!$type $rlsname $reason $network"
				
			}
		}                        
	}
}

proc isy:nuke { nick uhost hand chan arg } {
	return [isy:nukelog $chan [lindex $arg 0] [clock seconds] [lindex $arg 1] [lindex $arg 2] "1" "nuke"];
}

proc isy:modnuke { nick uhost hand chan arg } {
	return [isy:nukelog $chan [lindex $arg 0] [clock seconds] [lindex $arg 1] [lindex $arg 2] "2" "modnuke"];
}

proc isy:unnuke { nick uhost hand chan arg } {
	return [isy:nukelog $chan [lindex $arg 0] [clock seconds] [lindex $arg 1] [lindex $arg 2] "3" "unnuke"];
}

proc isy:spamswitch {chan rlsname unixtime reason network status type} {
	global db_handle
	
	set chan [string trim [stripcodes bc $chan]]
	set rlsname [string trim [stripcodes bc $rlsname]]
	set unixtime [string trim [stripcodes bc $unixtime]]
	set reason [string trim [stripcodes bc $reason]]
	set network [string trim [stripcodes bc $network]]
	set type [string trim [stripcodes bc $type]]
	
	if {[channel get $chan $type]} {
	
		set rlsvalid [isy:validrelease $rlsname]
		
		if { $rlsvalid == "0" } { return; }
	
		if { $type == "delpre" } {
			
			set isdone [::mysql::exec $db_handle "INSERT IGNORE INTO spam ( `rlsname` , `grp` , `section` , `time` , `files` , `size` , `genre` ) SELECT rlsname, grp, section, time, files, size, genre FROM releases WHERE rlsname = '[::mysql::escape $db_handle $rlsname]'"]
		
		
		} elseif { $type == "undelpre" } {
		
			set isdone [::mysql::exec $db_handle "INSERT IGNORE INTO releases ( `rlsname` , `grp` , `section` , `time` , `files` , `size` , `genre` ) SELECT rlsname, grp, section, time, files, size, genre FROM spam WHERE rlsname = '[::mysql::escape $db_handle $rlsname]'"]
		
		}
		
		if {$isdone == "1"} {
		
			set somevar [isy:nukelog $chan $rlsname $unixtime $reason $network $status $type];
			
			#putquick "PRIVMSG $chan :!$type $rlsname $reason $network"
			
		}
	}
}

proc isy:delpre {nick uhost handle chan arg} {
	return [isy:spamswitch $chan [lindex $arg 0] [clock seconds] [lindex $arg 1] [lindex $arg 2] "4" "delpre"];
}

proc isy:undelpre {nick uhost handle chan arg} {
	return [isy:spamswitch $chan [lindex $arg 0] [clock seconds] [lindex $arg 1] [lindex $arg 2] "5" "undelpre"];
}

proc isy:validrelease { release } {
	
	set rlscopy $release
	set minlen 1
	set maxlen 256
 
	if {[string length $release] < $minlen}                                 				{return 0}
	if {[string length $release] > $maxlen}                                 				{return 0}
	if {![regexp {\.|\_|\-} $release]}                                      				{return 0}
	#if {[regexp {\$|\!|\:|\@|\~|\||\[|\]|\`|\#|\^|\+|\{|\}|\[|\]|\/|\?|\>|\<} $release]} 	{return 0}
	if {[regexp {[\-\.\(\)_]$} $release]}                                   				{return 0}
	if {![regexp {^[0-9]} $release]}  {
		if {![regexp -nocase {^[a-z]} $release]}                           					{return 0}
	}
	if {[regexp ^[clock format [clock scan today] -format %Y-%m] $release]} 				{return 0}
	if {[regexp ^[clock format [clock scan today] -format %m%d] $release]}  				{return 0}
	if {[regexp -all {\(} $release]!=[regexp -all {\)} $release]}           				{return 0}
	
	regsub -all {[A-Za-z0-9\_\.\-\(\)]} $rlscopy "" rlscopy
	
	if {[string trim $rlscopy] != ""}                                						{return 0}
	
	if {[regexp -nocase {p[-\._]?r[-\._]?[e3][-\._]?[7t][-\._]?[e3][-\._]?[s5][-\._]?[t7]|[7t][-\._]?[e3][-\._]?[s5][-\._]?[t7][-\._]?p[-\._]?r[-\._]?[e3][-\._]?|d[o0][-\._]?n[o0]?[t7].*[t7]r[a4]d[e3]|^[t7][-\._]?[e3][-\._]?[s5][-\._]?[t7][-\._]?[a-z0-9]+$} $release]} {return 0}
 
	return 1
 
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
	if {[regexp -nocase {[\.\-\_](bluray\.complete|complete\.bluray)[\.\-\_]} $release]} { set section "BLURAY" }
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
			
			if {[regexp {[\.\-\_](WS|PDTV|HDTV)[\.\-\_]} $release]} { set section "TV-SD-X264" }
			if {[regexp -nocase {[\.\-\_](720p|1080i|1080p)[\.\-\_]} $release]} { set section "TV-HD-X264" }
			if {[regexp -nocase {[\.\-\_]bluray[\.\-\_]} $release]} { set section "TV-HDRIP" }
		
		}
	
	}
	
	return $section
}

# It would be nice if you didn't delete this but there is really nothing I can do!
putlog "$script_version --> By \002Islander\002 ||| Loaded Succesfully!"