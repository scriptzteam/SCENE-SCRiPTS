package require TclCurl

set isy_(createhash) "http://example.com/sethash.php?r="
set isy_(viewhash) "https://example.com/index.php?h="

set chann_(search) "#search"

bind pub - !nfo isy:nfosearch

proc isy:nfosearch { nick uhost hand chan arg } {
	global chann_
	
	set chan [string tolower $chan]
	
	if { $chan == $chann_(search) } {
		
		set arg [string trim $arg]
		
		curl::transfer -sslverifypeer 0 -url $isy_(createhash)$arg -bodyvar data -timeout 10
		
		if { [string trim $data] == "" } { putquick "PRIVMSG $chan : Internal Error1 $data $arg"; return; }

		set rlsname [string trim [lindex [split [string trim $data] " "] 0]]
		set hash [string trim [lindex [split [string trim $data] " "] 1]]
		
		if { [string length $hash] == 32 } {
		
			putquick "PRIVMSG $chan : Info for $rlsname $isy_(viewhash)$hash"
		
		} else {
			
			putquick "PRIVMSG $chan : Internal Error2 $data $arg"
			
		}
		
	}
	
}