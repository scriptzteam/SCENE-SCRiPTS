# Get it at http://www.xdobry.de/mysqltcl/ or your distributions repository
load /usr/lib/tcltk/mysqltcl-3.05/libmysqltcl3.05.so;


if {![info exists mysql(host)]}		{ set	mysql(host)		"127.0.0.1" }
if {![info exists mysql(user)]}		{ set	mysql(user)		"root" }
if {![info exists mysql(pass)]}		{ set	mysql(pass)		"T?35y#07q2" }
if {![info exists mysql(db)]}		{ set	mysql(db)		"predb" }
if {![info exists mysql(port)]}		{ set	mysql(port)		"3306" }

if {![info exists nfo(path)]}		{ set	nfo(path)		"/var/www/nfo/" }
if {![info exists nfo(host)]}		{ set	nfo(host)		"http://predbdupenfo.doesntexist.com/nfo/" }
if {![info exists cover(path)]}		{ set	cover(path)		"/var/www/cover/" }
if {![info exists cover(host)]}		{ set	cover(host)		"http://predbdupenfo.doesntexist.com/cover/" }
if {![info exists jpg(path)]}		{ set	jpg(path)		"/var/www/jpg/" }
if {![info exists jpg(host)]}		{ set	jpg(host)		"http://predbdupenfo.doesntexist.com/jpg/" }
if {![info exists sfv(path)]}		{ set	sfv(path)		"/var/www/sfv/" }
if {![info exists sfv(host)]}		{ set	sfv(host)		"http://predbdupenfo.doesntexist.com/sfv/" }
if {![info exists m3u(path)]}		{ set	m3u(path)		"/var/www/m3u/" }
if {![info exists m3u(host)]}		{ set	m3u(host)		"http://predbdupenfo.doesntexist.com/m3u/" }

proc getdb {} {
	global mysql
	if {[catch {set handle [mysql::connect -host $mysql(host) -user $mysql(user) -password $mysql(pass) -port $mysql(port) -db $mysql(db)]} errorMsg]} {
		putlog "\[QUERY-ERROR\] Unable to connect to MySQL server: $errorMsg"
		return
	}
	return $handle
}


bind pub -|- !addid3c		addmp3info
bind pub -|- !addmp3info    addmp3info
bind pub -|- !oldmp3info	addmp3info
bind pub -|- !addvideoinfo	addvideoinfo
bind pub -|- !oldvideoinfo	addvideoinfo
bind pub -|- !oldid3c		addmp3info
bind pub -|- !addurl		addurl
bind pub -|- !oldurl		addurl
#bind pub -|- !shadowdb	    shadowdb
bind pub -|- !nfo			nfo
bind pub -|- !sfv    		sfv
bind pub -|- !m3u			m3u
bind pub -|- !url			url
bind pub -|- !jpg			jpg
#bind pub -|- !mp3info		mp3info
#bind pub -|- !videoinfo		videoinfo

 
 


proc addmp3info {nick host hand chan arg} {
	if {[llength $arg] != 7 || [lindex $arg 6] == ""} { return }
	
	foreach {release genre year freq chans bitrate type} $arg {}
	
	if {$genre == "{}" || $genre == ""} { return }
	if {$year == "{}" || $year == "" || ![string is integer $year]} { return }
	if {$freq == "{}" || $freq == "" || ![string is integer $freq]} { return }
	if {$chans == "{}" || $chans == ""} { return }
	if {$bitrate == "{}" || $bitrate == "" || ![string is integer $bitrate]} { return }
	if {$type == "{}" || $type == ""} { return }
	
	set	info	[string trim "$genre $year $freq $chans $bitrate $type"]
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	if {[::mysql::sel $handle "SELECT COUNT(*) FROM `mp3info` WHERE `rel_name` = '[::mysql::escape $handle $release]'" -flatlist]} {
		::mysql::close $handle
		return
	}
	
	if {[catch {::mysql::exec $handle [format "INSERT INTO `mp3info` ( `rel_name` , `rel_info` ) VALUES ('%s', '%s')" [::mysql::escape $handle $release] [::mysql::escape $handle $info]]} error]} {}
	
	#putnow "PRIVMSG #mp3info :09ADD-MP3INFO 07$release 08$genre $year $freq $chans $bitrate $type 11Added by:$nick"
	::mysql::close $handle
}

proc addvideoinfo {nick host hand chan arg} {
	if {[llength $arg] != 9} { return }
	
	foreach {release codec framerate resolution ar acodec abitrate asampling achannel} $arg {}
	
	if {$codec == "{}" || $codec == ""} { return }
	if {$framerate == "{}" || $framerate == "" || ![string is double $framerate]} { return }
	if {$resolution == "{}" || $resolution == ""} { return }
	if {$ar == "{}" || $ar == "" || ![string is double $ar]} { return }
	if {$acodec == "{}" || $acodec == ""} { return }
	if {$abitrate == "{}" || $abitrate == ""} { return }
	if {$asampling == "{}" || $asampling == ""} { return }
	if {$achannel == "{}" || $achannel == ""} { return }
	
	set	info	[string trim "$codec $framerate $resolution $ar $acodec $abitrate $asampling $achannel"]
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	if {[::mysql::sel $handle "SELECT COUNT(*) FROM `videoinfo` WHERE `rel_name` = '[::mysql::escape $handle $release]'" -flatlist]} {
		::mysql::close $handle
		return
	}
	
	if {[catch {::mysql::exec $handle [format "INSERT INTO `videoinfo` ( `rel_name` , `rel_info` ) VALUES ('%s', '%s')" [::mysql::escape $handle $release] [::mysql::escape $handle $info]]} error]} {}
	#putnow "PRIVMSG #videoinfo :09ADD-VIDEOINFO 07$release 08$codec $framerate $resolution $ar $acodec $abitrate $asampling $achannel 11Added by:$nick"
	::mysql::close $handle
}

proc addurl {nick host hand chan arg} {
	if {[llength $arg] != 2} { return }
	
	foreach {release url} $arg {}
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	if {[::mysql::sel $handle "SELECT COUNT(*) FROM `url` WHERE `rel_name` = '[::mysql::escape $handle $release]' AND `rel_url` = '[::mysql::escape $handle $url]'" -flatlist]} {
		::mysql::close $handle
		return
	}
	
	if {[catch {::mysql::exec $handle [format "INSERT INTO `url` ( `rel_name` , `rel_url` ) VALUES ('%s', '%s')" [::mysql::escape $handle $release] [::mysql::escape $handle $url]]} error]} {}
	#putnow "PRIVMSG #mp3info :09ADD-URL 07$release 08$url 11Added by:$nick"
	::mysql::close $handle
}



proc getvideoinfo {nick host hand chan arg} {
	if {[llength $arg] != 1} { return }
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	set	query	[::mysql::sel $handle "SELECT `rel_name`, `rel_info` FROM `videoinfo` WHERE `rel_name` = '[::mysql::escape $handle $arg]'" -flatlist]
	::mysql::close $handle
	if {$query == ""} { return }
	
	foreach {release info} $query {}
	
	putserv "PRIVMSG $chan :!oldvideoinfo $release $info"
}

proc nfo {nick host hand chan arg} {
	if {[llength $arg] != 1} { return }
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	::mysql::encoding $handle binary
	
	set	query	[::mysql::sel $handle "SELECT `rel_filename`, UNCOMPRESS(`rel_nfo`) FROM `nfo` WHERE `rel_name` = '[::mysql::escape $handle $arg]'" -flatlist]
	::mysql::close $handle
	if {$query == ""} {
 putserv "PRIVMSG $chan :nfo not found, sorry!"
}
	
	
	foreach {file data} $query {
	    set	code	"[md5 "$arg$file[unixtime]"].nfo"
	
	    set	url		"$::nfo(host)$code"
	    set	write	"$::nfo(path)$code"
	
	    set	fp		[open $write "w"]
	    fconfigure $fp -translation binary
	    puts -nonewline $fp $data
	    close $fp
	
	    putserv "PRIVMSG $chan :\[\00304NFO-VIEWER\003\] \002$arg ($file) ~~ $url\002"
	
	    utimer 600 [list filewipe $write]
	}  	
}

proc sfv {nick host hand chan arg} {
	if {[llength $arg] != 1} { return }
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	::mysql::encoding $handle binary
	
	set	query	[::mysql::sel $handle "SELECT `rel_filename`, UNCOMPRESS(`rel_sfv`) FROM `sfv` WHERE `rel_name` = '[::mysql::escape $handle $arg]'" -flatlist]
	::mysql::close $handle
	if {$query == ""} {
 putserv "PRIVMSG $chan :sfv not found, sorry!"
}
	
	
    foreach {file data} $query {
	   set	code	"[md5 "$arg$file[unixtime]"].sfv"
	
	   set	url		"$::sfv(host)$code"
	   set	write	"$::sfv(path)$code"
	
	   set	fp		[open $write "w"]
	   fconfigure $fp -translation binary
	   puts -nonewline $fp $data
	   close $fp
	
	   putserv "PRIVMSG $chan :\[\00304SFV-VIEWER\003\] \002$arg ($file) ~~ $url\002"
	   
	   utimer 600 [list filewipe $write]   
	}  
}

proc cover {nick host hand chan arg} {
	if {[llength $arg] != 1} { return }
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	::mysql::encoding $handle binary
	
	set	query	[::mysql::sel $handle "SELECT `rel_filename`, UNCOMPRESS(`rel_cover`) FROM `cover` WHERE `rel_name` = '[::mysql::escape $handle $arg]'" -flatlist]
	::mysql::close $handle
	if {$query == ""} {
 putserv "PRIVMSG $chan :cover not found, sorry!"
}
	
	foreach {file data} $query {
		set	code	"[md5 "$arg$file[unixtime]"].jpg"

		set	url		"$::cover(host)$code"
		set	write	"$::cover(path)$code"

		set	fp		[open $write "w"]
		fconfigure $fp -translation binary
		puts -nonewline $fp $data
		close $fp

		putserv "PRIVMSG $chan :\[\00304COVER-VIEWER\003\] \002$arg ($file) ~~ $url\002"

		utimer 600 [list filewipe $write]
	}
}

proc jpg {nick host hand chan arg} {
	if {[llength $arg] != 1} { return }
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	::mysql::encoding $handle binary
	
	set	query	[::mysql::sel $handle "SELECT `rel_filename`, UNCOMPRESS(`rel_jpg`) FROM `jpg` WHERE `rel_name` = '[::mysql::escape $handle $arg]'" -flatlist]
	::mysql::close $handle
	if {$query == ""} {
 putserv "PRIVMSG $chan :jpg not found, sorry!"
}
	
	foreach {file data} $query {
		set	code	"[md5 "$arg$file[unixtime]"].jpg"

		set	url		"$::jpg(host)$code"
		set	write	"$::jpg(path)$code"

		set	fp		[open $write "w"]
		fconfigure $fp -translation binary
		puts -nonewline $fp $data
		close $fp

		putserv "PRIVMSG $chan :\[\00304JPG-VIEWER\003\] \002$arg ($file) ~~ $url\002"

		utimer 600 [list filewipe $write]
	}
}


proc m3u {nick host hand chan arg} {
	if {[llength $arg] != 1} { return }
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	::mysql::encoding $handle binary
	
	set	query	[::mysql::sel $handle "SELECT `rel_filename`, `rel_m3u` FROM `m3u` WHERE `rel_name` = '[::mysql::escape $handle $arg]'" -flatlist]
	::mysql::close $handle
	if {$query == ""} {
 putserv "PRIVMSG $chan :m3u not found, sorry!"
}
	
	foreach {file data} $query {
		set	code	"[md5 "$arg$file[unixtime]"].m3u"

		set	url		"$::m3u(host)$code"
		set	write	"$::m3u(path)$code"

		set	fp		[open $write "w"]
		fconfigure $fp -translation binary
		puts -nonewline $fp $data
		close $fp

		putserv "PRIVMSG $chan :\[\00304M3U-VIEWER\003\] \002$arg ($file) ~~ $url\002"

		utimer 600 [list filewipe $write]
	}
}


proc tracks {nick host hand chan arg} {
	if {[llength $arg] != 1} { return }
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	set	query	[::mysql::sel $handle "SELECT `rel_name`, `rel_file`, `rel_size` FROM `tracks` WHERE `rel_name` = '[::mysql::escape $handle $arg]'" -flatlist]
	::mysql::close $handle
	if {$query == ""} {
 putserv "PRIVMSG $chan :TRACKS not found, sorry!"
}
	 
	    putserv "PRIVMSG $chan :Sending you the results in query..."
	foreach {release file size} $query {	
		putserv "PRIVMSG $nick :\[\00304TRACKS\003\] $release : Track: $file / Size: $size bytes"
	}
}

proc url {nick host hand chan arg} {
	if {[llength $arg] != 1} { return }
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	set	query	[::mysql::sel $handle "SELECT `rel_name`, `rel_url` FROM `url` WHERE `rel_name` = '[::mysql::escape $handle $arg]'" -flatlist]
	::mysql::close $handle
	if {$query == ""} {
 putserv "PRIVMSG $chan :URL not found, sorry!"
}
	
	foreach {release url} $query {	
		putserv "PRIVMSG $chan :\[\00304URL\003\] $release : URL: $url"
	}
}

proc mp3info {nick host hand chan arg} {
	if {[llength $arg] != 1} { return }
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	set	query	[::mysql::sel $handle "SELECT `rel_name`, `rel_info` FROM `mp3info` WHERE `rel_name` = '[::mysql::escape $handle $arg]'" -flatlist]
	::mysql::close $handle
	if {$query == ""} {
 putserv "PRIVMSG $chan :mp3info not found, sorry!"
}
	
	foreach {release info} $query {}
	foreach {genre year freq chans bitrate type} $info {}
	
	putserv "PRIVMSG $chan :\[\00304MP3INFO\003\] $release : Genre: $genre / Year: $year / Freq: $freq / Chans: $chans / Bitrate: $bitrate / Type: $type"
}

proc videoinfo {nick host hand chan arg} {
	if {[llength $arg] != 1} { return }
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	set	query	[::mysql::sel $handle "SELECT `rel_name`, `rel_info` FROM `videoinfo` WHERE `rel_name` = '[::mysql::escape $handle $arg]'" -flatlist]
	::mysql::close $handle
	if {$query == ""} {
 putserv "PRIVMSG $chan :videoinfo not found, sorry!"
}
	
	foreach {release info} $query {}
	foreach {codec framerate resolution ar acodec abitrate asampling achannel} $info {}
	
	putserv "PRIVMSG $chan :\[\00304VIDEOINFO\003\] $release : Codec: $codec / FPS: $framerate / Res: $resolution / AR: $ar // Codec: $acodec / Bitrate: $abitrate / Sampling: $asampling / Channel: $achannel"
}

proc filewipe {path} {
	if {[file exists $path]} {
		file delete $path
	}
	return 0
}




