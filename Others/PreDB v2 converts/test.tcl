#!/usr/bin/tclsh

if {[llength $argv] != 1} {puts "Invalid arguments passed to script!" ; exit 2}

proc isy:validrelease { release } {
	
	set rlscopy $release
	set minlen 10
	set maxlen 256
 
	if {[string length $release] < $minlen}                                 				{return 0}
	if {[string length $release] > $maxlen}                                 				{return 0}
	if {![regexp {\.|\_} $release]}                                      					{return 0}
	#if {![regexp {\.|\_|\-} $release]}                                      				{return 0}
	#if {[regexp {\$|\!|\:|\@|\~|\||\[|\]|\`|\#|\^|\+|\{|\}|\[|\]|\/|\?|\>|\<} $release]} 	{return 0}
	if {[regexp {[\-\.\(\)_]$} $release]}                                   				{return 0}
	if {![regexp {^[0-9]} $release]}  {
		if {![regexp -nocase {^[a-z]} $release]}                           					{return 0}
	}
	if {[regexp ^[clock format [clock scan today] -format %Y-%m] $release]} 				{return 0}
	if {[regexp ^[clock format [clock scan today] -format %m%d] $release]}  				{return 0}
	if {[regexp -all {\(} $release]!=[regexp -all {\)} $release]}           				{return 0}
	
	regsub -all {[A-Za-z0-9\_\.\-\(\)]} $rlscopy "" rlscopy
	
	if {[string trim $rlscopy] != ""}                                						{return 0}
	
	if {[regexp -nocase {p[-\._]?r[-\._]?[e3][-\._]?[7t][-\._]?[e3][-\._]?[s5][-\._]?[t7]|[7t][-\._]?[e3][-\._]?[s5][-\._]?[t7][-\._]?p[-\._]?r[-\._]?[e3][-\._]?|d[o0][-\._]?n[o0]?[t7].*[t7]r[a4]d[e3]|^[t7][-\._]?[e3][-\._]?[s5][-\._]?[t7][-\._]?[a-z0-9]+$} $release]} {return 0}
 
	return 1
 
}

proc isy:validgroup { grp } {
	
	set grpcopy $grp
	set minlen 1
	set maxlen 20
	
	if {[string length $grp] < $minlen}                                 					{return 0}
	if {[string length $grp] > $maxlen}                                 					{return 0}
	
	regsub -all {[A-Za-z0-9]} $grpcopy "" grpcopy
	regsub {_} $grpcopy "" grpcopy
	
	if {[string trim $grpcopy] != ""}                                						{return 0}
	
	#if {[regexp {\$|\!|\:|\@|\~|\||\[|\]|\`|\#|\.|\^|\+|\{|\}|\[|\]|\/|\?|\>|\<} $grp]}    {return 0}
	#if {[array size [split $grp "_"]] > 1}                              					{return 0}
	#if {[array size [split $grp "-"]] > 1}                              					{return 0}
	#if {![regexp -nocase {[a-z0-9]} $grp]}                              					{return 0}
	
	if {[regexp ^[clock format [clock scan today] -format %Y-%m] $grp]} 					{return 0}
	if {[regexp ^[clock format [clock scan today] -format %m%d] $grp]}  					{return 0}
	
	return 1
 
}


set rlsname "Desaparecidos_-_Me_Gusta-(GO_301301-2)-WEB-2012-ZzZz"

if {[regexp {\$|\!|\:|\@|\~|\||\[|\]|\`|\#|\.|\^|\+|\{|\}|\[|\]|\/|\?|\>|\<} $rlsname]}    { puts "hmm"; exit 2}

set grp [string trim [lindex [split $rlsname "-"] end]]

set release [string trim [join [lrange [split $rlsname "-"] 0 end-1] "-"]]

puts "$release"
puts "$grp"

set rlsvalid [isy:validrelease $release]

puts "$rlsvalid"

set grpvalid [isy:validgroup $grp]

puts "$grpvalid"

exit 0