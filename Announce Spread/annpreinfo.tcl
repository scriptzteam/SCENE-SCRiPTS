
set whichinfobot "STRB"

set anninfochan "#pre.info"

set bopen "\002\[\002"
set bclose "\002\]\002"
set bdiv "\002\/\002"

bind bot - PREINFO getinforls
bind bot - GENRE getgenrerls

bind bot - ADDVIDEOINFO videoprerls
bind bot - ADDMP3INFO mp3prerls
bind bot - ADDIMDB getimdbrls
bind bot - ADDURL geturlrls

# Set your prefixes for announce / search.
set video_prefix "\0032ViDE0 iNF0\003"
set mp3_prefix "\0039MP3 iNF0\003"
set track_prefix "\00313tRACK iNF0\003"
set info_prefix "\0037iNF0\003"
set genre_prefix "\0035GENRE\003"
set imdb_prefix "\0034iMDB\003"
set url_prefix "\00314URL\003"

proc isy:highlight_group {rlsname} {

	set grp [string trim [lindex [split $rlsname "-"] end]]
	
	return [regsub -all -- $grp $rlsname "\002\\0\002"]
	
}

proc getinforls {bot com args} {
	global anninfochan info_prefix whichinfobot bopen bclose bdiv 
	
	if { $bot == $whichinfobot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set rls [isy:highlight_group $rlsname]
		set fles [lindex [lindex $args 0] 1]
		set size [lindex [lindex $args 0] 2]
			
		putquick "PRIVMSG $anninfochan :$bopen$info_prefix$bclose $rls $bopen\00314 $size\003MB $bdiv\00314 $fles\003Files $bclose"
		
	}
}

proc getgenrerls {bot com args} {
	global anninfochan genre_prefix whichinfobot bopen bclose 
	
	if { $bot == $whichinfobot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set rls [isy:highlight_group $rlsname]
		set gnre [lindex [lindex $args 0] 1]
			
		putquick "PRIVMSG $anninfochan :$bopen$genre_prefix$bclose $rls $bopen\00314$gnre\003$bclose"
		
	}
}

proc getimdbrls {bot com args} {
	global anninfochan imdb_prefix whichinfobot bopen bclose
	
	if { $bot == $whichinfobot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set rls [isy:highlight_group $rlsname]
		set imdbid [lindex [lindex $args 0] 1]
		set rating [lindex [lindex $args 0] 2]
		set votes [lindex [lindex $args 0] 3]
		
		putquick "PRIVMSG $anninfochan :$bopen$imdb_prefix$bclose $rls $bopen\00314http:\/\/www.imdb.com\/title\/$imdbid\/\003$bclose $bopenRating: \00314$rating/10\003$bclose $bopenVotes: \00314$votes\003$bclose"
	
	}
}

proc geturlrls {bot com args} {
	global anninfochan url_prefix whichinfobot bopen bclose
	
	if { $bot == $whichinfobot } {	
	
		set rlsname [lindex [lindex $args 0] 0]
		set rls [isy:highlight_group $rlsname]
		set url [lindex [lindex $args 0] 1]
			
		putquick "PRIVMSG $anninfochan :$bopen$url_prefix$bclose $rls $bopen\00314$url\003$bclose"
	
	}
}

proc videoprerls {bot com args} {
	global anninfochan video_prefix whichinfobot bopen bclose bdiv
	
	if { $bot == $whichinfobot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set rls [isy:highlight_group $rlsname]
		set vidcodec [lindex [lindex $args 0] 1]
		set frmes [lindex [lindex $args 0] 2]
		set resl [lindex [lindex $args 0] 3]
		set resnfrmes [lindex [lindex $args 0] 4]
		set audcodec [lindex [lindex $args 0] 5]
		set bitrate [lindex [lindex $args 0] 6]
		set hertz [lindex [lindex $args 0] 7]
		set channel [lindex [lindex $args 0] 8]


		putquick "PRIVMSG $anninfochan :$bopen$video_prefix$bclose $rls $bopen\00314ViDE0-C0DEC:\003 $vidcodec $bdiv \00314Frames/Sec:\003 $frmes $bdiv \00314Resolution:\003 $resl $bdiv \00314ResFrames:\003 $resnfrmes$bclose $bopen\00314AUDi0-C0DEC:\003 $audcodec $bdiv \00314Bitrate:\003 $bitrate $bdiv \00314Hertz:\003 $hertz $bdiv \00314Channel:\003 $channel$bclose"
		
	}
}

proc mp3prerls {bot com args} {
	global anninfochan mp3_prefix whichinfobot bopen bclose bdiv
	
	if { $bot == $whichinfobot } {
	
		set rlsname [lindex [lindex $args 0] 0]
		set rls [isy:highlight_group $rlsname]
		set genre [lindex [lindex $args 0] 1]
		set year [lindex [lindex $args 0] 2]
		set hertz [lindex [lindex $args 0] 3]
		set type [lindex [lindex $args 0] 4]
		set bitrate [lindex [lindex $args 0] 5]
		set bittype [lindex [lindex $args 0] 6]

		putquick "PRIVMSG $anninfochan :$bopen$mp3_prefix$bclose $rls $bopen\00314Genre:\003 $genre $bdiv \00314Year:\003 $year $bdiv \00314Hertz:\003 $hertz $bdiv \00314Type:\003 $type $bdiv \00314Bitrate:\003 $bitrate $bdiv \00314Format:\003 $bittype$bclose"
		
	}
}

putlog "xxx Announce --> iNF0GN & ViDMP3iMDB Script v1.22 by Islander -- Loaded Succesfully!"