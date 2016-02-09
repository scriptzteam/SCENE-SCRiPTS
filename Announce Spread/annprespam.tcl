
set whichspambot "STRB"

set addspamchan "#pre.spam"

set spamglobalann "0"

set spamann "1"

bind bot - ADDNFO nfoprerls
bind bot - ADDSFV sfvprerls
bind bot - ADDM3U m3uprerls

set nfo_prefix "\0033\[NFO\]\003"
set sfv_prefix "\0037\[SFV\]\003"
set m3u_prefix "\00310\[M3U\]\003"


proc nfoprerls {bot com args} {
	global addspamchan nfo_prefix whichspambot spamglobalann spamann  
	if { $bot == $whichspambot } {	
		set rlsname [lindex [lindex $args 0] 0]
		set size [lindex [lindex $args 0] 1]
		
		if { $spamann == "1" } {
			set sized [filesize $size]
			putquick "PRIVMSG $addspamchan :$nfo_prefix $rlsname \[URL\] http://example.com/details.php?type=nfo&rls=$rlsname \00315\[\003\0035Size\003: \002$sized\002\00315\]\003"
		}
	
	}
}

proc sfvprerls {bot com args} {
	global addspamchan sfv_prefix whichspambot spamglobalann spamann  
	if { $bot == $whichspambot } {	
		set rlsname [lindex [lindex $args 0] 0]
		set size [lindex [lindex $args 0] 1]
		
		if { $spamann == "1" } {
			set sized [filesize $size]
			putquick "PRIVMSG $addspamchan :$sfv_prefix $rlsname \[URL\] http://example.com/details.php?type=sfv&rls=$rlsname \00315\[\003\0035Size\003: \002$sized\002\00315\]\003"
		}
	
	}
}

proc m3uprerls {bot com args} {
	global addspamchan m3u_prefix whichspambot spamglobalann spamann  
	if { $bot == $whichspambot } {	
		set rlsname [lindex [lindex $args 0] 0]
		set size [lindex [lindex $args 0] 1]
		
		if { $spamann == "1" } {
			set sized [filesize $size]
			putquick "PRIVMSG $addspamchan :$m3u_prefix $rlsname \[URL\] http://example.com/details.php?type=m3u&rls=$rlsname \00315\[\003\0035Size\003: \002$sized\002\00315\]\003"
		}
	
	}
}

proc filesize { zzzsize } {
	set size [lindex $zzzsize 0]
	
	set sized "0 kB"
	if {[expr $size / 1024] >= 1} {set sized "[string range "[expr $size / 1024.0]" 0 [expr [string length "[expr $size / 1024]"]+ 2] ] KB"};
	if {[expr $size / 1048576] >= 1} {set sized "[string range "[expr $size / 1048576.0]" 0 [expr [string length "[expr $size / 1048576]"]+ 2] ] MB"};
	if {[expr $size / 1073741824] >= 1} {set sized "[string range "[expr $size / 1073741824.0]" 0 [expr [string length "[expr $size / 1073741824]"]+ 2] ] GB"};
    return $sized
}

putlog "xxx Announce --> NFO|SFV|M3U Script v1.22 by Islander -- Loaded Succesfully!"