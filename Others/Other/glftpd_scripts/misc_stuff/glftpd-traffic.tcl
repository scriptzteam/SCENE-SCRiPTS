# v-1.05 22 Feb 05 (21:06:58)
# Don't know who the original author is, but I'm releasing this
# out with a few fixes to get around looping into negatives above
# 2GB when reading k size. -Genocaust

# glftpd users directory
set glftpdusers "/glftpd/ftp-data/users"

# output themes
#  variables:
#   $traffick - traffic in kilobytes
#   $trafficm - traffic in megabytes
#   $trafficg - traffic in gigabytes
#   $msgtag   - i just prepend to the outputs to match my bot theme

set msgtag          "\002LEET-SITE\002 :: \[\002stats \002\]"
set gtoutput(all)   {$msgtag \002${trafficg}\002GB have passed through the LEET-SITE.}
set gtoutput(month) {$msgtag While passing into the LEET-SITE, \002${trafficg}\002GB had an out of body experience this month.}
set gtoutput(wk)    {$msgtag \002${trafficg}\002GB saw Elvis this week in the LEET-SITE.}
set gtoutput(day)   {$msgtag Today \002${trafficg}\002GB all agreed that 'if the dick don't fit, you must acquit.'}

# trigger
set gtcommand "!traffic"

# usage is: trigger [day/wk/month/all] - if not period is specified the default will be used
set gtdefault "all"

proc gtgltraffic {nick host hand chan arg} {
	set monthup 0
	set monthdn 0
	global msgtag
	if {[llength [split $arg]]==0} {
		set period $::gtdefault
	} else {
		set period [lindex $arg 0]
	}
	if {![info exists ::gtoutput($period)]} {
		puthelp "PRIVMSG $chan :usage: $::gtcommand \[day/wk/month/all\]"
		return
	}
	foreach user [glob -nocomplain $::glftpdusers/*] {
#		putlog $user
		if {[catch {open $user} fp]} {
#			putlog "glftpd-traffic.tcl: $fp :("
			continue
		}
		set lines [split [read $fp] \n]
		foreach line $lines {
			if {[lindex [split $line] 0]=="[string toupper $period]UP"} {
#				putlog $line
				foreach {files size time} [lrange [split $line] 1 end] {
					if {$size==""} {continue}
					incr monthup $size
				}
			} elseif {[lindex [split $line] 0]=="[string toupper $period]DN"} {
#				putlog $line
				foreach {files size time} [lrange [split $line] 1 end] {
					if {$size==""} {continue}
					incr monthdn $size
				}
			}
		}
	}
	set traffick [expr wide($monthdn) + wide($monthup)]
	set trafficm [format %.1f [expr wide($traffick) /1024.0]]
	set trafficg [format %.1f [expr wide($trafficm) /1024.0]]
	puthelp "PRIVMSG $chan :[subst -nocommands $::gtoutput($period)]"
}

bind pub - $gtcommand gtgltraffic

putlog "glFTPD Traffic 1.05 loaded"
