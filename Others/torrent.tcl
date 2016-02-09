# Mysql-IRC v7.4 COMPL3T3 SCRiPT
# By sCRiPTzTEAM :)
# Special thanks to TBDEV.NET
# Greets to TBDEV members, P2P.IN, and YOU.
# This script is coded by combining various other scripts and this is the best one ever !!!
# It took many many long hours to code this script, so please leave credit to whom it deservers ie for the original
# creators of the scripts. Sorry i cant find all the names of creators but some of then are redline, pdq, ...)
# FiSH , BlowFiSH support for the staff channels :D
package require mysqltcl

# Enter in your MySQL connection data
set mysql_(user) "siteuser"
set mysql_(password) "xxx"
set mysql_(host) "localhost"
set mysql_(db) "site"

#Site URL
set site_url "https://example.com"

# botlisten port for your script you want to listen on (you need to set same port in php script)
# listen port number should be always higher than 34000
set botlisten_(port) "30035"

# botlisten password (you need to set same password in php script)
set botlisten_(password) "xxx"

# Self-Explanatory! Set main chan to your main chan of choice! and same for other channels.
# USE LOWER LETTERS FOR CHANNEL Names. Ex: "#MainChannel" should be "#mainchannel"
# If any of the channel is not required leave that channel BLANK.
set chann_(main) "#main"
set chann_(fls) ""
set chann_(vip) ""
set chann_(uploaders) "#uploaders"
set chann_(staff) "#staff"
set chann_(staffelite) ""
set chann_(log) "#staff"
set chann_(support) "#support"
set chann_(rippers) "#xxx"

# Set the numbers to the class numbers defined in site.
# Set the user class name to the name of that particular class number.
# user class name and number is VERY IMPROTANT , even <space> also makes a BIG difference
# both class number and name should be 100% matching or else the INVITE script will fuck up and 
# it might result in wrong class members to be invited to higher channels like staff channels etc...
array set classes_replace { 
		"1"         "Noob"
        "2"         "User"
        "3"         "Power User"
        "4"         "VIP"
        "5"         "Uploader"
        "6"         "Administrator"
	}
	
# Set this to the user class numbers defined. Read above ^^^ very important.
set class_(main) "0"
set class_(vip) "4"
set class_(rippers) "42"
set class_(uploaders) "5"
set class_(staff) "6"
set class_(staffelite) "8"

# Set this to the main channel welcome message announce minimum class number. Read above ^^^ very important.
set class_(welcome) "4"

# Announces releases in irc channels set to 1, if you want to disable then set this option to 0.
set ann_(log) "0"
set ann_(welcomemsg) "1"
set ann_(newtorrent) "1"

# set to 1 for enabling blowcrypt for staff channels only OR 0 for plain text.
set blowfish_(enabled) "0"

# blowfish channel key if not used leave BLANK.
set blowfish_(key) "blowfish-channel-key"
set fishkey_(rippers) "xxx"

# Bracket Types. Look below for color codes.
set bracket_(open) "\00315\[\003 "
set bracket_(close) " \00315\]\003"
set bracket_(divider) " \00315\|\003 "

# Color code list precede a color with \003<code> and append \003 to clear the color
#  0 white
#  1 black
#  2 blue     (navy)
#  3 green
#  4 red
#  5 brown    (maroon)
#  6 purple
#  7 orange   (olive)
#  8 yellow
#  9 lt.green (lime)
#  10 teal    (a kinda green/blue cyan)
#  11 lt.cyan (cyan ?) (aqua)
#  12 lt.blue (royal)
#  13 pink    (light purple) (fuchsia)
#  14 grey
#  15 lt.grey (silver)

set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]

# * v - voice
# * o - op
# * m - master
# * n - owner
# * f - friend
# * p - partyline access

#other binds
bind join - "$chann_(main) *" isy:joinchan
bind part - "$chann_(main) *" isy:partchan
bind sign - "$chann_(main) *" isy:signchan
bind nick - "$chann_(main) *" isy:nickchan
bind rejn - "$chann_(main) *" isy:joinchan
bind kick - "$chann_(main) *" isy:kickchan
bind evnt - init-server evnt:init_server

bind dcc n rehashme isy:rehash

#user-cmds
bind msg -|- invite isy:invite_mein
bind pub -|- !help isy:userhelp
bind pub -|- !torrent user_torrent
bind pub -|- !req find_req
bind pub -|- !findtorrent find_torrent
bind pub -|- !section last_torrent
bind pub -|- !user isy:userglobal
bind pub -|- !u isy:userglobal
bind pub -|- !stats stats_torrent

#admin-cmds
bind pub -|- .help isy:adminhelp
bind pub -|- .info isy:usermod
bind pub -|- .user isy:userstaff
bind pub -|- .u isy:userstaff
bind pub -|- .finduser isy:usersearch
bind pub -|- .irc isy:checkircount
bind pub -|- .ip isy:ipsearch
bind pub -|- .unban isy:unbanuser
bind pub -|- .ban isy:banuser

# Blowfish decrypt command
if {$blowfish_(enabled) == 1} {
	bind pub - +OK cmdencryptedincominghandler
}

#IRC - ON START
proc evnt:init_server {type} {
  global botnick chann_
  putquick "MODE $botnick +i-ws"
  putserv "PRIVMSG nickserv :IDENTIFY xxx"
  putserv "PRIVMSG chanserv :INVITE $chann_(main)"
  putserv "PRIVMSG chanserv :INVITE $chann_(staff)"
  putserv "PRIVMSG chanserv :INVITE $chann_(fls)"
  putserv "PRIVMSG chanserv :INVITE $chann_(uploaders)"
  putserv "PRIVMSG chanserv :INVITE $chann_(vip)"
  putserv "PRIVMSG chanserv :INVITE $chann_(rippers)"
  putserv "PRIVMSG chanserv :INVITE $chann_(staffelite)"
  putserv "PRIVMSG chanserv :INVITE $chann_(log)"
  putserv "PRIVMSG chanserv :INVITE $chann_(support)"
  putquick "/join $chann_(main) CHANNEL-KEY-IF-SET"
}
#IRC - ON START END

proc mysql:keepalive {} {
	global db_handle mysql_
	
	if {[catch {mysql::ping $db_handle} error] || ![mysql::ping $db_handle]} {
		set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
	}

	utimer 120 [list mysql:keepalive]
	
	return 0
}

mysql:keepalive

# Get Userclass Name Function
proc isy:getclassname { arg } {
 global classes_replace 
 
	set class [lindex $arg 0]
	
    foreach {classno replace} [array get classes_replace] {
        
		if { $classno == $class } {
			return $replace
		}
    }
	
}

# User IRC Bonus Enable, Kick & Users Modes settings Function
proc isy:ircenable { nick uhost hand chan } {
 global db_handle chann_ class_ botnick ann_ 

	set chan [string tolower $chan]
	if { $chan != $chann_(main) } { return 0 }
	
	if { ![botonchan $chan] } { return 0 }
	
	if { ![botisop $chan] } { return 0 }
	
	set nick [::mysql::escape $nick]
	
	if { [isbotnick $nick] } { return 0 }
	
	if { ![onchan $nick $chan] } { return 0 }
	
	set sql "SELECT username, class, warned, support, donor FROM users WHERE username='$nick' AND enabled='yes'"
	set result [mysqlsel $db_handle $sql]
	
	if { $result == "0" } {
		
		isy:kickuser $nick
		putquick "KICK $chan $nick"
		putquick "PRIVMSG $nick :NOT Found $nick in Database or banned. Invited you to $chann_(support)"
		putquick "INVITE $nick $chann_(support)"
		
		cmdputblow "PRIVMSG $chann_(log) :KICKED \002$hand\002 ($nick!$uhost) from $chan by $botnick \002Reason: NOT Found the $nick in Database or banned\002 . Invited $nick to $chann_(support)"
		
		return 0
		
	} elseif { $result == "1" } {
		
		mysqlmap $db_handle {username class warned flsmember donated} {}
		
		set sqlx "UPDATE users SET onirc = 'yes', irccheck='yes' WHERE username='$username' AND enabled='yes' LIMIT 1"
		set resultx [mysqlexec $db_handle $sqlx]
		
		if { $result == "1" } {
			
			puthelp "NOTICE $nick :User Online: \002$nick\002 - IRC bonus enabled."
			
			if { $class >= $class_(welcome) && $ann_(welcomemsg) == "1" } {
				
				set classname [isy:getclassname $class]
				putquick "PRIVMSG $chan :Welcome To Our $classname - $nick"
			}
			
			if { $class >= $class_(staff) && ![isop $nick $chan] } {
				putquick "MODE $chan +o $nick"
			}
			
			if { $flsmember == "yes" && $warned == "no" && ![ishop $nick $chan] } {
				putquick "MODE $chan +h $nick"
			}
			
			if { ($class >= $class_(vip) && $warned == "no") || ($donated == "yes" && $warned == "no") } {
				if { ![isvoice $nick $chan] } {
					putquick "MODE $chan +v $nick"
				}
			}
			
			isy:processlog "PRIVMSG $chann_(log) :User Online: \002$nick\002 - IRC bonus enabled."
			
		}
	}
	
	mysqlendquery $resultx
	mysqlendquery $result
	
}

# User IRC Bonus Disable, Ban & Kick Function
proc isy:ircdisable { nick uhost hand chan } {
 global db_handle chann_ botnick 

	set chan [string tolower $chan]
	if { $chan != $chann_(main) } { return 0 }
	
	if { ![botonchan $chan] } { return 0 }
	
	if { ![botisop $chan] } { return 0 }
	
	set nick [::mysql::escape $nick]
	
	if { [isbotnick $nick] } { return 0 }
	
	set sql "UPDATE users SET onirc = 'no', irccheck='no' WHERE username = '$nick' LIMIT 1"
	set result [mysqlexec $db_handle $sql]
	
	if { $result == "0" } {
		
		set sql "SELECT COUNT(id) FROM users WHERE username='$nick'"
		set founduser [mysqlsel $db_handle $sql]
		
		if { $founduser == "0" } {
			
			set onick [hand2nick $hand $chan]
			set banreason "NOT a Member of this site"
			set host "*![getchanhost $onick $chan]"
			newchanban $chan $host $botnick $banreason
			putquick "KICK $chan $onick"
			isy:kickuser $onick
			
			cmdputblow "PRIVMSG $chann_(staff) :\002$nick\002 NOT found in database but was ideling in $chan . KICKED & BANNED $onick from $chan"
			
		}
		
		return 0
		
	} elseif { $result == "1" } {
		
		puthelp "NOTICE $nick :User Offline: \002$nick\002 - IRC bonus disabled."
		
		isy:processlog "PRIVMSG $chann_(log) :User Offline: \002$nick\002 - IRC bonus disabled."
		
		if { [onchan $nick $chann_(main)] } {
			putquick "KICK $chann_(main) $nick"
		}
		
		return 1
		
	}
	
	mysqlendquery $founduser
	mysqlendquery $result
	
}

# User Has Quit Channel Function
proc isy:signchan {nick uhost hand chan reason} {
	isy:ircdisable $nick $uhost $hand $chan
}

# User Has Left Channel Function
proc isy:partchan {nick uhost hand chan reason} {
	isy:ircdisable $nick $uhost $hand $chan
}

# User Kicked from Channel Function
proc isy:kickchan {nick uhost hand chan knick reason} {
	isy:ircdisable $nick $uhost $hand $chan
	isy:ircdisable $knick $uhost $hand $chan
}

# New User Join Channel Function
proc isy:joinchan {nick uhost hand chan} {
	isy:ircenable $nick $uhost $hand $chan
}

# User Nick change in Channel Function
# Better set the channel to +N mode so that users cant change there nicks when on that channel
proc isy:nickchan {nick uhost hand chan newnick} {

	set isok [isy:ircdisable $nick $uhost $hand $chan]
	
	if { $isok == "1" } {
		isy:ircenable $newnick $uhost $hand $chan
	}
}

# Bot Rehash Function
proc isy:rehash {hand idx arg} {
  putlog "Rehashing myself..."; rehash
}

# IRC Status Count, Match & Send Fix Command Function
proc isy:checkircount {nick host hand chan arg} {
  global db_handle chann_ botnick 
  
	set chan [string tolower $chan]
	if { $chan != $chann_(staff) } { return 0 }
	
	if { ![botonchan $chan] } { return 0 }
	
	if { ![botisop $chan] } { return 0 }
	
	if { [isbotnick $nick] } { return 0 }
	
	set sql "SELECT id FROM users WHERE onirc='yes'"
	set ircstatus [mysqlsel $db_handle $sql]
	
	set ircount [llength [chanlist $chann_(main)]]
	# 3 Bots on channel
	set ircount [expr $ircount - 3]
	
	if {$ircstatus > 0}  {
		
		append inargs "There are $ircount in the IRC channel $chann_(main) & "
		append inargs "$ircstatus have there IRC Status enabled in site. There are 3 Bots on $chann_(main)"
		
		cmdputblow "PRIVMSG $chann_(staff) :$inargs"
		
		if { $ircount != $ircstatus } {
			
			if { $ircstatus > $ircount }  {
				
				set diff [expr $ircstatus - $ircount]
				
			} elseif { $ircount > $ircstatus }  {
				
				set diff [expr $ircount - $ircstatus]
			}
			
			cmdputblow "PRIVMSG $chann_(staff) :\002There is a difference of $diff users in IRC Status, fixing it now. \002"
			
			isy:fixircidelusers $chann_(main)
			
		}
		
	} else {
		
		cmdputblow "PRIVMSG $chann_(staff) :There are $ircount in the IRC channel $chann_(main) but No users have there IRC Status enabled in site."
		
	}
	
	mysqlendquery $ircstatus
	
}

# IRC Status Fix & Send IRC Status Count Command Function
proc isy:fixircidelusers {chan} {
  global db_handle chann_ 
  
	set chan [string tolower $chan]
	if { $chan != $chann_(main) } { return 0 }
	
	set sqle "UPDATE users SET ircban='yes' WHERE enabled='no'"
	set resulte [mysqlsel $db_handle $sqle]
	
	set sqlfi "UPDATE users SET ircban='no' WHERE enabled='yes'"
	set resultfi [mysqlsel $db_handle $sqlfi]
	
	set sql "UPDATE users SET irccheck='no'"
	set result [mysqlsel $db_handle $sql]
	
	if {$result == 0}  { return 0 }
	
	set chanmemb [chanlist $chan]
	#set finalChanlist [join [lsort [chanlist $chan]] ", "]
	
	foreach mem $chanmemb {
		
		set nick [::mysql::escape $mem]
		
		set sqlu "UPDATE users SET irccheck='yes', onirc='yes' WHERE username='$nick'"
		set resultu [mysqlsel $db_handle $sqlu]
		
	}
	
	append final "Updated Users IRC Status. "
	set count 0
	
	set sql1 "SELECT username, class, enabled, ircban FROM users WHERE onirc='yes' AND irccheck='no' ORDER BY class DESC"
	set result1 [mysqlsel $db_handle $sql1 -flatlist]
	
	if {$result1 != ""} {
		
		foreach {username class enabled ircban} $result1 {
			
			set sqlx "UPDATE users SET irccheck='no', onirc='no' WHERE username='$username'"
			set resultx [mysqlsel $db_handle $sqlx]
			
			set count [expr $count + 1]
			set classname [isy:getclassname $class]
			
			if { $enabled == "no" || $ircban == "yes" } {
				isy:kickuser $username
				append whois "\0034\002$username\002\($classname\)\003"
			} else {
				append whois "\002$username\002\($classname\)"
			}
			
			set whoall [join $whois ", "]
		}
		
		append final "Found $count users who are \n $whoall \n with IRC Status enable but there IRC Status is fixed now."
	}
	
	cmdputblow "PRIVMSG $chann_(staff) :$final"
	
	isy:checkircount $nick $host $hand $chan $arg
	
	mysqlendquery $resulte
	mysqlendquery $resultfi
	mysqlendquery $resultu
	mysqlendquery $result
	mysqlendquery $resultx
	mysqlendquery $result1

}

# Global Channels Kick User Function
proc isy:kickuser { nick } {
  global chann_ botnick 
	
	if { [isbotnick $nick] } { return 0 }
	
	if { [onchan $nick $chann_(main)] == 1 && $chann_(main) != "" && [botonchan $chann_(main)] == 1 && [botisop $chann_(main)] == 1 } {
		putquick "KICK $chann_(main) $nick"
		append where "$chann_(main) "
	}
	
	if { [onchan $nick $chann_(fls)] == 1 && $chann_(fls) != "" && [botonchan $chann_(fls)] == 1 && [botisop $chann_(fls)] == 1 } {
		putquick "KICK $chann_(fls) $nick"
		append where "$chann_(fls) "
	}
	
	if { [onchan $nick $chann_(vip)] == 1 && $chann_(vip) != "" && [botonchan $chann_(vip)] == 1 && [botisop $chann_(vip)] == 1 } {
		putquick "KICK $chann_(vip) $nick"
		append where "$chann_(vip) "
	}
	
	if { [onchan $nick $chann_(rippers)] == 1 && $chann_(rippers) != "" && [botonchan $chann_(rippers)] == 1 && [botisop $chann_(rippers)] == 1 } {
		putquick "KICK $chann_(rippers) $nick"
		append where "$chann_(rippers) "
	}
	
	if { [onchan $nick $chann_(uploaders)] == 1 && $chann_(uploaders) != "" && [botonchan $chann_(uploaders)] == 1 && [botisop $chann_(uploaders)] == 1 } {
		putquick "KICK $chann_(uploaders) $nick"
		append where "$chann_(uploaders) "
	}
	
	if { [onchan $nick $chann_(staff)] == 1 && $chann_(staff) != "" && [botonchan $chann_(staff)] == 1 && [botisop $chann_(staff)] == 1 } {
		putquick "KICK $chann_(staff) $nick"
		append where "$chann_(staff) "
	}
	
	if { [onchan $nick $chann_(staffelite)] == 1 && $chann_(staffeilte) != "" && [botonchan $chann_(staffelite)] == 1 && [botisop $chann_(staffelite)] == 1 } {
		putquick "KICK $chann_(staffelite) $nick"
		append where "$chann_(staffelite) "
	}
	
	if { [onchan $nick $chann_(log)] == 1 && $chann_(log) != "" && [botonchan $chann_(log)] == 1 && [botisop $chann_(log)] == 1 } {
		putquick "KICK $chann_(log) $nick"
		append where "$chann_(log) "
	}
	
	puthelp "NOTICE $nick :Site Banned: \002$nick\002 - Kicked from $where site channels. Invited you to $chann_(support)"
	putquick "INVITE $nick $chann_(support)"
	
	cmdputblow "PRIVMSG $chann_(staff) :Site Banned: \002$nick\002 - Kicked from $where site channels. Invited $nick to $chann_(support)"
	
}

# Users Commands PM Function
proc isy:userhelp {nick uhost hand chan arg} {
  global chann_ botnick 
  
	set chan [string tolower $chan]
	if { $chan != $chann_(main) } { return 0 }
	
	if { ![botonchan $chan] } { return 0 }
	
	if { ![botisop $chan] } { return 0 }
	
	if { [isbotnick $nick] } { return 0 }
	
	putquick "PRIVMSG $chann_(main) :Sending help to $nick in query."
	putquick "PRIVMSG $nick :User Torrent Commands:"
	putquick "PRIVMSG $nick :\002 All the below commands will \002ONLY\002 work in $chann_(main) channel.\002"
	putquick "PRIVMSG $nick :----------------------------------------------------------------------------------------"
	putquick "PRIVMSG $nick :/msg $botnick invite <ircpasskey> -> Invites you to the \002suitable\002 irc channels."
	putquick "PRIVMSG $nick :!torrent <string> -----------------> Displays the newest torrents 1 result."
	putquick "PRIVMSG $nick :!findtorrent <string> -------------> PM's the newest torrents 10 results."
	putquick "PRIVMSG $nick :!user -----------------------------> Displays your Profile Infos."
	putquick "PRIVMSG $nick :!section <section> ----------------> PM's the last 10 torrents uploaded to that section."
	putquick "PRIVMSG $nick :!stats ----------------------------> Displays trackers stats users,seeds..etc"
	putquick "PRIVMSG $nick :!count ----------------------------> Displays the IRC count and Site Database IRC count."
	putquick "PRIVMSG $nick :----------------------------------------------------------------------------------------"

}

# Staff Commands PM Function
proc isy:adminhelp {nick uhost hand chan arg} {
  global chann_ botnick 
  
	set chan [string tolower $chan]
	if { $chan != $chann_(staff) } { return 0 }
	
	if { ![botonchan $chan] } { return 0 }
	
	if { ![botisop $chan] } { return 0 }
	
	if { [isbotnick $nick] } { return 0 }
	
	cmdputblow "PRIVMSG $chann_(staff) :Sending help to $nick in query."
	cmdputblow "PRIVMSG $nick :Admin Torrent Commands:"
	cmdputblow "PRIVMSG $nick :\002 All the below commands will \002ONLY\002 work in $chann_(staff) channel.\002"
	cmdputblow "PRIVMSG $nick :--------------------------------------------------------------------------------------------"
	cmdputblow "PRIVMSG $nick :.user <user> ------> Shows \002Advanced\002 users details."
	cmdputblow "PRIVMSG $nick :.finduser <query> -> Displays 10 matching query nicks."
	cmdputblow "PRIVMSG $nick :.info <user> ------> Shows users Mod Comment history."
	cmdputblow "PRIVMSG $nick :.irc --------------> Check the site and $chann_(main) channel user count & fix if necessary."
	cmdputblow "PRIVMSG $nick :.ip <ip> ----------> Show IP history and if banned or not."
	cmdputblow "PRIVMSG $nick :.ban <username> ---> Enables users Site and IRC Status."
	cmdputblow "PRIVMSG $nick :.unban <username> -> Disables users Site and IRC Status."
	cmdputblow "PRIVMSG $nick :--------------------------------------------------------------------------------------------"

}

proc find_torrent {nick host handle channel text} {
 
  global db_handle site_add
	
	set sql "SELECT id, name, size, unix_timestamp(added) FROM torrents WHERE name LIKE '%$text%' ORDER BY unix_timestamp(added) DESC LIMIT 6"
	set result [mysqlsel $db_handle $sql -list]
	
	set sendMessage ""
	set currentTorrent ""
	
	if {$result > 0} {
	set numberOfTorrentsFound [llength $result]
	if { [llength $result] > 1} {
	if { [llength $result] > 5} {
	append sendMessage "\002Found\002 $numberOfTorrentsFound \002Torrents, Sending Details\002 in private.\002"
	} else {
	append sendMessage "\002Found\002 $numberOfTorrentsFound \002Torrents, Sending Details\002 in private.\002"
	}					
	} else {
	append sendMessage "\002Found\002 1 \002Torrent, details in private"
	}   
	putquick "PRIVMSG $channel :$sendMessage"
	puthelp "PRIVMSG $nick :\002Torrents:"
	set sendMessage ""
	for { set number 0 } { $number < [llength $result] && ($number < 5) } { incr number } {
	set sendMessage ""
	set record [lindex $result $number];
	set id [lindex $record 0];
	set name [lindex $record 1];
	set size [lindex $record 2];			
	
	set sized "0 kB"
	if {[expr $size / 1024] >= 1} {set sized "[string range "[expr $size / 1024.0]" 0 [expr [string length "[expr $size / 1024]"]+ 2] ] KB"};
	if {[expr $size / 1048576] >= 1} {set sized "[string range "[expr $size / 1048576.0]" 0 [expr [string length "[expr $size / 1048576]"]+ 2] ] MB"};
	if {[expr $size / 1073741824] >= 1} {set sized "[string range "[expr $size / 1073741824.0]" 0 [expr [string length "[expr $size / 1073741824]"]+ 2] ] GB"};
	
	set currentTorrent "$name \002-\002 $sized \002-\002 $site_add/details.php?id=$id"
	
	append sendMessage "[expr ($number+1)]: $currentTorrent "
	
	puthelp "PRIVMSG $nick :$sendMessage"
	}
	} else {
	puthelp "NOTICE $nick :\002No matches\002 : Please try again"
	}
}

proc find_req {nick host handle channel text} {
 
  global db_handle site_add
	
	set sql "SELECT id, request, hits FROM requests WHERE filled='no' AND request LIKE '%$text%' ORDER BY added DESC LIMIT 6"
	set result [mysqlsel $db_handle $sql -list]
	
	set sendMessage ""
	set currentTorrent ""
	
	if {$result > 0} {
	set numberOfTorrentsFound [llength $result]
	if { [llength $result] > 1} {
	if { [llength $result] > 5} {
	append sendMessage "\002Found\002 $numberOfTorrentsFound \002Torrents, Sending Details\002 in private.\002"
	} else {
	append sendMessage "\002Found\002 $numberOfTorrentsFound \002Torrents, Sending Details\002 in private.\002"
	}					
	} else {
	append sendMessage "\002Found\002 1 \002Torrent, details in private"
	}   
	putquick "PRIVMSG $channel :$sendMessage"
	puthelp "PRIVMSG $nick :\002Torrents:"
	set sendMessage ""
	for { set number 0 } { $number < [llength $result] && ($number < 5) } { incr number } {
	set sendMessage ""
	set record [lindex $result $number];
	set id [lindex $record 0];
	set request [lindex $record 1];
	set hits [lindex $record 2];
	
	if {$hits == "1"} {set hitz "hit"}
	if {$hits != "1"} {set hitz "hits"}
	
	set currentTorrent "$request \002-\002 $hits $hitz \002-\002 $site_add/viewrequests.php?id=$id\&req_details=1"
	
	append sendMessage "[expr ($number+1)]: $currentTorrent "
	
	puthelp "PRIVMSG $nick :$sendMessage"
	}
	} else {
	puthelp "NOTICE $nick :\002No matches\002 : Please try again"
	}
}

proc user_torrent {nick host handle channel text} {
  
  global db_handle site_add
	
	set sql "SELECT id, name, size, unix_timestamp(added), leechers, seeders FROM torrents WHERE name LIKE '%$text%' ORDER BY added DESC LIMIT 1"
	set result [mysqlsel $db_handle $sql -list]
	
	if {$result > 0} {
	set record [lindex $result 0];
        set id [lindex $record 0];
	set name [lindex $record 1];
        set size [lindex $record 2];
        set added [lindex $record 3];
        set added [duration [expr [clock seconds] - $added]];
        set durationList [split $added]
	set added [lrange $durationList 0 3]
        set leechers [lindex $record 4];
        set seeders [lindex $record 5];
	
	set sized "0 kB"
        if {[expr $size / 1024] >= 1} {set sized "[string range "[expr $size / 1024.0]" 0 [expr [string length "[expr $size / 1024]"]+ 2] ] KB"};
        if {[expr $size / 1048576] >= 1} {set sized "[string range "[expr $size / 1048576.0]" 0 [expr [string length "[expr $size / 1048576]"]+ 2] ] MB"};
        if {[expr $size / 1073741824] >= 1} {set sized "[string range "[expr $size / 1073741824.0]" 0 [expr [string length "[expr $size / 1073741824]"]+ 2] ] GB"};
	
	putquick "PRIVMSG $channel :\002Torrent:\002 $name"
	putquick "PRIVMSG $channel :\002Link:\002    $site_add/details.php?id=$id"
	putquick "PRIVMSG $channel :\002Added:\002   $added ago"
	putquick "PRIVMSG $channel :\002Size:\002    $sized - Seeders: [format %2s $seeders] - Leechers: [format %2s $leechers]"
	} else {
	puthelp "NOTICE $nick :\002No matches\002 : Please try again"
	}
}

# Staff User Search Query Function
proc isy:usersearch {nick host hand chan arg} {
  global chann_ botnick db_handle 
  
	set chan [string tolower $chan]
	if { $chan != $chann_(staff) } { return 0 }
	
	if { ![botonchan $chan] } { return 0 }
	
	if { ![botisop $chan] } { return 0 }
	
	if { $arg == "" } { return 0 }
	
	if { $nick == $botnick } { return 0 }
	
	if { ![onchan $nick $chan] } { return 0 }
	
	set args [::mysql::escape $arg]
	
	set str [string map [list "*" "%" " " "%"] $args]
	
	set sql "SELECT username FROM users WHERE username LIKE '%$str%' ORDER BY username ASC LIMIT 10" 
	set result [mysqlsel $db_handle $sql -list]
	
	if {$result > 0} {
		
		set ufound [llength $result]
		
		if { $ufound > 1} {
			
			if { $ufound > 10} {
				append sendMessage "\002Found\002 $ufound \002Users,\002 showing:"
			} else {
				append sendMessage "\002Found\002 $ufound \002Users:\002"
			}
			
		} else {
			
			append sendMessage "\002Found User:\002"
			
		}
		
		for { set number 0 } { $number < $ufound && ($number < 10) } { incr number } {
			
			append sendMessage " [expr ($number+1)]: [lindex $result $number] "
		}
		
		cmdputblow "PRIVMSG $chann_(staff) :$sendMessage"
		
	} else {
		cmdputblow "PRIVMSG $chann_(staff) :\002No matches\002 for $arg , Please refine your search query & try again."
	}
	
	mysqlendquery $result
	
}

proc isy:inirctotal { timeis } {
	
	set time1 [lindex $timeis 0]
	set finago [string map {" years" "yrs" " weeks" "wks" " days" "dys" " hours" "hrs" " minutes" "mins" " seconds" "secs" " year" "yr" " week" "wk" " day" "dy" " hour" "hr" " minute" "min" " second" "sec"} [duration $time1]]
	#regsub -all -- { }                       $finago "" finago
	
	return $finago
}

# User Info Staff Function
proc isy:userstaff {nick host hand chan arg} {
  global chann_ botnick db_handle site_url 

	set chan [string tolower $chan]
	if { $chan == $chann_(main) || $chan == $chann_(staff) || $chan == $chann_(support) } {
	
	if { ![botonchan $chan] } { return 0 }
	
	if { ![botisop $chan] } { return 0 }
	
	set who [::mysql::escape $nick]
	set nickc [::mysql::escape $nick]
	
	if { [isbotnick $who] } { return 0 }
	
	set usersql "SELECT class FROM users WHERE username='$nickc'"
	set userresult [mysqlsel $db_handle $usersql]
	mysqlmap $db_handle {userclass} {}
	
	if { $userclass >= "60" && $arg != "" } {
		set who [::mysql::escape $arg]
	}
	
	set sql "SELECT id, username, class, downloaded, uploaded, enabled, irctotal, onirc FROM users WHERE username='$who' LIMIT 1"
	set result [mysqlsel $db_handle $sql]
	
	if {$result == 1} {
		
		mysqlmap $db_handle {id username class download upload enabled irctotal onirc} {}
		
		if {$class > $userclass} {
			putquick "PRIVMSG $chan :You dont have permissions to view \002$who\002\'s info"
		} else {
			
			if {$enabled == "yes"} { append status "\[ Enabled |" } elseif {$enabled == "no"} { append status "\[ Disabled |" }
			if {$onirc == "yes"} { append status " ON IRC \]" } elseif {$onirc == "no"} { append status " OFF IRC \]" }
			
			set uploaded "0 kB"
			if {$upload > 0} {
				if {[expr $upload / 1024] >= 1} {set uploaded "[string range "[expr $upload / 1024.0]" 0 [expr [string length "[expr $upload / 1024]"]+ 2] ] kB"};
				if {[expr $upload / 1048576] >= 1} {set uploaded "[string range "[expr $upload / 1048576.0]" 0 [expr [string length "[expr $upload / 1048576]"]+ 2] ] MB"};
				if {[expr $upload / 1073741824] >= 1} {set uploaded "[string range "[expr $upload / 1073741824.0]" 0 [expr [string length "[expr $upload / 1073741824]"]+ 2] ] GB"};				
				if {[expr $upload / 1099511627776] >= 1} {set uploaded "[string range "[expr $upload / 1099511627776.0]" 0 [expr [string length "[expr $upload / 1099511627776]"]+ 2] ] TB"};
			}
			
			set downloaded "0 kB"
			if {$download > 0} {
				if {[expr $download / 1024] >= 1} {set downloaded "[string range "[expr $download / 1024.0]" 0 [expr [string length "[expr $download / 1024]"]+ 2] ] kB"};
				if {[expr $download / 1048576] >= 1} {set downloaded "[string range "[expr $download / 1048576.0]" 0 [expr [string length "[expr $download / 1048576]"]+ 2] ] MB"};
				if {[expr $download / 1073741824] >= 1} {set downloaded "[string range "[expr $download / 1073741824.0]" 0 [expr [string length "[expr $download / 1073741824]"]+ 2] ] GB"};
				if {[expr $download / 1099511627776] >= 1} {set downloaded "[string range "[expr $download / 1099511627776.0]" 0 [expr [string length "[expr $download / 1099511627776]"]+ 2] ] TB"};
			}
			
			if {$download > 0} {
				set ratio [expr $upload / ($download + 0.0)]
				set ratio [format %.4f $ratio]
				set ratio [format %.3f $ratio]
			} elseif {$upload > 0} {
				set ratio "Inf"
			} elseif {$download == 0 && $upload == 0} {
				set ratio "---"
			}
			
			set classname [isy:getclassname $class]
			
			if { $irctotal == 0 } {
				append ircidle "Never Seen in IRC"
			} else {
				set interval [expr 60*30*4]
				append ircidle "Points -> [expr [expr $irctotal / $interval] *2]"
				append ircidle " \([isy:inirctotal $irctotal]\)"
			}
			
			putquick "PRIVMSG $chan :User: $username \($classname\) / $status / Uploaded: \($uploaded\) / Downloaded: \($downloaded\) / IRC Bonus: $ircidle / Ratio: \($ratio\) / Profile: $site_url/userdetails.php?id=$id"
			
		}
		
	} else {
		
		putquick "PRIVMSG $chan :\002No matches\002 found for $who in Database."
	}
	
	mysqlendquery $userresult
	mysqlendquery $result
	
	}
}

# User Search Function
proc isy:userglobal {nick host hand chan arg} {
  global chann_ botnick db_handle site_url 

	set chan [string tolower $chan]
	if { $chan == $chann_(main) || $chan == $chann_(support) } {
	
	if { ![botonchan $chan] } { return 0 }
	
	if { ![botisop $chan] } { return 0 }
	
	set who [::mysql::escape $nick]
	set nickc [::mysql::escape $nick]
	
	if { [isbotnick $who] } { return 0 }
	
	set usersql "SELECT class FROM users WHERE username='$nickc'"
	set userresult [mysqlsel $db_handle $usersql]
	mysqlmap $db_handle {userclass} {}
	
	if { $userclass >= "60" && $arg != "" } {
		set who [::mysql::escape $arg]
	}
	
	set sql "SELECT id, username, class, downloaded, uploaded, enabled, irctotal, onirc FROM users WHERE username='$who' LIMIT 1"
	set result [mysqlsel $db_handle $sql]
	
	if {$result == 1} {
		
		mysqlmap $db_handle {id username class download upload enabled irctotal onirc} {}
		
		if {$class > $userclass} {
			putquick "PRIVMSG $chan :You dont have permissions to view \002$who\002\'s info"
		} else {
			
			if {$enabled == "yes"} { append status "\[ Enabled |" } elseif {$enabled == "no"} { append status "\[ Disabled |" }
			if {$onirc == "yes"} { append status " ON IRC \]" } elseif {$onirc == "no"} { append status " OFF IRC \]" }
			
			set totaltraffic "0 kB"
			set totaltraffic [expr $upload + $download]
			
			if {$totaltraffic > 0} {
				if {[expr $totaltraffic / 1024] >= 1} {set ttraffic "[string range "[expr $totaltraffic / 1024.0]" 0 [expr [string length "[expr $totaltraffic / 1024]"]+ 2] ] kB"};
				if {[expr $totaltraffic / 1048576] >= 1} {set ttraffic "[string range "[expr $totaltraffic / 1048576.0]" 0 [expr [string length "[expr $totaltraffic / 1048576]"]+ 2] ] MB"};
				if {[expr $totaltraffic / 1073741824] >= 1} {set ttraffic "[string range "[expr $totaltraffic / 1073741824.0]" 0 [expr [string length "[expr $totaltraffic / 1073741824]"]+ 2] ] GB"};				
				if {[expr $totaltraffic / 1099511627776] >= 1} {set ttraffic "[string range "[expr $totaltraffic / 1099511627776.0]" 0 [expr [string length "[expr $totaltraffic / 1099511627776]"]+ 2] ] TB"};
			}
			
			set classname [isy:getclassname $class]
			
			if { $irctotal == 0 } {
				append ircidle "Never Seen in IRC"
			} else {
				set interval [expr 60*30*4]
				append ircidle "Points -> [expr [expr $irctotal / $interval] *2]"
				append ircidle " \([isy:inirctotal $irctotal]\)"
			}
			
			putquick "PRIVMSG $chan :User: $username \($classname\) / $status / Total Traffic: \($ttraffic\) / IRC Bonus: $ircidle / Profile: $site_url/userdetails.php?id=$id"
			
		}
		
	} else {
		
		putquick "PRIVMSG $chan :\002No matches\002 found for $who in Database."
	}
	
	mysqlendquery $userresult
	mysqlendquery $result
	
	}
}

proc last_torrent {nick host handle channel text} {
  
  global db_handle site_add
	
	set section [section_torrent $text]
	
	set sql "SELECT id, name, size, unix_timestamp(added), numfiles FROM torrents WHERE category ='$section' ORDER BY added DESC LIMIT 10"
	set result [mysqlsel $db_handle $sql -list]
	
	if {$result > 0} {
	putquick "PRIVMSG $channel :\002Sending\002 Last 10 \002Torrents, details in private"
	putquick "PRIVMSG $nick :\002Torrents:\002"
	for {set i 0} {$i < 10} {incr i} {
	
	set record [lindex $result $i];
	set id [lindex $record 0];
	set name [lindex $record 1];
	set size [lindex $record 2];
	set added [lindex $record 3];
	set added [duration [expr [clock seconds] - $added]];
	set files [lindex $record 4];
	
	set sized "0 kB"
	if {[expr $size / 1024] >= 1} {set sized "[string range "[expr $size / 1024.0]" 0 [expr [string length "[expr $size / 1024]"]+ 2] ] KB"};
	if {[expr $size / 1048576] >= 1} {set sized "[string range "[expr $size / 1048576.0]" 0 [expr [string length "[expr $size / 1048576]"]+ 2] ] MB"};
	if {[expr $size / 1073741824] >= 1} {set sized "[string range "[expr $size / 1073741824.0]" 0 [expr [string length "[expr $size / 1073741824]"]+ 2] ] GB"};
	
	putquick "PRIVMSG $nick :$name \002-\002 $sized \002-\002 $site_add/details.php?id=$id"
	}
	} else {
	puthelp "NOTICE $nick :\002No matches\002 : Please try again"
	}
}

proc stats_torrent {nick host handle channel text} {
 
  global db_handle site_add
	
	set sql "SELECT COUNT(id) FROM users WHERE enabled='yes'"
	set users [mysqlsel $db_handle $sql]
	mysqlmap $db_handle {users} {}
	
	set sql "SELECT COUNT(id) FROM peers WHERE seeder='yes'"
	set seeders [mysqlsel $db_handle $sql]
	mysqlmap $db_handle {seeders} {}
	
	set sql "SELECT COUNT(id) FROM peers WHERE seeder='no'"
	set leechers [mysqlsel $db_handle $sql]
	mysqlmap $db_handle {leechers} {}
	
	set sql "SELECT COUNT(id) FROM torrents WHERE visible='yes'"
	set torrents [mysqlsel $db_handle $sql]
	mysqlmap $db_handle {torrents} {}
	
	set peers [expr $seeders + $leechers]
	set sl [format "%.2f" [expr ((1.0 * $seeders / $leechers ) * 100)]]
	
	putquick "PRIVMSG $channel :\002Site Stats\002"
	putquick "PRIVMSG $channel :Users.........: $users"
	putquick "PRIVMSG $channel :Peers.........: $peers"
	putquick "PRIVMSG $channel :Seeders......: $seeders"
	putquick "PRIVMSG $channel :Leechers.....: $leechers"
	putquick "PRIVMSG $channel :S/L Ratio.....: $sl\%"
}

proc modinfo_torrent {nick host handle channel text} {
  global db_handle site_add staffchan
	if { $channel == $staffchan || [channel get $channel add] } { 
	set sql "SELECT class, modcomment FROM users WHERE username='$text'"
	set result [mysqlsel $db_handle $sql]
	mysqlmap $db_handle {class info} {}
	
	set usersql "SELECT class FROM users WHERE username='$nick'"
	set userresult [mysqlsel $db_handle $usersql]
	mysqlmap $db_handle {userclass} {}
	
	if {$result == 0} {
	putquick "PRIVMSG $channel :No such user"; 
	return 0
	}
	
	if {$class > $userclass} {
	putquick "PRIVMSG $staffchan :You dont have permissions to view \002$text\002\'s info"
	} else {
	putquick "PRIVMSG $staffchan :Sending \002$text\002\'s mod comments in PM"
	set data [split $info "\n"]
	foreach line $data {
	putquick "PRIVMSG $nick :$line"
	}
	}
	}
}

proc ipcheck_torrent {nick host handle channel text} {
  global db_handle staffchan
	if { $channel == $staffchan || [channel get $channel add] } { 
	set sql "SELECT username FROM users WHERE ip='$text';"
	set result [mysqlsel $db_handle $sql]
	if {$result == 1}  {
	mysqlmap $db_handle {username} {}
	putquick "PRIVMSG $staffchan :The ip $text is banned on the site, user: $username check mod comment for more info"
	} else {
	putquick "PRIVMSG $staffchan :The ip $text is not banned on the site"
	}
	}
}

proc isy:banuser {nick host handle chan arg} {
  global db_handle chann_ botnick site_url 
  
	set chan [string tolower $chan]
	if { $chan != $chann_(staff) } { return 0 }
	
	if { ![botonchan $chan] } { return 0 }
	
	if { ![botisop $chan] } { return 0 }
	
	if { $arg == "" } { return 0 }
	
	set who [::mysql::escape [lindex $arg 0]]
	
	if { [isbotnick $nick] } { return 0 }
	
	if { [isbotnick $who] } { return 0 }
	
	set sql "SELECT id,username,class,enabled,ircban FROM users WHERE username='$who' LIMIT 1"
	set result [mysqlsel $db_handle $sql -flatlist];
	
	if {$result != ""}  {
		
		foreach {id username class enabled ircban} $result {
		
			set classname [isy:getclassname $class]
			
			append finalinfo "\002$who\002\($classname\) -> "
			
			if { $enabled == "no" } {
				append finalinfo "Status already Disabled in site. "
			}
			
			if { $ircban == "yes" } {
				append finalinfo "IRC Status is also banned."
			}
			
			if { $ircban == "no" || $enabled == "yes" } {
				
				set sqlb "UPDATE users SET enabled='no', ircban='yes' WHERE username='$username' LIMIT 1"
				set resultb [mysqlsel $db_handle $sqlb]
				
				append finalinfo "Disabled from site and IRC."
			}
			
			append finalinfo " -> $site_url/userdetails.php?id=$id"
			
			cmdputblow "PRIVMSG $chann_(staff) :$finalinfo"
			isy:kickuser $username
		
		}
		
	} else {
		
		cmdputblow "PRIVMSG $chann_(staff) :No such user named [lindex $arg 0] in site database."
	}
	
	mysqlendquery $resultb
	mysqlendquery $result
}

proc isy:unbanuser {nick host handle chan arg} {
  global db_handle chann_ botnick site_url 
  
	set chan [string tolower $chan]
	if { $chan != $chann_(staff) } { return 0 }
	
	if { ![botonchan $chan] } { return 0 }
	
	if { ![botisop $chan] } { return 0 }
	
	if { $arg == "" } { return 0 }
	
	set who [::mysql::escape [lindex $arg 0]]
	
	if { [isbotnick $nick] } { return 0 }
	
	if { [isbotnick $who] } { return 0 }
	
	set sql "SELECT id,username,class,enabled,ircban FROM users WHERE username='$who' LIMIT 1"
	set result [mysqlsel $db_handle $sql -flatlist];
	
	if {$result != ""}  {
		
		foreach {id username class enabled ircban} $result {
		
			set classname [isy:getclassname $class]
			
			append finalinfo "\002$who\002\($classname\) -> "
			
			if { $enabled == "yes" } {
				append finalinfo "Status already Enabled in site. "
			}
			
			if { $ircban == "no" } {
				append finalinfo "IRC Status is also not banned. "
			}
			
			if { $ircban == "yes" || $enabled == "no" } {
				
				set sqlb "UPDATE users SET enabled='yes', ircban='no' WHERE username='$username' LIMIT 1"
				set resultb [mysqlsel $db_handle $sqlb]
				
				append finalinfo "Site and IRC Status is now enabled."
				
			}
			
			append finalinfo " -> $site_url/userdetails.php?id=$id"
			
			cmdputblow "PRIVMSG $chann_(staff) :$finalinfo"
		
		}
		
	} else {
		
		cmdputblow "PRIVMSG $chann_(staff) :No such user named [lindex $arg 0] in site database."
	}
	
	mysqlendquery $resultb
	mysqlendquery $result
}

# User Invite Function START
proc isy:invite_mein {nick uhost hand arg} {
 global db_handle chann_ botnick 
	
	if { ![botonchan $chann_(main)] } { return 0 }
	
	if { ![botisop $chann_(main)] } { return 0 }
	
	set text [string trim [::mysql::escape $arg]]
	set nick [::mysql::escape $nick]
	
	if { [isbotnick $nick] } { return 0 }
	
	if { $text == "" } {
		
		putquick "PRIVMSG $nick :Empty Password. Invited you to $chann_(support)"
		putquick "INVITE $nick $chann_(support)"
		
		isy:processlog "PRIVMSG $chann_(log) :$nick failed to join the channel empty password. Invited $nick to $chann_(support)"
		
		return 0
	}
	
	set sql "SELECT username, class, irchash, ircban, support, enabled FROM users WHERE username='$nick'"
	set result [mysqlsel $db_handle $sql]
	
	if { $result == "0" } {
		
		putquick "PRIVMSG $nick :No such username. Join $chann_(support)"
		#putquick "INVITE $nick $chann_(support)"
		
		isy:processlog "PRIVMSG $chann_(log) :$nick failed to join the channel bad username. Invited $nick to $chann_(support)"
		
		return 0
		
	} elseif { $result == "1" } {
		
		mysqlmap $db_handle {username class dbhash ircban flsmember enabled} {}
			
		if {$ircban == "yes" || $enabled == "no"} {
			putquick "PRIVMSG $nick :$username has been banned from the Site & IRC Channel. Join $chann_(support)"
			putquick "INVITE $nick $chann_(support)"
			
			isy:processlog "PRIVMSG $chann_(log) :$nick failed to join the channel Site & IRC Banned. Invited $nick to $chann_(support)"
			
			return 0
		}
		
		if {$text != $dbhash} {
			
			putquick "PRIVMSG $nick :Invite code incorrect for username $username. Join $chann_(support)"
			putquick "INVITE $nick $chann_(support)"
			
			isy:processlog "PRIVMSG $chann_(log) :$nick failed to join the channel invalid Invite code. Invited $nick to $chann_(support)"
			
			return 0
			
		} elseif { $text == $dbhash } {
			
			isy:okinvite "$nick $class $flsmember"
		}
	}
	
	mysqlendquery $result
	
}
# User Invite Function END

# Check if user is valid & identified & stuff..
proc isy:okinvite { args } {
 global botnick chann_ class_
 
	set args [lindex $args 0]
	set nick [lindex $args 0]
	set class [lindex $args 1]
	set flsmember [lindex $args 2]
	
	append where ""
	
	if { $class >= $class_(main) && $chann_(main) != "" && [botonchan $chann_(main)] == 1 && [botisop $chann_(main)] == 1 && [onchan $nick $chann_(main)] == 0 } {
		putquick "INVITE $nick $chann_(main)"
		append where "$chann_(main) "
	}
	
	if { $class >= $class_(vip) && $chann_(vip) != "" && [botonchan $chann_(vip)] == 1 && [botisop $chann_(vip)] == 1 && [onchan $nick $chann_(vip)] == 0 } {
		putquick "INVITE $nick $chann_(vip)"
		append where "$chann_(vip) "
	}
	
	if { $class >= $class_(rippers) && $chann_(rippers) != "" && [botonchan $chann_(rippers)] == 1 && [botisop $chann_(rippers)] == 1 && [onchan $nick $chann_(rippers)] == 0 } {
		putquick "INVITE $nick $chann_(rippers)"
		append where "$chann_(rippers) "
	}
	
	if { $class >= $class_(uploaders) && $chann_(uploaders) != "" && [botonchan $chann_(uploaders)] == 1 && [botisop $chann_(uploaders)] == 1 && [onchan $nick $chann_(uploaders)] == 0 } {
		putquick "INVITE $nick $chann_(uploaders)"
		append where "$chann_(uploaders) "
	}
	
	if { $class >= $class_(staff) && $chann_(staff) != "" && [botonchan $chann_(staff)] == 1 && [botisop $chann_(staff)] == 1 && [onchan $nick $chann_(staff)] == 0 } {
		putquick "INVITE $nick $chann_(staff)"
		append where "$chann_(staff) "
	}
	
	if { $class >= $class_(staffelite) && $chann_(staffelite) != "" && [botonchan $chann_(staffelite)] == 1 && [botisop $chann_(staffelite)] == 1 && [onchan $nick $chann_(staffelite)] == 0 } {
		putquick "INVITE $nick $chann_(staffelite)"
	}
	
	if { ($class >= $class_(staff) || $flsmember == "yes") && $chann_(support) != "" && [botonchan $chann_(support)] == 1 && [botisop $chann_(support)] == 1 && [onchan $nick $chann_(support)] == 0 } {
		putquick "INVITE $nick $chann_(support)"
		append where "$chann_(support) "
	}
	
	if { ($class >= $class_(staff) || $flsmember == "yes") && $chann_(fls) != "" && [botonchan $chann_(fls)] == 1 && [botisop $chann_(fls)] == 1 && [onchan $nick $chann_(fls)] == 0 } {
		putquick "INVITE $nick $chann_(fls)"
		append where "$chann_(fls) "
	}
	
	if { $where != "" } {
		isy:processlog "PRIVMSG $chann_(log) :Successfully invited \002$nick\002 to $where site channels."
	}
	
}

# Process LOG Function
proc isy:processlog { arg } {
 global ann_ blowfish_ 

	if { $ann_(log) == "1" } {
		
		if { $blowfish_(enabled) == "1" } {
			cmdputblow $arg
		} else {
			putquick $arg
		}
	}

}

#IRC ANN START
listen $botlisten_(port) script botlisten

proc botlisten {idx} {
	control $idx botlisten2
}

proc botlisten2 {idx args} {
  global botlisten_ chann_ ann_ botnick fishkey_ 
  
  	if { ![botonchan $chann_(main)] } { return 0 }
	
	if { ![botisop $chann_(main)] } { return 0 }
	
	set args [join $args]
	set pass [lindex [split $args] 0]
	set type [lindex [split $args] 1]
	set message [join [lrange [split $args] 2 end]]
	
	if { $botlisten_(password) == $pass && $type == "INVITE" } {
		
		set msg [split $message]
		set nick [lindex $msg 0]
		set class [lindex $msg 1]
		set flsmember [lindex $msg 2]
		
		if { [isbotnick $nick] } { return 0 }
		
		isy:okinvite "$nick $class $flsmember"
		isy:processlog "PRIVMSG $chann_(log) :Channel invite request from \002$nick\002 via site."
		
	} elseif { $botlisten_(password) == $pass && $type == "UPLOAD" && $ann_(newtorrent) == "1" } {
		
		putquick "PRIVMSG $chann_(main) :$message"
		putquick "PRIVMSG $chann_(uploaders) :$message"
		
		set messagex [string trim [stripcodes bc $message]]
		set grp [string trim [lindex [split [lindex $messagex 5] "-"] end]]
		
		if {$grp == "SKALiWAGZ"} {
			putquick "PRIVMSG $chan_(rippers) :$message"
		}
		
	} elseif { $botlisten_(password) == $pass && $type == "ANN" } {
		
		cmdputblow "PRIVMSG $chann_(main) :$message"
		
	} elseif { $botlisten_(password) == $pass && $type == "STAFF" } {
		
		cmdputblow "PRIVMSG $chann_(staff) :$message"
		
	}
	
}
## IRC ANN End

# blowcrypt code by poci

proc cmdputblow {text {option ""}} {
	global blowfish_
	if {$option==""} {
		if {[lindex $text 0]=="PRIVMSG" && [info exists blowfish_(key)] && $blowfish_(enabled) == 1} {
			putserv "PRIVMSG [lindex $text 1] :+OK [encrypt $blowfish_(key) [string trimleft [join [lrange $text 2 end]] :]]"
		} else {
			putserv $text
		}
	} else {
	  	if {[lindex $text 0]=="PRIVMSG" && [info exists slblowkey([string tolower [lindex $text 1]])] && $blowfish_(enabled) == 1} {
			putserv "PRIVMSG [lindex $text 1] :+OK [encrypt $blowfish_(key) [string trimleft [join [lrange $text 2 end]] :]]" $option
		} else {
			putserv $text $option
		}
	}
}

proc cmdencryptedincominghandler {nick host hand chan arg} {
	global blowfish_
	if {![info exists blowfish_(key)]} {return}
	set tmp [decrypt $blowfish_(key) $arg]
	foreach item [binds pub] {
		if {[lindex $item 2]=="+OK"} {continue}
		if {[lindex $item 1]!="-|-"} {
			if {![matchattr $hand [lindex $item 1] $chan]} {continue}
		}
		if {[lindex $item 2]==[lindex $tmp 0]} {[lindex $item 4] $nick $host $hand $chan [lrange $tmp 1 end]}
	}
}

# blowcrypt code by poci END

# Mysql Disconnect
#mysqlclose $db_handle

# It would be nice if you didn't delete this but there is really nothing I can do!
putlog "Mysql-IRC v7.58 COMPL3T3 SCRiPT --> By \002sCRiPTzTEAM\002 ||| Loaded Succesfully!"