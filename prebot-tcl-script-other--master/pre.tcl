
################################################################################
#                                                                              #
# Edit the variables below to match your mysql configuration                   #
#                                                                              #
################################################################################

##################
### Mysql path ###
##################

load /usr/lib/tcltk/mysqltcl-3.05/libmysqltcl3.05.so
package require TclCurl

# define database parameters
set mysql_(user) "root"
set mysql_(password) "root"
set mysql_(host) "localhost"
set mysql_(database) "predb"
set mysql_(table) "releases"

if {![info exists mysql_(handle)]} {
set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(database)]
}

#PREBOT
#set db_(user) ""
#set db_(password) ""
#set db_(host) "localhost"
#set db_(db) ""
#set db_table ""
#END

################################################
#											   #
# The table info, must match the database	   #
#											   #
################################################

#PREBOT
set db_(rlsname) "name"
set db_(section) "type"
set db_(group) "grp"
set db_(status) "status"
set db_(reason) "reason"
set db_(network) "nukenetwork"
set db_(id) "id"
set db_(time) "time"
set db_(year) "year"
set db_(hertz) "hertz"
set db_(channel) "channel"
set db_(bitrate) "bitrate"
set db_(mode) "mode"
set db_(videocodec) "videocodec"
set db_(videofps) "videofps"
set db_(videores) "videores"
set db_(videoaspect) "videoaspect"
set db_(audiocodec) "audiocodec"
set db_(audiokbps) "audiokbps"
set db_(audiorate) "audiorate"
set db_(audiochans) "audiochans"
set db_(files) "files"
set db_(size) "size"
set db_(siteurl) "siteurl"
set db_(nick) "nick"
set db_(genre) "genre"
#END

#CSTM
set cstm_(id) "id"
set cstm_(rlsname) "cstmname"
set cstm_(group) "cstmgrp"
set cstm_(time) "cstmtime"
#END

#TRACEBOT
#set db_(name) "name"
#set db_(site) "site"
#set db_(time) "time"
#set db_(place) "place"
#END

################################################################################
#                                                                              #
# Edit the variables below to match some other configuration                   #
#                                                                              #
################################################################################
# Channel Settings

#CHANS
set testchan "dev.null"
set addprechan "#addpre"
set addnfochan "addnfo"
set addprecstmchan "#addpre.cstm"
set prechan "#Pre"
set spamchan "#Pre.Info"
set staffchan "#Pre.Staff"
set searchchan "#Pre.Search"
set searchchan "#dev.null"
set mp3chan "#Pre.Spam"
set xxxchan "#Pre"
set nordicchan "#Pre.Nordic"
set foreignchan "#Filter.Pre"
set nfochan "Pre.Search"
set output_channel "#dev.null"

# Global Filters

# Pre from nordic groups
set nordicgroups "imcare|wilder|division|faf|smokey|classic|pringles|incognito|wax|plan9|invandraren|radius|sublime|cce|nosence|tv2lax9|tilmigselv|svinto|dtfs|subtitles|winters|dba"

# Pre with foreign subs
set foreignlangs "kiosk|german|dutch|spanish|flemish|italian|french|czech"

# Pre with flemish / french / german / polish
set foreigngroups "helix|vedett|wmz|ifh|backtorg|drd|awake|custodes|details|misfits|tvp|heritage|itg|zzgtv|idib|xpert_hd|d4u|zzglive|nsn|aihd|airline|oursky|r4f|sibv|epz|jmt|phoque|atlas|bawls_int|dupli|full|bawls|hto|bfhmov|tracks|shx|sinx|hybris|lips|cora|onepiece|n0l|lost|press|iboks|rough|deal|elearning|ukdhd|gtvg|boolz|tsunami|d4kid|get|aymo|czl"    

# Pre with danish / swedish / norwegian / nordic subs
set nordiclangs "danish|swedish|norwegian|nordic"

# Prefixes for announce
set prefix_(site) "7\[PRE7\]"
set prefix_(nuke) "\0034NUKE\003"
set prefix_(unnuke) "\0033UNNUKE\003"

# Flags for Channel Announce

#CSTM
setudef flag cstmdb
#END

setudef flag search
setudef flag db
setudef flag spam
setudef flag stats
setudef flag url
setudef flag mp3
setudef flag addold
setudef flag videoaudio
setudef flag nfoget

# Triggers for Channel with SEARCH Flag

#PRE SEARCH
bind pub -|- !pre ms:pre
bind pub -|- .pre ms:pre
#END

#DUPE SEARCH
bind pub -|- !dupe ms:dupe
bind pub -|- .dupe ms:dupe
#END

#GROUP SEARCH
bind pub -|- !group ms:group
bind pub -|- !grp ms:group
bind pub -|- .grp ms:group
bind pub -|- .group ms:group
#END

#GLAST10 SEARCH
bind pub -|- !glast10 ms:glast10
bind pub -|- .glast10 ms:glast10
#END

#GET NFO
bind pub -|- !getnfo ms:getnfo
bind pub -|- .getnfo ms:getnfo
#END

#LASTNUKE
bind pub -|- !lastnuke ms:lastnuke
bind pub -|- .lastnuke ms:lastnuke
#END

#LAST UNNUKE
bind pub -|- !lastunnuke ms:lastunnuke
bind pub -|- .lastunnuke ms:lastunnuke
#END

#GROUP UNNUKES
bind pub -|- !groupunnukes ms:groupunnukes
bind pub -|- .groupunnukes ms:groupunnukes
#END

#GROUP NUKES
bind pub -|- !groupnukes ms:groupnukes
bind pub -|- .groupnukes ms:groupnukes
#END

#GROUP NUKE
bind pub -|- !groupnuke ms:groupnukes
bind pub -|- .groupnuke ms:groupnukes
#END

#LAST30
bind pub -|- !last30 ms:last24
bind pub -|- .last30 ms:last24
#END

#LAST60
bind pub -|- !last60 ms:last48
bind pub -|- .last60 ms:last48
#END

#SECTION
bind pub -|- !section ms:section
bind pub -|- .section ms:section
#END

#CHANGE SECTION
bind pub -|- !chgsec ms:chgsec
bind pub -|- .chgsec ms:chgsec
#END

#PREHELP
bind pub -|- !prehelp helpme
bind pub -|- .prehelp helpme
#END

#DATABASE
bind pub -|- !db pre:db
bind pub -|- .db pre:db
#END

# Triggers for Channel with ADD and/or DB Flag

bind pub -|- !addurl ms:url
#bind pub -|- !addold ms:addold
#bind pub -|- !oldadd ms:addold
bind pub -|- !addpre ms:addpre
bind pub -|- !addnfo ms:addnfo
bind pub -|- !cstmadd ms:cstmaddpre
#bind pubm -|- "*" ms:cstmaddpre
bind pub -|- !addvideoinfo ms:addvideoinfo
bind pub -|- !addmp3info ms:addmp3info
bind pub -|- !ap ms:addpre
bind pub -|- !nuke ms:nuke
bind pub -|- !n ms:nuke
bind pub -|- !unnuke ms:unnuke
bind pub -|- !u ms:unnuke
bind pub -|- !info ms:info
bind pub -|- !addinfo ms:info
bind pub -|- !addgenre ms:genre
bind pub -|- !gn ms:genre
bind pub -|- !delpre ms:delpre
bind pub -|- !undelpre ms:delpre
bind pub -|- !mn ms:modnuke
bind pub -|- !modnuke ms:modnuke

if {[info command duration2] == "" && [info proc duration2] == ""} {rename duration duration2};
proc duration {t} {
#string map {" hours" h " hour" h " minutes" m " minute" m " years" y " year" y " days" d " day" d " seconds" s " second" s " weeks" w " week" w} [duration2 $t]
return [timediff $t]
}
################################################################################
#                                                                              #
# DON'T CHANGE ANYTHING BELOW HERE UNLESS YOU KNOW WHAT U ARE DOING            #
#                                                                              #
################################################################################
package require mysqltcl

set spamvar "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
set spamturn "0"

set nukevar "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
set nuketurn "0"

set unnukevar "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
set unnuketurn "0"

set infovar "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
set infoturn "0"

set urlvar "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
set urlturn "0"

set mp3var "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
set mp3turn "0"

set genrevar "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
set genreturn "0"

set videoaudiovar "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
set videoaudioturn "0"

proc getsection { section rlsname } {
#SECTION FILTER
if {[regexp {(?i)([^(grea)](t|7)(e|3)(s|5)(t|7)|(t|7)(e|3)(s|5)(t|7)(o|0)r)} $section] } {
return "TV"
}
if {[regexp {2nd regex} $section] } {
return "XXX"
}
if {[regexp {3nd regex} $section] } {
return "XViD"
}
if {[regexp {4nd regex} $section] } {
return "MP3"
}
if {[regexp {5nd regex} $section] } {
return "MVID"
}
if {[regexp {6nd regex} $section] } {
return "SUBPACK"
}
if {[regexp {7nd regex} $section] } {
return "X264"
}
#When all failes return default cat
return "Unknown"
}
#END
proc isy:sectioncolor { arg } {
	
	set sec [lindex $arg 0]
	
	array set sectionColors {
			"APPS" 	"\0034APPS\003" 
			
}
	
    foreach {section replace} [array get sectionColors] {
        if {[string equal -nocase $section $sec]} {
			return $replace
		} 
    }
}
#SECTION COLORS
\0034SCENENOTiCE\003
#RED - 04
dict set TrColors APPS 04

dict set TrColors SCENENOTiCE 04
dict set TrColors DOX 04
#BROWN - 05
dict set TrColors PDA 05
dict set TrColors SUBPACK 05
dict set TrColors 0DAY 05
#PURPLE - 06
dict set TrColors TV 06
#ORANGE - 07
dict set TrColors PS3 07
dict set TrColors XBOX360 07
dict set TrColors PSP 07
dict set TrColors NDS 07
dict set TrColors WII 07
dict set TrColors PS3 07
dict set TrColors PSP 07
dict set TrColors GAMES 07
#YELLOW - 08
dict set TrColors SVCD 08
dict set TrColors DIVX 08
#TEAL - 10
dict set TrColors MP3 10
dict set TrColors FLAC 10
dict set TrColors AUDIOBOOK 10
#LIGHTCYAN - 11
dict set TrColors MDVDR 11
dict set TrColors MVID 11
#PINK - 13
dict set TrColors XXX 13
dict set TrColors EXTREME 13
dict set TrColors XXX-PAYSITE 13
dict set TrColors XXX-0DAY 13
dict set TrColors XXX-iMAGESETS 13
dict set TrColors XXX-IMAGESET 13
dict set TrColors XXX-IMGSET 13
dict set TrColors XXX-PAYSITE 13
dict set TrColors XXX-X264 13
dict set TrColors XXX-PAY 13
dict set TrColors IMAGESET 13
dict set TrColors XXX-WEB 13
dict set TrColors WMV 13
dict set TrColors IMGSET 13
dict set TrColors XXX-DVDR 13
#GREY - 14
dict set TrColors X264 14
dict set TrColors DVD 14
dict set TrColors DVDR 14
dict set TrColors DVDR-DE 14
dict set TrColors TV-HD-DE 14
dict set TrColors TV-HD 14
dict set TrColors TV-DVDRIP 14
dict set TrColors TV-HDRIP 14
dict set TrColors COVERS 14
dict set TrColors EBOOK 14
dict set TrColors TV-X264 14
dict set TrColors TV-XVID 14
dict set TrColors XVID 14
dict set TrColors TV-BLURAY 14
dict set TrColors MBLURAY 14
dict set TrColors BLURAY 14

#SECTION COLORS - CSTM
dict set cstmColors SUBLiME 03
dict set cstmColors Maat 03
dict set cstmColors SUBCiTRON 03
dict set cstmColors iRL 03
dict set cstmColors RAPiDCOWS 03
dict set cstmColors MediaMasters 03
#COLORADD - CATEGORY
proc tr:text2color {text} {
if {[info exist ::TrColors] && [dict exist $::TrColors $text]} {return [dict get $::TrColors $text]$text}
	set a 0;set value 0
	set sl [string length $text]
	while {$a <= $sl} {
		#converts text to there ascii numbers then adds them up
		scan [string index $text $a] %c v
		set value [expr $value+$v]
		incr a
	};set c 0
	
	set colors "04 05 06 07 08 10 11 13 14"
	while {$value >= 0} {
		#we increase $c by 1 then lower the ascii number from before by 1
		#when $c goes over the number colors we set $c to 0.
		if {$c >= [expr [llength $colors]-1]} {set c 0;incr value -1
		} else {incr c 1;incr value -1}
	}
	return [lindex $colors $c]$text
}
#END

#COLORADD - CSTMCATEGORY
proc  {text} {
if {[info exist ::cstmColors] && [dict exist $::cstmColors $text]} {return [dict get $::cstmColors $text]$text}
	set a 0;set value 0
	set sl [string length $text]
	while {$a <= $sl} {
		#converts text to there ascii numbers then adds them up
		scan [string index $text $a] %c v
		set value [expr $value+$v]
		incr a
	};set c 0
	
	set colors "04 05 06 07 08 10 11 13 14"
	while {$value >= 0} {
		#we increase $c by 1 then lower the ascii number from before by 1
		#when $c goes over the number colors we set $c to 0.
		if {$c >= [expr [llength $colors]-1]} {set c 0;incr value -1
		} else {incr c 1;incr value -1}
	}
	return [lindex $colors $c]$text
}
#END

#HIGHLIGHT
proc highlight_string {strin subject pre past} {
    return [regsub -all -- $strin $subject "$pre\\0$past"] 
	}
#END

#DUPE
proc ms:dupe {nick uhost hand chan arg} {
      global db_ mysql_ searchchan
 if {![channel get [string tolower $chan] search]} { return 0 }
            putnow "PRIVMSG $chan :\[ \0037SEARCHING\003 \]"
        set sea1 [string map [list "*" "%" " " "%"] $arg];
        set sea2 [string map [list "%" "*"] $sea1];
        set query1 [mysqlsel $mysql_(handle) "SELECT $db_(rlsname),$db_(section),$db_(files),$db_(size),$db_(status),$db_(reason),$db_(time),$db_(genre),$db_(network) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%$sea1%' ORDER BY $db_(time) DESC LIMIT 10" -flatlist];
          if {$query1 == ""} {
           # putnow "PRIVMSG $chan :\[ \0037SEARCHING\003 \]"
            putnow "PRIVMSG $chan :\[ \0034No results found\003 \]"
          } elseif {$query1 != ""} {
		  putnow "PRIVMSG $chan :\[ \0037Sending last 10 Search Results in Priv Msg to $nick\003 \]"
             	# putnow "PRIVMSG $nick : Your Top 10 results for \"\0034\002$sea1\003\002\""
          	foreach {rls type files mb status reason timestamp genre nukenetwork} $query1 { 
          		set rls [highlight_string $sea1 $rls \0034\002 \003\002]
          		set time1 [unixtime]
          		incr time1 -$timestamp
          		set ago [duration $time1] 
                if { $mb == "0.00" || $files == "0" } { set info ""} else { set info "\[ \00314INFO\003: $mb MB / $files Files \]" }
				#if { $genre == "" } { set genre "" } else { set genre " / $genre" }
				if {![string match $genre "-"]} { set genre " / $genre" } else { set genre "" }
                	if { $status == "0"} {
                putnow "PRIVMSG $nick :\[ \0033PRED\003 \] $rls \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE:\003 [clock format $timestamp -format %d-%m-%Y] \] \[ \00314Time:\003 [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"
			} elseif { $status == "1" } {
                putnow "PRIVMSG $nick :\[ \0033PRED\003 \] $rls \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE:\003 [clock format $timestamp -format %d-%m-%Y] \] \[ \00314Time:\003 [clock format $timestamp -format %H:%M:%S] \] \[ \0034NUKED\003:\0034 $reason\003 => \0034$nukenetwork\003 \] $info"
			} elseif { $status == "2" } {
				putnow "PRIVMSG $nick :\[ \0033PRED\003 \] $rls \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE:\003 [clock format $timestamp -format %d-%m-%Y] \] \[ \00314Time:\003 [clock format $timestamp -format %H:%M:%S] \] \[ \0033UNNUKED\003:\0033 $reason\003 => \0033$nukenetwork\003 \] $info"
			} elseif { $status == "3" } {
			    putnow "PRIVMSG $nick :\[ \0033PRED\003 \] $rls \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE:\003 [clock format $timestamp -format %d-%m-%Y] \] \[ \00314Time:\003 [clock format $timestamp -format %H:%M:%S] \] \[ \0035MODNUKED\003:\0035 $reason\003 => \0035$nukenetwork\003 \] $info"
			} else {
                putnow "PRIVMSG $chan : Error in the search" 
			}
        }
  }
 	mysqlendquery $mysql_(handle)
}
#END

#SECTION
proc ms:section {nick uhost hand chan arg } {
	if {![channel get [string tolower $chan] search]} { return 0 }
	global mysql_ db_
	if { $arg == "" } {
		putnow "PRIVMSG $chan : Use !section <section>"
        } else {
        	set splitz [split $arg " "]
        	set section [lrange $splitz 0 0]
        	set section [string trimleft $section "\\\{"]
		    set genre [lrange $splitz 1 1]
          	set genre [string trimleft $genre "\\\{"]
          	set genre [string trimright $genre "\\\}"]
		set query1 [mysqlsel $mysql_(handle) "SELECT $db_(rlsname),$db_(section),$db_(files),$db_(size),$db_(status),$db_(reason),$db_(time),$db_(genre),$db_(network) FROM $mysql_(table) WHERE $db_(section)='$section' ORDER BY $db_(id) DESC LIMIT 10" -flatlist];
		if {$query1 == ""} {
            putnow "PRIVMSG $chan :\[ \0037SEARCHING\003 \]"
            putnow "PRIVMSG $chan :\[ \0034No results found\003 \]"
          	} elseif {$query1 != ""} {
	  		putnow "PRIVMSG $chan :\[ \0037Sending last 10 Search Results in Priv Msg to $nick\003 \]"
          		foreach {rls type files mb status reason timestamp genre nukenetwork } $query1 {
				#putlog "$rls $type $files $mb $status $timestamp $genre $reason $nukenetwork"
            			set time1 [unixtime]
            			incr time1 -$timestamp
                        	set ago [duration $time1]
				if { $genre == "" } { set genre "" } else { set genre " / $genre" }
				if { $mb == "0.00" || $files == "0" } { set info ""} else { set info "\[ \00314INFO\003: $mb MB / $files Files \]" }
                		if { $status == "0"} {
                			putnow "PRIVMSG $nick :\[ \0033PRED\003 \] $rls \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE:\003 [clock format $timestamp -format %d-%m-%Y] \] \[ \00314Time:\003 [clock format $timestamp -format %H:%M:%S]  \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"
				} elseif { $status == "1" } {
                			putnow "PRIVMSG $nick :\[ \0033PRED\003 \] $rls \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE:\003 [clock format $timestamp -format %d-%m-%Y] \] \[ \00314Time:\003 [clock format $timestamp -format %H:%M:%S]  \] \[ \0034NUKED\003:\0034 $reason\003 => \0034$nukenetwork\003 \] $info"
			    	} elseif { $status == "2" } {
					putnow "PRIVMSG $nick :\[ \0033PRED\003 \] $rls \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE:\003 [clock format $timestamp -format %d-%m-%Y] \] \[ \00314Time:\003 [clock format $timestamp -format %H:%M:%S]  \] \[ \0033UNNUKED\003:\0033 $reason\003 => \0033$nukenetwork\003 \] $info"
				} elseif { $status == "3" } {
				    putnow "PRIVMSG $nick :\[ \0033PRED\003 \] $rls \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE:\003 [clock format $timestamp -format %d-%m-%Y] \] \[ \00314Time:\003 [clock format $timestamp -format %H:%M:%S]  \] \[ \0035MODNUKED\003:\0035 $reason\003 => \0035$nukenetwork\003 \] $info"
				} else {
                 putnow "PRIVMSG $chan : Error in the search" 
				}
             }
  		}
	}
mysqlendquery $mysql_(handle)
}
#END

#GLAST10
proc ms:glast10 {nick uhost hand chan arg } {
	if {![channel get [string tolower $chan] search]} { return 0 }
	global mysql_ db_
	if { $arg == "" } {
		putnow "PRIVMSG $chan : ERROR in the string!"
        } else {
         set splitz [split $arg " "]
          set group [lrange $splitz 0 0]
          set group [string trimleft $group "\\\{"]
          set group [string trimright $group "\\\}"]  
		    set q [mysqlsel $mysql_(handle) "SELECT $db_(rlsname),$db_(section),$db_(group),$db_(files),$db_(size),$db_(status),$db_(reason),$db_(time),$db_(genre),$db_(network) FROM $mysql_(table) WHERE $db_(group)= '$group' ORDER BY $db_(id) DESC LIMIT 10" -flatlist];
		set numrel [mysqlsel $mysql_(handle) "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(group)= '$group'"]
		if {$numrel == "0"} {
            putnow "PRIVMSG $chan :\[ \0037SEARCHING\003 \]"
            putnow "PRIVMSG $chan :\[ \0034No results found\003 \]"
          	} elseif {$q != ""} {
	  		    putnow "PRIVMSG $chan :\[ \0037SEARCHING\003 \]"
				putnow "PRIVMSG $chan :\[ \0037Sending last 10 Search Results in Priv Msg to $nick\003 \]"
          		foreach {rls type grp files mb status reason timestamp genre nukenetwork } $q {
				#putlog "$rls $type $files $mb $status $timestamp $genre $reason $nukenetwork"
            			set time1 [unixtime]
						incr time1 -$timestamp
            			set ago [duration $time1]
						if { $genre == "" } { set genre "" } else { set genre " / $genre" }
						if { $mb == "0.00" || $files == "0" } { set info ""} else { set info "\[ \00314INFO\003: $mb MB / $files Files \]" }
                		if { $status == "0"} {
                		putnow "PRIVMSG $nick :\[ \0032GROUP\003: \0032$arg\003 \] $rls \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE:\003 [clock format $timestamp -format %d-%m-%Y] \] \[ \00314Time:\003 [clock format $timestamp -format %H:%M:%S]  \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"
				       } elseif { $status == "1" } {
                		putnow "PRIVMSG $nick :\[ \0032GROUP\003: \0032$arg\003 \] $rls \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE:\003 [clock format $timestamp -format %d-%m-%Y] \] \[ \00314Time:\003 [clock format $timestamp -format %H:%M:%S]  \] \[ \0034NUKED\003:\0034 $reason\003 => \0034$nukenetwork\003 \] $info"
			    	} elseif { $status == "2" } {
					putnow "PRIVMSG $nick :\[ \0032GROUP\003: \0032$arg\003 \] $rls \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE:\003 [clock format $timestamp -format %d-%m-%Y] \] \[ \00314Time:\003 [clock format $timestamp -format %H:%M:%S]  \] \[ \0033UNNUKED\003:\0033 $reason\003 => \0033$nukenetwork\003 \] $info"
				    } elseif { $status == "3" } {
               		putnow "PRIVMSG $nick :\[ \0032GROUP\003: \0032$arg\003 \] $rls \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE:\003 [clock format $timestamp -format %d-%m-%Y] \] \[ \00314Time:\003 [clock format $timestamp -format %H:%M:%S]  \] \[ \0035MODNUKED\003:\0035 $reason\003 => \0035$nukenetwork\003 \] $info"		
				} else {
                  			putnow "PRIVMSG $chan : Error in the search" 
				}
           	}
  		}
	}
	mysqlendquery $q
	mysqlendquery $numrel
}
#END

#NFO
proc ms:getnfo {n u h c t} {
global mysql_
  if {$t == ""} {
    putquick "notice $nick :!getnfo <nfo name>" 
    return 
  } 

  if {[channel get $c nfoget] == 1 } {

#Sanitize $t, avoiding any kind of SQL-injections. 
    set t [mysqlescape $t] 
#Replace * with % 
#Using string map should be quicker than regsub 
    set t [string map {* %} $t] 

    set search [mysqlsel $mysql_(handle) "SELECT nfoid,rlsname,filename,size FROM nfodb WHERE rlsname LIKE '%$t%' ORDER BY nfoid DESC LIMIT 1" -list]
	set search [lindex $search 0]
    mysqlendquery $mysql_(handle)
#Get the first entity from the result list 
    set rlsname [lindex $search 1]
	set filename [lindex $search 2]
	set size [lindex $search 3]
    if { $size != "" } { set nfosize "\[ \00307FiLESiZE\003: $size Bytes \]" } else { set nfosize "\[ \00307FiLESiZE\003: N/A \]"}
    if { $search == "" } {
      puthelp "PRIVMSG $c :No NFOFiLES found for *$t*" 
      return 
    } else { 
      #putnow "PRIVMSG $c \0037ReLEASE\003 : $rlsname \0037NFO FiLE\003 : http://91.121.110.219/~bot/nfo.php/$filename" 
	  putnow "PRIVMSG $c \0037ReLEASE\003 : $rlsname \0037NFO FiLE\003 : http://getnfo.bot.nu/~bot/nfo.php/$filename $nfosize" 
    }
  }
  	mysqlendquery $mysql_(handle)
}
#END

#LASTNUKE
proc ms:lastnuke {nick uhost hand chan arg } {
	global mysql_ db_
	
	if {![channel get [string tolower $chan] search]} { return 0 }

	putnow "PRIVMSG $chan :\[ \0037SEARCHING\003 \]"	
	
	set group [mysqlescape $arg]

	set numrel [mysqlsel $mysql_(handle) "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(group)= '$group'"]
	if {$numrel == "0"} {
		if { $group != "" } {
			putnow "PRIVMSG $chan :\[ \0034Group not found\003 \]"
		} else {
			set result [mysqlsel $mysql_(handle) "SELECT $db_(rlsname),$db_(section),$db_(files),$db_(size),$db_(status),$db_(reason),$db_(network),$db_(time),$db_(genre) FROM $mysql_(table) WHERE $db_(status)= '1' ORDER BY time DESC LIMIT 1" -list];
		}
	} else {
		set result [mysqlsel $mysql_(handle) "SELECT $db_(rlsname),$db_(section),$db_(files),$db_(size),$db_(status),$db_(reason),$db_(network),$db_(time),$db_(genre) FROM $mysql_(table) WHERE $db_(status)= '1' AND $db_(group)= '$group' ORDER BY time DESC LIMIT 3" -list];
	}
	foreach res $result {
		set release	[lindex $res 0]
		set section	[lindex $res 1]
		set files	[lindex $res 2]
		set mb		[lindex $res 3]
		set status	[lindex $res 4]
		set reason	[lindex $res 5]
		set network	[lindex $res 6]
		set time	[lindex $res 7]
		set genre	[lindex $res 8]
		
		if { $genre == "" } { set genre "" } else { set genre " / $genre" }
        if { $mb == "0.00" || $files == "0" } { set info ""} else { set info "\[ \00314INFO\003: $mb MB / $files Files \]" }
		
		if { $status == "1" } {
			putnow "PRIVMSG $chan :\[ \0034Nuked\003 \] $release \[ \00314PRED\003: [duration [expr [unixtime] - $time]] \] \[\00314DATE\003: [clock format $time -format %d-%m-%Y] \] \[\00314TIME\003: [clock format $time -format "%H:%M:%S"] \] \00314in\003 \[ [tr:text2color $section] $genre \] $info \[ \00314Nuke reason:\003 \0034$reason\003 \00314by\003: \0034$network\003 \]"
		} else {
			putnow "PRIVMSG $chan : Error in the search" 
		}
	}
	mysqlendquery $mysql_(handle)
	mysqlendquery $mysql_(handle)
}
#END

#LASTUNNUKE
proc ms:lastunnuke {nick uhost hand chan arg } {
	global mysql_ db_
	
	if {![channel get [string tolower $chan] search]} { return 0 }

	putnow "PRIVMSG $chan :\[ \0037SEARCHING\003 \]"	
	
	set group [mysqlescape $arg]

	set numrel [mysqlsel $mysql_(handle) "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(group)= '$group'"]
	if {$numrel == "0"} {
		if { $group != "" } {
			putnow "PRIVMSG $chan :\[ \0034Group not found\003 \]"
		} else {
			set result [mysqlsel $mysql_(handle) "SELECT $db_(rlsname),$db_(section),$db_(files),$db_(size),$db_(status),$db_(reason),$db_(network),$db_(time),$db_(genre) FROM $mysql_(table) WHERE $db_(status)= '2' ORDER BY time DESC LIMIT 1" -list];
		}
	} else {
		set result [mysqlsel $mysql_(handle) "SELECT $db_(rlsname),$db_(section),$db_(files),$db_(size),$db_(status),$db_(reason),$db_(network),$db_(time),$db_(genre) FROM $mysql_(table) WHERE $db_(status)= '2' AND $db_(group)= '$group' ORDER BY time DESC LIMIT 3" -list];
	}

	foreach res $result {
		set release	[lindex $res 0]
		set section	[lindex $res 1]
		set files	[lindex $res 2]
		set mb		[lindex $res 3]
		set status	[lindex $res 4]
		set reason	[lindex $res 5]
		set network	[lindex $res 6]
		set time	[lindex $res 7]
		set genre	[lindex $res 8]
		
		if { $genre == "" } { set genre "" } else { set genre " / $genre" }
		if { [string match $mb "0.00"] } { set mb "" } else { set mb " $mb MB / " }
		if { [string match $files "0"] } { set files "" } else { set files " $files Files " }
		
		if { $status == "2" } {
			putnow "PRIVMSG $chan :\[ \0033UnNuked\003 \] $release \[ \00314PRED\003: [duration [expr [unixtime] - $time]] \] \[\00314DATE\003: [clock format $time -format %d-%m-%Y] \] \[\00314TIME\003: [clock format $time -format "%H:%M:%S"] \] \00314in\003 \[ [tr:text2color $section] $genre \] \[ \00314INFO\003: $mb $files \] \[ \00314UnNuke reason:\003 \0033$reason\003 \00314by\003: \0033$network\003 \]"
		} else {
			putnow "PRIVMSG $chan : Error in the search" 
		}
	}
	mysqlendquery $mysql_(handle)
	mysqlendquery $mysql_(handle)
}
#END

#PRE
proc ms:pre {nick uhost hand chan arg} {
global mysql_ db_ searchchan
	
	#save currenttime
	set time [unixtime] 
	
	#check if channel is a search channel
	if {![channel get [string tolower $chan] search]} { putnow "NOTICE $nick :please join $searchchan for searches thanks"; return 0 }
	
	#check if we got an argument
	if {[lindex $arg 0] ==""} {putserv "NOTICE $nick :USAGE\: !pre(d) RELEASE"; return 0 }
	
	#tell the user we are searching
	putnow "PRIVMSG $chan :\[ \0037SEARCHING\003 \]"
	
	#replace whitespace and * with %
	regsub -all -- {[\* ]}	$arg "\%" search

	#check if we are searching with wildcards or not, if not then its faster to lookup with equal sign.
	#if we are searching with wildcards then we have to use a like statement. takes longer time but it will find the release if its there
	if { ![string match -nocase *%* $search] } {
		set sql "SELECT $db_(rlsname),$db_(section),$db_(files),$db_(siteurl),$db_(size),$db_(status),$db_(reason),$db_(network),$db_(time),$db_(year),$db_(hertz),$db_(channel),$db_(bitrate),$db_(mode),$db_(videocodec),$db_(videofps),$db_(videores),$db_(videoaspect),$db_(audiocodec),$db_(audiokbps),$db_(audiorate),$db_(audiochans),$db_(genre) FROM $mysql_(table) WHERE $db_(rlsname) = '[mysqlescape $search]' ORDER BY $db_(time) DESC LIMIT 1 "
	} else {
		set sql "SELECT $db_(rlsname),$db_(section),$db_(files),$db_(siteurl),$db_(size),$db_(status),$db_(reason),$db_(network),$db_(time),$db_(year),$db_(hertz),$db_(channel),$db_(bitrate),$db_(mode),$db_(videocodec),$db_(videofps),$db_(videores),$db_(videoaspect),$db_(audiocodec),$db_(audiokbps),$db_(audiorate),$db_(audiochans),$db_(genre) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%[mysqlescape $search]%' ORDER BY $db_(time) DESC LIMIT 1 "
	}
	set nfosql [mysqlsel $mysql_(handle) "SELECT nfoid,rlsname,filename FROM nfodb LEFT JOIN pred ON nfodb.rlsname=pred.name WHERE rlsname='[mysqlescape $search]' LIMIT 1" -flatlist];
	
	set query [mysqlsel $mysql_(handle) $sql -flatlist];
	
	if {$query == "" } {
		putnow "PRIVMSG $chan :\[ \0034No results found\003 \]"
	} else {
		foreach {rls type files siteurl mb nuke reason nukenetwork timestamp year hertz channel bitrate mode videocodec videofps videores videoaspect audiocodec audiokbps audiorate audiochans genre name} $query {
			
			#replace with better time checking, use a global funcktion perhaps?
			set time [unixtime]
			incr time -$timestamp
			set ago [duration $time]
			set after [clock clicks -milliseconds]
			set rlsname [lindex $nfosql 2]
			#GENRE strips "-" and empty genre line
			#if {[string match $genre "-"]} { set genre "/ $genre" } else { set genre "" }
			if { $genre != "" } { set genre " / $genre" } else { set genre "" }
			#MB / FILES
			if { $mb != "0" || $files != "0.00" } { set info "\[ \00314INFO\003: $mb MB / $files Files \]" } else { set info ""}
			#MP3
			if { $year !=  "" && $hertz != "" && $channel != "" && $bitrate != "" && $mode != "" } { set mp3 "\[ \00314MP3 INFO\003: \00314Genre\003: [tr:text2color $type] $genre \0037::\003 \00314Year\003: $year \0037::\003 \00314Hertz\003: $hertz \0037::\003 \00314Channels\003: $channel \0037::\003 \00314Bitrate\003: $bitrate \0037::\003 \00314Mode\003: $mode \]"  } else { set mp3 "" }
			#VIDEO INFO
			if { $videocodec != "" && $videofps != "" && $videores != "" && $videoaspect != "" && $audiocodec != "" && $audiokbps != "" && $audiorate != "" && $audiochans != "" } { set audiovideo "\[ \00314VIDEO INFO\003: \00314Codec\003: $videocodec \0037::\003 \00314FPS\003: $videofps \0037::\003 \00314Video Aspect\003: $videoaspect  \0037::\003 \00314Audio Codec\003: $audiocodec \0037::\003 \00314Audio Kpbs\003: $audiokbps \0037::\003 \00314Audio Rate\003: $audiorate \0037::\003 \00314Audio Chans\003: $audiochans \]" } else { set audiovideo "" }
			#URL
			if { $siteurl == "" } { set siteurl "" } else { set siteurl "\[ \0037URL\003: $siteurl \]" }
			#NFO
			if {![string match $rlsname ""]} { set nfo "\[\0039NFO\003\]" } else { set nfo "\[\0034NFO\003\]" }
			#NUKE 1/2/3
	        if {$nuke == "0"} {
				putnow "PRIVMSG $chan :\[ \0033PRED\003 \] \[ $rls \] $nfo \00314got released\003 \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE\003: [clock format $timestamp -format %d.%m.%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"          
			#URL / MP3 Output
			 if { $audiovideo == "" && $mp3 == ""  && $siteurl == ""} {  } else { putnow "PRIVMSG $chan : $audiovideo $mp3 $siteurl" }
			} elseif {$nuke == "1"} {
				putnow "PRIVMSG $chan :\[ \0033PRED\003 \] \[ $rls \] $nfo \[ \00314got Nuked with reason:\003 \0034$reason\003 \00314by\003: \0034$nukenetwork\003 \] \[ \00314PRED\003: $ago \00314ago\003 \]  \[ \00314DATE\003: [clock format $timestamp -format %d.%m.%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"
			 #URL / MP3 Output
              if { $mp3 == ""  && $siteurl == ""} {  } else { putnow "PRIVMSG $chan : $mp3 $siteurl" }
			} elseif {$nuke == "2"} {
				putnow "PRIVMSG $chan :\[ \0033PRED\003 \] \[ $rls \] $nfo \[ \00314got UnNuked with reason:\003 \0033$reason\003 \00314by\003: \0033$nukenetwork\003 \] \[ \00314PRED\003: $ago \00314ago\003 \]  \[ \00314DATE\003: [clock format $timestamp -format %d.%m.%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"
			 #URL / MP3 Output
              if { $mp3 == ""  && $siteurl == ""} {  } else { putnow "PRIVMSG $chan : $mp3 $siteurl" }
			} elseif {$nuke == "3"} {
			    putnow "PRIVMSG $chan :\[ \0033PRED\003 \] \[ $rls \] $nfo \[ \00314got ModNuked with reason:\003 \0035$reason\003 \00314by\003: \0035$nukenetwork\003 \] \[ \00314PRED\003: $ago \00314ago\003 \]  \[ \00314DATE\003: [clock format $timestamp -format %d.%m.%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"
			 #URL / MP3 Output
			  if { $mp3 == ""  && $siteurl == ""} {  } else { putnow "PRIVMSG $chan : $mp3 $siteurl" }
			} else {
				putlog "ERROR in (PRESEARCH)"
			}
		}
	}
mysqlendquery $mysql_(handle)
}
#END

#ADDPRE
proc ms:addpre { nick uhost hand chan arg } {
global addprechan getsection
 if {![channel get [string tolower $chan] db]} { return 0 }
          global prefix_ mysql_ db_ spamvar spamturn staffchan spamchan prechan movieschan xxxchan mp3chan nordicchan nordicgroups nordiclangs foreignchan foreignlangs foreigngroups
              set section [isy:sectioncolor $sect]
			  set splitz [split $arg " "]
              set add_(release) [lrange $splitz 0 0]
	          set add_(group) [mysqlescape [lindex [split $add_(release) -] end]]
              set add_(release) [string trimleft $add_(release) "\\\{"]
              set add_(release) [string trimright $add_(release) "\\\}"] 
			  set add_(section) [lrange $splitz 1 1]
              set add_(section) [string trimleft $add_(section) "\\\{"]
              set add_(section) [string trimright $add_(section) "\\\}"] 
		      set add_(nick) $nick
              set add_(time) [clock seconds]
              set temp1 [split $add_(release) -]
              set group [lindex $temp1 end]
              set rlsl [string length $add_(release)]
			  set add_(time) [clock seconds]
              set numrel [mysqlsel $mysql_(handle) "SELECT * FROM $mysql_(table) WHERE $db_(rlsname) = '$add_(release)'"]                         
            if { $numrel == 0 } {
			set numrel10 [mysqlsel $mysql_(handle) "SELECT * FROM pre_name WHERE Section = '$add_(section)'"]                         
					            if { $numrel10 != 0 } {
			                      set q [mysqlsel $mysql_(handle) "SELECT * FROM pre_name WHERE Section = '$add_(section)'" ]                
 								   mysqlmap $mysql_(handle) { ID new_Section mIRC } {
								   set mircode "$mIRC"
								   }
								   } else {
								   set mircode "$add_(section)"
								   }
 set nix [mysqlexec $mysql_(handle) "INSERT INTO $mysql_(table) ($db_(section),$db_(rlsname),$db_(group),$db_(time),$db_(nick)) VALUES ( '$add_(section)' , '$add_(release)' , '$add_(group)' , '$add_(time)' , '$nick' )"]
				putlog "--ADD-- RLS: $add_(release) GRP: $add_(group) was successfully added by $nick"             
				set q [mysqlsel $mysql_(handle) "SELECT * FROM $mysql_(table) WHERE $db_(rlsname) = '$add_(release)'"]
mysqlmap $mysql_(handle) { name section genre} {
putnow "PRIVMSG $spamchan :\[ \00314UNIX TIME\003: $add_(time) - \00314ADDPRE\003 \] \002[tr:text2color $section]\002 - $name"
set announce "\[ \0037PRE\003 \] \[ [$section] \] - $name"                        
#Filter
if {[regexp (?i)(^($nordicgroups)$) $add_(group)]} {
        putnow "PRIVMSG $nordicchan :$announce"
} elseif {[regexp (?i)($nordiclangs) $add_(release)]} {
	    putnow "PRIVMSG $nordicchan :$announce"
} elseif {[regexp (?i)(^($foreigngroups)$) $add_(group)]} {
        putnow "PRIVMSG $foreignchan :$announce"
} elseif {[regexp (?i)($foreignlangs) $add_(release)]} {
        putnow "PRIVMSG $foreignchan :$announce"
	} else {
	if {$add_(section) == "MP3" || $add_(section) == "MP3-INTERNAL" || $add_(section) == "FLAC" || $add_(section) == "WMA" || $add_(section) == "MVID" || $add_(section) == "MDVDR" || $add_(section) == "0DAY" || $add_(section) == "APPS" || $add_(section) == "PDA"} { 
		putnow "PRIVMSG $mp3chan :$announce"
	} else {
		putnow "PRIVMSG $prechan :$announce"
				}
			}
		}
	}
}

#END

#ADDNFO
proc ms:addnfo {nick uhost hand chan text} {
global mysql_ addnfochan
   if {[scan $text {%s%s%s} rlsname url filename] != 3} {
      puthelp "Usage: !addnfo <release> <url> <filename>" 
      return 
   }
#Make dir and $rlsname in dir name
   exec mkdir "/home/bot/pre/filesys/nfo/$rlsname"
   set curlHandle [curl::init]
  $curlHandle configure -url $url -file "/home/bot/pre/filesys/nfo/$rlsname/$filename"
  $curlHandle perform
  $curlHandle cleanup

#Makes the $filename and filesize
set nfofp [open "/home/bot/pre/filesys/nfo/$rlsname/$filename" "r"]
set rawnfo [read $nfofp]
set size [file size "/home/bot/pre/filesys/nfo/$rlsname/$filename"]
close $nfofp

#Output to channel
set escapednfo [mysql::escape $mysql_(handle) $rawnfo]
set nix [mysqlexec $mysql_(handle) "INSERT INTO nfodb (rlsname,filename,rawnfo,size) VALUES ( '$rlsname' , '$filename' , '$escapednfo' , '$size')"]
putlog "--ADDNFO-- $rlsname with NFO: $filename"
putquick "PRIVMSG $chan : \[ \00314ADDNFO\003 \] \00314UPDATING NFODB\003: \0033$rlsname\003 \00314With NFO\003:\0033 $filename\003 / \00314FiLESiZE\003:\0033 $size\003 \00314Bytes\003" 
mysqlendquery $mysql_(handle)
mysqlendquery $mysql_(handle)
}
#END

#CSTMADDPRE
proc ms:cstmaddpre { nick uhost hand chan arg } {
global addprecstmchan
 if {![channel get [string tolower $chan] cstmdb]} { return 0 }
          global mysql_ cstm_ spamvar spamturn staffchan spamchan prechan
              set splitz [split $arg " "]
              set cstm_(release) [lrange $splitz 0 0]
			  set add_(group) [mysqlescape [lindex [split $cstm_(release) -] end]]
              set cstm_(release) [string trimleft $cstm_(release) "\\\{"]
              set cstm_(release) [string trimright $cstm_(release) "\\\}"] 
              set temp1 [split $cstm_(release) -]
              set rlsl [string length $cstm_(release)]
			  set add_(time) [clock seconds]
			  set temp1 [split $cstm_(release) -]
              set group [lindex $temp1 end]

              set numrel [mysqlsel $mysql_(handle) "SELECT * FROM cstm_pred WHERE $cstm_(rlsname) = '$cstm_(release)'"]                         
            if { $numrel == 0 } {              
 set nix [mysqlexec $mysql_(handle) "INSERT INTO cstm_pred ($cstm_(rlsname),$cstm_(group),$cstm_(time)) VALUES ( '$cstm_(release)' , '$add_(group)' , '$add_(time)' )"]
				putlog "--CSTMADD-- $cstm_(release) GRP: $add_(group) was successfully added by $nick"
                     set q [mysqlsel $mysql_(handle) "SELECT * FROM cstm_pred WHERE $cstm_(rlsname) = '$cstm_(release)'"]
mysqlmap $mysql_(handle) { id cstmname group } {
set announce "\[ \0037CSTMPRE\003 \] \[ [ \0033$group\003] \] - $cstmname"                        
putnow "PRIVMSG $prechan :$announce"	
		}
} 
}                                                             
#END
#NUKE
proc ms:nuke { nick uhost hand chan arg } {
	global addprechan spamchan prechan mysql_ db_ prefix_ nukevar nuketurn
 if {![channel get [string tolower $chan] db]} { return 0 }

	#Dont nuke if theres no nukenetwork in the announce
	if { [lindex $arg 2] ==""} {
		return 0
	}
          if {[lsearch $nukevar [lindex $arg 0]] == "-1"} {
          set nukevar [lreplace $nukevar $nuketurn $nuketurn [lindex $arg 0]]
          incr nuketurn
          if {$nuketurn >= 29} {set nuketurn 0}
      set splitz [split $arg " "]
      set nuke_(release) [lrange $splitz 0 0]
      set nuke_(release) [string trimright $nuke_(release) "\\\{"]
      set nuke_(release) [string trimleft $nuke_(release) "\\\}"]
      set nuke_(reason) [lrange $splitz 1 1]
      set nuke_(reason) [string trimleft $nuke_(reason) "\\\{"]
      set nuke_(reason) [string trimright $nuke_(reason) "\\\}"]
      set nuke_(network) [lrange $splitz 2 2]
      set nuke_(network) [string trimleft $nuke_(network) "\\\{"]
      set nuke_(network) [string trimright $nuke_(network) "\\\}"]
      set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$nuke_(release)'"
      set numrel [mysqlsel $mysql_(handle) $q]
      set w [mysqlsel $mysql_(handle) "SELECT reason FROM $mysql_(table) WHERE $db_(rlsname)='$nuke_(release)'"]
                mysqlmap $mysql_(handle) { reason } {
                    if { $reason == $nuke_(reason) } { set rskip 1
                    } else { set rskip 0 }
                        if { $numrel != 0 && $rskip != 1 } {
                            mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(status)=1 , $db_(reason)='$nuke_(reason)' , $db_(network)='$nuke_(network)' WHERE $db_(rlsname)='$nuke_(release)'"
							putlog "--NUKE-- $nuke_(release) nuked with reason $nuke_(reason)"
							set q [mysqlsel $mysql_(handle) "SELECT name,type,reason,nukenetwork FROM $mysql_(table) WHERE $db_(rlsname)='$nuke_(release)'"]
                            mysqlmap $mysql_(handle) { name section reason nukenetwork } {
                                  set temp1 [split $name -]
                                  set group [lindex $temp1 end]
                                      putnow "PRIVMSG $prechan :\[ \0034NUKE\003 \] \[ $name \] \[\0034 $reason\003 \] => \0034$nukenetwork\003 " }
                          }
              }
    }
  }
#END
#MODNUKE
proc ms:modnuke { nick uhost hand chan arg } {
	global addprechan spamchan prechan mysql_ db_ prefix_ nukevar nuketurn
  if {![channel get [string tolower $chan] db]} { return 0 }
		#Dont modnuke if theres no nukenetwork in the announce
	if { [lindex $arg 2] ==""} {
		return 0
	}
          if {[lsearch $nukevar [lindex $arg 0]] == "-1"} {
          set nukevar [lreplace $nukevar $nuketurn $nuketurn [lindex $arg 0]]
          incr nuketurn
          if {$nuketurn >= 29} {set nuketurn 0}
      set splitz [split $arg " "]
      set nuke_(release) [lrange $splitz 0 0]
      set nuke_(release) [string trimright $nuke_(release) "\\\{"]
      set nuke_(release) [string trimleft $nuke_(release) "\\\}"]
      set nuke_(reason) [lrange $splitz 1 1]
      set nuke_(reason) [string trimleft $nuke_(reason) "\\\{"]
      set nuke_(reason) [string trimright $nuke_(reason) "\\\}"]
	  set nuke_(network) [lrange $splitz 2 2]
      set nuke_(network) [string trimleft $nuke_(network) "\\\{"]
      set nuke_(network) [string trimright $nuke_(network) "\\\}"]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$nuke_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                set w [mysqlsel $mysql_(handle) "SELECT reason FROM $mysql_(table) WHERE $db_(rlsname) = '$nuke_(release)'"]
                mysqlmap $mysql_(handle) { reason } {
                    if { $reason == $nuke_(reason) } { set rskip 1
                    } else { set rskip 0 }
                        if { $numrel != 0 && $rskip != 1 } {
                            mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(status)=3 , $db_(reason)='$nuke_(reason)' , $db_(network)='$nuke_(network)' WHERE $db_(rlsname)='$nuke_(release)'"
							putlog "--MODNUKE-- $nuke_(release) modnuked with reason $nuke_(reason)"
							set q [mysqlsel $mysql_(handle) "SELECT name,type,reason,nukenetwork FROM $mysql_(table) WHERE $db_(rlsname) = '$nuke_(release)'"]
                            mysqlmap $mysql_(handle) { name section reason nukenetwork} {
                                  set temp1 [split $name -]
                                  set group [lindex $temp1 end]
                                      putnow "PRIVMSG $prechan :\[ \0035MODNUKE\003 \] $name - \[\0035 $reason\003 \] => \0035$nukenetwork\003 " }
        }
     }
  }
}
#END
#UNNUKE
proc ms:unnuke { nick uhost hand chan arg } {
	global addprechan spamchan prechan mysql_ db_ prefix_ unnukevar unnuketurn
  if {![channel get [string tolower $chan] db]} { return 0 }
    
	#Dont nuke if theres no nukenetwork in the announce
	if { [lindex $arg 2] ==""} {
		return 0
	}    
        if { $arg == "" } {
          putnow "NOTICE $nick : \002Syntax is\002 !unnuke <release> <reason> <nukenetwork>"
        } else {
          if {[lsearch $unnukevar [lindex $arg 0]] == "-1"} {
          set unnukevar [lreplace $unnukevar $unnuketurn $unnuketurn [lindex $arg 0]]
          incr unnuketurn
          if {$unnuketurn >= 29} {set unnuketurn 0}
      set splitz [split $arg " "]
      set unnuke_(release) [lrange $splitz 0 0]
      set unnuke_(release) [string trimright $unnuke_(release) "\\\{"]
      set unnuke_(release) [string trimleft $unnuke_(release) "\\\}"]
      set unnuke_(reason) [lrange $splitz 1 1]
      set unnuke_(reason) [string trimleft $unnuke_(reason) "\\\{"]
      set unnuke_(reason) [string trimright $unnuke_(reason) "\\\}"]
	  set nuke_(network) [lrange $splitz 2 2]
      set nuke_(network) [string trimleft $nuke_(network) "\\\{"]
      set nuke_(network) [string trimright $nuke_(network) "\\\}"]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$unnuke_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                set w [mysqlsel $mysql_(handle) "SELECT reason FROM $mysql_(table) WHERE $db_(rlsname) = '$unnuke_(release)'"]
                mysqlmap $mysql_(handle) { reason } {
                    if { $reason == $unnuke_(reason) } { set rskip 1
                    } else { set rskip 0 }
                        if { $numrel != 0 } {
                            mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(status)=2 , $db_(reason)='$unnuke_(reason)' , $db_(network)='$nuke_(network)' WHERE $db_(rlsname)='$unnuke_(release)'"
                           putlog "--UNNUKE-- $unnuke_(release) unnuked with reason $unnuke_(reason)"                           
						   set q [mysqlsel $mysql_(handle) "SELECT name,type,reason,nukenetwork FROM $mysql_(table) WHERE $db_(rlsname)='$unnuke_(release)'"]
                            mysqlmap $mysql_(handle) { name section reason nukenetwork } {
                                  set temp1 [split $name -]
                                  set group [lindex $temp1 end]
                                      putnow "PRIVMSG $prechan :\[ \0033UNNUKE\003 \] \[ $name \] \[\0033 $reason\003 \] => \0033$nukenetwork\003" }
                      }
            }
  }
}
}
#END

#INFO
proc ms:info { nick uhost hand chan arg } {
	global mysql_ db_ addprechan spamchan infovar infoturn
  if {![channel get [string tolower $chan] db]} { return 0 }
        if { $arg == "" } {
          putnow "NOTICE $nick : \002Syntax is\002 !addinfo <release> <files> <size>"
        } else {
          if {[lsearch $infovar [lindex $arg 0]] == "-1"} {
          set infovar [lreplace $infovar $infoturn $infoturn [lindex $arg 0]]
          incr infoturn
          if {$infoturn >= 29} {set infoturn 0}
          set splitz [split $arg " "]
          set info_(release) [lrange $splitz 0 0]
          set info_(release) [string trimleft $info_(release) "\\\{"]
          set info_(release) [string trimright $info_(release) "\\\}"]
          set info_(files) [lrange $splitz 1 1]
          set info_(files) [string trimleft $info_(files) "\\\{"]
          set info_(files) [string trimright $info_(files) "\\\}"]
          set info_(size) [lrange $splitz 2 2]
          set info_(size) [string trimleft $info_(size) "\\\{"]
          set info_(size) [string trimright $info_(size) "\\\}"]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$info_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                        if { $numrel == 0 } {
                          } else {
                            set nix [mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(files)='$info_(files)' , $db_(size)='$info_(size)' WHERE $db_(rlsname)='$info_(release)'"]
#putnow "PRIVMSG $spamchan \[ UPDATED.ADDiNFO / $info_(size) MB in $info_(files) F \] * $info_(release)"
 putlog "--INFO-- Add info for $info_(release) - $info_(files)Files $info_(size)MB"
							#set announce "\[ \00311INFO\003: \] $info_(release) \002\[\002\00314 $info_(files)\003Files /\00314 $info_(size)\003MB \002\]\003"
set announce "\[ \00314ADDiNFO\003 / $info_(size) MB in $info_(files) F \] * $info_(release)"							
					putnow "PRIVMSG $spamchan $announce"
      }
    }
  }
}    
#END

#DELPRE         
proc ms:delpre { nick uhost hand chan arg } {
            global mysql_ prefix_ db_ addprechan prechan
  if {![channel get [string tolower $chan] db]} { return 0 }
	#Dont nuke if theres no nukenetwork in the announce
	if { [lindex $arg 2] ==""} {
		return 0
	}
      if { $arg == "" } {
          putnow "NOTICE $nick : \002Syntax is\002 !delpre <release> <reason> <Nukenetwork>" }
      if { $arg != "" } {
          set splitz [split $arg " "]
          set del_(release) [lrange $arg 0 0]
          set del_(release) [string trimleft $del_(release) "\\\{"]
          set del_(release) [string trimright $del_(release) "\\\}"]
          set del_(reason) [lrange $arg 1 1]
          set del_(reason) [string trimleft $del_(reason) "\\\{"]
          set del_(reason) [string trimright $del_(reason) "\\\}"]
		  set del_(by) [lrange $arg 2 2]
          set del_(by) [string trimleft $del_(by) "\\\{"]
          set del_(by) [string trimright $del_(by) "\\\}"]
            set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) = '$del_(release)'"
            set numrel [mysqlsel $mysql_(handle) $q]
                if { $numrel != 0 } {
                    mysqlsel $mysql_(handle) "SELECT $db_(section),$db_(nick),$db_(time) FROM $mysql_(table) WHERE $db_(rlsname) = '$del_(release)'"
                    mysqlmap $mysql_(handle) { dbsection dbnick dbtime } {
                    set q "DELETE FROM $mysql_(table) WHERE $db_(rlsname)='$del_(release)'"
					putlog "--DELPRE-- Deletet $del_(release)- $del_(reason)"
                    set nix [mysqlexec $mysql_(handle) $q]
					putnow "PRIVMSG $prechan :\[ \00304DELPRE\003 \] \[ $del_(release) \] \[ \00304$del_(reason)\003 \] => \00304$del_(by)\003"
            }
      } 
  }
}       
#END
#GENRE
proc ms:genre { nick uhost hand chan arg } {
	global  mysql_ db_ genrevar genreturn spamchan addprechan genchan prechan movieschan xxxchan mp3chan
  if {![channel get [string tolower $chan] db]} { return 0 }

	if { $arg == "" } {
          putnow "NOTICE $nick : \002Syntax is\002 !addgenre <release> <genre>"
        } else {
          set splitz [split $arg " "]
          set fee_(release) [lrange $splitz 0 0]
          set fee_(release) [string trimleft $fee_(release) "\\\{"]
          set fee_(release) [string trimright $fee_(release) "\\\}"]
          set fee_(genre) [lrange $splitz 1 1]
          set fee_(genre) [string trimleft $fee_(genre) "\\\{"]
          set fee_(genre) [string trimright $fee_(genre) "\\\}"]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$fee_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                        if { $numrel == 0 } {
                          } else {
                            mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(genre)='$fee_(genre)' WHERE $db_(rlsname)='$fee_(release)'"

							putnow "PRIVMSG $spamchan \[ \00314UPDATED.GENRE\003 / \00311$fee_(genre)\003 \] * $fee_(release)"
                        }
				}
          if {[lsearch $genrevar [lindex $arg 0]] == "-1"} {
          set genrevar [lreplace $genrevar $genreturn $genreturn [lindex $arg 0]]
          incr genreturn
          if {$genreturn >= 29} {set genreturn 0}
          set splitz [split $arg " "]
          set genre_(release) [lrange $splitz 0 0]
          set genre_(release) [string trimleft $genre_(release) "\\\{"]
          set genre_(release) [string trimright $genre_(release) "\\\}"]
          set genre_(genre) [lrange $splitz 1 1]
          set genre_(genre) [string trimleft $genre_(genre) "\\\{"]
          set genre_(genre) [string trimright $genre_(genre) "\\\}"]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$genre_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                        if { $numrel == 0 } {
                          } else {
putlog "--GENRE-- Add genre for $genre_(release) - $genre_(genre)"
set nix [mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(genre)='$genre_(genre)' WHERE $db_(rlsname)='$genre_(release)'"]
#set announce "\[ \0039GENRE\003: \] $genre_(release) \002\[\002 \00314$genre_(genre)\003 \002\]\002" 
set announce "\[ \00314ADDED.GENRE\003 / \00311$genre_(genre)\003 \] * $genre_(release)"

putnow "PRIVMSG $spamchan $announce"

# echo genre add to channels
set announce "\[ \0037GENRE\003 \] \[ $genre_(genre) \] - $genre_(release)"
set add_(section) [mysqlsel $mysql_(handle) "SELECT $db_(section) FROM $mysql_(table) WHERE $db_(rlsname)='$genre_(release)'" -flatlist]

#if {$add_(section) != "XXX" } {
#putnow "PRIVMSG $prechan :$announce"} 

#if {$add_(section) == "XVID" || $add_(section) == "X264"} {
#putnow "PRIVMSG $movieschan :$announce" }

#if {$add_(section) == "XXX" } {
#putnow "PRIVMSG $xxxchan :$announce" }


if {$add_(section) == "MP3" || $add_(section) == "FLAC" || $add_(section) == "WMA" } {
putnow "PRIVMSG $mp3chan :$announce"}

          }
    }
mysqlendquery $mysql_(handle)
}
#END
#GROUPNUKES
proc ms:groupnukes {nick uhost hand chan arg } {
  if {![channel get [string tolower $chan] stats]} { return 0 }
	global mysql_ db_
	
	#tell the user we are searching
	putnow "PRIVMSG $chan :\[ \0037SEARCHING\003 \]"
	if { $arg == "" } {
          putnow "PRIVMSG $chan : No group set!"
        } else {
          set splitz [split $arg " "]
          set group [lrange $splitz 0 0]
          set group [string trimleft $group "\\\{"]
          set numrel [mysqlsel $mysql_(handle) "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(group) = '$group'"]
              if { $numrel == 0 } {
            putnow "PRIVMSG $chan :\[ \0034No results found\003 \]"
              } else {
			set nuked [mysqlsel $mysql_(handle) "SELECT COUNT(`$db_(id)`) FROM $mysql_(table) WHERE $db_(group) = '$group' AND $db_(status)=1" -flatlist]

			  putnow "PRIVMSG $chan :\[ \0037Sending last 10 Search Results in Priv Msg to $nick\003 \]"
              putnow "PRIVMSG $nick :\[ \0032GROUP\003: \0032$arg\003 \] \[ \0037Releases\003: $numrel \] \[ \0034Nukes\003: $nuked \]"
			  set q [mysqlsel $mysql_(handle) "SELECT $db_(rlsname),$db_(section),$db_(files),$db_(size),$db_(status),$db_(reason),$db_(time),$db_(genre),$db_(network) FROM $mysql_(table) WHERE $db_(group) = '$group' AND $db_(status)=1 ORDER BY $db_(time) DESC LIMIT 10"]
			  mysqlmap $mysql_(handle) { name section files mb nukenetwork reason time genre } {       
              set f "Files"
              set m "MB"			  
				 putnow "PRIVMSG $nick : $name \[ \00314PRED\003: [duration [expr [unixtime] - $time]] \] \[\00314DATE\003: [clock format $time -format %d-%m-%Y] \] \[\00314TIME\003: [clock format $time -format "%H:%M:%S"] \] \00314in\003 \[ [tr:text2color $section] / $genre \] \[ \00314INFO\003: $mb $m / $files $f \] \[ \00314Nuke reason:\003 \0034$reason\003 \00314by\003: \0034$nukenetwork\003 \]"
                  }
      }
  }
mysqlendquery $mysql_(handle)
mysqlendquery $mysql_(handle)
mysqlendquery $mysql_(handle)
}
#END
#GROUPUNNKES
proc ms:groupunnukes {nick uhost hand chan arg } {
if {![channel get [string tolower $chan] stats]} { return 0 }
        global mysql_ db_
		
#tell the user we are searching
	putnow "PRIVMSG $chan :\[ \0037SEARCHING\003 \]"
	
        if { $arg == "" } {
          putnow "PRIVMSG $chan : No group set!"
        } else {
          set splitz [split $arg " "]
          set group [lrange $splitz 0 0]
          set group [string trimleft $group "\\\{"]
          set numrel [mysqlsel $mysql_(handle) "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(group) = '$group'"]
              if { $numrel == 0 } {
            putnow "PRIVMSG $chan :\[ \0034No results found\003 \]"
              } else {
                        set nuked [mysqlsel $mysql_(handle) "SELECT COUNT(`$db_(id)`) FROM $mysql_(table) WHERE $db_(group) = '$group' AND $db_(status)=2" -flatlist]
             putnow "PRIVMSG $chan :\[ \0037Sending last 10 Search Results in Priv Msg to $nick\003 \]"
              putnow "PRIVMSG $nick :\[ \0032GROUP\003: \0032$arg\003 \] \[ \0037Releases\003: $numrel \] \[ \0033UnNukes\003: $nuked \]"
                          set q [mysqlsel $mysql_(handle) "SELECT $db_(rlsname),$db_(section),$db_(reason),$db_(network),$db_(time) FROM $mysql_(table) WHERE $db_(group) = '$group' AND $db_(status)=2 ORDER BY $db_(time) DESC LIMIT 5"]
                          mysqlmap $mysql_(handle) { name section reason nukenetwork time } {
                  putnow "PRIVMSG $nick :\[ \0032GROUP\003: \0032$arg\003 \] $name \[ \00314PRED\003: [duration [expr [unixtime] - $time]] \] \[\00314DATE\003: [clock format $time -format %d-%m-%Y] \] \[\00314TIME\003: [clock format $time -format "%H:%M:%S"] \] \00314in\003 \[ [tr:text2color $section] \] \[ \00314UnNuke reason:\003 \0033$reason\003 \00314by\003: \0033$nukenetwork\003 \]"
                  }
      }
  }
mysqlendquery $mysql_(handle)
mysqlendquery $mysql_(handle)
mysqlendquery $mysql_(handle)
}
#END
#GROUP
proc ms:group {nick uhost hand chan arg } {
if {![channel get [string tolower $chan] search]} { return 0 }
    global mysql_ db_
	#tell the user we are searching
	putnow "PRIVMSG $chan :\[ \0037SEARCHING\003 \]"   
    if { $arg == "" } {
          putnow "PRIVMSG $chan : No group set!"
    } else {
          set splitz [split $arg " "]
          set group [lrange $splitz 0 0]
          set group [string trimleft $group "\\\{"]
          set group [string trimright $group "\\\}"]    
		   set numrel [mysqlsel $mysql_(handle) "SELECT `$db_(id)` FROM `pred` WHERE `name` LIKE '%-$group'"] 
		  if { $numrel == 0 } {
            putnow "PRIVMSG $chan :\[ \0034No results found\003 \]"
              } else {
              #Find Nukes / UnNukes / Fitst Pre / Last Pre
	          set now [unixtime]
              set after [clock clicks -milliseconds]   
              set nuked [mysqlsel $mysql_(handle) "SELECT COUNT(`$db_(id)`) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%-$group' AND $db_(status)=1" -flatlist]
              set unnuke [mysqlsel $mysql_(handle) "SELECT COUNT(`$db_(id)`) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '%-$group' AND $db_(status)=2" -flatlist]

              set firstpre [mysqlsel $mysql_(handle) "SELECT name,time,type,genre FROM `pred` WHERE $db_(group) = '$group' ORDER BY `$db_(time)` ASC LIMIT 0,1" -flatlist]
	          set fpre [lindex [split $firstpre " "] 0]
	          set ftime [lindex [split $firstpre " "] 1]
              set fago [duration [expr { $now - [lindex [split $firstpre " "] 1]}]]
	          set ftype [lindex [split $firstpre " "] 2]
	          set fgenre [lindex [split $firstpre " "] 3]
	      if { $fgenre != "{}" } {
			set fgenre " / $fgenre"
	      } else {
			set fgenre ""
	      }	
	      set lastpre [mysqlsel $mysql_(handle) "SELECT name,time,type,genre FROM `pred` WHERE $db_(group) = '$group' ORDER BY `$db_(time)` DESC LIMIT 0,1" -flatlist]
	      set lpre [lindex [split $lastpre " "] 0]
	      set ltime [lindex [split $lastpre " "] 1]
          set lago [duration [expr { $now - [lindex [split $lastpre " "] 1]}]]
	      set ltype [lindex [split $lastpre " "] 2]
	      set lgenre [lindex [split $lastpre " "] 3]
	      if { $lgenre != "{}" } {
	      set lgenre " / $lgenre"
	      } else {
			set lgenre ""
	      }

	      # OUTPUT TO CHANNEL [tr:text2color $section]
			  putnow "PRIVMSG $chan :\[ \0032GROUP\003: \0032$arg\003 \] \[ \0037Releases\003: $numrel \] \[ \0034Nukes\003: $nuked \] \[ \0033UnNukes\003: $unnuke \]"
			  putnow "PRIVMSG $chan :\[ \0032GROUP\003: \0032$arg\003 \] \[ \0038First Release\003: $fpre \] \[ \00314PRED\003: $fago \00314ago\003 \] \[\00314DATE\003: [clock format $ftime -format %d-%m-%Y] \] \[\00314TIME\003: [clock format $ftime -format "%H:%M:%S"] \] \00314in\003 \[ [tr:text2color $ftype]$fgenre \]"	  
              putnow "PRIVMSG $chan :\[ \0032GROUP\003: \0032$arg\003 \] \[ \0033Last Release\003: $lpre \] \[ \00314PRED\003: $lago \00314ago\003 \] \[\00314DATE\003: [clock format $ltime -format %d-%m-%Y] \] \[\00314TIME\003: [clock format $ltime -format "%H:%M:%S"] \] \00314in\003 \[ [tr:text2color $ltype]$lgenre \]"
          }
	}
mysqlendquery $mysql_(handle)
mysqlendquery $mysql_(handle)
mysqlendquery $mysql_(handle)
mysqlendquery $mysql_(handle)
}
#END
#LAST24
proc ms:last24 {nick uhost hand chan arg} {
global mysql_ db_ searchchan

	#save currenttime
	set time [unixtime]  
	
	#check if channel is a search channel
	if {![channel get [string tolower $chan] search]} { putnow "NOTICE $nick :please join $searchchan for searches thanks"; return 0 }
	
	#check if we got an argument
	#if {[lindex $arg 0] ==""} {putserv "NOTICE $nick :USAGE\: !pre(d) RELEASE"; return 0 }
	
	#tell the user we are searching
	putnow "PRIVMSG $chan :\[ \0037SEARCHING\003 \]"
	
	#replace whitespace and * with %
	regsub -all -- {[\* ]}	$arg "\%" search
	
	#check if we are searching with wildcards or not, if not then its faster to lookup with equal sign.
	#if we are searching with wildcards then we have to use a like statement. takes longer time but it will find the release if its there
		set sqllast24 "SELECT name,type,files,size,status,reason,nukenetwork,time,genre FROM pred WHERE name LIKE '%DANISH%' AND time > [expr [unixtime]-86400] "
	
	set query1 [mysqlsel $mysql_(handle) $sqllast24 -flatlist];
	
	if {$query1 == ""} {
		putnow "PRIVMSG $chan :\[ \0034No results found\003 \]"
	} else {
		putnow "PRIVMSG $chan :\[ \0037Sending the last month danish pre results in Priv Msg to $nick\003 \]"		
		foreach {rls type files mb nuke reason nukenetwork timestamp genre} $query1 {
			
			#replace with better time checking, use a global funcktion perhaps?
			incr time -$timestamp
			set ago [duration $time]
			set after [clock clicks -milliseconds]

			if { $genre == "" } { set genre "" } else { set genre " / $genre" }
			if { $mb == "0" || $files == "0.00" } { set info ""} else { set info "\[ \00314INFO\003: $mb MB $files Files \]" }
			if {$nuke == "0"} {
			  # putnow "PRIVMSG $chan :\[ \0033PRED\003 \] \[ $rls \] \00314got released\003 \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE\003: [clock format $timestamp -format %d.%m.%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] \[ \00314INFO\003: $mb $m / $files $f \]"
				putnow "PRIVMSG $nick :\[ \0033PRED\003 \] \[ $rls \] \00314got released\003 \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE\003: [clock format $timestamp -format %d-%m-%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"
			} elseif {$nuke == "1"} {
				# putnow "PRIVMSG $chan :\[ \0033PRED\003 \] \[ $rls \] \[ \00314got nuked with reason:\003 \0034$reason\003 \00314by\003: \0034$nukenetwork\003 \] \[ \00314PRED\003: $ago \00314ago\003 \]  \[ \00314DATE\003: [clock format $timestamp -format %d.%m.%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] \[ \00314INFO\003: $mb $m / $files $f \]"
				putnow "PRIVMSG $nick :\[ \0033PRED\003 \] \[ $rls \] \[ \00314got nuked with reason:\003 \0034$reason\003 \00314by\003: \0034$nukenetwork\003 \] \[ \00314PRED\003: $ago \00314ago\003 \]  \[ \00314DATE\003: [clock format $timestamp -format %d-%m-%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"
			} elseif {$nuke == "2"} {
				# putnow "PRIVMSG $chan :\[ \0033PRED\003 \] \[ $rls \] \[ \00314got UnNuked with reason:\003 \0033$reason\003 \00314by\003: \0033$nukenetwork\003 \] \[ \00314PRED\003: $ago \00314ago\003 \]  \[ \00314DATE\003: [clock format $timestamp -format %d.%m.%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] \[ \00314INFO\003: $mb $m / $files $f \]"
				putnow "PRIVMSG $nick :\[ \0033PRED\003 \] \[ $rls \] \[ \00314got UnNuked with reason:\003 \0033$reason\003 \00314by\003: \0033$nukenetwork\003 \] \[ \00314PRED\003: $ago \00314ago\003 \]  \[ \00314DATE\003: [clock format $timestamp -format %d-%m-%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"
			} elseif {$nuke == "3"} {
                putnow "PRIVMSG $nick :\[ \0033PRED\003 \] \[ $rls \] \[ \00314got UnNuked with reason:\003 \0035$reason\003 \00314by\003: \0035$nukenetwork\003 \] \[ \00314PRED\003: $ago \00314ago\003 \]  \[ \00314DATE\003: [clock format $timestamp -format %d-%m-%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"
			} else {
				putlog "ERROR in (PRESEARCH)"
			}
		}
	}
mysqlendquery $mysql_(handle)
}

#END

#LAST48
proc ms:last48 {nick uhost hand chan arg} {
global mysql_ db_ searchchan
	
	#save currenttime
	set time [unixtime]
	
	#mysql connection 
	
	#check if channel is a search channel
	if {![channel get [string tolower $chan] search]} { putnow "NOTICE $nick :please join $searchchan for searches thanks"; return 0 }
	
	#check if we got an argument
	#if {[lindex $arg 0] ==""} {putserv "NOTICE $nick :USAGE\: !pre(d) RELEASE"; return 0 }
	
	#tell the user we are searching
	putnow "PRIVMSG $chan :\[ \0037SEARCHING\003 \]"
	
	#replace whitespace and * with %
	regsub -all -- {[\* ]}	$arg "\%" search
	
	#check if we are searching with wildcards or not, if not then its faster to lookup with equal sign.
	#if we are searching with wildcards then we have to use a like statement. takes longer time but it will find the release if its there
		set sqllast48 "SELECT name,type,files,size,status,reason,nukenetwork,time,genre FROM pred WHERE name LIKE '%DANISH%' AND time > [expr [unixtime]-172800] "
	
	set query2 [mysqlsel $mysql_(handle) $sqllast48 -flatlist];
	
	if {$query2 == ""} {
		putnow "PRIVMSG $chan :\[ \0034No results found\003 \]"
	} else {
		putnow "PRIVMSG $chan :\[ \0037Sending the last 2 month danish pre results in Priv Msg to $nick\003 \]"		
		foreach {rls type files mb nuke reason nukenetwork timestamp genre} $query2 {
			
			#replace with better time checking, use a global funcktion perhaps?
			incr time -$timestamp
			set ago [duration $time]
			set after [clock clicks -milliseconds]

			if { $genre == "" } { set genre "" } else { set genre " / $genre" }
			if { $mb == "0" || $files == "0.00" } { set info ""} else { set info "\[ \00314INFO\003: $mb MB $files Files \]" }
			if {$nuke == "0"} {
			  # putnow "PRIVMSG $chan :\[ \0033PRED\003 \] \[ $rls \] \00314got released\003 \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE\003: [clock format $timestamp -format %d.%m.%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] \[ \00314INFO\003: $mb $m / $files $f \]"
				putnow "PRIVMSG $nick :\[ \0033PRED\003 \] \[ $rls \] \00314got released\003 \[ \00314PRED\003: $ago \00314ago\003 \] \[ \00314DATE\003: [clock format $timestamp -format %d-%m-%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"
			} elseif {$nuke == "1"} {
				# putnow "PRIVMSG $chan :\[ \0033PRED\003 \] \[ $rls \] \[ \00314got nuked with reason:\003 \0034$reason\003 \00314by\003: \0034$nukenetwork\003 \] \[ \00314PRED\003: $ago \00314ago\003 \]  \[ \00314DATE\003: [clock format $timestamp -format %d.%m.%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] \[ \00314INFO\003: $mb $m / $files $f \]"
				putnow "PRIVMSG $nick :\[ \0033PRED\003 \] \[ $rls \] \[ \00314got nuked with reason:\003 \0034$reason\003 \00314by\003: \0034$nukenetwork\003 \] \[ \00314PRED\003: $ago \00314ago\003 \]  \[ \00314DATE\003: [clock format $timestamp -format %H:%M:%S] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"
			} elseif {$nuke == "2"} {
				# putnow "PRIVMSG $chan :\[ \0033PRED\003 \] \[ $rls \] \[ \00314got UnNuked with reason:\003 \0033$reason\003 \00314by\003: \0033$nukenetwork\003 \] \[ \00314PRED\003: $ago \00314ago\003 \]  \[ \00314DATE\003: [clock format $timestamp -format %d.%m.%Y] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] \[ \00314INFO\003: $mb $m / $files $f \]"
				putnow "PRIVMSG $nick :\[ \0033PRED\003 \] \[ $rls \] \[ \00314got UnNuked with reason:\003 \0033$reason\003 \00314by\003: \0033$nukenetwork\003 \] \[ \00314PRED\003: $ago \00314ago\003 \]  \[ \00314DATE\003: [clock format $timestamp -format %H:%M:%S] \] \[ \00314TIME\003: [clock format $timestamp -format %H:%M:%S] \] \00314in\003 \[ [tr:text2color $type] $genre \] $info"
			} else {
				putlog "ERROR in (PRESEARCH)"
			}
		}
	}
mysqlendquery $mysql_(handle)
}

#END

#DATABASE
proc pre:db {nick uhost hand chan arg} {
global mysql_ db_ searchchan

	#check if channel is a search channel
	if {![channel get [string tolower $chan] stats]} { putnow "NOTICE $nick :please join $searchchan for searches thanks"; return 0 }
	
  
	#lav noget med at finde de sidste 10 minutter (?)
	#set now [clock seconds]
	#set dur [expr $now - 3600]
	
	#Denne bruges ikke endnu
	#set row [lindex [mysqlsel $db_(handle) "SHOW TABLE STATUS LIKE '$db_(table)';" -list] 0]
	
	#find antal releases
	set sqlreleases "SELECT COUNT(id) FROM pred"
	set releases [mysqlsel $mysql_(handle) $sqlreleases -flatlist]
    #END
	
	#CSTM RLS
	set sqlcstmreleases "SELECT COUNT(id) FROM cstm_pred"
	set cstmreleases [mysqlsel $mysql_(handle) $sqlcstmreleases -flatlist]
    #END
	
	#find antal der er nuked indenfor 10 minutter (?)
    set sqlnuked "SELECT COUNT(id) FROM pred WHERE status='1'"
	set nuked [mysqlsel $mysql_(handle) $sqlnuked -flatlist]
	#END
	
	#find antal der er unnuke indenfor 10 minutter (?)
    set sqlunnuke "SELECT COUNT(id) FROM pred WHERE status='2'"
	set unnuke [mysqlsel $mysql_(handle) $sqlunnuke -flatlist]
	
	#Find number of modnukes
	set sqlmodnukes "SELECT COUNT(id) FROM pred WHERE status='3'"
	set modnukes [mysqlsel $mysql_(handle) $sqlmodnukes -flatlist]
	
	#Last pre
	set sqllastpre "SELECT name FROM pred ORDER BY id DESC LIMIT 1"
	set lastpre [mysqlsel $mysql_(handle) $sqllastpre -flatlist]
	#END
	
	#CSTM Last pre
    set sqlcstmlastpre "SELECT cstmname FROM cstm_pred ORDER BY id DESC LIMIT 1"
	set cstmlastpre [mysqlsel $mysql_(handle) $sqlcstmlastpre -flatlist]
	#END
	
	#Url
	set sqlsiteurl "SELECT COUNT(DISTINCT(siteurl)) FROM pred"
	set siteurl [mysqlsel $mysql_(handle) $sqlsiteurl -flatlist]
	
	#NFO
	set sqlnfo "SELECT COUNT(nfoid) FROM nfodb"
	set nfo [mysqlsel $mysql_(handle) $sqlnfo -flatlist]
	
	#ADD COMMA TO RELASES 
	proc commify number {regsub -all {\d(?=(\d{3})+($|\.))} $number  {\0,}}
	
	#TRACE
	#set tracereleases [mysqlsel $db_(handle) "SELECT COUNT(`$db_(id)`) from $db_(table2)" -flatlist]
	#set siteraced [mysqlsel $db_(handle) "SELECT COUNT(`$db_(id)`) FROM site" -flatlist]
	#set numrel [mysqlsel $db_(handle) "SELECT name FROM $db_(table2) WHERE $db_(name) LIKE '%' AND $db_(time) > $dur"]
	
	#END
 
	#lav output til channel
	putnow "PRIVMSG $chan : \[ \0037PRE DATABASE\003 \] \[ \0038Releases\003: [commify $releases] \] \[ \0034Nukes\003: [commify $nuked] \] \[ \0035ModNukes\003: [commify $modnukes] \] \[ \0033UnNukes\003: [commify $unnuke] ] \[ \00314URLS\003: [commify $siteurl] \] \[ \00314NFO\003: [commify $nfo] \] \[ \00311Last Pre\003: $lastpre \]"
	putnow "PRIVMSG $chan : \[ \0037CSTM PRE DATABASE\003 \] \[ \0038Releases\003: [commify $cstmreleases] \] \[ \00311Last Pre\003: $cstmlastpre \]"

mysqlendquery $mysql_(handle)
 }
#END

#CHANGE SECTION
proc ms:chgsec { nick uhost hand chan arg } {
    global mysql_ db_
if {![channel get [string tolower $chan] db]} { return 0 }
	if {[isop $nick $chan]} {
        if { $arg == "" } {
          putquick "NOTICE $nick : \002Syntax is\002 !chgsec <release> <newsection>"
        } else {
          set splitz [split $arg " "]
          set fee_(release) [lrange $splitz 0 0]
          set fee_(release) [string trimleft $fee_(release) "\\\{"]
          set fee_(release) [string trimright $fee_(release) "\\\}"]
          set fee_(newsec) [lrange $splitz 1 1]
          set fee_(newsec) [string trimleft $fee_(newsec) "\\\{"]
          set fee_(newsec) [string trimright $fee_(newsec) "\\\}"]
                set q "SELECT id FROM pred WHERE name LIKE '$fee_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                        if { $numrel == 0 } {
                            putquick "PRIVMSG $chan : \002$fee_(release)\002 not found in my DB"
                          } else {                        
                            mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET type='$fee_(newsec)' WHERE name='$fee_(release)'"
                                putquick "PRIVMSG $chan :\[ $nick changes section \0034 $fee_(release)\003 \] \00314=>\003\0033 $fee_(newsec)\003 \]"
			}
		}
	}
mysqlendquery $mysql_(handle)
}
#END

#ADDOLD
proc ms:addold { nick uhost hand chan arg } {
global mysql_ db_ prefix_ prechan announce mp3chan nordicchan nordicgroups nordiclangs foreignchan foreignlangs foreigngroups
if {![channel get [string tolower $chan] addold]} { return 0 }
    if { $arg == "" } {
         putserv "NOTICE $nick : Syntax is !oldadd <release> <section> <YYYY-MM-DD> <HH:MM-SS>"
      } else {
            set splitz [split $arg " "]
            set old_(release) [lrange $splitz 0 0]
			set old_(group) [mysqlescape [lindex [split $old_(release) -] end]]
            set old_(release) [string trimleft $old_(release) "\\\{"]
            set old_(release) [string trimright $old_(release) "\\\}"]
            set old_(section) [lrange $splitz 1 1]
            set old_(section) [string trimleft $old_(section) "\\\{"]
            set old_(section) [string trimright $old_(section) "\\\}"]
			set old_(newunixtime) [lrange $splitz 2 2]
			set old_(newunixtime) [string trimleft $old_(newunixtime) "\\{"]
			set old_(newunixtime) [string trimright $old_(newunixtime) "\\}"]
			set old_(newfilecount) [lrange $splitz 3 3]
			set old_(newfilecount) [string trimleft $old_(newfilecount) "\\{"]
			set old_(newfilecount) [string trimright $old_(newfilecount) "\\}"]
			set old_(newfilesize) [lrange $splitz 4 4]
			set old_(newfilesize) [string trimleft $old_(newfilesize) "\\{"]
			set old_(newfilesize) [string trimright $old_(newfilesize) "\\}"]
			set old_(newgenre) [lrange $splitz 5 5]
			set old_(newgenre) [string trimleft $old_(newgenre) "\\{"]
			set old_(newgenre) [string trimright $old_(newgenre) "\\}"]		
			set old_(reason) [lrange $splitz 6 6]
			set old_(reason) [string trimleft $old_(reason) "\\{"]
			set old_(reason) [string trimright $old_(reason) "\\}"]
            set temp1 [split $old_(release) -]
            set group [lindex $temp1 end]
		#if { $old_(reason) != "" } { set status 1 } else { set status 0 } 
                if { ! [string match $old_(reason) "-"] } { set status 1 } else { set status 0 }
			}
			#Timer
			set time [unixtime]
			incr time -$old_(newunixtime)
			set ago [duration $time]
#END
                    set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$old_(release)'"
                    set numrel [mysqlsel $mysql_(handle) $q]
                        if { $numrel != 0 } {
					mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(rlsname)='$old_(release)' , $db_(section)='$old_(section)' , $db_(time)='$old_(newunixtime)' , $db_(files)='$old_(newfilecount)' , $db_(size)='$old_(newfilesize)' , $db_(genre)='$old_(newgenre)' , $db_(reason)='$old_(reason)', $db_(status)='$status'  WHERE $db_(rlsname)='$old_(release)'"
					putquick "PRIVMSG $chan : \[ \00314ADDOLD\003 \] \00314UPDATING THE PREDB\003: \00314Rlsname\003:\0033 $old_(release)\003 / \00314 Section\003: $old_(section) / \00314 Unixtime\003:  $old_(newunixtime) / \00314 Filecount\003: $old_(newfilecount) / \00314 Filesize\003: $old_(newfilesize) / \00314Genre\003: $old_(newgenre) / \00314Nuke\003: $old_(reason) \0037::\003 found in db checking for update"
					putlog "--ADDOLD / UPDATE-- Rlsname: $old_(release) Section: $old_(section) Unixtime: $old_(newunixtime) Filecount: $old_(newfilecount) Filesize: $old_(newfilesize) Genre: $old_(newgenre) Nuke: $old_(reason)" 
						} else {
                    if { $numrel == 0 } {
                        set q "INSERT INTO $mysql_(table) ($db_(rlsname),$db_(section),$db_(group),$db_(time),$db_(files),$db_(size),$db_(genre),$db_(reason),$db_(network),$db_(status)) VALUES ( '$old_(release)' , '$old_(section)' , '$old_(group)' , '$old_(newunixtime)' , '$old_(newfilecount)' , '$old_(newfilesize)' , '$old_(newgenre)' , '$old_(reason)' , 'N/A', '$status' )"
						set nix [mysqlexec $mysql_(handle) $q]
						putquick "PRIVMSG $chan : \[ \00314ADDOLD\003 \] \00314INSERTING INTO PreDB\003: \00314Rlsname\003:\0033 $old_(release)\003 / \00314 Section\003: $old_(section) / \00314 Unixtime\003:  $old_(newunixtime) / \00314 Filecount\003: $old_(newfilecount) / \00314 Filesize\003: $old_(newfilesize) / \00314Genre\003: $old_(newgenre) / \00314Nuke\003: $old_(reason)"
                        set announce "\[ \0039OLDPRE\003 \] \[ [tr:text2color $old_(section)] \] - $old_(release) \0034PRED On\003 [clock format $old_(newunixtime) -format %d-%m-%Y] [clock format $old_(newunixtime) -format %H:%M:%S]"
						putlog "--ADDOLD / INSERT INTO-- $old_(section) -- $old_(release) $old_(group)"
#Filter
if {[regexp (?i)(^($nordicgroups)$) $old_(group)]} {
        putnow "PRIVMSG $nordicchan :$announce"
} elseif {[regexp (?i)($nordiclangs) $old_(release)]} {
            putnow "PRIVMSG $nordicchan :$announce"
} elseif {[regexp (?i)(^($foreigngroups)$) $old_(group)]} {
        putnow "PRIVMSG $foreignchan :$announce"
} elseif {[regexp (?i)($foreignlangs) $old_(release)]} {
        putnow "PRIVMSG $foreignchan :$announce"
        } else {
        if {$old_(section) == "MP3" || $old_(section) == "MP3-INTERNAL" || $old_(section) == "FLAC" || $old_(section) == "WMA" || $old_(section) == "MVID" || $old_(section) == "MDVDR" || $old_(section) == "0DAY" || $old_(section) == "APPS" || $old_(section) == "PDA"} {
                putnow "PRIVMSG $mp3chan :$announce"
        } else {
                putnow "PRIVMSG $prechan :$announce"
                                }
                        }
                }
        }
mysqlendquery $mysql_(handle)
mysqlendquery $mysql_(handle)
mysqlendquery $mysql_(handle)
}
#END

#URL
proc ms:url { nick uhost hand chan arg } {
	global mysql_ db_ url_ addprechan spamchan urlvar urlturn
  if {![channel get [string tolower $chan] url]} { return 0 }
        if { $arg == "" } {
          putnow "NOTICE $nick : \002Syntax is\002 !addurl <release> <URL>"
        } else {
          if {[lsearch $urlvar [lindex $arg 0]] == "-1"} {
          set urlvar [lreplace $urlvar $urlturn $urlturn [lindex $arg 0]]
          incr urlturn
          if {$urlturn >= 29} {set urlturn 0}
          set splitz [split $arg " "]
          set url_(release) [lrange $splitz 0 0]
          set url_(release) [string trimleft $url_(release) "\\\{"]
          set url_(release) [string trimright $url_(release) "\\\}"]
		  
		  set url_(siteurl) [lrange $splitz 1 1]
          set url_(siteurl) [string trimleft $url_(siteurl) "\\{"]
		  set url_(siteurl) [string trimright $url_(siteurl) "\\}"]
                set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$url_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                        if { $numrel == 0 } {
                          } else {
                            set nix [mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(siteurl)='$url_(siteurl)' WHERE $db_(rlsname)='$url_(release)'"]
putquick "PRIVMSG $chan : \[ \00314URL\003 \] \00314UPDATING PreDB\003: \00314Rlsname\003:\0033 $url_(release)\003 / \00314WITH URL\003: $url_(siteurl)" 
putlog "--URL / UPDATE-- $url_(release) WITH $url_(siteurl)"
      }
    }
  }
mysqlendquery $mysql_(handle)
mysqlendquery $mysql_(handle)
} 
#END

#ADDMP3INFO
proc ms:addmp3info { nick uhost hand chan arg } {
	global mysql_ db_ mp3_ addprechan spamchan mp3var mp3turn
  if {![channel get [string tolower $chan] mp3]} { return 0 }
        if { $arg == "" } {
          putnow "NOTICE $nick : \002Syntax is\002 !addmp3info <release> <Genre> <Year> <Hertz> <channel> <bitrate> <Mode>"
        } else {
          if {[lsearch $mp3var [lindex $arg 0]] == "-1"} {
          set mp3var [lreplace $mp3var $mp3turn $mp3turn [lindex $arg 0]]
          incr urlturn
          if {$urlturn >= 29} {set mp3turn 0}
          set splitz [split $arg " "]
          set mp3_(release) [lrange $splitz 0 0]
          set mp3_(release) [string trimleft $mp3_(release) "\\\{"]
          set mp3_(release) [string trimright $mp3_(release) "\\\}"]
		  set mp3_(genre) [lrange $splitz 1 1]
          set mp3_(genre) [string trimleft $mp3_(genre) "\\\{"]
          set mp3_(genre) [string trimright $mp3_(genre) "\\\}"]
		  set mp3_(year) [lrange $splitz 2 2]
          set mp3_(year) [string trimleft $mp3_(year) "\\{"]
		  set mp3_(year) [string trimright $mp3_(year) "\\}"]
		  set mp3_(hertz) [lrange $splitz 3 3]
          set mp3_(hertz) [string trimleft $mp3_(hertz) "\\\{"]
          set mp3_(hertz) [string trimright $mp3_(hertz) "\\\}"]
		  set mp3_(channel) [lrange $splitz 4 4]
          set mp3_(channel) [string trimleft $mp3_(channel) "\\\{"]
          set mp3_(channel) [string trimright $mp3_(channel) "\\\}"]
		  set mp3_(bitrate) [lrange $splitz 5 5]
          set mp3_(bitrate) [string trimleft $mp3_(bitrate) "\\\{"]
          set mp3_(bitrate) [string trimright $mp3_(bitrate) "\\\}"]
		  set mp3_(mode) [lrange $splitz 6 6]
          set mp3_(mode) [string trimleft $mp3_(mode) "\\\{"]
          set mp3_(mode) [string trimright $mp3_(mode) "\\\}"]
		  set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$mp3_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                        if { $numrel == 0 } {
                          } else {
                            set nix [mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(genre)='$mp3_(genre)' , $db_(year)='$mp3_(year)' , $db_(hertz)='$mp3_(hertz)' , $db_(channel)='$mp3_(channel)' , $db_(bitrate)='$mp3_(bitrate)' , $db_(mode)='$mp3_(mode)' WHERE $db_(rlsname)='$mp3_(release)'"]
putquick "PRIVMSG $chan : \[ \00314MP3\003 \] \00314UPDATING PreDB\003: \00314Rlsname\003:\0033 $mp3_(release)\003 \00314WITH\003: \00314Genre\003: $mp3_(genre) / \00314Year\003: $mp3_(year) / \00314Hertz\003: $mp3_(hertz) / \00314Channels\003: $mp3_(channel) \00314Bitrate\003: $mp3_(bitrate) / \00314Mode\003: $mp3_(mode)" 
putlog "--MP3 / UPDATE-- $mp3_(release) WITH $mp3_(year)"
      }
    }
  }
mysqlendquery $mysql_(handle)
} 
#END

#ADDVIDEOINFO
proc ms:addvideoinfo { nick uhost hand chan arg } {
	global mysql_ db_ videoaudio_ addprechan spamchan videoaudiovar videoaudioturn
  if {![channel get [string tolower $chan] videoaudio]} { return 0 }
        if { $arg == "" } {
          putnow "NOTICE $nick : \002Syntax is\002 !addvideoinfo <codec> <fps> <res> <audiocodec> <audiokpbs> <audiorate> <audiochans>"
        } else {
          if {[lsearch $videoaudiovar [lindex $arg 0]] == "-1"} {
          set videoaudiovar [lreplace $videoaudiovar $videoaudioturn $videoaudioturn [lindex $arg 0]]
          incr videoaudioturn
          if {$videoaudioturn >= 29} {set videoaudioturn 0}
          set splitz [split $arg " "]
          set videoaudioturn_(release) [lrange $splitz 0 0]
          set videoaudioturn_(release) [string trimleft $videoaudioturn_(release) "\\\{"]
          set videoaudioturn_(release) [string trimright $videoaudioturn_(release) "\\\}"]
		  
		  set videoaudioturn_(videocodec) [lrange $splitz 1 1]
          set videoaudioturn_(videocodec) [string trimleft $videoaudioturn_(videocodec) "\\\{"]
          set videoaudioturn_(videocodec) [string trimright $videoaudioturn_(videocodec) "\\\}"]
		  
		  set videoaudioturn_(videofps) [lrange $splitz 2 2]
          set videoaudioturn_(videofps) [string trimleft $videoaudioturn_(videofps) "\\{"]
		  set videoaudioturn_(videofps) [string trimright $videoaudioturn_(videofps) "\\}"]
		  
		  set videoaudioturn_(videores) [lrange $splitz 3 3]
          set videoaudioturn_(videores) [string trimleft $videoaudioturn_(videores) "\\\{"]
          set videoaudioturn_(videores) [string trimright $videoaudioturn_(videores) "\\\}"]
		  
		  set videoaudioturn_(videoaspect) [lrange $splitz 4 4]
          set videoaudioturn_(videoaspect) [string trimleft $videoaudioturn_(videoaspect) "\\\{"]
          set videoaudioturn_(videoaspect) [string trimright $videoaudioturn_(videoaspect) "\\\}"]
		  
		  set videoaudioturn_(audiocodec) [lrange $splitz 5 5]
          set videoaudioturn_(audiocodec) [string trimleft $videoaudioturn_(audiocodec) "\\\{"]
          set videoaudioturn_(audiocodec) [string trimright $videoaudioturn_(audiocodec) "\\\}"]
		  
		  set videoaudioturn_(audiokbps) [lrange $splitz 6 6]
          set videoaudioturn_(audiokbps) [string trimleft $videoaudioturn_(audiokbps) "\\\{"]
          set videoaudioturn_(audiokbps) [string trimright $videoaudioturn_(audiokbps) "\\\}"]
		  
		  set videoaudioturn_(audiorate) [lrange $splitz 7 7]
          set videoaudioturn_(audiorate) [string trimleft $videoaudioturn_(audiorate) "\\\{"]
          set videoaudioturn_(audiorate) [string trimright $videoaudioturn_(audiorate) "\\\}"]
		  
		  set videoaudioturn_(audiochans) [lrange $splitz 8 8]
          set videoaudioturn_(audiochans) [string trimleft $videoaudioturn_(audiochans) "\\\{"]
          set videoaudioturn_(audiochans) [string trimright $videoaudioturn_(audiochans) "\\\}"]
		  
		  set q "SELECT $db_(id) FROM $mysql_(table) WHERE $db_(rlsname) LIKE '$videoaudioturn_(release)'"
                set numrel [mysqlsel $mysql_(handle) $q]
                        if { $numrel == 0 } {
                          } else {
                            set nix [mysqlexec $mysql_(handle) "UPDATE $mysql_(table) SET $db_(videocodec)='$videoaudioturn_(videocodec)' , $db_(videofps)='$videoaudioturn_(videofps)' , $db_(videores)='$videoaudioturn_(videores)' , $db_(videoaspect)='$videoaudioturn_(videoaspect)' , $db_(audiocodec)='$videoaudioturn_(audiocodec)' , $db_(audiokbps)='$videoaudioturn_(audiokbps)' , $db_(audiorate)='$videoaudioturn_(audiorate)' , $db_(audiochans)='$videoaudioturn_(audiochans)' WHERE $db_(rlsname)='$videoaudioturn_(release)'"]
putquick "PRIVMSG $chan : \[ \00314VIDEO INFO\003 \] \00314UPDATING PreDB\003: \00314Rlsname\003:\0033 $videoaudioturn_(release)\003 \00314WITH\003: \00314Codec\003: $videoaudioturn_(videocodec) / \00314FPS\003: $videoaudioturn_(videofps) / \00314Aspect\003: $videoaudioturn_(videoaspect) / \00314Audio Codec\003: $videoaudioturn_(audiocodec) / \00314Audio Kpbs\003: $videoaudioturn_(audiokbps) / \00314Audio Rate\003: $videoaudioturn_(audiorate) / \00314Audio Chans\003: $videoaudioturn_(audiochans)" 
putlog "--ADDVIDEOINFO / UPDATE-- $videoaudioturn_(release)"
      }
    }
  }
mysqlendquery $mysql_(handle)
} 
#END

#PREHELP
proc helpme {nick uhost hand chan args} {

      putnow "PRIVMSG $chan :\00312\[Sending help to $nick in Priv Msg\]\003"
      putnow "PRIVMSG $nick : :: PREHELP ::"
      putnow "PRIVMSG $nick : .pre/!pre <string>: Wildcard search : %-PART.OF.THE.RLSNAME - %-GROUPNAME. To search for one specific result."
      putnow "PRIVMSG $nick : .dupe/!dupe <string>: Wildcard search : %-PART.OF.THE.RLSNAME - %-GROUPNAME. Last 10 will be PM'd"
      putnow "PRIVMSG $nick : .group/!group / !grp <string>: Shows group stats of the specified group."
      putnow "PRIVMSG $nick : .getnfo/!getnfo <nfo filename>: Download the nfo file."
      putnow "PRIVMSG $nick : .lastnuke/!lastnuke <group>: Shows last nuked release (Groupname is optional)."
      putnow "PRIVMSG $nick : .lastunnuke/!lastunnuke <group>: Shows last unnuked release (Groupname is optional)."
      putnow "PRIVMSG $nick : .last30/!last30: Shows the last 24 hours danish pres."
      putnow "PRIVMSG $nick : .last60/!last60: Shows the last 48 hours danish pres."
      putnow "PRIVMSG $nick : .groupnukes/!groupnukes / !groupnuke <string>: Shows group nukes of the specified group."
      putnow "PRIVMSG $nick : .groupunnukes/!groupunnukes / !groupunnuke <string>: Shows group unnukes of the specified group."
      putnow "PRIVMSG $nick : .glast10/!glast10 <group> : Shows last 10 release added by group to the DB"
      putnow "PRIVMSG $nick : .section/!section <string> : Shows last 10 releases in the selected section"
      putnow "PRIVMSG $nick : .db/!db : Shows statistics of the DataBase."
      putnow "PRIVMSG $nick : If you like this bot or having questions about it find IronHideDK on irc ;)"
 }
#END
proc timediff {t} {

        set years [expr $t/31558150]
        set t [expr $t-[expr $years*31558150]]
        set months [expr $t/2629743]
        set t [expr $t-[expr $months*2629743]]
        set days [expr $t/86400]
        set t [expr $t-[expr $days*86400]]
        set hours [expr $t/3600]
        set t [expr $t-[expr $hours*3600]]
        set minutes [expr $t/60]
        set seconds [expr $t-[expr $minutes*60]]
	if { $days > 0 } { set days "${days}d " } else { set days "" }
	if { $months > 0 } { set months "${months}m " } else { set months "" }
	if { $years > 0 } { set years "${years}y " } else { set years "" }
		
        return "${years}${months}${days}${hours}h ${minutes}m ${seconds}s"

}


######################################
### Timer for the mysql connection ###
######################################
if {[timerexists pre:dbconnection] !=""} { killtimer $dbconnect(dbtimer) }

set dbconnect(dbtimer) [timer 1 pre:dbconnection]

proc pre:dbconnection {} {
	global mysql_ dbconnect
	if {[catch  {mysqlping $mysql_(handle)}] != 0} { 
         set mysql_(handle) [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(database)]
	}
	if {[set var [timerexists pre:dbconnection]] !="" } { killtimer $var }
	set dbconnect(dbtimer) [timer 1 pre:dbconnection]
}
#if {[file exists /usr/lib/mysqltcl-3.02/libmysqltcl3.02.so]} {
#    load /usr/lib/mysqltcl-3.02/libmysqltcl3.02.so
#}
####################################END OF SCRIPT###############################
putlog "PRE v2 successfully loaded, by scriptz-team.info"

bind pub -|- !xrehash xRehash 

proc xRehash { nick uhost handle chan arg } {
    rehash
    putserv "privmsg $chan : rehash"
}
