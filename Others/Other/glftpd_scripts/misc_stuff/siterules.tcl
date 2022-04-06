# v-1.5 22 Feb 05 (19:18:50)
# I got tired of not being able to find a rule script that worked 100% how I wanted
# so I finally stumbled around in TCL and wrote this for myself.  This is my second
# attempt ever to write TCL, so any comments are appreciated.  I can usually be found
# on efnet in #pzs-ng.  -Genocaust
#
# rulespath - Where the script should look for your section rules files, they need to have a .rules extention
# sections  - What sections you would like to list rules for, case insensitive
# errmsg    - What file to output when somebody attempts to request rules for a non-existant section

bind pub - !rules pub:rules

set rulespath   "/glftpd/ftp-data/misc"
set sections     "GENERAL 0DAY VCD"
set errmsg       "errmsg.rules"

### Don't touch below here

proc pub:rules {nick uhost handle chan arg} {
 global rulespath
 global sections
 global errmsg
 set readsect [string tolower [lindex $arg 0]]
 if { $arg == "" } {
  putquick "PRIVMSG $chan :Syntax is !rules <section>"
  putquick "PRIVMSG $chan :Valid sections are: $sections"
  return
 }
 foreach sect $sections {
  if { [string equal $readsect [string tolower $sect]] } {
   if { ![file readable "$rulespath/$readsect.rules"] } {
    putquick "PRIVMSG $chan :Unable to read $readsect.rules, please verify that it exists and is readable."
    return
   }
   foreach line [split [exec cat $rulespath/$readsect.rules] "\n"] {
    putquick "PRIVMSG $nick :$line"
   }
   return
  }
 }
 foreach line [split [exec cat $rulespath/$errmsg] "\n"] {
  putquick "PRIVMSG $chan :$line"
  return
 }
}

putlog "Site Rules 1.5 loaded"

