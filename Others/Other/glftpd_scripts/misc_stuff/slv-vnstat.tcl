putlog "slv-vnstat.tcl by silver 20061124"

set staffchanvnstat "#chab"
set vnstat {/usr/bin/vnstat}

bind pub o|o !vnstat pub:slv-vnstat

proc pub:slv-vnstat {nick uhost handle chan arg} {
        global vnstat slvvnstat staffchanvnstat
        if {$chan == $staffchanvnstat} {
                if {$arg == ""} {
		        foreach line [split [exec $vnstat] "\n" ] {
				if {$line != ""} {
				        putquick "PRIVMSG $chan :\037vnstat\037 $line"
				}
			}
		}
                if {$arg != ""} {
                        if {$arg == "--help"} {
			        foreach line [split [exec $vnstat --help] "\n" ] {
					if {$line != ""} {
					        putquick "PRIVMSG $nick :\037vnstat\037 $line"
					}
				}
			} else {
		        	foreach line [split [eval [concat exec $vnstat $arg]] "\n" ] {
					if {$line != ""} {
				        	putquick "PRIVMSG $chan :\037vnstat\037 $line"
					}
				}
			}
		}
	}
}
