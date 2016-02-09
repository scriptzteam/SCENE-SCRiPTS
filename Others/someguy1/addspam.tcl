package require mysqltcl
package require TclCurl

# Enter in your MySQL connection data
set mysql_(user) "xxx"
set mysql_(password) "xxx"
set mysql_(host) "localhost"

set mysql_(db) "xxx"

# Self-Explanatory! Set .chanset for channels you want all these command enabled
#   .chanset #channel +addfiles

bind pub - !addnfo isy:addnfo
bind pub - !addsfv isy:addsfv
bind pub - !addm3u isy:addm3u
bind pub - !addjpg isy:addjpg
bind pub - !adddiz isy:adddiz

bind pub - !oldnfo isy:addnfo
bind pub - !oldsfv isy:addsfv
bind pub - !oldm3u isy:addm3u
bind pub - !oldjpg isy:addjpg
bind pub - !olddiz isy:adddiz

proc mysql:keepalive {} {
	global db_handle mysql_
	
	if {[catch {mysql::ping $db_handle} error] || ![mysql::ping $db_handle]} {
		set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
	}

	utimer 120 [list mysql:keepalive]
	
	return 0
}

mysql:keepalive
setudef flag addfiles

proc isy:addfile { channel type rlsname url filename } {
	global db_handle
	
	if {[channel get $channel addfiles]} {
	
		if { $type == "" } { return }
		if { $rlsname == "" } { return }
		if { $url == "" } { return }
		if { $filename == "" } { return }
		
		set numrel [mysqlsel $db_handle "SELECT id FROM $type WHERE rel_name = '$rlsname'"]

		if { $numrel == 0 } {
			
			set hvar ""
			if { [string match "*https://*" $url] == "1" } { set hvar "-sslverifypeer 0 " }
			
			curl::transfer $hvar-url $url -bodyvar data -timeout 5
			
			if { $data == "" } { return }
			
			set expired [string match "*Not*Found*The*requested*URL*was*not*found*on*this*server*" $data]
			
			if { $expired == "1" } { return }
			
			set nix [::mysql::exec $db_handle "INSERT INTO $type ( `rel_name` , `rel_$type` , `rel_filename` ) VALUES ( '[::mysql::escape $db_handle $rlsname]' , COMPRESS('[::mysql::escape $db_handle $data]') , '[::mysql::escape $db_handle $filename]' )"]
			
			if { $nix == "1" } { putlog "$rlsname $type added to db" } else { putlog "mysql error ?" }
			
		}
	
	}
	
	return

}

proc isy:addnfo { nick uhost hand chan args } {
	return [isy:addfile $chan "nfo" [lindex [split [lindex $args 0] " "] 0] [lindex [split [lindex $args 0] " "] 1] [lindex [split [lindex $args 0] " "] 2]]
}

proc isy:addsfv { nick uhost hand chan args } {
	return [isy:addfile $chan "sfv" [lindex [split [lindex $args 0] " "] 0] [lindex [split [lindex $args 0] " "] 1] [lindex [split [lindex $args 0] " "] 2]]
}

proc isy:addm3u { nick uhost hand chan args } {
	return [isy:addfile $chan "m3u" [lindex [split [lindex $args 0] " "] 0] [lindex [split [lindex $args 0] " "] 1] [lindex [split [lindex $args 0] " "] 2]]
}

proc isy:addjpg { nick uhost hand chan args } {
	return [isy:addfile $chan "jpg" [lindex [split [lindex $args 0] " "] 0] [lindex [split [lindex $args 0] " "] 1] [lindex [split [lindex $args 0] " "] 2]]
}

proc isy:adddiz { nick uhost hand chan args } {
	return [isy:addfile $chan "diz" [lindex [split [lindex $args 0] " "] 0] [lindex [split [lindex $args 0] " "] 1] [lindex [split [lindex $args 0] " "] 2]]
}

# It would be nice if you didn't delete this but there is really nothing I can do!
putlog "ADD NF0|SFV|M3U|JPG|DIZ v2.01 --> By \002Islander\002 ||| Loaded Succesfully!"