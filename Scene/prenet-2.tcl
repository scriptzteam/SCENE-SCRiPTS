# Mysql-Pre v9.4 ADVANC3D ELiT3 SCRiPT
# By Islander :)
# This script is coded by combining various other pre scripts and this is the best one ever !!!
# It took many many long hours to code this script, please leave credits where its due
package require mysqltcl
package require TclCurl
 
set script_version "xxx ALL v2.01 SCRiPT"
 
# Features:
# Spam prevention and valid release checker.
# Categories filter almost 99% accurate.
# Categories colors choices.
# Network announce feature also available for other linked bots w00t :D
# Release Group also saved.
# Don't worry if it's one with multiple sources (for redundancy!) this script has dupe prevention :)
# Pre and spam are seperate in two seperate tables.
# Easy flexible announce style editor with the bracket_ values.
# Trims ALL color codes as soon as the release is announced in addpre channels & then adds to database.
# And hell looot more.....

# Enter in your MySQL connection data
set mysql_(user) "scenedbaxx"
set mysql_(password) "Q3wX8GdPV7eKNQpw"
set mysql_(host) "localhost"

set mysql_(db) "scenestuff"

set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]

set mysql_(pretable) "prerlsdb"
set mysql_(craptable) "craprlsdb"
set mysql_(nuketable) "delnukedb"
set mysql_(videotable) "videoinfo"
set mysql_(mp3table) "mp3info"
set mysql_(tracktable) "trackinfo"

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

set videodb_(id) "id"
set videodb_(rlsname) "rlsname"
set videodb_(videocodec) "videocodec"
set videodb_(frames) "frames"
set videodb_(resolution) "resolution"
set videodb_(resnframe) "resnframe"
set videodb_(audiocodec) "audiocodec"
set videodb_(bitrate) "bitrate"
set videodb_(hertz) "hertz"
set videodb_(channel) "channel"
set videodb_(unixtime) "unixtime"
set videodb_(addedon) "addedon"
set videodb_(fromnet) "fromnet"

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
set mp3db_(fromnet) "fromnet"

# Self-Explanatory! Set addpre to your addpre chan of choice! and same for other channels.
set PR3N3T "xxx"

set chann_(addpre) "#xxx"
set chann_(addinfo) "#xxx"
set chann_(nuke) "#nuke"
set chann_(nuke2) "#nuke"
set chann_(delpre) "#del"

set chann_(addmp3) "#mp3"
set chann_(addvideo) "#video"
set chann_(addurl) "#imdb"

set chann_(addold) "#old"
set chann_(sitepre) "#site"

# Set this to your IRC pre announce channels.
set chann_(infoann) "#xxx"
set chann_(spamann) "#xxx"

set chann_(addspam) "#file"

set addfeedurl "http://example.com/preadddata.php?data="

# Announces releases in irc channels set to 1 if you want to disable then set this option to 0.
set ann_(network) "1"
set ann_(info) "1"
set ann_(genre) "1"

set whichbot "STRB"

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
bind pub - !gn isy:genre
bind pub - !nuke isy:nuke
bind pub - !modnuke isy:modnuke
bind pub - !unnuke isy:unnuke
bind pub - !delpre isy:delpre
bind pub - !undelpre isy:undelpre
bind pub - !info isy:info
bind pub - !addvideoinfo videointodb
bind pub - !addmp3info mp3intodb
bind pub - !addid3c mp3intodb
#bind pub - !addtrack trackintodb
bind pub - !addurl urlintodb
bind pub - !addimdb imdbintodb

bind pub - !time isy:timenow

bind pub - !addold isy:addold
bind pub - !oldnuke isy:nuke
bind pub - !oldunnuke isy:unnuke

bind pub - !oldvideoinfo videointodb
bind pub - !oldmp3info mp3intodb
bind pub - !oldid3c mp3intodb
#bind pub - !oldtrack trackintodb
bind pub - !oldurl urlintodb
bind pub - !oldimdb imdbintodb


bind pub - !addnfo nfoinsidedb
bind pub - !addsfv sfvinsidedb
bind pub - !addm3u m3uinsidedb

bind pub - !oldnfo nfoinsidedb
bind pub - !oldsfv sfvinsidedb
bind pub - !oldm3u m3uinsidedb


bind bot - PREAFFIL spreadpreaffil

bind bot - ADDPRE getprerls
bind bot - NUKE nukerls
bind bot - UNNUKE unnukerls
bind bot - MODNUKE modnukerls
bind bot - DELPRE delprerls
bind bot - UNDELPRE undelprerls

bind bot - PREINFO getinforls
bind bot - GENRE getgenrerls

bind bot - ADDNFO nfoprerls
bind bot - ADDSFV sfvprerls
bind bot - ADDM3U m3uprerls
bind bot - ADDJPG jpgprerls
bind bot - ADDDIZ dizprerls
bind bot - ADDVIDEOINFO videoprerls
bind bot - ADDMP3INFO mp3prerls
bind bot - ADDIMDB imdbrls
bind bot - ADDURL urlrls

proc mysql:keepalive {} {
	global db_handle mysql_
	
	if {[catch {mysql::ping $db_handle} error] || ![mysql::ping $db_handle]} {
		set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
	}

	utimer 120 [list mysql:keepalive]
	
	return 0
}

mysql:keepalive

proc spreadpreaffil {bot com args} {
	global chann_
	
	set rlsname [lindex [lindex $args 0] 0]
	set section [lindex [lindex $args 0] 1]
	set files [lindex [lindex $args 0] 2]
	set size [lindex [lindex $args 0] 3]
	
	putquick "PRIVMSG $chann_(addpre) :!addpre $rlsname $section"
	putquick "PRIVMSG $chann_(addinfo) :!info $rlsname $files $size"
	putquick "PRIVMSG $chann_(sitepre) :!sitepre $rlsname $section - -"
	
}


proc getprerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set section [lindex [lindex $args 0] 1]
		
		putquick "PRIVMSG $chann_(addpre) :!addpre $rlsname $section"
	
	}
}

proc nukerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {	
	
	set rlsname [lindex [lindex $args 0] 0]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putquick "PRIVMSG $chann_(nuke) :!nuke $rlsname $reason $nukenet"

	}
}

proc unnukerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {	
	
	set rlsname [lindex [lindex $args 0] 0]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putquick "PRIVMSG $chann_(nuke) :!unnuke $rlsname $reason $nukenet"

	}
}

proc modnukerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {	
	
	set rlsname [lindex [lindex $args 0] 0]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putquick "PRIVMSG $chann_(nuke) :!modnuke $rlsname $reason $nukenet"

	}
}

proc delprerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {	
	
	set rlsname [lindex [lindex $args 0] 0]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putquick "PRIVMSG $chann_(delpre) :!delpre $rlsname $reason $nukenet"
	
	}
}

proc undelprerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {	
	
	set rlsname [lindex [lindex $args 0] 0]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putquick "PRIVMSG $chann_(delpre) :!undelpre $rlsname $reason $nukenet"

	}
}

proc getinforls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set fles [lindex [lindex $args 0] 1]
		set size [lindex [lindex $args 0] 2]
			
		putquick "PRIVMSG $chann_(addinfo) :!info $rlsname $fles $size"
		
	}
}

proc getgenrerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set gnre [lindex [lindex $args 0] 1]
			
		putquick "PRIVMSG $chann_(addinfo) :!gn $rlsname $gnre"
		
	}
}

proc imdbrls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set imdbid [lindex [lindex $args 0] 1]
		set rating [lindex [lindex $args 0] 2]
		set votes [lindex [lindex $args 0] 3]
		
		putquick "PRIVMSG $chann_(addurl) :!addimdb $rlsname $rating $votes $imdbid"
	
	}
}

proc urlrls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set url [lindex [lindex $args 0] 1]
			
		putquick "PRIVMSG $chann_(addurl) :!addurl $rlsname $url"
	
	}
}

proc videoprerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set vidcodec [lindex [lindex $args 0] 1]
		set frmes [lindex [lindex $args 0] 2]
		set resl [lindex [lindex $args 0] 3]
		set resnfrmes [lindex [lindex $args 0] 4]
		set audcodec [lindex [lindex $args 0] 5]
		set bitrate [lindex [lindex $args 0] 6]
		set hertz [lindex [lindex $args 0] 7]
		set channel [lindex [lindex $args 0] 8]


		putquick "PRIVMSG $chann_(addvideo) :!addvideoinfo $rlsname $vidcodec $frmes $resl $resnfrmes $audcodec $bitrate $hertz $channel"
		
	}
}

proc mp3prerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set genre [lindex [lindex $args 0] 1]
		set year [lindex [lindex $args 0] 2]
		set hertz [lindex [lindex $args 0] 3]
		set type [lindex [lindex $args 0] 4]
		set bitrate [lindex [lindex $args 0] 5]
		set bittype [lindex [lindex $args 0] 6]

		putquick "PRIVMSG $chann_(addmp3) :!addid3c $rlsname $genre $year $hertz $type $bitrate $bittype"
		
	}
}

proc nfoprerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set hash [lindex [lindex $args 0] 1]
		set filename [lindex [lindex $args 0] 2]
		set crc [lindex [lindex $args 0] 3]
		set size [lindex [lindex $args 0] 4]

		putquick "PRIVMSG $chann_(addspam) :!addnfo $rlsname https://example.com/file.php?l=$hash $filename $crc"
	
	}
}

proc sfvprerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set hash [lindex [lindex $args 0] 1]
		set filename [lindex [lindex $args 0] 2]
		set crc [lindex [lindex $args 0] 3]
		set size [lindex [lindex $args 0] 4]
		
		putquick "PRIVMSG $chann_(addspam) :!addsfv $rlsname https://example.com/file.php?l=$hash $filename $crc"
	
	}
}

proc m3uprerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set hash [lindex [lindex $args 0] 1]
		set filename [lindex [lindex $args 0] 2]
		set crc [lindex [lindex $args 0] 3]
		set size [lindex [lindex $args 0] 4]
		
		putquick "PRIVMSG $chann_(addspam) :!addm3u $rlsname https://example.com/file.php?l=$hash $filename $crc"
	
	}
}

proc jpgprerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set hash [lindex [lindex $args 0] 1]
		set filename [lindex [lindex $args 0] 2]
		set crc [lindex [lindex $args 0] 3]
		set size [lindex [lindex $args 0] 4]
		
		putquick "PRIVMSG $chann_(addspam) :!addjpg $rlsname https://example.com/file.php?l=$hash $filename $crc"
	
	}
}

proc dizprerls {bot com args} {
	global chann_ whichbot 
	
	if { $bot == $whichbot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set hash [lindex [lindex $args 0] 1]
		set filename [lindex [lindex $args 0] 2]
		set crc [lindex [lindex $args 0] 3]
		set size [lindex [lindex $args 0] 4]
		
		putquick "PRIVMSG $chann_(addspam) :!adddiz $rlsname https://example.com/file.php?l=$hash $filename $crc"
	
	}
}

proc isy:addpre { nick uhost hand chan arg } {
	global mysql_ predb_ chann_ db_handle PR3N3T whichbot 
	
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
					
					putbot $whichbot "ADDPRE $rlsname $section $grp"
					
					#putquick "PRIVMSG $chan :!addpre $rlsname $section"
					
				}
			}
	}
}

proc isy:timenow { nick uhost hand chan arg } {
	global chann_ fishkey_ 
	
	if { $chan == $chann_(addold) } { 
		
		set unixtime [clock seconds]
		set humandate [clock format $unixtime -format %D]
		set humantime [clock format $unixtime -format %H:%M:%S]
		
		append var "\[ TiME N0W \] "
		append var "\[ UNiX TiME -> $unixtime \] "
		append var "\[ HUMAN TiME -> $humandate $humantime \]"
		
		putquick "PRIVMSG $chan :$var"
		
	}
	
}

proc isy:addold { nick uhost hand chan arg } {
	global mysql_ predb_ chann_ ann_ db_handle PR3N3T whichbot
	
	if { $chan == $chann_(addold) } { 
		
		set unixtime [clock seconds]
		
		set arg [string trim [stripcodes bc $arg]]
		#set arg [isy:trimcolors $arg]
		set rlsname [lindex $arg 0]
		set predon [lindex $arg 2]
		
		if { [string trim [lindex $arg 1]] == "-" } {
			set sectionmain "PRE"
		} else {
			set sectionmain [string trim [lindex $arg 1]]
		}
		
		if { [string trim [lindex $arg 3]] == "-" } {
			set files ""
		} else {
			set files [string trim [lindex $arg 3]]
		}
		
		if { [string trim [lindex $arg 4]] == "-" } {
			set size ""
		} else {
			set size [string trim [lindex $arg 4]]
		}
		
		if { [string trim [lindex $arg 5]] == "-" } {
			set genre ""
		} else {
			set genre [string trim [lindex $arg 5]]
		}
		
		if { [string trim [lindex $arg 6]] == "-" } {
			set nukereason ""
			set nukenet ""
			set nukestatus ""
		} else {
			set nukereason [string trim [lindex $arg 6]]
			set nukenet "UNKN0WN"
			set nukestatus ""
		}
		
		set rlsvalid [isy:validrelease $rlsname]
		
			if { $rlsvalid == "1" } { 
				set whichtable "$mysql_(pretable)"
				
			} elseif { $rlsvalid == "0" } {
				putlog "SPAM BL0CKED -> $rlsname"
				set whichtable "$mysql_(craptable)"
			}
			
			set result [mysqlsel $db_handle "SELECT $predb_(id) FROM $whichtable WHERE $predb_(rlsname) = '$rlsname'"]
				
			if { $result == "0" } {
				
				set section [isy:getsec_fromrls $rlsname]
				
				set grp [string trim [lindex [split [lindex $arg 0] "-"] end]]
				
				set fromdata "$nick:$chan:$PR3N3T"
				set frominfo [::mysql::escape $fromdata]
				
				set isdone [mysqlexec $db_handle "INSERT INTO $whichtable ( `$predb_(sectionmain)` , `$predb_(section)` , `$predb_(rlsname)` , `$predb_(unixtime)` , `$predb_(grp)` , `$predb_(addedon)` , `$predb_(files)` , `$predb_(size)` , `$predb_(genre)` , `$predb_(nukereason)` , `$predb_(nukenet)` , `$predb_(nukestatus)` , `$predb_(frompre)` , `$predb_(addold)` ) VALUES ( '$sectionmain' , '$section' ,  '$rlsname' , '$predon' ,  '$grp' , '$unixtime' , '$files' ,  '$size' , '$genre' , '$nukereason' ,  '$nukenet' , '$nukestatus' , '$frominfo' , 'yes' )"]
					
				if { $isdone == "1" && $rlsvalid == "1" } {
				
					#putquick "PRIVMSG $chan :!addold $arg"
					
					if { $ann_(network) == "1" } {
						#putbot $whichbot "ADDOLD $rlsname $section $predon $files $size $genre $nukereason $grp"
					}
				}
			}
	}
}


proc isy:info { nick uhost hand chan arg } {
	global mysql_ predb_ chann_ ann_ db_handle PR3N3T whichbot
	
	if { $chan == $chann_(addinfo) } {
		
		set unixtime [clock seconds]
		set arg [string trim [stripcodes bc $arg]]
	    set rlsname [lindex $arg 0]
	    set files [lindex $arg 1]
	    set size [lindex $arg 2]
		
		if { $files == "0" || $size == "0" }  { return }
	    if { $files == "-" || $size == "-" }  { return }
	  
		set result [mysqlsel $db_handle "SELECT $predb_(id) FROM $mysql_(pretable) WHERE $predb_(rlsname) = '$rlsname' AND $predb_(files) != 0 AND $predb_(size) != 0" -list]
		
		if { $result == "" && $files != "" && $size != "" } {
			
			set fromdata "$nick:$chan:$PR3N3T:$unixtime"
			set frominfo [::mysql::escape $fromdata]
			set isdone [mysqlexec $db_handle "UPDATE $mysql_(pretable) SET $predb_(files)='$files', $predb_(size)='$size', $predb_(frominfo)='$frominfo' WHERE $predb_(rlsname)='$rlsname'"]
			
			if {$isdone == "1"} {
				
				if { $ann_(network) == "1" } {
					putbot $whichbot "PREINFO $rlsname $files $size"
				}
				
				if {$ann_(info) == "1"} {
					#putquick "PRIVMSG $chann_(infoann) :!info $rlsname $files $size"
				}
				
			}
        }
    }
}

proc isy:genre { nick uhost hand chan arg } {
	global mysql_ predb_ chann_ ann_ db_handle PR3N3T whichbot
	
	if { $chan == $chann_(addinfo) } {
		
		set unixtime [clock seconds]
		set arg [string trim [stripcodes bc $arg]]
	    set rlsname [lindex $arg 0]
	    set genre [lindex $arg 1]
	  
		set result [mysqlsel $db_handle "SELECT $predb_(id) FROM $mysql_(pretable) WHERE $predb_(rlsname) = '$rlsname' AND $predb_(genre) IS NULL" -list]
		
		if { $result != "" && $genre != "" } {
			
			regsub -all {\/|\&} $genre "_" genre
			
			set fromdata "$nick:$chan:$PR3N3T:$unixtime"
			set frominfo [::mysql::escape $fromdata]
			
            set isdone [mysqlexec $db_handle "UPDATE $mysql_(pretable) SET $predb_(genre)='$genre',$predb_(fromgenre)='$frominfo' WHERE $predb_(rlsname)='$rlsname'"]
			
			if {$isdone == "1"} {
				
				if { $ann_(network) == "1" } {
					putbot $whichbot "GENRE $rlsname $genre"
				}
				
				if {$ann_(genre) == "1"} {
					#putquick "PRIVMSG $chann_(infoann) :!gn $rlsname $genre"
				}
				
			}
       	}
	}
}

proc imdbintodb { nick uhost hand chan arg } {
	global mysql_ predb_ chann_ ann_ db_handle PR3N3T whichbot
	
	if { $chan == $chann_(addurl) } {
		
		set unixtime [clock seconds]
		set arg [string trim [stripcodes bc $arg]]
	    set rlsname [lindex $arg 0]
	    set imdb [lindex $arg 1]
	  
		set result [mysqlsel $db_handle "SELECT $predb_(id) FROM $mysql_(pretable) WHERE $predb_(rlsname) = '$rlsname' AND $predb_(imdb) IS NULL" -list]
		
		if { $result != "" && $imdb != "" } {
			
			set fromdata "$nick:$chan:$PR3N3T:$unixtime"
			set frominfo [::mysql::escape $fromdata]
			
            set isdone [mysqlexec $db_handle "UPDATE $mysql_(pretable) SET $predb_(imdb)='$imdb',$predb_(fromimdb)='$frominfo' WHERE $predb_(rlsname)='$rlsname'"]
			
			if {$isdone == "1"} {
				
				if { $ann_(network) == "1" } {
					putbot $whichbot "IMDB $rlsname $imdb"
				}
				
			}
       	}
	}
}

proc urlintodb { nick uhost hand chan arg } {
	global mysql_ predb_ chann_ ann_ db_handle PR3N3T whichbot
	
	if { $chan == $chann_(addurl) } {
		
		set unixtime [clock seconds]
		set arg [string trim [stripcodes bc $arg]]
	    set rlsname [lindex $arg 0]
	    set url [lindex $arg 1]
	  
		set result [mysqlsel $db_handle "SELECT $predb_(id) FROM $mysql_(pretable) WHERE $predb_(rlsname) = '$rlsname' AND $predb_(url) IS NULL" -list]
		
		if { $result != "" && $url != "" } {
			
			set fromdata "$nick:$chan:$PR3N3T:$unixtime"
			set frominfo [::mysql::escape $fromdata]
			
            set isdone [mysqlexec $db_handle "UPDATE $mysql_(pretable) SET $predb_(url)='$url',$predb_(fromurl)='$frominfo' WHERE $predb_(rlsname)='$rlsname'"]
			
			if {$isdone == "1"} {
				
				if { $ann_(network) == "1" } {
					putbot $whichbot "URL $rlsname $url"
				}
				
			}
       	}
	}
}

proc isy:nuke { nick uhost hand chan arg } {
	global mysql_ predb_ chann_ ann_ db_handle PR3N3T whichbot
	
	if { $chan == $chann_(nuke) || $chan == $chann_(nuke2) || $chan == $chann_(addold) } {
	
		set arg [string trim [stripcodes bc $arg]]
		set unixtime [clock seconds]
		set rlsname [lindex $arg 0]
		set reason [lindex $arg 1]
		set nukenet [lindex $arg 2]
		set nukestatus "Nuked"
		
		set result [mysqlsel $db_handle "SELECT $predb_(nukestatus), $predb_(nukereason) FROM $mysql_(pretable) WHERE $predb_(rlsname) = '$rlsname'" -list]
		
		set data [lindex $result 0]
		set nstatus [lindex $data 0]
		set nreason [lindex $data 1]
		
		if { $nukenet != "" && $nreason != $reason &&  $nstatus != $nukestatus } {
		
		set fromdata "$nick:$chan:$PR3N3T:$unixtime"
		set frominfo [::mysql::escape $fromdata]
		
		set isdone [mysqlexec $db_handle "UPDATE $mysql_(pretable) SET $predb_(nukestatus)='$nukestatus',$predb_(nukereason)='$reason',$predb_(nukenet)='$nukenet',$predb_(fromnuke)='$frominfo' WHERE $predb_(rlsname)='$rlsname' LIMIT 1"]
			
			if {$isdone == "1"} {
				
				if { $ann_(network) == "1" } {
					putbot $whichbot "NUKE $rlsname $reason $nukenet"
				}
				
			}
		}                        
	}
}

proc isy:modnuke { nick uhost hand chan arg } {
	global mysql_ predb_ chann_ ann_ db_handle PR3N3T whichbot
	
	if { $chan == $chann_(nuke) || $chan == $chann_(nuke2) || $chan == $chann_(addold) } {
	
		set arg [string trim [stripcodes bc $arg]]
		set unixtime [clock seconds]
		set rlsname [lindex $arg 0]
		set reason [lindex $arg 1]
		set nukenet [lindex $arg 2]
		set nukestatus "ModNuked"
		
		set result [mysqlsel $db_handle "SELECT $predb_(nukestatus), $predb_(nukereason) FROM $mysql_(pretable) WHERE $predb_(rlsname) = '$rlsname'" -list]
		
		set data [lindex $result 0]
		set nstatus [lindex $data 0]
		set nreason [lindex $data 1]
		
		if { $nukenet != "" && $nreason != $reason &&  $nstatus != $nukestatus } {
		
		set fromdata "$nick:$chan:$PR3N3T:$unixtime"
		set frominfo [::mysql::escape $fromdata]
		
		set isdone [mysqlexec $db_handle "UPDATE $mysql_(pretable) SET $predb_(nukestatus)='$nukestatus',$predb_(nukereason)='$reason',$predb_(nukenet)='$nukenet',$predb_(fromnuke)='$frominfo' WHERE $predb_(rlsname)='$rlsname' LIMIT 1"]
			
			if {$isdone == "1"} {
				
				if { $ann_(network) == "1" } {
					putbot $whichbot "MODNUKE $rlsname $reason $nukenet"
				}
				
			}
		}                        
	}
}

proc isy:unnuke { nick uhost hand chan arg } {
	global mysql_ predb_ chann_ ann_ db_handle PR3N3T whichbot
	
	if { $chan == $chann_(nuke) || $chan == $chann_(nuke2) || $chan == $chann_(addold) } {
	
		set arg [string trim [stripcodes bc $arg]]
		set unixtime [clock seconds]
		set rlsname [lindex $arg 0]
		set reason [lindex $arg 1]
		set nukenet [lindex $arg 2]
		set nukestatus "UnNuked"
		
		set result [mysqlsel $db_handle "SELECT $predb_(nukestatus), $predb_(nukereason) FROM $mysql_(pretable) WHERE $predb_(rlsname) = '$rlsname'" -list]
		
		set data [lindex $result 0]
		set nstatus [lindex $data 0]
		set nreason [lindex $data 1]
		
		if { $nukenet != "" && $nreason != $reason &&  $nstatus != $nukestatus } {
		
		set fromdata "$nick:$chan:$PR3N3T:$unixtime"
		set frominfo [::mysql::escape $fromdata]
		
		set isdone [mysqlexec $db_handle "UPDATE $mysql_(pretable) SET $predb_(nukestatus)='$nukestatus',$predb_(nukereason)='$reason',$predb_(nukenet)='$nukenet',$predb_(fromnuke)='$frominfo' WHERE $predb_(rlsname)='$rlsname' LIMIT 1"]
			
			if {$isdone == "1"} {
				
				if { $ann_(network) == "1" } {
					putbot $whichbot "UNNUKE $rlsname $reason $nukenet"
				}
				
			}
		}                        
	}
}

proc isy:delpre {nick uhost handle chan arg} {
	global mysql_ predb_ chann_ ann_ db_handle PR3N3T nukedb_ whichbot
	
	if { $chan == $chann_(delpre) || $chan == $chann_(addold) } {
	
		set arg [string trim [stripcodes bc $arg]]
		set rlsname [lindex $arg 0]
		set reason [lindex $arg 1]
		set nukenet [lindex $arg 2]
		set nukestatus "Deleted"
		set timenow [clock seconds]
		
		set result [mysqlsel $db_handle "SELECT $predb_(id),$predb_(rlsname),$predb_(sectionmain),$predb_(section),$predb_(files),$predb_(size),$predb_(unixtime),$predb_(addedon),$predb_(genre),$predb_(grp) FROM $mysql_(pretable) WHERE $predb_(rlsname) = '$rlsname' AND $predb_(delstatus) IS NULL LIMIT 1" -list]
		
		if { $result == "" } {
			set result2 [mysqlsel $db_handle "SELECT $nukedb_(id) FROM $mysql_(nuketable) WHERE $nukedb_(rlsname) = '$rlsname' AND $nukedb_(reason) = '$reason' AND $nukedb_(status) = '$nukestatus' ORDER BY DESC LIMIT 1" -list]
		}
		
		if { $result != "" && $nukenet != "" } {
			
			set data [lindex $result 0]
			set release [lindex $data 1]
			set sectionmain [lindex $data 2]
			set section [lindex $data 3]
			set files [lindex $data 4]
			set size [lindex $data 5]
			set unixtime [lindex $data 6]
			set addedon [lindex $data 7]
			set genre [lindex $data 8]
			set grp [lindex $data 9]
				
				set isdone [mysqlexec $db_handle "UPDATE $mysql_(pretable) SET $predb_(delstatus)='$nukestatus' WHERE $predb_(rlsname)='$release'"]
				set ismoved [mysqlexec $db_handle "INSERT INTO $mysql_(craptable) ( `$predb_(rlsname)` , `$predb_(sectionmain)` , `$predb_(section)` , `$predb_(files)` , `$predb_(size)` , `$predb_(unixtime)` , `$predb_(addedon)` , `$predb_(genre)` , `$predb_(grp)` , `$predb_(fromnick)` , `$predb_(fromchan)` , `$predb_(fromnet)` ) VALUES ( '$release' ,  '$sectionmain' ,  '$section' , '$files' , '$size' , '$unixtime' , '$timenow' ,  '$genre' ,  '$grp' , '$nick' ,  '$chan' ,  '$PR3N3T' )"]
				set isdeldone [mysqlexec $db_handle "INSERT INTO $mysql_(nuketable) ( `$nukedb_(rlsname)` , `$nukedb_(nukestatus)` , `$nukedb_(nukereason)` , `$nukedb_(nukenet)` , `$nukedb_(unixtime)` , `$nukedb_(fromnick)` , `$nukedb_(fromchan)` , `$nukedb_(fromnet)` ) VALUES ( '$release' , '$nukestatus' ,  '$reason' ,  '$nukenet' , '$timenow' ,  '$nick' ,  '$chan' , '$PR3N3T' )"]
				
			if { $isdone == "1" && $ismoved == "1" && $isdeldone == "1" } {
				
				if { $ann_(network) == "1" } {
					putbot $whichbot "DELPRE $release $reason $nukenet"
				}
				
			}
		}
	}
}

proc isy:undelpre {nick uhost handle chan arg} {
	global mysql_ predb_ chann_ ann_ db_handle PR3N3T nukedb_ whichbot
	
	if { $chan == $chann_(delpre) || $chan == $chann_(addold) } { 
		set arg [string trim [stripcodes bc $arg]]
		set rlsname [lindex $arg 0]
		set reason [lindex $arg 1]
		set nukenet [lindex $arg 2]
		set nukestatus "UnDeleted"
		set timenow [clock seconds]
		
		set result [mysqlsel $db_handle "SELECT $predb_(id),$predb_(rlsname),$predb_(sectionmain),$predb_(section),$predb_(files),$predb_(size),$predb_(unixtime),$predb_(addedon),$predb_(genre),$predb_(grp) FROM $mysql_(craptable) WHERE $predb_(rlsname) = '$rlsname' AND $predb_(delstatus) IS NULL" -list]
		
		if { $result != "" && $nukenet != "" } {
			
			set data [lindex $result 0]
			set release [lindex $data 1]
			set sectionmain [lindex $data 2]
			set section [lindex $data 3]
			set files [lindex $data 4]
			set size [lindex $data 5]
			set unixtime [lindex $data 6]
			set addedon [lindex $data 7]
			set genre [lindex $data 8]
			set grp [lindex $data 9]
				
				set isdone [mysqlexec $db_handle "UPDATE $mysql_(craptable) SET $predb_(delstatus)='$nukestatus' WHERE $predb_(rlsname)='$release'"]
				set ismoved [mysqlexec $db_handle "UPDATE $mysql_(pretable) SET $predb_(delstatus)='$nukestatus' WHERE $predb_(rlsname)='$release'"]
				set isdeldone [mysqlexec $db_handle "INSERT INTO $mysql_(nuketable) ( `$nukedb_(rlsname)` , `$nukedb_(nukestatus)` , `$nukedb_(nukereason)` , `$nukedb_(nukenet)` , `$nukedb_(unixtime)` , `$nukedb_(fromnick)` , `$nukedb_(fromchan)` , `$nukedb_(fromnet)` ) VALUES ( '$release' , '$nukestatus' ,  '$reason' ,  '$nukenet' , '$timenow' ,  '$nick' ,  '$chan' , '$PR3N3T' )"]
				
			if { $isdone == "1" && $ismoved == "1" && $isdeldone == "1" } {
				
				if { $ann_(network) == "1" } {
					putbot $whichbot "UNDELPRE $release $reason $nukenet"
				}
				
			}
		}
	}
}

proc videointodb { nick uhost hand chan arg } {
	global mysql_ videodb_ chann_ ann_ db_handle PR3N3T whichbot
	
	if { $chan == $chann_(addvideo) || $chan == $chann_(addold) } {
	
			set rlsname [lindex $arg 0]
			set vidcodec [lindex $arg 1]
			set frmes [lindex $arg 2]
			set resl [lindex $arg 3]
			set resnfrmes [lindex $arg 4]
			set audcodec [lindex $arg 5]
			set bitrate [lindex $arg 6]
			set hertz [lindex $arg 7]
			set channel [lindex $arg 8]
			set unixtime [clock seconds]
			
			if { $rlsname == "" || $vidcodec == "" || $frmes == "" || $resl == "" || $resnfrmes == "" || $audcodec == "" || $bitrate == "" || $hertz == "" || $channel == "" } { return }
			
			set fromdata "$nick:$chan:$PR3N3T:$unixtime"
			set fromnet [::mysql::escape $fromdata]
			
			set numrel [mysqlsel $db_handle "SELECT $videodb_(id) FROM $mysql_(videotable) WHERE $videodb_(rlsname) = '$rlsname'"]
			
			if { $numrel == 0 } {
			
				set nix [mysqlexec $db_handle "INSERT INTO $mysql_(videotable) ( `$videodb_(rlsname)` , `$videodb_(videocodec)` , `$videodb_(frames)` , `$videodb_(resolution)` , `$videodb_(resnframe)` , `$videodb_(audiocodec)` , `$videodb_(bitrate)` , `$videodb_(hertz)` , `$videodb_(channel)` , `$videodb_(unixtime)` , `$videodb_(addedon)` , `$videodb_(fromnet)` ) VALUES ( '$rlsname' , '$vidcodec' , '$frmes' , '$resl' , '$resnfrmes' , '$audcodec' , '$bitrate' , '$hertz' , '$channel' , '$unixtime' , NOW() , '$fromnet' )"]	
				
				if { $ann_(network) == "1" } {
					#putbot $whichbot "VIDEOPRE $rlsname $vidcodec $frmes $resl $resnfrmes $audcodec $bitrate $hertz $channel"
				}
				
				#putquick "PRIVMSG $chann_(addvideo) :!addvideoinfo $rlsname $vidcodec $frmes $resl $resnfrmes $audcodec $bitrate $hertz $channel"
				
			}
	}
}

proc mp3intodb { nick uhost hand chan arg } {
	global mysql_ mp3db_ chann_ ann_ db_handle PR3N3T whichbot
	
	if { $chan == $chann_(addmp3) || $chan == $chann_(addold) } {
	
			set rlsname [lindex $arg 0]
			set genre [lindex $arg 1]
			set year [lindex $arg 2]
			set hertz [lindex $arg 3]
			set type [lindex $arg 4]
			set bitrate [lindex $arg 5]
			set bittype [lindex $arg 6]
			set unixtime [clock seconds]
			
			if { $rlsname == "" || $genre == "" || $year == "" || $hertz == "" || $type == "" || $bitrate == "" || $bittype == "" } { return }
			
			set fromdata "$nick:$chan:$PR3N3T:$unixtime"
			set fromnet [::mysql::escape $fromdata]
			
			set numrel [mysqlsel $db_handle "SELECT $mp3db_(id) FROM $mysql_(mp3table) WHERE $mp3db_(rlsname) = '$rlsname'"]
			
			if { $numrel == 0 } {
			
				set nix [mysqlexec $db_handle "INSERT INTO $mysql_(mp3table) ( `$mp3db_(rlsname)` , `$mp3db_(genre)` , `$mp3db_(year)` , `$mp3db_(hertz)` , `$mp3db_(type)` , `$mp3db_(bitrate)` , `$mp3db_(bittype)` , `$mp3db_(unixtime)` , `$mp3db_(addedon)` , `$mp3db_(fromnet)` ) VALUES ( '$rlsname' , '$genre' , '$year' , '$hertz' , '$type' , '$bitrate' , '$bittype' , '$unixtime' , NOW() , '$fromnet' )"]	
				
				if { $ann_(network) == "1" } {
					#putbot $whichbot "MP3PRE $rlsname $genre $year $hertz $type $bitrate $bittype"
				}
				
				#putquick "PRIVMSG $chann_(addmp3) :!addmp3info $rlsname $genre $year $hertz $type $bitrate $bittype"
				
			}
	}
}

proc nfoinsidedb { nick uhost hand chan args } {
	global chann_ PR3N3T
	
	if { $chan == $chann_(addspam) } {
	
	set args [string trim [stripcodes bc $args]]
	set infoteh [lindex $args 0]
	set info [split "$infoteh" " "]

	set rlsname [lindex $info 0]
	set downlink [lindex $info 1]
	set filename [lindex $info 2]
	
	if { $filename == "" } {
		set filename "filename.nfo"
	}
	
	set chanx [string trim $chan "#"]
	set fromnet "$nick:$chanx:$PR3N3T"
	
	set hashdata [senddata "ADDNFO,$rlsname,$downlink,$filename,$fromnet"]
	putlog "$hashdata"
	if { $hashdata != "" } {
		
		set hash [lindex $hashdata 0]
		set crc [lindex $hashdata 1]
		set size [lindex $hashdata 2]
		
		#putbot "STRB" "ADDNFO $rlsname $hash $filename $crc $size"
		
		#putquick "PRIVMSG $chan :!addnfo $rlsname https://example.com/file.php?h=$hash $filename"
	}
	
	}

}

proc sfvinsidedb { nick uhost hand chan args } {
	global chann_ PR3N3T
	
	if { $chan == $chann_(addspam) } {
	
	set args [string trim [stripcodes bc $args]]
	set infoteh [lindex $args 0]
	set info [split "$infoteh" " "]

	set rlsname [lindex $info 0]
	set downlink [lindex $info 1]
	set filename [lindex $info 2]
	
	if { $filename == "" } {
		set filename "filename.sfv"
	}
	
	set chanx [string trim $chan "#"]
	set fromnet "$nick:$chanx:$PR3N3T"
	
	set hashdata [senddata "ADDSFV,$rlsname,$downlink,$filename,$fromnet"]
	
	if { $hashdata != "" } {
		
		set hash [lindex $hashdata 0]
		set crc [lindex $hashdata 1]
		set size [lindex $hashdata 2]
		
		#putbot "STRB" "ADDSFV $rlsname $hash $filename $crc $size"
		
		#putquick "PRIVMSG $chan :!addsfv $rlsname https://example.com/file.php?h=$hash $filename"
	
	}
	
	}

}

proc m3uinsidedb { nick uhost hand chan args } {
	global chann_ PR3N3T
	
	if { $chan == $chann_(addspam) } {
	
	set args [string trim [stripcodes bc $args]]
	set infoteh [lindex $args 0]
	set info [split "$infoteh" " "]

	set rlsname [lindex $info 0]
	set downlink [lindex $info 1]
	set filename [lindex $info 2]
	
	if { $filename == "" } {
		set filename "filename.m3u"
	}
	
	set chanx [string trim $chan "#"]
	set fromnet "$nick:$chanx:$PR3N3T"
	
	set hashdata [senddata "ADDM3U,$rlsname,$downlink,$filename,$fromnet"]
	
	if { $hashdata != "" } {
		
		set hash [lindex $hashdata 0]
		set crc [lindex $hashdata 1]
		set size [lindex $hashdata 2]
		
		#putbot "STRB" "ADDM3U $rlsname $hash $filename $crc $size"
		
		#putquick "PRIVMSG $chan :!addm3u $rlsname https://example.com/file.php?h=$hash $filename"
	}
	
	}

}

proc senddata { data } {
	global addfeedurl
	
	# with ssl
	# curl::transfer -sslverifyhost 0 -sslverifypeer 0 -url $addfeedurl$data -bodyvar html -timeout 2
	
	# without ssl
	curl::transfer -url $addfeedurl$data -bodyvar html -timeout 2
	
	return $html
	
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
		
			if {[regexp {[\.\-\_]HDTV[\.\-\_]} $release]} { set section "TV-X264" }
			if {[regexp -nocase {[\.\-\_]bluray[\.\-\_]} $release]} { set section "TV-HDRIP" }
		
		}
	
	}
	
	return $section
}
# Below functions are not used in this new version of the script..

# filter color bold /bla code
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

set pre_(spamfilters)  {{{psx.+psx.+psx} 10.0 0 0} {{kthx} 10.0 0 0} {{^R3Q-} 10.0 0 0} {{[5s]c[e3]n[e3]b[4a]n} 10.0 0 0} {{[\.\_]p2p[\.\_\-]} 10.0 0 0} {{piratox} 7.0 0 0} {{pr[3e][s5]p[4a]m} 7.0 0 0} {{^incomplete-} 10.0 0 0} {{prereport} 9.0 0 0} {{^NUKED-} 10.0 0 0} {{[^a-zA-Z0-9\(\)_\.\-\&]} 10.0 0 1} {{d[o0]n[t7].*(r[a4]c[e3]|tr[a4]d[e3])} 8.0 0 0} {{([t7][e3][s5][t7]|pr[e3]|[s5][o0]rry|[s5]cr[i1]p[t7]|c[o0]nf[i1]g)[\.\-_]*([t7][e3][s5][t7]|pr[e3]|[s5][o0]rry|[s5]cr[i1][p][t7]|c[o0]nf[i1]g)} 8.0 0 0} {{c[o0]nf[i1]g} 3.5 0 0} {{[s5]cr[i1]p[t7]} 3.0 0 0} {{[s5][o0]rry} 3.5 0 0} {{pr[e3]} 2.0 0 0} {{[t7][e3][s5][t7]} 3.0 0 0} {{[^a-zA-Z0-9_\-/]} 10.0 3 1} {{[s5]p[a4]m} 3.0 3 0} {{[t7][e3][s5][t7]} 3.0 3 0} {{[s5]c[e3]n[e3]} 3.0 3 0} {{n[o0][t7][i1]c[e3]} 3.0 3 0} {{[i1]nf[0o]} 6.0 3 0} {{[l1][e3][e3][t7]} 6.0 3 0} {{[a4][u][t][o0](.|)[n][u][k][e3]} 10.0 1 0} {{b[a4](n|nn)[e3]d(.|)gr[o0]up} 10.0 1 0} {{[^a-zA-Z0-9\(\)_\.\-:\&\?/\!]} 10.0 1 1} {{^[^A-Z0-9]} 10.0 0 1} {{(^REQ(UEST|)[.\-_])|([.\-_]REQ(UEST|)$)} 10.0 0 0} {{was[\.\-_]pr[e3][\.\-_][o0]n} 10.0 0 0} {{[e3]f(.|)n[e3][7t]|[a4]f[t7][e3]r(\-)?[a4][l1][l1]|l[i1]nk(\-)?n[e3][t7]|[e3]r[i1][s5].?fr[e3][e3]} 5.0 0 0} {{f[i1]x[\.\-_]b[0o][t7][s5]} 5.0 0 0} {{[a4]dd(\.|)pr[e3]} 10.0 0 0} {{n[0o]([\.\-_]|)nf[0o]} 6.0 0 0} {{\.(rar|r[0-9]{2}|avi|mp|mpg|mpeg|zip|sfv|nfo|mp3|m3u|diz|torrent|jpg)$} 10.0 0 0} {{([a-z0-9])\1{3}} 3.0 0 0} {{([a-z0-9])\1{3}} 3.0 3 0} {{(\-[a-z0-9]{1,25})\1$} 5.5 0 0} {{([\.\-_]|)[s5][t7]fu([\.\-_]|)} 3.5 0 0} {{k[i1]dd[i1][e3]} 4.0 0 0} {{^Hello-Nasty[0-9]} 5.5 0 0} {fxpler 5.0 0 0} {{^pl[sz]*die$} 10.0 1 0} {fucker 2.0 1 0} {{shut.the.(fuck|fuk|f[o0][0o]k).(up|[o0]ff)} 5.5 1 0} {{(fuck|fuk|f[o0]([0o]|)k).[o0]ff} 5.0 1 0} {{y[o0]ur.pr[e3].s[o0]urc[e3]} 5.0 1 0} {{[s5]c[e3]n[e3]} 2.0 0 0} {the(.|)truth 2.5 0 0} {{(fxp|([e3]|)f([\.\-_]|)([e3]|)x([\.\-_]|)p([e3]|))} 4.0 1 0} {{^[t7][e3][s5][t7]$} 10.0 1 0} {{[t7][e3][s5][t7]} 3.5 1 0} {{[s5][o0]r(r|)y} 2.5 1 0} {{^g[o0].h[o0]m[e3]$} 5.5 1 0} {{nuk[e3]} 2.0 1 0} {{pl([e3][a4]s[e3]|s|z).us[e3].f[o0][o0]b[a4](rr|r)[e3][a4]s[o0]n} 10.0 1 0} {{([A-Z])\1\1\1\1\1} 3.0 0 0} {{\.\.} 10.0 0 0}}

proc isy:validreleasereason { reason } {
	  set minlen 4
	  set maxlen 256
	  if {[string is digit $reason]}       {return 0}
	  if {[string length $reason]<$minlen} {return 0}
	  if {[string length $reason]>$maxlen} {return 0}
	  if {[regexp -nocase -- {missing.src|cr[4a]p|old.pre|p2p|spam|mislabeld|mislabeled|no+.dirfix+.after+.nuke} $reason]} {return 0}
	  return 1
}

# End of unused functions...

#mysqlclose $mysql_(handle)

# It would be nice if you didn't delete this but there is really nothing I can do!
putlog "$script_version --> By \002Islander\002 ||| Loaded Succesfully!"