#
#     _ _____ .___ __ _______ __ ______ _____ .___ __ ____ _ _______ _ _ 
#         ____|   \ _/   _   \ _/  __  \ _____|   \ _/___/__/   _   \_ _ 
#     _ _/    \    \\_   |____\\_  :/   \\_   \    \\_     /____|   _/// 
#     \\\_    /     |______    |   /____//   __\   |       |   ______|   
#       _    /|     _    :/    _         _   \:    _       _   \:    _ ©d
#     _ /    \:     \_   /     \_        \_   \    \_      \_   \    \ _ 
#     \\\      _____//_________//________//________//______//__      /// 
#     - -\____/------------------------------------------------\____/- - 
#
#     -- useDIZ v1.10 by dMG/t!s 20090426 - asciiscene[-AT-]gmail.com --
#
# What is it?
# -----------
#
# useDIZ is a multifunctional irc channel script for eggdrop. It does the
# following things:
#
# - Greets users joining irc channel through a notice
# - Announces new uploads to irc channel
# - Dupechecks uploads against a database and removes duplicate uploads
#   (works for all filetypes)
# - Attaches a textfile with advertizement, upload date and time to uploaded
#   textfiles. If the advertizement file is missing, useDIZ will add the
#   script- and author names in it's place
# - Automatically creates, populates and sorts a database if it doesn't
#   exist under the (user configurable) path
# - Allows users that are registered and have set a password for the bot to
#   use !get command to download files from the filesystem without having to
#   log in. Safety measures have been made to assure that no file outside of
#   the $rootdir can be downloaded
# - Extracts and displays the file_id.diz of a textfile. useDIZ finds the
#   path recursively under the $rootdir and lets the user know if the file
#   is lacking a file_id.diz or is missing. If the diz command is used from
#   within the filesystem, the current path of the user will be used instead
# - Has a built in search function to recursively find the path of a file
#   under the $rootdir. Good for situations when only the path of a known
#   filename is needed for fast and easy download, possibly using !get
# - Has a built in help function that accepts arguments for different sections
#   of the easilly editable external help file. Open help.txt for syntax
# - Shows filesystem statistics when triggered by !stats command
#
# useDIZ was created by consolidating the following scripts that i have
# previously written: showDIZ, getDIZ and putDIZ together with some
# other ideas.
#
# This script was written for #ascii on ircNET.
#
# Example output:
# ---------------
#
# <@dMG> !diz lp!-ssfm.txt
# <@hosee2> -=( showing file_id.diz for lp!-ssfm.txt )=-
# <@hosee2>                                  _.____
# <@hosee2>  L ô W P R ô F i L ë.____ _       ?   /
# <@hosee2>    ............._,-' `-......... _!/// __
# <@hosee2> __::::::___ _  /      ) \_     :(....)   |
# <@hosee2>   ::::::      ( ______\_ (     ::::::::  |
# <@hosee2> _ ......_      \(     \`   lP! .:?:::?   |
# <@hosee2>    .    /______ )\\ !  )_(      ? ?      |
# <@hosee2>   /    /   _   \ _`?.-'__ SOULSURVIVORS  |
# <@hosee2>  /    /_  /    ///(__//_(_   PART TWO    |
# <@hosee2> / ©Mt  / /    / (     )/ / LOWPROSOUL FM |
# <@hosee2> \_____/ _____/   )     \ ) BEATS & SKITS |
# <@hosee2> __ /____\  _____/       )___________ ____|
# <@hosee2>  /_________\                       //__ _
# <@hosee2>
# <@hosee2> file size of lp!-ssfm.txt is 81511 bytes.
# <@hosee2> found under path /_archive/l/lp!-ssfm.txt.
# <@hosee2> --==(\/)- useDIZ v1.03 by dMG/t!s -(\/)==--
#
# Prerequisites
# -------------
#
# The following changes must be made to your eggdrop.conf file:
#
# Add or uncomment the line saying 'loadmodule filesys'.
#
# Change the following paths to where your bot is installed:
#
# set files-path "/path/to/your/bot/filesys"
# set incoming-path "/path/to/your/bot/filesys/incoming"
#
# Add or uncomment the line saying 'loadmodule console'.
#
# Install:
# --------
#
# Copy useDIZ.tcl to your botdir/scripts directory.
# Copy help.txt to whereever you want it and set the helpfile variable (see below).
# Add 'source scripts/useDIZ.tcl' at the end of your eggdrop.conf.
#
# Configure:
# ----------
#
# set channel  "#dL"
# set botdir   "/home/esko/eggdrop"
# set rootdir  "$botdir/filesys"    It should be safe to leave this as is
# set adfile   "$botdir/ad.txt"     Advertizement to append to (text) uploads
# set dbfile   "$botdir/db.txt"     Path to database
# set helpfile "$botdir/help.txt"   Path to helpfile
#
# Edit help.txt to suit your needs.
#
# useDIZ is set up to only work for users with the +v flag (except for the help
# and join functions). To change this behaviour so that anyone can use the
# commands, change the 'v' in the bind lines below to '-'. For more
# information and a list of flags, consult the eggdrop tcl documentation.
#
# useDIZ has been tested using eggdrop v1.6.19.
# Don't forget to .rehash or start your eggdrop!
#
# Usage:
# ------
#
# On public channel:
#
# !help [section]
# !diz <filename.txt>
# !search <filename.txt>
# !get [[path] <filename>] #requires password set in bot!
# !stats
#
# By private message:
#
# /msg <botnick> !help [section]
# /msg <botnick> !diz <filename.txt>
# /msg <botnick> !search <filename.txt>
#
# On filesystem:
#
# diz <filename.txt>
# search <filename.txt>
#
# Everything else should(tm) work by itself.
#
# Changelog
# ---------
#
# v1.00 -       Initial release
#	v1.01	-				Forgot to add helpfile to distribution archive
#				-				Cleaned up some code, fixed indetions and added some missing
#								non-mandatory return values
# v1.02	-				Added the wrong version script to 1.01 archive. I'm clearly
#								too tired for this right now. Sorry about that
#	v1.10	-				showDIZ now handles file_id.diz parsing internally, thus
#								the external txtdiz command is no longer needed
#				-				Fixed two hardcoded paths in the stats function
#				-				Minor fixes to the helpfile
#				-				Added some return values i had missed
#				-				Added a check if $helpfile is missing
#				-				Forgot to add txtdiz to the distribution after consolidating
#				-				Removed some faulty global variables
#				-				Documented help.txt
#

set channel  "#dL"
set botdir   "/home/esko/eggdrop"
set rootdir  "$botdir/filesys"
set adfile   "$botdir/ad.txt"
set dbfile   "$botdir/db.txt"
set helpfile "$botdir/help.txt"

bind pub - !help help
bind pub - !get get_file
bind pub - !nfo file_id
bind pub - !search search
bind pub - !stats stats
bind fil - nfo file_id_fil
bind fil - search search_fil
bind msg - !help help_msg
bind msg - !nfo file_id_msg
bind msg - !search search_msg
bind rcvd - * insad
bind join - * joining

# You shouldn't really need to edit anything below this line.

set dbdata   ""
set scrver   "diskohost.1.0.0.0.0.infinite"
set author   "esk0disk0"

proc joining { nick uhost hand chan } {
	puthelp "NOTICE $nick :\002 welcome back mighty space explorer\002 || execute \002!help\002 to keep up to date"
}

proc opendb { } {
	global dbfile rootdir dbdata adfile scrver                     
	if { [file exists "$dbfile"] == 0 } {
		putlog "\002$scrver\002 - database file $dbfile \002does not exist\002 - populating"
		exec "/bin/sh" -c "find $rootdir -type f -exec basename {} \\;|sort > $dbfile"
	}  
	if { [file exists "$adfile"] == 0 } {
		putlog "\002$scrver\002 - nfo $adfile \002does not exist\002"
	}
	set opendb [open "$dbfile" r+]
	set dbdata [list]
	while { [gets $opendb line] >= 0 } {
		lappend dbdata $line
	}
	close $opendb
}

proc savedb { } {
	global dbfile dbdata
	set fhandle [open "$dbfile" w]
	foreach element $dbdata { puts $fhandle $element }
	close $fhandle
}

proc matchdb { arg } {
	global dbdata
	expr 1 + [lsearch $dbdata $arg]
}

proc addtodb { arg } {
	global dbdata
	set dbdata [lappend dbdata $arg]
}

opendb

proc insad { hand nick path } {
	global channel botname botdir rootdir adfile scrver author
	if { [string match "$rootdir/*" $path] } {
		set fileout [string range $path [string length $rootdir/] end]
		set output   "i just recieved info about a pre from \002$nick\002. Use \002!nfo $fileout\002 to check the file_id or \002!get $fileout\002 to download."
		if { [matchdb $fileout] } {
			putchan $channel "Filename $fileout \002already exists\002. Removing duplicate"
			file delete "$rootdir/$fileout"
			return 0
		}
		if { [file exists "$adfile"] == 0 } {
			set date "$fileout was uploaded to $botname by $nick [clock format [clock seconds] -format {%a %d %B %Y at %T}]\n\n"
			set fileId1 [open "$path" a]
			set data "\n$scrver by $author\n"
			puts -nonewline $fileId1 $data
			puts -nonewline $fileId1 $date
			close $fileId1
			putchan $channel "$output"
			addtodb $fileout
			savedb
		} else {
			set date "$fileout was uploaded to $botname by $nick [clock format [clock seconds] -format {%a %d %B %Y at %T}]\n\n"
			set fsize [file size "$adfile"]
			set fileId2 [open "$adfile" r]
			set fileId1 [open "$path" a]
			set data [read $fileId2 $fsize]
			puts -nonewline $fileId1 $data
			puts -nonewline $fileId1 $date
			close $fileId1
			close $fileId2
			putchan $channel "$output"
			addtodb $fileout
			savedb
		}
	}
}

proc get_file { nick uhost hand chan args } {
	global rootdir scrver author
	regsub -all -nocase { [^[:alnum:][][$\\]._()!'?^-] } [lindex $args 0] {} arg
	if { [llength $arg] != 1 } {
		putchan $chan "Usage: !get \[\[path\] <filename>\]"
		return 0
	}
	set find "$rootdir/$arg"
	set send [dccsend $find $nick]
	putchan $chan "requesting transfer of $arg to $nick"
	if { [passwdok $hand ""] == 1 } {
		putchan $chan "you have to set a password (or maybe you must identify yourself?). type \002!help register\002 for info"
		return 0
	}
	if { [regexp -all -nocase -- {\.\./} $arg] } {
		putchan $chan "\002illegal path\002"
		return 0
	}
	if { $send == 0 } { putchan $chan "\002ok!\002 sending file" }
	if { $send == 1 } { putchan $chan "too many connections. try again later)" }
	if { $send == 2 } { putchan $chan "can't open a socket for the transfer. try again later" }
	if { $send == 3 } { putchan $chan "the file $arg \002does not exist\002 (maybe you entered the wrong path?)" }
	if { $send == 4 } { putchan $chan "too many simultanious transfers. putting file in queue" }
	if { $send == 5 } { putchan $chan "\002RiP iN THE SPACE-TiME CONTiNUUM! RUN FOR YOUR LiFE!\002" }
	putchan $chan "---==(\\/)- $scrver by $author -(\\/)==---"
	return 1
}

proc search { nick uhost hand chan args } {
	global botdir rootdir scrver author
	regsub -all -nocase { [^[:alnum:][][$\\]._()!'?^-] } [lindex $args 0] {} arg
	if { [llength $arg] != 1 } {
		putchan $chan "Usage: !search <filename.txt>"
		return 0
	}
	set find [exec "sh" -c "find $rootdir -iname $arg"]
	if { [file exists $find] == 0 } {
		putchan $chan "file $arg does not exist"
		return 0
	}
	if { [string match "$rootdir*" $find] } {
		set find2 [string range $find [string length $rootdir] end]
		putchan $chan "$arg was found under path $find2"
		putchan $chan "--==(\\/)- $scrver by $author -(\\/)==--"
	}
	return 1
}

proc search_msg { nick uhost hand args } {
	global botdir rootdir scrver author
	regsub -all -nocase { [^[:alnum:][][$\\]._()!'?^-] } [lindex $args 0] {} arg
	if { [llength $arg] != 1 } {
		puthelp "PRIVMSG $nick :Usage: !search <filename.txt>"
		return 0
  }
	set find [exec "sh" -c "find $rootdir -iname $arg"]
	if { [file exists $find] == 0 } {
		puthelp "PRIVMSG $nick :file $arg does not exist"
		return 0
	}
	if { [string match "$rootdir*" $find] } {
		set find2 [string range $find [string length $rootdir] end]
		puthelp "PRIVMSG $nick :$arg was found under path $find2"
		puthelp "PRIVMSG $nick :--==(\\/)- $scrver by $author -(\\/)==--"
	}
	return 1
}

proc search_fil { hand idx args } {
	global botdir rootdir scrver author
	regsub -all -nocase { [^[:alnum:][][$\\]._()!'?^-] } [lindex $args 0] {} arg
	if { [llength $arg] != 1 } {
		putdcc $idx "Usage: search <filename.txt>"
		return 0
  }
	set find [exec "sh" -c "find $rootdir -iname $arg"]
	if { [file exists $find] == 0 } {
		putdcc $idx "file $arg does not exist"
		return 0
	}
	if { [string match "$rootdir*" $find] } {
		set find2 [string range $find [string length $rootdir] end]
		putdcc $idx "$arg was found under path $find2"
		putdcc $idx "--==(\\/)- $scrver by $author -(\\/)==--"
		return 1
	}
}

proc parse-helpfile-body { handle } {
	set value [list]
	while { [gets $handle line] >= 0 && ![string equal $line "@end"] } {
		lappend value $line
	}
	return $value
}

proc parse-helpfile { } {
	global helpfile scrver
	if { [file exists "$helpfile"] == 0 } {
		putlog "\002$scrver\002 - help file $helpfile \002does not exist\002. !help command will \002not\002 work until this is fixed"
	}
	set fhand [open $helpfile r]
	set value [list]
	while { [gets $fhand line] >= 0 } {
		if { ![regexp {^@(\w+)} $line matchline tag] } {
			continue
		}
		lappend value [list $tag [parse-helpfile-body $fhand]]
	}
	close $fhand
	return $value
}

set helpdata [parse-helpfile]

proc help-for-tag {tag} {
	global helpdata
	foreach element $helpdata {
		if { [lindex $element 0] == $tag } {
			return [lindex $element 1]
		}
	}
	return [lindex [lindex $helpdata 0] 1]
}

proc help { nick uhost hand chan args } {
	regsub -all -nocase { [^[a-z]+] } [lindex $args 0] {} arg
	foreach line [help-for-tag "$arg"] {
		puthelp "PRIVMSG $nick :$line"
	}
}

proc help_msg { nick uhost hand args } {
	regsub -all -nocase { [^[a-z]+] } [lindex $args 0] {} arg
	foreach line [help-for-tag "$arg"] {
		puthelp "PRIVMSG $nick :$line"
	}
}

proc file_stats { } {
	global rootdir
	set du_out [exec "sh" -c "du -s $rootdir"]
	set size [lindex [split $du_out] 0]
	set files [exec "sh" -c "find $rootdir -type f|wc -l"]
	set date "[clock format [clock seconds] -format {%B %d %Y}]"
	return "file archive statistics $date - $size kB in $files files"
}

proc stats { nick uhost hand chan args } {
	putchan $chan [file_stats]
}    

proc file_id-body { handle } {
	set value [list]
	while { [gets $handle line] >= 0 && ![string equal $line "@END_FILE_ID.DIZ"] } {
		lappend value $line
	}
	return $value
}

proc parse-file_id { args } {
	putlog "$args"
	set fhand [open $args r]
	set value [list]
	while { [gets $fhand line] >= 0 } {
		if { ![regexp {^@BEGIN_FILE_ID.DIZ(.*)} $line matchline line0] } {
			continue
		}
		if {[string length $line0] == 0} {
			set value [file_id-body $fhand]
		} else {
			set value [concat [list $line0] [file_id-body $fhand]]
		}
	}
	close $fhand
	return $value
}

proc file_id { nick uhost hand chan args } {
	global botdir rootdir scrver author
	regsub -all -nocase { [^[:alnum:][][$\\]._()!'?^-] } [lindex $args 0] {} arg
	if { [llength $arg] != 1 } {
		putchan $chan "Usage: !diz <filename.txt>"
		return 0
	}
	set find [exec "sh" -c "find $rootdir -iname $arg"]
	if { [file exists $find] == 0 } {
		putchan $chan "file $arg does not exist"
		return 0
	}
	set showdiz [parse-file_id $find]
	if { [llength $showdiz] == 0 } {
		putchan $chan "the file $arg seems to lack a file_id.diz"
		return 0
	}
	if { [string match "$rootdir*" $find] } {
		set find2 [string range $find [string length $rootdir] end]
	}
	putchan $chan "-=( showing file_id.diz of $arg )=-"
	foreach line $showdiz {
		putchan $chan "$line"
	}
	putchan $chan "file size of $arg is [file size $find] bytes"
	putchan $chan "found under path $find2"
	putchan $chan "--==(\\/)- $scrver by $author -(\\/)==--"
	return 1
}

proc file_id_msg { nick uhost hand args } {
	global botdir rootdir scrver author
	regsub -all -nocase { [^[:alnum:][][$\\]._()!'?^-] } [lindex $args 0] {} arg
	if { [llength $arg] != 1 } {
		puthelp "PRIVMSG $nick :Usage: !diz <filename.txt>"
		return 0
	}
	set find [exec "sh" -c "find $rootdir -iname $arg"]
	if { [file exists $find] == 0 } {
		puthelp "PRIVMSG $nick :file $arg does not exist"
		return 0
	}
	set showdiz [parse-file_id $find]
	if { [llength $showdiz] == 0 } {
		puthelp "PRIVMSG $nick :the file $arg seems to lack a file_id.diz"
		return 0
	}
	if { [string match "$rootdir*" $find] } {
		set find2 [string range $find [string length $rootdir] end]
	}
	puthelp "PRIVMSG $nick :-=( showing file_id.diz of $arg )=-"
	foreach line $showdiz {
		puthelp "PRIVMSG $nick :$line"
	}
	puthelp "PRIVMSG $nick :file size of $arg is [file size $find] bytes"
	puthelp "PRIVMSG $nick :found under path $find2"
	puthelp "PRIVMSG $nick :--==(\\/)- $scrver by $author -(\\/)==--"
	return 1
}

proc file_id_fil { hand idx args } {
	global botdir rootdir scrver author
	set userdir [getuser $hand DCCDIR]
	regsub -all -nocase { [^[:alnum:][][$\\]._()!'?^-] } [lindex $args 0] {} arg
	if { [llength $arg] != 1 } {
		putdcc $idx "Usage: diz <filename.txt>"
		return 0
	}
	set find "$rootdir/$userdir/$arg"
	if { [file exists $rootdir/$userdir/$arg] == 0 } {
		putdcc $idx "file $arg does not exist under /$userdir"
		return 0
	}
	set showdiz [parse-file_id $find]
	if { [llength $showdiz] == 0 } {
		putdcc $idx "the file $arg seems to lack a file_id.diz"
		return 0
	}
	putdcc $idx "-=( showing file_id.diz of $arg )=-"
	foreach line $showdiz {
		putdcc $idx "$line"
	}
	putdcc $idx "--==(\\/)- $scrver by $author -(\\/)==--"
	return 1
}

putlog "\002$scrver\002 by $author"
