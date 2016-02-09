set botlisten(port) "34155"
set botlisten(password) "xxx"
set botlisten(channel) "#announce"

#IRC ANN
listen $botlisten(port) script botlisten
proc botlisten {idx} {control $idx botlisten2}
proc botlisten2 {idx args} {
  global botlisten
	set args [join $args]
	set botlisten(pass) [lindex [split $args] 0]
	set botlisten(message) [join [lrange [split $args] 1 end]]
	if {[string match $botlisten(pass) $botlisten(password)]} then {
	putquick "PRIVMSG $botlisten(channel) :$botlisten(message)"
	}
}
## End
#IRC CMDS

putlog "Torrent announce successfully loaded."