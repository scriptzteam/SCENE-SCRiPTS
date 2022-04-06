#putlog "Creditshow v0.3 (c) 2005 by Holybull loaded"

namespace eval ::ngBot::plugin::CreditShow {
	# Short hand for ::ngBot::plugin::Example
	variable ns [namespace current]
	# Short hand for ::ngBot
	variable np [namespace qualifiers [namespace parent]]
	variable glroot [set ${np}::glroot]
	# Config:
	variable hbCredShow     "$glroot/bin/hb_creditshow.sh"
	variable announceLayout "\002\[\0032CREDS\003\]\002"
	variable permsraw  "1 =SiTEOPS"

        namespace import ${np}::plugin::NickDb::*
	variable scriptName ${ns}::LogEvent
	#bind evnt -|- prerehash ${ns}::deinit

	interp alias {} IsTrue {} string is true -strict
	interp alias {} IsFalse {} string is false -strict

	proc init {args} {
		variable ns
		variable scriptName
		bind pub -|- !credits ${ns}::Show
		putlog "\[ngBot\] CreditShow :: Loaded successfully."
		return
	}

	proc deinit {args} {
		variable ns
		variable scriptName
		#catch {unbind evnt -|- prerehash ${ns}::deinit}
		catch {unbind pub -|- !credits ${ns}::Show}
		namespace delete ${ns}::
	return
	}

	proc GetInfo {ftpUser groupVar flagsVar} {
		variable np
		global ${np}::location
		upvar $groupVar group $flagsVar flags
		set group ""; set flags ""

		if {![catch {set handle [open "$location(USERS)/$ftpUser" r]} error]} {
			set data [read $handle]
			close $handle
			foreach line [split $data "\n"] {
				switch -exact -- [lindex $line 0] {
			                "FLAGS" {set flags [lindex $line 1]}
			                "GROUP" {set group [lindex $line 1]}
				}
			}
		return 1
		} else {
			putlog "dZSbot error: Unable to open user file for \"$ftpUser\" ($error)"
			return 0
		}
	}

	proc Show {nick uhost hand chan args} {
		variable np
		variable hbCredShow
		variable announceLayout
		variable permsraw

		set checkUser [GetFtpUser $nick]
		if {[string equal "" $nick]} {return}

		if {[GetInfo $checkUser group flags]} {
			if {[${np}::rightscheck $permsraw $ $group $flags]} {
				if { [lindex $args 0] != "" } {
					set checkUser [GetFtpUser [lindex $args 0]]
				}
				if { $checkUser == "" } {
					if {[GetIrcUser [lindex $args 0]] != ""} {set checkUser [lindex $args 0]}
				}
			}
			if { $checkUser == "" } { return }
		}

		#putlog "DEBUG: $checkUser"

		set output [exec $hbCredShow $checkUser]
		set credits [lindex $output 0]
		set ratio [lindex $output 1]

		if { $ratio == 0 } {
			putserv "PRIVMSG $chan :$announceLayout $checkUser is on leech"
		} else {
			set credits [expr $credits/1024]
			set outputgb [format "%.2f" [expr $credits/1024.0]]
			putserv "PRIVMSG $chan :$announceLayout $checkUser has \002${credits}\002MB (\002${outputgb}\002GB) credits"
		}
	}
}

#  if {[lindex $args 0] != "" } {
#    if {[file isfile /jail/glftpd/ftp-data/users/[lindex $args 0]]} {
#      set output [exec /jail/glftpd/bin/hb_creditshow.sh [lindex $args 0]]
#      set credits [lindex $output 0]
#      set ratio [lindex $output 1]
#      if { $ratio == 0 } {
#        putserv "PRIVMSG $chan :-\002$sitename\002-: [lindex $args 0] is on leech"
#      } else {
#        set credits [expr $credits/1024]
#        set outputgb [format "%.2f" [expr $credits/1024.0]]
#        putserv "PRIVMSG $chan :-\002$sitename\002- Credits: $credits MB ($outputgb GB)"
#      }
#    } else {
#      putserv "PRIVMSG $chan :-\002$sitename\002- No such user"
#    }
#  } else {
#    putserv "PRIVMSG $chan :-\002$sitename\002- Usage: !credits <username>"
#  }
#}

if {[string equal "" $::ngBot::plugin::CreditShow::np]} {
        ::ngBot::plugin::CreditShow::init
}
