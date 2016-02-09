
set whichprebot "STRB"

set annprechan "#pre"

set bopen "\002\[\002"
set bclose "\002\]\002"
set bdiv "\002\/\002"

bind bot - ADDPRE getprerls
bind bot - NUKE nukerls
bind bot - UNNUKE unnukerls
bind bot - MODNUKE modnukerls
bind bot - DELPRE delprerls
bind bot - UNDELPRE undelprerls

# Set your prefixes for announce / search.
set nuke_prefix "\0034NUKE\003"
set modnuke_prefix "\0034MODNUKE\003"
set unnuke_prefix "\0033UNNUKE\003"
set undelete_prefix "\00310UNDELPRE\003"
set delete_prefix "\00310DELPRE\003"

proc isy:highlight_group {rlsname} {

	set grp [string trim [lindex [split $rlsname "-"] end]]
	
	return [regsub -all -- $grp $rlsname "\002\\0\002"]
	
}


proc getprerls {bot com args} {
	global annprechan whichprebot bopen bclose 
	
	if { $bot == $whichprebot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set sec [lindex [lindex $args 0] 1]
		set section [isy:sectioncolor $sec]
		set rls [isy:highlight_group $rlsname]
		
		putquick "PRIVMSG $annprechan :$bopen$section$bclose $rls"
	
	}
}

proc nukerls {bot com args} {
	global annprechan nuke_prefix whichprebot bopen bclose bdiv 
	
	if { $bot == $whichprebot } {
	
	set rlsname [lindex [lindex $args 0] 0]
	set rls [isy:highlight_group $rlsname]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putquick "PRIVMSG $annprechan :$bopen$nuke_prefix$bclose $rls $bopen\00314$reason\003$bdiv\00314$nukenet\003$bclose"

	}
}

proc unnukerls {bot com args} {
	global annprechan unnuke_prefix whichprebot bopen bclose bdiv 
	
	if { $bot == $whichprebot } {
	
	set rlsname [lindex [lindex $args 0] 0]
	set rls [isy:highlight_group $rlsname]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putquick "PRIVMSG $annprechan :$bopen$unnuke_prefix$bclose $rls $bopen\00314$reason\003$bdiv\00314$nukenet\003$bclose"

	}
}

proc modnukerls {bot com args} {
	global annprechan modnuke_prefix whichprebot bopen bclose bdiv 
	
	if { $bot == $whichprebot } {
	
	set rlsname [lindex [lindex $args 0] 0]
	set rls [isy:highlight_group $rlsname]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putquick "PRIVMSG $annprechan :$bopen$modnuke_prefix$bclose $rls $bopen\00314$reason\003$bdiv\00314$nukenet\003$bclose"

	}
}

proc delprerls {bot com args} {
	global annprechan delete_prefix whichprebot bopen bclose bdiv 
	
	if { $bot == $whichprebot } {
	
	set rlsname [lindex [lindex $args 0] 0]
	set rls [isy:highlight_group $rlsname]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putquick "PRIVMSG $annprechan :$bopen$delete_prefix$bclose $rls $bopen\00314$reason\003$bdiv\00314$nukenet\003$bclose"
	
	}
}

proc undelprerls {bot com args} {
	global annprechan undelete_prefix whichprebot bopen bclose bdiv 
	
	if { $bot == $whichprebot } {
	
	set rlsname [lindex [lindex $args 0] 0]
	set rls [isy:highlight_group $rlsname]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putquick "PRIVMSG $annprechan :$bopen$undelete_prefix$bclose $rls $bopen\00314$reason\003$bdiv\00314$nukenet\003$bclose"

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

putlog "xxx Announce --> PRE Script v1.08 by Islander -- Loaded Succesfully!"