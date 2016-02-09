set botlisten_(port) "420"
set botlisten_(password) "xxx"

listen $botlisten_(port) script botlisten

proc botlisten {idx} {
	control $idx botlisten2
}

proc botlisten2 {idx args} {
	global botlisten_
	
	set args [join $args]
	set pass [lindex $args 0]
	
	if { $botlisten_(password) == $pass } {
	
		set annme [string trim [lrange $args 1 end]]
		
		putallbots "$annme"

	}
	
}

bind bot - ADDPRE getprerls
bind bot - NUKE nukerls
bind bot - UNNUKE unnukerls
bind bot - MODNUKE modnukerls
bind bot - DELPRE delprerls
bind bot - UNDELPRE undelprerls

bind bot - PREINFO getinforls
bind bot - GENRE getgenrerls

bind bot - ADDVIDEOINFO videoprerls
bind bot - ADDMP3INFO mp3prerls
bind bot - ADDIMDB getimdbrls
bind bot - ADDURL geturlrls

bind bot - ADDNFO nfoprerls
bind bot - ADDSFV sfvprerls
bind bot - ADDM3U m3uprerls
bind bot - ADDJPG jpgprerls
bind bot - ADDDIZ dizprerls

bind bot - PREAFFIL spreadpreaffil

proc spreadpreaffil {bot com args} {
	
	set rlsname [lindex [lindex $args 0] 0]
	set section [lindex [lindex $args 0] 1]
	set files [lindex [lindex $args 0] 2]
	set size [lindex [lindex $args 0] 3]
	
	set grp [string trim [lindex [split $rlsname "-"] end]]
	
	putallbots "PREAFFIL $rlsname $section $files $size"
	
}

proc getprerls {bot com args} {
	
	set rlsname [lindex [lindex $args 0] 0]
	set section [lindex [lindex $args 0] 1]
	set grp [lindex [lindex $args 0] 2]
	
	putallbots "ADDPRE $rlsname $section $grp"
	
}

proc nukerls {bot com args} {
	
	set rlsname [lindex [lindex $args 0] 0]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putallbots "NUKE $rlsname $reason $nukenet"

}

proc unnukerls {bot com args} {
	
	set rlsname [lindex [lindex $args 0] 0]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putallbots "UNNUKE $rlsname $reason $nukenet"
	
}

proc modnukerls {bot com args} {
	
	set rlsname [lindex [lindex $args 0] 0]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putallbots "MODNUKE $rlsname $reason $nukenet"
	
}

proc delprerls {bot com args} {
	
	set rlsname [lindex [lindex $args 0] 0]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putallbots "DELPRE $rlsname $reason $nukenet"
	
}

proc undelprerls {bot com args} {
	
	set rlsname [lindex [lindex $args 0] 0]
 	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

    putallbots "UNDELPRE $rlsname $reason $nukenet"
	
}

proc getinforls {bot com args} {
	
	set args [lindex [lindex $args 0]]

    putallbots "PREINFO $args"
	
}

proc getgenrerls {bot com args} {
	
	set args [lindex [lindex $args 0]]

    putallbots "GENRE $args"
	
}

proc getimdbrls {bot com args} {
	
	set args [lindex [lindex $args 0]]

    putallbots "ADDIMDB $args"
	
}

proc geturlrls {bot com args} {
	
	set args [lindex [lindex $args 0]]

    putallbots "ADDURL $args"
	
}

proc videoprerls {bot com args} {
	
	set args [lindex [lindex $args 0]]

    putallbots "ADDVIDEOINFO $args"
	
}

proc mp3prerls {bot com args} {
	
	set args [lindex [lindex $args 0]]

    putallbots "ADDMP3INFO $args"
	
}

proc nfoprerls {bot com args} {
	
	set args [lindex [lindex $args 0]]

    putallbots "ADDNFO $args"
	
}

proc sfvprerls {bot com args} {
	
	set args [lindex [lindex $args 0]]

    putallbots "ADDSFV $args"
	
}

proc m3uprerls {bot com args} {
	
	set args [lindex [lindex $args 0]]

    putallbots "ADDM3U $args"
	
}


proc jpgprerls {bot com args} {
	
	set args [lindex [lindex $args 0]]

    putallbots "ADDJPG $args"
	
}

proc dizprerls {bot com args} {
	
	set args [lindex [lindex $args 0]]

    putallbots "ADDDIZ $args"
	
}

putlog "STRB SPR3AD --> PRE ||| iNF0GN & ViDMP3iMDB ||| NFO|SFV|M3U|JPG Script v1.44 by Islander -- Loaded Succesfully!"