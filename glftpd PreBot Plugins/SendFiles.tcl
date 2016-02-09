package require TclCurl


namespace eval ::ngBot::plugin::SendFiles {
	
	variable ns [namespace current]
	variable np [namespace qualifiers [namespace parent]]
	variable scriptname ${ns}::log_event
	
	set addto(files) { {ADDNFO NFO_FILE} {ADDSFV SFV_AUDIO} {ADDSFV SFV_OTHER} {ADDSFV SFV_RAR} {ADDSFV SFV_VIDEO} {ADDM3U COMPLETE_AUDIO_CBR} {ADDM3U COMPLETE_AUDIO_VBR} {ADDM3U COMPLETE_STAT_RACE_AUDIO_CBR} {ADDM3U COMPLETE_STAT_RACE_AUDIO_VBR} {ADDDIZ UPDATE_ZIP} }
	
	variable events [list "NFO_FILE" "SFV_AUDIO" "SFV_OTHER" "SFV_RAR" "SFV_VIDEO" "COMPLETE_AUDIO_CBR" "COMPLETE_AUDIO_VBR" "COMPLETE_STAT_RACE_AUDIO_CBR" "COMPLETE_STAT_RACE_AUDIO_VBR" "UPDATE_VBR" "UPDATE_CBR" "UPDATE_ZIP"]
	variable addfileurl "http://example.com/prefilesadd.php"
	variable addinfourl "http://example.com/preinfoadd.php"
	variable dirglroot "/jail/glftpd"
	variable fromnet "xxx:unknown:xxx"


	proc init {} {
		variable ns
		variable np
		variable events
		variable scriptname

		variable ${np}::postcommand

		foreach event $events {
			lappend postcommand($event) $scriptname
		}
		
		return
		
	}

	proc deinit {} {
		variable ns
		variable np
		variable events
		variable scriptname
		variable ${np}::postcommand

		foreach event $events {
			if {[info exists postcommand($event)] && [set pos [lsearch -exact $postcommand($event) $scriptname]] !=  -1} {
				set postcommand($event) [lreplace $postcommand($event) $pos $pos]
			}
		}

		namespace delete $ns
		
		return
		
	}


	proc log_event {event section logdata} {
		variable np
		variable addfileurl
		variable addinfourl
		variable dirglroot
		variable fromnet
		variable addto
		
		set filepath [lindex $logdata 0]
		set rlsname [lindex $logdata 1]
		set filename [lindex $logdata 5]
		
		if { $event == "UPDATE_CBR" } {
		
			set rlsname [lindex $logdata 7]
			set genre [lindex $logdata 9]
			set year [lindex $logdata 10]
			set bitrate [lindex $logdata 11]
			set hertz [lindex $logdata 12]
			set tp [lindex $logdata 13]
			set bittype [lindex $logdata 14]
			
			curl::transfer -url $addinfourl -timeout 3 -bodyvar hashdata -verbose 1 -post 1 -httppost [list name "rlsname"  contents $rlsname] -httppost [list name "type"  contents "ADDMP3INFO"] -httppost [list name "genre"  contents $genre] -httppost [list name "year"  contents $year] -httppost [list name "bitrate"  contents $bitrate] -httppost [list name "hertz"  contents $hertz] -httppost [list name "tp"  contents $tp] -httppost [list name "bittype"  contents $bittype] -httppost [list name "fromnet" contents $fromnet] -followlocation 1 -maxredirs 1 -useragent "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2b5) Gecko/20091204 Firefox/3.6b5 GTB7.0" -httpheader "Expect: "
			
			
			return 1;
		
		} elseif { $event == "UPDATE_VBR" } {
		
			set rlsname [lindex $logdata 7]
			set genre [lindex $logdata 9]
			set year [lindex $logdata 10]
			set bitrate [lindex $logdata 11]
			set hertz [lindex $logdata 12]
			set tp [lindex $logdata 13]
			set bittx [lindex $logdata 15]
			
			if { $bittx == "" } {
				
				set bittype [lindex $logdata 14]
				
			} else {
			
				set bitt [lindex $logdata 14]
				set bittx [lindex $logdata 15]
				
				set bittype "$bitt-$bittx"
				
			}
			
			curl::transfer -url $addinfourl -timeout 3 -bodyvar hashdata -verbose 1 -post 1 -httppost [list name "rlsname"  contents $rlsname] -httppost [list name "type"  contents "ADDMP3INFO"] -httppost [list name "genre"  contents $genre] -httppost [list name "year"  contents $year] -httppost [list name "bitrate"  contents $bitrate] -httppost [list name "hertz"  contents $hertz] -httppost [list name "tp"  contents $tp] -httppost [list name "bittype"  contents $bittype] -httppost [list name "fromnet" contents $fromnet] -followlocation 1 -maxredirs 1 -useragent "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2b5) Gecko/20091204 Firefox/3.6b5 GTB7.0" -httpheader "Expect: "
			
			return 1;
		
		} elseif { $event == "COMPLETE_STAT_RACE_AUDIO_CBR" || $event == "COMPLETE_AUDIO_CBR" } {
		
			set genre [lindex $logdata 10]
			set year [lindex $logdata 11]
			set bitrate [lindex $logdata 12]
			set hertz [lindex $logdata 13]
			set tp [lindex $logdata 14]
			set bittype [lindex $logdata 15]
			
			curl::transfer -url $addinfourl -timeout 3 -bodyvar hashdata -verbose 1 -post 1 -httppost [list name "rlsname"  contents $rlsname] -httppost [list name "type"  contents "ADDMP3INFO"] -httppost [list name "genre"  contents $genre] -httppost [list name "year"  contents $year] -httppost [list name "bitrate"  contents $bitrate] -httppost [list name "hertz"  contents $hertz] -httppost [list name "tp"  contents $tp] -httppost [list name "bittype"  contents $bittype] -httppost [list name "fromnet" contents $fromnet] -followlocation 1 -maxredirs 1 -useragent "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2b5) Gecko/20091204 Firefox/3.6b5 GTB7.0" -httpheader "Expect: "
			
		} elseif { $event == "COMPLETE_STAT_RACE_AUDIO_VBR" || $event == "COMPLETE_AUDIO_VBR" } {
		
			set genre [lindex $logdata 10]
			set year [lindex $logdata 11]
			set bitrate [lindex $logdata 12]
			set hertz [lindex $logdata 13]
			set tp [lindex $logdata 14]
			set bittx [lindex $logdata 16]
			
			if { $bittx == "" } {
				
				set bittype [lindex $logdata 15]
				
			} else {
			
				set bitt [lindex $logdata 15]
				set bittx [lindex $logdata 16]
				
				set bittype "$bitt-$bittx"
				
			}
			
			curl::transfer -url $addinfourl -timeout 3 -bodyvar hashdata -verbose 1 -post 1 -httppost [list name "rlsname"  contents $rlsname] -httppost [list name "type"  contents "ADDMP3INFO"] -httppost [list name "genre"  contents $genre] -httppost [list name "year"  contents $year] -httppost [list name "bitrate"  contents $bitrate] -httppost [list name "hertz"  contents $hertz] -httppost [list name "tp"  contents $tp] -httppost [list name "bittype"  contents $bittype] -httppost [list name "fromnet" contents $fromnet] -followlocation 1 -maxredirs 1 -useragent "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2b5) Gecko/20091204 Firefox/3.6b5 GTB7.0" -httpheader "Expect: "
			
		}
		
		set type ""
		
		foreach {typeorig eventorig} [join $addto(files)] {
		
			if { $event == $eventorig } {
			
				set type $typeorig
				break;
			}
		
		}
		
		if { $type == "ADDM3U" } {
		
			catch { exec ls $dirglroot$filepath | grep \.m3u$ } data
			
			set filename [string trim [lindex $data end]]
			
			if { $filename == "" } { return 1; }
		
		} elseif { $type == "ADDDIZ" } {
		
			catch { exec ls $dirglroot$filepath | grep \.diz$ } data
			
			set filename [string trim [lindex $data end]]
			
			if { $filename == "" } { return 1; }
			
			set rlsname [lindex $logdata 7]
		
		}
		
		set fullpath $dirglroot$filepath/$filename
		
		if {![file readable $fullpath]} {
			putlog "Bitch at the sysop, because he has\nabsolutely no idea how to setup this script!"; return 1
		}
		
		curl::transfer -url $addfileurl -timeout 3 -bodyvar hashdata -verbose 1 -post 1 -httppost [list name "rlsname"  contents $rlsname] -httppost [list name "type"  contents $type] -httppost [list name "filename"  contents $filename] -httppost [list name "fromnet" contents $fromnet] -httppost [list name "data" file $fullpath] -followlocation 1 -maxredirs 1 -useragent "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2b5) Gecko/20091204 Firefox/3.6b5 GTB7.0" -httpheader "Expect: "
		
		return 1;
	}
}

putlog "SendFiles v1.6 29122011 By sCRiPTzTEAM Loaded Successfully!"