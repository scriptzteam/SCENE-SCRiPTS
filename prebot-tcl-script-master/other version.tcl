# Get it at http://www.xdobry.de/mysqltcl/ or your distributions repository
load /usr/lib/tcltk/mysqltcl-3.051/libmysqltcl3.051.so;
# Load Package: CRC32
#if {![info exists ::tcl_package(crc32)]} { package require crc32; } elseif {$::tcl_package(crc32) != "" && $::tcl_package(crc32) != "-" && [file exists $::tcl_package(crc32)] } { source $::tcl_package(crc32); } else { package require crc32; }
# Should be included with TCL
#if {![info exists ::tcl_package(tls)]} { package require tls; } elseif {$::tcl_package(tls) != "" && $::tcl_package(tls) != "-" && [file exists $::tcl_package(tls)] } { source $::tcl_package(tls); } else { package require tls; }
# Load Package: http
if {![info exists ::tcl_package(http)]} { package require http; } elseif {$::tcl_package(http) != "" && $::tcl_package(http) != "-" && [file exists $::tcl_package(http)] } { source $::tcl_package(http); } else { package require http; }


if {![info exists mysql(host)]}		{ set	mysql(host)		"127.0.0.1" }
if {![info exists mysql(user)]}		{ set	mysql(user)		"" }
if {![info exists mysql(pass)]}		{ set	mysql(pass)		"" }
if {![info exists mysql(db)]}		{ set	mysql(db)		"" }
if {![info exists mysql(port)]}		{ set	mysql(port)		"3306" }

if {![info exists nfo(path)]}		{ set	nfo(path)		"/var/www/nfo/" }
if {![info exists nfo(host)]}		{ set	nfo(host)		"http://*/nfo/" }
if {![info exists sfv(path)]}		{ set	sfv(path)		"/var/www/sfv/" }
if {![info exists sfv(host)]}		{ set	sfv(host)		"http://*/sfv/" }


proc getdb {} {
	global mysql
	if {[catch {set handle [mysql::connect -host $mysql(host) -user $mysql(user) -password $mysql(pass) -port $mysql(port) -db $mysql(db)]} errorMsg]} {
		putlog "\[QUERY-ERROR\] Unable to connect to MySQL server: $errorMsg"
		return
	}
	return $handle
}

bind pub -|- !addnfo		addnfo
bind pub -|- !oldnfo		addnfo
#bind pub -|- !addsfv		addsfv
#bind pub -|- !oldsfv		addsfv
#bind pub -|- !addjpg		addjpg
#bind pub -|- !oldjpg		addjpg
bind pub -|- !addid3c		addmp3info
bind pub -|- !addmp3info    addmp3info
bind pub -|- !oldmp3info	addmp3info
bind pub -|- !addvideoinfo	addvideoinfo
bind pub -|- !oldvideoinfo	addvideoinfo
bind pub -|- !addurl		addurl
bind pub -|- !oldurl		addurl
bind pub -|- !nfo		nfo
bind pub -|- !url		url
bind pub -|- !videoinfo	videoinfo
bind pub -|- !mp3info    mp3info




 proc addnfo {nick host hand chan arg} {
	if {[llength $arg] < 3} { return }
	
	set	release	[lindex $arg 0]
	set	url		[lindex $arg 1]
	set	file	[lindex $arg 2]
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	::mysql::encoding $handle binary
	
	if {[::mysql::sel $handle "SELECT COUNT(*) FROM `nfo` WHERE `rel_name` = '[::mysql::escape $handle $release]'" -flatlist]} {
		::mysql::close $handle
		return
	}
	
	if {[string equal -nocase [string range $url 0 4] "https"]} {
		::http::register https 443 ::tls::socket
	}
	
	if {[catch {set	token [::http::geturl $url -timeout 5000 -binary 1]} error]} {
		::mysql::close $handle
		return
	}
	
	set	state	[::http::status $token]
	set	ncode	[::http::ncode $token]
	set	size	[::http::size $token]
		
	if {![string equal -nocase $state "ok"] || $ncode == 404 || $ncode == 302 || $size < 15 || $size > 1048576} {
		::mysql::close $handle
		return
	}
	
	set	data	[::http::data $token]
	::http::cleanup $token
	
	if {[regexp -nocase -line -- {(404 - not found|404 nfo not found|href|This resource|link.*expired|invalid.*(?:link|hash)|The requested URL .* was not found|<\?php|<html|<script|mysql_(?:query|connect))} $data matchall match]} {
		::mysql::close $handle
		return
	}
	
	if {[catch {mysql::exec $handle "INSERT INTO `nfo` ( `rel_name` , `rel_filename` , `rel_nfo` ) VALUES ('[mysql::escape $handle $release]', '[mysql::escape $handle $file]', COMPRESS('[mysql::escape $handle $data]'))"} error]} {}


	set	code	"[md5 "$release$file[unixtime]"].nfo"
	
	set	url		"$::nfo(host)$code"
	set	write	"$::nfo(path)$code"
	
	set	fp		[open $write "w"]
	fconfigure $fp -translation binary
	puts -nonewline $fp $data
	close $fp
	
	utimer 600 [list filewipe $write]

	putallbots "nfo $release $url $file"
	
	::mysql::close $handle
}
 
proc addsfv {nick host hand chan arg} {
	if {[llength $arg] < 3} { return }
	
	set	release	[lindex $arg 0]
	set	url		[lindex $arg 1]
	set	file	[lindex $arg 2]
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	::mysql::encoding $handle binary
	
	if {[::mysql::sel $handle "SELECT COUNT(*) FROM `sfv` WHERE `rel_name` = '[::mysql::escape $handle $release]'" -flatlist]} {
		::mysql::close $handle
		return
	}
	
	if {[string equal -nocase [string range $url 0 4] "https"]} {
		::http::register https 443 ::tls::socket
	}
	
	if {[catch {set	token [::http::geturl $url -timeout 5000 -binary 1]} error]} {
		::mysql::close $handle
		return
	}
	
	set	state	[::http::status $token]
	set	ncode	[::http::ncode $token]
	set	size	[::http::size $token]
		
	if {![string equal -nocase $state "ok"] || $ncode == 404 || $ncode == 302 || $size < 15 || $size > 1048576} {
		::mysql::close $handle
		return
	}
	
	set	data	[::http::data $token]
	::http::cleanup $token
	
	if {[regexp -nocase -line -- {(404 - not found|404 nfo not found|href|This resource|link.*expired|invalid.*(?:link|hash)|The requested URL .* was not found|<\?php|<html|<script|mysql_(?:query|connect))} $data matchall match]} {
		::mysql::close $handle
		return
	}
	
	if {[catch {mysql::exec $handle "INSERT INTO `sfv` ( `rel_name` , `rel_filename` , `rel_sfv` ) VALUES ('[mysql::escape $handle $release]', '[mysql::escape $handle $file]', COMPRESS('[mysql::escape $handle $data]'))"} error]} {}


	set	code	"[md5 "$release$file[unixtime]"].sfv"
	
	set	url		"$::sfv(host)$code"
	set	write	"$::sfv(path)$code"
	
	set	fp		[open $write "w"]
	fconfigure $fp -translation binary
	puts -nonewline $fp $data
	close $fp
	
	utimer 600 [list filewipe $write]

	putallbots "sfv $release $url $file"
	::mysql::close $handle
}

proc addjpg {nick host hand chan arg} {
	if {[llength $arg] < 3} { return }
	
	set	release	[lindex $arg 0]
	set	url		[lindex $arg 1]
	set	file	[lindex $arg 2]
	
	set	handle	[getdb]
	if {$handle == ""} { return }
	
	::mysql::encoding $handle binary
	
	if {[::mysql::sel $handle "SELECT COUNT(*) FROM `jpg` WHERE `rel_name` = '[::mysql::escape $handle $release]'" -flatlist]} {
		::mysql::close $handle
		return
	}
	
	if {[string equal -nocase [string range $url 0 4] "https"]} {
		::http::register https 443 ::tls::socket
	}
	
	if {[catch {set	token [::http::geturl $url -timeout 5000 -binary 1]} error]} {
		::mysql::close $handle
		return
	}
	
	set	state	[::http::status $token]
	set	ncode	[::http::ncode $token]
	set	size	[::http::size $token]
		
	if {![string equal -nocase $state "ok"] || $ncode == 404 || $ncode == 302 || $size < 15 || $size > 1048576} {
		::mysql::close $handle
		return
	}
	
	set	data	[::http::data $token]
	::http::cleanup $token
	
	if {[regexp -nocase -line -- {(404 - not found|404 nfo not found|href|This resource|link.*expired|invalid.*(?:link|hash)|The requested URL .* was not found|<\?php|<html|<script|mysql_(?:query|connect))} $data matchall match]} {
		::mysql::close $handle
		return
	}
	
	if {[catch {mysql::exec $handle "INSERT INTO `jpg` ( `rel_name` , `rel_filename` , `rel_jpg` ) VALUES ('[mysql::escape $handle $release]', '[mysql::escape $handle $file]', COMPRESS('[mysql::escape $handle $data]'))"} error]} {}


	set	code	"[md5 "$release$file[unixtime]"].jpg"
	
	set	url		"$::jpg(host)$code"
	set	write	"$::jpg(path)$code"
	
	set	fp		[open $write "w"]
	fconfigure $fp -translation binary
	puts -nonewline $fp $data
	close $fp
	
	utimer 600 [list filewipe $write]

	putallbots "jpg $release $url $file"
	
	::mysql::close $handle
}



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
	
	::mysql::close $handle
}

proc nfo {nick host hand chan arg} {
    if {[llength $arg] != 1} { return }
    
    set    handle    [getdb]
    if {$handle == ""} { return }
    
    set    query    [::mysql::sel $handle "SELECT `ID` FROM `nfo` WHERE `rel_name` = '[::mysql::escape $handle $arg]'" -flatlist]
    ::mysql::close $handle
    if {$query == ""} {
 putserv "PRIVMSG $chan :NFO not found, sorry!"
}
    
    foreach {release nfo} $query {    
        putserv "PRIVMSG $chan :\[\00304NFO\003\] $release : NFO: $nfo"
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



putlog "By scriptz-team.info ||| Loaded Succesfully!"

