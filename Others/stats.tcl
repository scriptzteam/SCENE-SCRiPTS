package require mysqltcl

# Enter in your MySQL connection data
set mysql_(user) "xxx"
set mysql_(password) "xxx"
set mysql_(host) "localhost"

set mysql_(db) "predatabase"

set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]

set mysql_(statstable) "nicks"

set chann_(annstats) "#chat"

bind pub - !hourstats hourstats
bind pub - !daystats daystats
bind pub - !weekstats weekstats
bind pub - !monthstats monthstats


proc calcstats { args } {
	global db_handle mysql_ chann_
    
	set name [lindex $args 0]
	set dur [lindex $args 1]
	set ischan [lindex $args 2]
	
	set query [mysqlsel $db_handle "SELECT a_nick, a_type, a_network, COUNT(rel_id) AS adds FROM $mysql_(statstable) WHERE UNIX_TIMESTAMP(a_added) > $dur GROUP BY a_nick, a_type, a_network ORDER BY adds DESC" -flatlist];

	if {$query != ""} {
		
		putnow "PRIVMSG $ischan :STATS F0R the $name"
		
        foreach {nick type network adds} $query {
			
			putnow "PRIVMSG $ischan :Nick: $nick Type: $type Network: $network Adds: $adds"
		
		}
	
	} else {
	
		putnow "PRIVMSG $ischan :N0 STATS for the $name"
		
	}
	
}

proc daystats { nick uhost hand chan arg } {
	global db_handle mysql_ chann_
	
	set chan [string tolower $chan]
	
	if { $chann_(annstats) == $chan } {
       	set now [clock seconds]
        set dur [expr $now - 60*60*24]
		set name "DAY"
		set calc [calcstats $name $dur $chan]
		
	}
}

proc hourstats { nick uhost hand chan arg } {
	global db_handle mysql_ chann_
	
	set chan [string tolower $chan]
	
	if { $chann_(annstats) == $chan } {
       	set now [clock seconds]
        set dur [expr $now - 60*60]
		set name "H0UR"
		set calc [calcstats $name $dur $chan]
		
	}
}

proc weekstats { nick uhost hand chan arg } {
	global db_handle mysql_ chann_
	
	set chan [string tolower $chan]
	
	if { $chann_(annstats) == $chan } {
       	set now [clock seconds]
        set dur [expr $now - 60*60*24*7]
		set name "WEEK"
		set calc [calcstats $name $dur $chan]
		
	}
}

proc monthstats { nick uhost hand chan arg } {
	global db_handle mysql_ chann_
	
	set chan [string tolower $chan]
	
	if { $chann_(annstats) == $chan } {
       	set now [clock seconds]
        set dur [expr $now - 60*60*24*30]
		set name "M0NTH"
		set calc [calcstats $name $dur $chan]
		
	}
}

putlog "Global STATS v1.04 14022012 --> By \002sCRiPTzTEAM\002 ||| Loaded Succesfully!"