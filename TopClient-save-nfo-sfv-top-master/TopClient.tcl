###########################
#  bot check site         #
###########################
proc ansiStrip {str} {
        set out ""
        foreach c [split $str ""] {
                if {[string is print $c]} {
                        append out $c
                }
        }
        return $out
}

bind pubm -|- "*LiNK*INFO*FOUND*http://*" pre:url
proc pre:url {nick uhost hand chan arg} {
set arg [ansiStrip [stripcodes bcruag $arg]]
set release [lindex $arg 8]
set url [lindex $arg 6]
say #addurl "!addurl $release $url"
say #debug "\0034force\0030 -> (\00310URL\0030):\0037 $release $url"
}

############################
#      TC lftp             #
############################
#   Link Bot               #
############################
bind bot - "topnew" bot:topnew
proc bot:topnew {bot cmd txt} {
	set site_name [lindex $txt 0]
	set release_name [lindex $txt 1]
	set release_section [lindex $txt 2]
	set release_file -
	set release_size -
	set nick site
	set uhost site
	set hand site
	set chan #debug
	if { $::topclient::top_config(chan_debug) != "" } { putquick "privmsg $::topclient::top_config(chan_debug) :\0034$site_name \003-> (\00310NEW\003):\0037 $release_name $release_section $release_file $release_size"; }
	proc_topnew $nick $uhost $hand $chan "$site_name $release_name $release_section";
}
bind bot - "topcomplete" bot:topcomplete
proc bot:topcomplete {bot cmd txt} {
        set site_name [lindex $txt 0]
        set release_name [lindex $txt 1]
        set release_section [lindex $txt 2]
        set release_file -
        set release_size -
        set nick site
        set uhost site
        set hand site
        set chan #debug
        if { $::topclient::top_config(chan_debug) != "" } { putquick "privmsg $::topclient::top_config(chan_debug) :\0034$site_name \003-> (\00310COMPLETE\003):\0037 $release_name $release_section $release_file $release_size"; }
        proc_topcomplete $nick $uhost $hand $chan "$site_name $release_name $release_section $release_file $release_size";
}
bind bot - "toppre" bot:toppre
proc bot:toppre {bot cmd txt} {
        set site_name [lindex $txt 0]
        set release_name [lindex $txt 1]
        set release_section [lindex $txt 2]
        set release_file -
        set release_size -
        set nick site
        set uhost site
        set hand site
        set chan #debug
        if { $::topclient::top_config(chan_debug) != "" } { putquick "privmsg $::topclient::top_config(chan_debug) :\0034$site_name \003-> (\00310PRE\003):\0037 $release_name $release_section $release_file $release_size"; }
        proc_toppre $nick $uhost $hand $chan "$site_name $release_name $release_section $release_file $release_size";
}
#####   addurl
bind bot - "addurl_site" bot:addurl
proc bot:addurl {bot cmd txt} {
	set site_name [lindex $txt 0]
	set release [lindex $txt 1]
	set url [lindex $txt 2]
	putfast "privmsg #debug :\0034$site_name \003-> (\00310URL\003):\0037 $release $url";
	putfast "privmsg #addurl :!addurl $release $url";
        putallbots "addurl $release $url"
}

bind bot - "h3llgn" bot:h3llgn
proc bot:h3llgn {bot cmd txt} {
        set siteh3ll h3ll
        set release [lindex $txt 0]
        set gn [lindex $txt 1]
        putfast "privmsg #debug :\0034$siteh3ll \003-> (\00310GN\003):\0037 $release $gn"
        putfast "privmsg #gn :!gn $release $gn"
}
bind bot - "planetgn" bot:planetgn
proc bot:planetgn {bot cmd txt} {
        set siteplanet planet
        set release [lindex $txt 0]
        set gn [lindex $txt 1]
        putfast "privmsg #debug :\0034$siteplanet \003-> (\00310GN\003):\0037 $release $gn"
        putfast "privmsg #gn :!gn $release $gn"
}

bind bot - "id3u" bot:id3u
proc bot:id3u {bot cmd txt} {
set site_name [lindex $txt 0]
set release [lindex $txt 1]
set genre [lindex $txt 2]
set year [lindex $txt 3]
set samplingrate [lindex $txt 4]
set channels [lindex $txt 5]
set bitrate [lindex $txt 6]
set bitratemode [lindex $txt 7]
putfast "privmsg #addid3c :!addid3c $release $genre $year $samplingrate $channels $bitrate $bitratemode"
putfast "privmsg #debug :\0034$site_name \003-> (\00310ID3U\003):\0037 $release $genre $year $samplingrate $channels $bitrate $bitratemode"
}


#####################################
# Binds                             #
#####################################
bind pub -|- !wtopcomplete proc_topcomplete
bind pub -|- !wtopnew proc_topnew
bind pub -|- !wtoppre proc_toppre
#####################################
# SizeControl                       #
#####################################
## wielkosc size
proc SizeControl {arg} {
	set arg [string tolower [stripcodes bcu $arg]]
	set tmp_buffer_size ""
	if {([string match "*mb" $arg])} { 
		set tmp_buffer_size [string map { "m" "" } $arg]
		set tmp_buffer_size [string map { "b" "" } $tmp_buffer_size]

	} elseif {([string match "*gb" $arg])} {
		set tmp_buffer_size [expr 1024 * [string map { "gb" "" } $arg]]

	} elseif {([string match "*b" $arg])} {
		set tmp_buffer_size [format %.3f [expr (([string map { "b" "" } $arg].000/1024.000)/1024.000)]]

	} elseif {([string match "*k" $arg])} {
		set tmp_buffer_size [string map { "k" "" } $arg]

	} elseif {([string match "*f" $arg])} {
		set tmp_buffer_size [string map { "f" "" } $arg]

	}
	if {$tmp_buffer_size == ""} { set tmp_buffer_size $arg }
	
	if { [string length [lindex [split $tmp_buffer_size "."] 1] ] > 3 } { 
		set tmp_buffer_size [format %.3f $tmp_buffer_size]
	}
	if { [string range $tmp_buffer_size end end] == "0" && [string match "*.*" $tmp_buffer_size]} { set tmp_buffer_size [string range $tmp_buffer_size 0 [expr [string length $tmp_buffer_size]-2]] }
	if { [string range $tmp_buffer_size end end] == "." } { set tmp_buffer_size [string range $tmp_buffer_size 0 [expr [string length $tmp_buffer_size]-2]] }
	if { [string range $tmp_buffer_size end end] == "0" && [string match "*.*" $tmp_buffer_size]} { set tmp_buffer_size [string range $tmp_buffer_size 0 [expr [string length $tmp_buffer_size]-2]] }
	if { [string range $tmp_buffer_size end end] == "." } { set tmp_buffer_size [string range $tmp_buffer_size 0 [expr [string length $tmp_buffer_size]-2]] }
	if { [string range $tmp_buffer_size end end] == "0" && [string match "*.*" $tmp_buffer_size]} { set tmp_buffer_size [string range $tmp_buffer_size 0 [expr [string length $tmp_buffer_size]-2]] }
	if { [string range $tmp_buffer_size end end] == "." } { set tmp_buffer_size [string range $tmp_buffer_size 0 [expr [string length $tmp_buffer_size]-2]] }

	if {([lindex [split $tmp_buffer_size "."] 1] == "0" || "00" || "000")} { set tmp_buffer_size [string map {  ".000" "" ".00" ""  ".0" "" } $tmp_buffer_size] } 
	if { $tmp_buffer_size == "0" || $tmp_buffer_size == "0.0" } { set tmp_buffer_size "-" }

	return "$tmp_buffer_size"

}
##
if {[file exists [file dirname [info script]]/TopClient.conf] == "0"} { 
	die "\n\n################################################################\n#        -> TopClient.tcl can not work without [file dirname [info script]]/TopClient.conf. <-        #\n################################################################";
} else { source [file dirname [info script]]/TopClient.conf; }

# Load Package: HTTP
if {![info exists ::tcl_package(http)]} { package require http; } elseif {$::tcl_package(http) != "" && $::tcl_package(http) != "-" && [file exists $::tcl_package(http)] } { source $::tcl_package(http); } else { package require http; }
# Load Package: TLS
if {![info exists ::tcl_package(tls)]} { package require tls; } elseif {$::tcl_package(tls) != "" && $::tcl_package(tls) != "-" && [file exists $::tcl_package(tls)] } { source $::tcl_package(tls); } else { package require tls; }
# Load Package: CRC32
if {![info exists ::tcl_package(crc32)]} { package require crc32; } elseif {$::tcl_package(crc32) != "" && $::tcl_package(crc32) != "-" && [file exists $::tcl_package(crc32)] } { source $::tcl_package(crc32); } else { package require crc32; }
#MySQL Fonction :
	package require mysqltcl;

# Fonction d'ouverture MySQL
proc OpenSQL {} {
	if {[info exists ::handle]} {
		if {[::mysql::state $::handle -numeric]!="1" && [::mysql::state $::handle -numeric]!="0"} { return $::handle; }
	}
	if {[catch { set ::handle [::mysql::connect -host $::topclient::sql_config(Host) -port $::topclient::sql_config(Port) -u $::topclient::sql_config(User) -password $::topclient::sql_config(Pass) -db $::topclient::sql_config(DBName)] } error]} {
		putlog "MySQL Connected Failled : $error"; return 0;
	} else { return $::handle; }
}

# Fonction de fermeture MySQL
proc CloseSQL {} {
	#Si la variable est inexistante on retourne 0
	if {![info exists ::handle]} { return 1; }
	#Si la variable existe, on verifie si elle est encore actif
	if {[::mysql::state $::handle -numeric]=="1" || [::mysql::state $::handle -numeric]=="0"} {  putlog "MySQL is already closed"; unset ::handle; return 1; }
	if {[catch {::mysql::ping $::handle} error]} {
		putlog "MySQL Couldn't ping The Handle SQL : $error"; unset ::handle; return 0; # Si plus actif on retourne un putlog, on efface la variable, et on retourne 0
	} else {
		#Si elle est encore actif on essaye de la fermer
		if {[catch {::mysql::close $::handle} error]} {
			putlog "MySQL Couldn't Close The Handle SQL : $error"; return 0; # Plus probleme de fermeture on putog l'erreur, et on retourne 0
		} else {
			return 1; # Fermerture reusiste, on retourne 1
		}
	} 
}



#####################################
# Get_info_ftp                      # grep : - zastapione tail -n +2
#####################################
proc Get_info_ftp {chan nick top_name release} {
	if {[catch {set ftp_buffer [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ;ls $release | tail -n +2"]} error]} {
		proc_SendMSG $chan $nick error "Error de listing File pour $release sur  $top_name : $error"
		if {[regexp "(.*)max-retries(.*)" [string tolower $error]]} { exec -- killall -9 lftp }
	} else {
		set count_file "0"
		set total_file_byte "0"
		foreach {ftp_droit ftp_unknown ftp_owner ftp_grp ftp_file_bytes ftp_file_month ftp_file_day ftp_file_hour ftp_file_name} $ftp_buffer {
           		if {[regexp ".r\[0-9\]{2}\$|.rar$|.mp3$|.flac$|.zip$|.mkv$|.\[0-9\]{3}\$" [string tolower $ftp_file_name]] && [regexp "^\[0-9\]{1,}$" $ftp_file_bytes]} { 
				incr count_file
				set total_file_byte [expr {wide($total_file_byte)+$ftp_file_bytes}]
			}
		}
		set file "[SizeControl $count_file]"
		set size "[SizeControl [format %.3f [expr (($total_file_byte.000/1024.000)/1024.000)]]]"
		if {$file == "-" || $size == "-"} {
			return "[Get_Total_size $chan $nick $top_name $release]"

		} elseif {$file == "0" || $size == "0"} {
			return "- -"
		} else {
			return "$file $size"
		}
	}
}

#####################################
# FTPCONNECTSITE                    #
#####################################
proc FTPCONNECTSITE { top_name } {
	return "ftp://$::topsite($top_name\_user):$::topsite($top_name\_pass)@$::topsite($top_name\_host):$::topsite($top_name\_port)"
}
#####################################
# Get_Total_size                    #tail -n +2 zmiana z grep ':'
#####################################
proc Get_Total_size {chan nick top_name release} {

	if {[catch {set ftp_buffer [exec -- $::top_config(lftp)  [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ;ls $release |tail -n +2"]} error]} {
		proc_SendMSG $chan $nick error "Error de listing File pour $release sur  $top_name : $error" "Erreur de listing File pour $release sur  $top_name : $error" 
		if {[regexp "(.*)max-retries(.*)" [string tolower $error]]} { exec -- killall -9 lftp }
	} else {
		set count_file "0"
		set total_file_byte "0"
		foreach {ftp_droit ftp_unknown ftp_owner ftp_grp ftp_file_bytes ftp_file_month ftp_file_day ftp_file_hour ftp_file_name} $ftp_buffer {
           		if {[regexp "^cd\[0-9\]\$|dvd\[0-9\]\$" [string tolower $ftp_file_name]] && ![regexp "(.*)\\(\[0-9\]{1,2}\\).(.*)" [string tolower $ftp_file_name]]} { 
				set tmp_info [Get_info_ftp $chan $nick $top_name $release/$ftp_file_name]
				set release_file [lindex $tmp_info 0]
				set release_size [lindex $tmp_info 1]
				set total_file_byte [expr {wide($total_file_byte)+$release_size}]
				set count_file [expr $count_file + $release_file]
			}
		}
		if {$count_file == "0"} { return "- -" } else { return "$count_file $total_file_byte" }
	}
}
proc LFTP_Connect { top_name CMD_Exec } {
	if { [catch { set ftp_buffer [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e "$CMD_Exec; "] } error] } {
		if {[regexp "(.*)nom ou service inconnu(.*)" [string tolower $error]]} { 
			proc_SendMSG chan nick error "Erreur 'Connexion impossible' sur $top_name. Le Hostname/Port incorrect ou érroné";
		} elseif { [regexp "(.*)max-retries(.*)" [string tolower $error]] } { 
			catch {exec -- killall -9 lftp}
			proc_SendMSG chan nick error "Erreur d'execution de LFTP lors de la commande -> $CMD_Exec";
			proc_SendMSG chan nick error "Erreur retournée -> $error" ;
		} else {
			proc_SendMSG chan nick error "Erreur d'execution de LFTP lors de la commande -> $CMD_Exec";
			proc_SendMSG chan nick error "Erreur retournée -> $error" ;
		}
		return 0;
	} else {
		return $ftp_buffer;
	}
}

#####################################
# audiochans                        #
#####################################
proc audiochans { chans } {
	if {$chans == "stereo"} { return "2" }
}


#####################################
# Release_Status                    #
#####################################
proc Release_Status {chan nick release section} {
	if {[regexp "(.*)/cd\[0-9\]\$|(.*)/dvd\[0-9\]\$|(.*)/sub\$|(.*)/subs\$|(.*)/sample\$|(.*)/ac3\$" [string tolower $release]]} { return 0; }

        foreach filter [split [concat $::topclient::skipdirname]] {
           if {[string match -nocase *$filter* $release]} {
		proc_SendMSG $chan $nick error "14\[Filtre dans dirname14\] 03$release ($filter)" 
             return 0
           }
         }
        foreach filter [split [concat $$::topclient::skipsection]] {
           if {[string match -nocase *$filter* $section]} {
		proc_SendMSG $chan $nick error "14\[Filtre dans section14\] 03$release ($filter)" 
             return 0
           }
         }
	if {[regexp "^\[A-Z0-9\]{1}\[a-zA-Z0-9\\.\\(\\)_\\-\]{6,254}$" $release] == 0 || [regexp "(((.*)\\-(.*)\\-.(.*))|((.*)\\.(.*)\\-.(.*))|((.*)_(.*)\\-.(.*)))" $release] == 0 } {
		proc_SendMSG $chan $nick error "14\[Filter in release14\] 03$release (REGEX ACTION)"; return 0;
	} else { return 1 }
}

#####################################
# File_Status                       #
#####################################
proc File_Status {chan nick release file} {
        foreach filter [split [concat $::topclient::skipfile]] {
           if {[string match -nocase *$filter* $file]} {
		proc_SendMSG $chan $nick error "14\[Filtre dans nom de fichier14\] 03$file ($filter) pour $release";
             return 0;
           }
         }
	return 1;
}

#####################################
# Check_Dynamic_section             #
#####################################
proc Check_Dynamic_section {chan nick top_name Release_Section} {
	if {![info exists ::topsite($top_name\_SECTION_1)]} { proc_SendMSG $chan $nick error "La variable ::topsite($top_name\_SECTION_1) a pas été ajouté au fichier de config de $top_name."; return 0; }
	if {![info exists ::topsite($top_name\_SECTION_2)]} { proc_SendMSG $chan $nick error "La variable ::topsite($top_name\_SECTION_2) a pas été ajouté au fichier de config de $top_name."; return 0; }
	if {![info exists ::topsite($top_name\_SECTION_3)]} { proc_SendMSG $chan $nick error "La variable ::topsite($top_name\_SECTION_3) a pas été ajouté au fichier de config de $top_name."; return 0; }
	if {![info exists ::topsite($top_name\_SECTION_4)]} { proc_SendMSG $chan $nick error "La variable ::topsite($top_name\_SECTION_4) a pas été ajouté au fichier de config de $top_name."; return 0; }
	if {![info exists ::topsite($top_name\_SECTION_5)]} { proc_SendMSG $chan $nick error "La variable ::topsite($top_name\_SECTION_5) a pas été ajouté au fichier de config de $top_name."; return 0; }
	if {![info exists ::topsite($top_name\_SECTION_1_TODAY)]} { proc_SendMSG $chan $nick error "La variable ::topsite($top_name\_SECTION_1_TODAY) a pas été ajouté au fichier de config de $top_name."; return 0; }
	if {![info exists ::topsite($top_name\_SECTION_2_TODAY)]} { proc_SendMSG $chan $nick error "La variable ::topsite($top_name\_SECTION_2_TODAY) a pas été ajouté au fichier de config de $top_name."; return 0; }
	if {![info exists ::topsite($top_name\_SECTION_3_TODAY)]} { proc_SendMSG $chan $nick error "La variable ::topsite($top_name\_SECTION_3_TODAY) a pas été ajouté au fichier de config de $top_name."; return 0; }
	if {![info exists ::topsite($top_name\_SECTION_4_TODAY)]} { proc_SendMSG $chan $nick error "La variable ::topsite($top_name\_SECTION_4_TODAY) a pas été ajouté au fichier de config de $top_name."; return 0; }
	if {![info exists ::topsite($top_name\_SECTION_5_TODAY)]} { proc_SendMSG $chan $nick error "La variable ::topsite($top_name\_SECTION_5_TODAY) a pas été ajouté au fichier de config de $top_name."; return 0; }
        if {[string tolower $Release_Section] == [string tolower  $::topsite($top_name\_SECTION_1)]} { 

		set Release_Section  $::topsite($top_name\_SECTION_1_TODAY)

	} elseif {[string tolower $Release_Section] == [string tolower  $::topsite($top_name\_SECTION_2)]} { 

		set Release_Section  $::topsite($top_name\_SECTION_2_TODAY)

	} elseif {[string tolower $Release_Section] == [string tolower  $::topsite($top_name\_SECTION_3)]} {

		set Release_Section  $::topsite($top_name\_SECTION_3_TODAY)

	} elseif {[string tolower $Release_Section] == [string tolower  $::topsite($top_name\_SECTION_4)]} {

		set Release_Section  $::topsite($top_name\_SECTION_4_TODAY)

	} elseif {[string tolower $Release_Section] == [string tolower  $::topsite($top_name\_SECTION_5)]} {

		set Release_Section  $::topsite($top_name\_SECTION_5_TODAY)

        } elseif {[string tolower $Release_Section] == [string tolower  $::topsite($top_name\_SECTION_6)]} {

                set Release_Section  $::topsite($top_name\_SECTION_6_TODAY)

        } elseif {[string tolower $Release_Section] == [string tolower  $::topsite($top_name\_SECTION_7)]} {

                set Release_Section  $::topsite($top_name\_SECTION_7_TODAY)
        }
	return $Release_Section
}
proc islinked { bot } {
	if { [lsearch -exact [string tolower [bots]] [string tolower $bot]] == -1 } { return 0; } else { return 1; }
}
#####################################
# proc_SendMSGBOT                   #
#####################################
proc proc_SendMSGBOT { msg } {
	if { [string tolower $::topclient::top_config(bot_dest)] == "all" } { 
		# putlog "Send to All botnet : $msg"
		putallbots "$msg";
	} elseif { [regexp {[ ]} $::topclient::top_config(bot_dest)] } {
		putlog "Send to $::topclient::top_config(bot_dest) : $msg"
		foreach BotToSend $::topclient::top_config(bot_dest) { 
			if { [islinked $::topclient::top_config(bot_dest)] } {
				putbot $BotToSend "$msg";
			} else {
#				proc_SendMSG chan nick error "Le bot '$::topclient::top_config(bot_dest)' est introuvable impossible d'envoyer :$msg";
			}
		}
	} elseif {$::topclient::top_config(bot_dest) == "" } {
		return 1;
	} elseif { [islinked $::topclient::top_config(bot_dest)] } {
		putlog "Send to $::topclient::top_config(bot_dest) : $msg"
		putbot $::topclient::top_config(bot_dest) "$msg"
	} else {
#		proc_SendMSG chan nick error "Le bot '$::topclient::top_config(bot_dest)' est introuvable impossible d'envoyer :$msg";
	}
}
set last_mp3info_rls "";
set last_fileinfo_rls "";
set last_style_rls "";
#####################################
# proc_SendMSG                      #
#####################################
proc proc_SendMSG {chan nick type msg} {
	switch -exact -- [string tolower $type] {
		addsitepre {
			set Release_Name [lindex $msg 0];
			if {[::topclient::indexInCache ThisNet Sitepre "$Release_Name"] == "0"} {
				if {$::topclient::top_config(debug_ppl) == "1"} { putlog "addsitepre $msg" }
       			if {$::topclient::top_config(chan_sitepre) != ""} { say $::topclient::top_config(chan_sitepre) "!sitepre $msg" }
				if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "3addsitepre $msg" }
				::topclient::addToCache $chan $nick Sitepre $Release_Name
			}
			proc_SendMSGBOT "addsitepre $msg"
		}

		addpre {
			set Release_Name [lindex $msg 0];
			if {[::topclient::indexInCache ThisNet Addpre "$Release_Name"] == "0"} {
                                if {$::topclient::top_config(debug_ppl) == "1"} { putlog "addpre $msg"}
				if {$::topclient::top_config(chan_addpre) != ""} { say $::topclient::top_config(chan_addpre) "!addpre $msg" }
				if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "3addpre $msg" }
				::topclient::addToCache $chan $nick Addpre $Release_Name
			}
			proc_SendMSGBOT "addpre $msg"
		}
		newdir {
                        set Release_Name "[lindex $msg 0]";
                        set Release_Section "[lindex $msg 1]";
			if {[::topclient::indexInCache ThisNet Newdir "$Release_Name"] == "0"} {
				if {$::topclient::top_config(debug_ppl) == "1"} { putlog "newdir $msg"}
				if {$::topclient::top_config(chan_addpre) != ""} { say $::topclient::top_config(chan_newdir) "!newdir $msg" }
				if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "\0033newdir $msg" }
				if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "\0034Site \003-> (\00311NEWDIR\003):\0037 ->\00311 $Release_Name $Release_Section" }
				::topclient::addToCache $chan $nick Newdir $Release_Name
			}
			proc_SendMSGBOT "newdir $msg"
		}
                addurl {
                        set Release_Name "[lindex $msg 0]";
                        if {[::topclient::indexInCache ThisNet Addurl "$Release_Name"] == "0"} {
                        if {$::topclient::top_config(debug_ppl) == "1"} { putlog "addurl $msg"}
                        if {$::topclient::top_config(chan_addurl) != ""} { say $::topclient::top_config(chan_addurl) "!addurl $msg" }
                        if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "\0033addurl $msg" }
                        if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "\00311ADDURL \003:\0037 ->\00311 $msg" }
                        ::topclient::addToCache $chan $nick Addurl $Release_Name
                        }
                        proc_SendMSGBOT "addurl $msg"
                }
		addinfo {
			set Release_Name [lindex $msg 0];
			if {[::topclient::indexInCache ThisNet Addinfo "$Release_Name"] == "0"} {
				if {[::topclient::ReleaseIsNew "$Release_Name"]} { set cmd "!ginfo"; } else  { set cmd "!ginfo"; }
			       if {$::topclient::top_config(debug_ppl) == "1"} { putlog "addinfo $msg" }
       			if {$::topclient::top_config(chan_addinfo) != ""} { say $::topclient::top_config(chan_addinfo) "$cmd $msg" }
				if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "3addinfo $msg" }
				::topclient::addToCache $chan $nick Addinfo $Release_Name
				::topclient::Addinfo_DB [lindex $msg 0] [lindex $msg 1] [lindex $msg 2];
			}
			proc_SendMSGBOT "addinfo $msg"
		}

		addginfo {
			set Release_Name [lindex $msg 0];
			if {[::topclient::indexInCache ThisNet Addginfo "$Release_Name"] == "0"} {
			       if {$::topclient::top_config(debug_ppl) == "1"} { putlog "addginfo $msg" }
				if {[::topclient::ReleaseIsNew $Release_Name]} { set cmd "!ginfo"; } else  { set cmd "!ginfo"; }
       			if {$::topclient::top_config(chan_addginfo) != ""} { say $::topclient::top_config(chan_addginfo) "$cmd $msg" }
				if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "3addginfo $msg" }
				::topclient::addToCache $chan $nick Addginfo $Release_Name
				::topclient::Addinfo_DB [lindex $msg 0] [lindex $msg 1] [lindex $msg 2];
			}
			proc_SendMSGBOT "addginfo $msg"
		}
		mp3info {
			set Release_Name "[lindex $msg 0]/[lindex $msg 1]";
			if {[::topclient::indexInCache ThisNet Mp3info "$Release_Name"] == "0" && [File_Status $chan $nick [lindex $msg 0] [lindex $msg 1]] != 0} {
				if {[::topclient::ReleaseIsNew [lindex $msg 0]]} { set cmd "!addtrack"; } else  { set cmd "!addtrack"; }
				if {$::topclient::top_config(debug_ppl) == "1"} { putlog "mp3info $msg" }
				if {$::topclient::top_config(chan_mp3info) != ""} { say $::topclient::top_config(chan_mp3info) "$cmd $msg" }
				if {$::topclient::top_config(chan_debug) != "" && $::last_mp3info_rls != "[lindex $msg 0]"} { say $::topclient::top_config(chan_debug) "3mp3info $msg"; set ::last_mp3info_rls [lindex $msg 0]; }
				::topclient::addToCache $chan $nick Mp3info $Release_Name
			}
			proc_SendMSGBOT "mp3info $msg"
		}
		fileinfo {
			set Release_Name "[lindex $msg 0]/[lindex $msg 1]";
			if {[::topclient::indexInCache ThisNet Fileinfo "$Release_Name"] == "0" && [File_Status $chan $nick [lindex $msg 0] [lindex $msg 1]] != 0} {
				if {$::topclient::top_config(debug_ppl) == "1"} { putlog "fileinfo $msg" }
				if {[::topclient::ReleaseIsNew [lindex $msg 0]]} { set cmd "!fileinfo"; } else  { set cmd "!fileinfo"; }
				if {$::topclient::top_config(chan_fileinfo) != ""} { say $::topclient::top_config(chan_fileinfo) "$cmd $msg" }
				if {$::topclient::top_config(chan_debug) != "" && $::last_fileinfo_rls != [lindex $msg 0] } { say $::topclient::top_config(chan_debug) "3fileinfo $msg"; set ::last_fileinfo_rls [lindex $msg 0]; }
				::topclient::addToCache $chan $nick Fileinfo $Release_Name
			}
			proc_SendMSGBOT "fileinfo $msg"
		}
		addm3u {
			set Release_Name "[lindex $msg 0]/[lindex $msg 2]";
			if {[::topclient::indexInCache ThisNet Addm3u "$Release_Name"] == "0"} {
				if {$::topclient::top_config(debug_ppl) == "1"} { putlog "addm3u $msg" }
				if {[::topclient::ReleaseIsNew "[lindex $msg 0]"]} { set cmd "!addm3u"; } else  { set cmd "!addm3u"; }
				if {$::topclient::top_config(chan_addm3u) != ""} { say $::topclient::top_config(chan_addm3u) "$cmd $msg" }
				if {$::topclient::top_config(chan_debug) != ""} { putfast "privmsg $::topclient::top_config(chan_debug) :3addm3u $msg" }
				::topclient::addToCache $chan $nick Addm3u $Release_Name
			}
			proc_SendMSGBOT "addm3u $msg"
		}
		addnfo {
			set Release_Name "[lindex $msg 0]/[lindex $msg 2]";
			if {[::topclient::indexInCache ThisNet Addnfo $Release_Name] == "0"} {
				if {$::topclient::top_config(debug_ppl) == "1"} { putlog "addnfo $msg" }
				if {[::topclient::ReleaseIsNew "[lindex $msg 0]"]} { set cmd "!addnfo"; } else  { set cmd "!addnfo"; }
				if {$::topclient::top_config(chan_addnfo) != ""} { say $::topclient::top_config(chan_addnfo) "$cmd $msg" }
				if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "3addnfo $msg" }
				::topclient::addToCache $chan $nick Addnfo $Release_Name
			}
			proc_SendMSGBOT "addnfo $msg"
		}
		addsfv {
			set Release_Name "[lindex $msg 0]/[lindex $msg 2]";
			if {[::topclient::indexInCache ThisNet Addsfv "$Release_Name"] == "0"} {
				if {$::topclient::top_config(debug_ppl) == "1"} { putlog "addsfv $msg" }
				if {[::topclient::ReleaseIsNew "[lindex $msg 0]"]} { set cmd "!addsfv"; } else  { set cmd "!addsfv"; }
				if {$::topclient::top_config(chan_addsfv) != ""} { say $::topclient::top_config(chan_addsfv) "$cmd $msg" }
				if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "3addsfv $msg" }
				::topclient::addToCache $chan $nick Addsfv $Release_Name
			}
			proc_SendMSGBOT "addsfv $msg"
		}
		addjpg {
			set Release_Name "[lindex $msg 0]/[lindex $msg 2]";
			if {[::topclient::indexInCache ThisNet Addjpg "$Release_Name"] == "0"} {
				if {$::topclient::top_config(debug_ppl) == "1"} { putlog "addjpg $msg" }
				if {[::topclient::ReleaseIsNew "[lindex $msg 0]"]} { set cmd "!addjpg"; } else  { set cmd "!addjpg"; }
				if {$::topclient::top_config(chan_addjpg) != ""} { say $::topclient::top_config(chan_addjpg) "$cmd $msg" }
				if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "3addjpg $msg" }
				::topclient::addToCache $chan $nick Addjpg $Release_Name
			}
			proc_SendMSGBOT "addjpg $msg"
		}
		addcue {
			set Release_Name "[lindex $msg 0]/[lindex $msg 2]";
			if {[::topclient::indexInCache ThisNet Addjpg "$Release_Name"] == "0"} {
				if {$::topclient::top_config(debug_ppl) == "1"} { putlog "addcue $msg" }
				if {[::topclient::ReleaseIsNew "[lindex $msg 0]"]} { set cmd "!addcue"; } else  { set cmd "!addcue"; }
				if {$::topclient::top_config(chan_addcue) != ""} { say $::topclient::top_config(chan_addcue) "$cmd $msg" }
				if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "3addcue $msg" }
				::topclient::addToCache $chan $nick Addcue $Release_Name
			}
			proc_SendMSGBOT "addcue $msg"
		}
		addcover {
			set Release_Name "[lindex $msg 0]/[lindex $msg 2]";
			if {[::topclient::indexInCache ThisNet Addcover "$Release_Name"] == "0"} {
				if {$::topclient::top_config(debug_ppl) == "1"} { putlog "addcover $msg" }
				if {[::topclient::ReleaseIsNew "[lindex $msg 0]"]} { set cmd "!addcover"; } else  { set cmd "!addcover"; }
				if {$::topclient::top_config(chan_addcover) != ""} { say $::topclient::top_config(chan_addcover) "$cmd $msg" }
				if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "\0033addcover $msg" }
				::topclient::addToCache $chan $nick Addcover $Release_Name
			}
			proc_SendMSGBOT "addcover $msg"
		}

		addvideoinfo {
			set Release_Name [lindex $msg 0];
			if {[::topclient::indexInCache ThisNet Addvideoinfo "$Release_Name"] == "0"} {
				if {$::topclient::top_config(debug_ppl) == "1"} { putlog "addvideoinfo $msg" }
				if {[::topclient::ReleaseIsNew $Release_Name]} { set cmd "!addvideoinfo"; } else  { set cmd "!addvideoinfo"; }
				if {$::topclient::top_config(chan_addvideoinfo) != ""} { say $::topclient::top_config(chan_addvideoinfo) "$cmd $msg" }
				if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "\0033addvideoinfo $msg" }
				::topclient::addToCache $chan $nick Addvideoinfo $Release_Name
			}
			proc_SendMSGBOT "addvideoinfo $msg"
		}
               addmediainfo {
                        set Release_Name [lindex $msg 0];
                        if {[::topclient::indexInCache ThisNet Addmediainfo "$Release_Name"] == "0"} {
                                if {$::topclient::top_config(debug_ppl) == "1"} { putlog "addmediainfo $msg" }
                                if {[::topclient::ReleaseIsNew $Release_Name]} { set cmd "!addmediainfo"; } else  { set cmd "!addmediainfo"; }
                                if {$::topclient::top_config(chan_addmediainfo) != ""} { say $::topclient::top_config(chan_addmediainfo) "$cmd $msg" }
                                if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "\0033addmediainfo $msg" }
                                ::topclient::addToCache $chan $nick Addmediainfo $Release_Name
                        }
                        proc_SendMSGBOT "addmediainfo $msg"
                }

		error {
			if { $::topclient::top_config(debug_ppl) == "1" } { putlog "$msg" }
			if { $::topclient::top_config(chan_debug) != "" } { say $::topclient::top_config(chan_debug) "4$msg"; return 1; }
		}
		default {
			putlog "Error from proc_SendMSG, What is : $type and $msg"
			if {$::topclient::top_config(chan_debug) != ""} { say $::topclient::top_config(chan_debug) "4Error from proc_SendMSG, What is : $type and $msg" }
		}
	}

}
proc S2SQL { string } {
	regsub -all {\\} $string {\\\\} string
	regsub -all {\^} $string {\\^} string
	regsub -all {\$} $string {\\$} string
	regsub -all {\.} $string {\\.} string
	regsub -all {\[} $string {\\[} string
	regsub -all {\'} $string {\\'} string
	regsub -all {\]} $string {\\]} string
	regsub -all {\-} $string {\\-} string
	regsub -all {\{} $string {\\{} string
	regsub -all {\}} $string {\\}} string
	regsub -all {\(} $string {\\(} string
	regsub -all {\)} $string {\\)} string
	regsub -all {\*} $string {\\*} string
	regsub -all {\+} $string {\\+} string
	regsub -all {\?} $string {\\?} string
	regsub -all {\|} $string {\\|} string
	#regsub -all {%} $string {} string
	return $string;
}

#####################################
# proc_topcomplete                  #
#####################################
proc proc_topcomplete {nick uhost hand chan arg} {
	if {[lindex $arg 2] == ""} { proc_SendMSG $chan $nick error "proc_topcomplete <site_name> <Release_Name> <section_name>"; return 0; }

	###### INIT - BEGIN ######
	set arg [stripcodes bcu $arg]
	set top_name [lindex $arg 0]
	set Release_Name [lindex $arg 1]
	if {[string rang $Release_Name 4 4] == "/"} { set Release_Name "[string rang $Release_Name 5 end]" }
	set Release_Section [lindex $arg 2]
	set release_file [SizeControl [lindex $arg 3]]
	set release_size [SizeControl [lindex $arg 4]]
	set release_nb "0"
	###### INIT - END ######

	###### VARIABLE VERIFICATOR - BEGIN ######
	if {![info exists ::topsite($top_name\_host)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_host) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_user)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_user) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_pass)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_pass) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_port)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_port) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_ADDINFO)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_ADDINFO) dans TopClient.Conf."; return 0; }
	###### VARIABLE VERIFICATOR - END ######


	###### FILTRE - BEGIN ######
	if {[regsub {(.*)/([c,C][d,D]|[d,D][V,v][d,D]|[d,D][i,I][s,S][c,C,k,K])[0,2,3,4,5,6,7,8,9][0,2,3,4,5,6,7,8,9]$} $Release_Name {\1} Release_Name]} {
		putlog "Multi CD/DVD for $Release_Name"
		proc_SendMSG $chan $nick error "Multi CD/DVD for $Release_Section/$Release_Name"
		set release_nb "2"

	} elseif {[regsub {(.*)/([c,C][d,D]|[d,D][V,v][d,D]|[d,D][i,I][s,S][c,C,k,K])[1]$} $Release_Name {\1} Release_Name]} {
		putlog "Multi CD/DVD for $Release_Name"
		proc_SendMSG $chan $nick error "Multi CD/DVD for $Release_Section/$Release_Name"
		set release_nb "1"
	} elseif {[Release_Status $chan $nick $Release_Name $Release_Section] == 0} { return 0; }
	###### FILTRE - END ######

	###### DYNAMIC SECTION - BEGIN ######
	set Release_Section_dynamic [Check_Dynamic_section $chan $nick $top_name $Release_Section]
	###### DYNAMIC SECTION - END ######
	
	###### GIVE INFO - BEGIN ######
	if {$release_file == "" || $release_file == "-" || $release_size == "" || $release_size != "-"} { set tmp_info [Get_info_ftp $chan $nick $top_name $Release_Section_dynamic/$Release_Name]; set release_file [lindex $tmp_info 0]; set release_size [lindex $tmp_info 1] }
	###### GIVE INFO - END ######


	###### ADDINFO - BEGIN ######
	if {$release_file != "" && $release_file != "-" && $release_size != "" && $release_size != "-" && $::topsite($top_name\_ADDINFO) == "1" && [::topclient::indexInCache ThisNet Addinfo "$Release_Name"] == "0"} { proc_SendMSG $chan $nick addinfo "$Release_Name $release_file $release_size" }
	###### ADDINFO - END ######

	###### GO TO Check_Content_Dir - BEGIN ######
	Check_Content_Dir $chan $nick finish $top_name $Release_Name $Release_Section_dynamic
	###### GO TO Check_Content_Dir - END ######
}


#####################################
# proc_topnew                       #
#####################################
proc proc_topnew {nick uhost hand chan arg} {
	###### INIT - BEGIN ######
	set arg [stripcodes bcu $arg]
	set top_name [lindex $arg 0]
	set Release_Name [lindex $arg 1]
	if {[string rang $Release_Name 4 4] == "/"} { set Release_Name "[string rang $Release_Name 5 end]" }
	set Release_Section [lindex $arg 2]
	###### INIT - END ######

	###### VARIABLE VERIFICATOR - BEGIN ######
	if {![info exists ::topsite($top_name\_host)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_host) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_user)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_user) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_pass)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_pass) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_port)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_port) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_NEWDIR)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_NEWDIR) dans TopClient.Conf."; return 0; }
	###### VARIABLE VERIFICATOR - END ######
	::topclient::addToReleaseTime $Release_Name - $Release_Section TOPNEWDIR;

	###### FILTRE - BEGIN ######
	if {[Release_Status $chan $nick $Release_Name $Release_Section] == 0} { return 0; }
	###### FILTRE - END ######

	###### DYNAMIC SECTION - BEGIN ######
	set Release_Section_dynamic [Check_Dynamic_section $chan $nick $top_name $Release_Section]
	###### DYNAMIC SECTION - END ######


	###### NEWDIR - BEGIN ######
	if { $::topsite($top_name\_NEWDIR) == "1" && [::topclient::indexInCache ThisNet Newdir "$Release_Name"] == "0" } { 
	#proc_SendMSG $chan $nick newdir "$Release_Name $Release_Section";
	proc_SendMSG $chan $nick newdir "$Release_Name $Release_Section"; 
	}
	###### NEWDIR - END ######

	sleep 300
	###### GO TO Check_Content_Dir - BEGIN ######
	Check_Content_Dir $chan $nick new $top_name $Release_Name $Release_Section_dynamic
	###### GO TO Check_Content_Dir - END ######

}

#####################################
# proc_toppre                       #
#####################################
proc proc_toppre {nick uhost hand chan arg} {

	###### INIT - BEGIN ######
	set arg [stripcodes bcu $arg]
	set top_name [lindex $arg 0]
	set Release_Name [lindex $arg 1]
	if {[string rang $Release_Name 4 4] == "/"} { set Release_Name "[string rang $Release_Name 5 end]" }
	set Release_Section [lindex $arg 2]
	set release_file [SizeControl [lindex $arg 3]]
	set release_size [SizeControl [lindex $arg 4]]
	###### INIT - END ######

	###### VARIABLE VERIFICATOR - BEGIN ######
	if {![info exists ::topsite($top_name\_host)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_host) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_user)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_user) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_pass)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_pass) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_port)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_port) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_SITEPRE_TO_ADDPRE)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_SITEPRE_TO_ADDPRE) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_SITEPRE_TO_INFO)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_SITEPRE_TO_INFO) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_SITEPRE)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_SITEPRE) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_NEWDIR)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_NEWDIR) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_ADDGINFO)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_ADDGINFO) dans TopClient.Conf."; return 0; }
        if {![info exists ::topsite($top_name\_ADDINFO)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_ADDINFO) dans TopClient.Conf."; return 0; }
	###### VARIABLE VERIFICATOR - END ######

	###### FILTRE - BEGIN ######
	if {[Release_Status $chan $nick $Release_Name $Release_Section] == 0} { return 0; }
	###### FILTRE - END ######

	if {![info exists ::topsite($top_name\_host)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez me l'ajouté."; return 0; }
	::topclient::addToReleaseTime $Release_Name - $Release_Section TOPSITEPRE;
	
	###### SITEPRE - BEGIN ######
	if { $::topsite($top_name\_SITEPRE) == "1"} { proc_SendMSG $chan $nick addsitepre "$Release_Name $Release_Section $release_file $release_size" }
	###### SITEPRE - END ######
	

	###### ADDPRE - BEGIN ######
	if { $::topsite($top_name\_SITEPRE_TO_ADDPRE) == "1" && [::topclient::indexInCache ThisNet Addpre "$Release_Name"] == "0" } { proc_SendMSG $chan $nick addpre "$Release_Name $Release_Section" }
	###### ADDPRE - END ######

	###### DYNAMIC SECTION - BEGIN ######
	set Release_Section_dynamic [Check_Dynamic_section $chan $nick $top_name $Release_Section]
	###### DYNAMIC SECTION - END ######

	###### GIVE INFO - BEGIN ######
	if {$release_file == "" || $release_file == "-" || $release_size == "" || $release_size != "-"} {
		set tmp_info [Get_info_ftp $chan $nick $top_name $Release_Section_dynamic/$Release_Name];
		set release_file [lindex $tmp_info 0];
		set release_size [lindex $tmp_info 1];

		###### GINFO - BEGIN ######
		if { ($release_file != "-" || $release_size != "-") && $::topsite($top_name\_ADDGINFO) == "1" } { proc_SendMSG $chan $nick addginfo "$Release_Name $release_file $release_size"; }
		###### GINFO - END ######
	 }
	###### GIVE INFO - END ######

	###### ADDINFO - BEGIN ######
	if {$release_file != "" && $release_file != "-" && $release_size != "" && $release_size != "-" &&  $::topsite($top_name\_SITEPRE_TO_INFO) == "1" &&  $::topsite($top_name\_ADDINFO) == "1" && [::topclient::indexInCache ThisNet Addinfo "$Release_Name"] == "0"} { proc_SendMSG $chan $nick addinfo "$Release_Name $release_file $release_size" }
	###### ADDINFO - END ######

	###### NEWDIR - BEGIN ######
	if { $::topsite($top_name\_NEWDIR) == "1" && [::topclient::indexInCache ALL Newdir "$Release_Name"] == "0"} { proc_SendMSG $chan $nick newdir "$Release_Name $Release_Section" }
	###### NEWDIR - END ######
	
	###### ADDINFO - BEGIN ######
	if {$release_file != "" && $release_file != "-" && $release_size != "" && $release_size != "-" && $::topsite($top_name\_ADDINFO) == "1" && [::topclient::indexInCache ThisNet Addinfo "$Release_Name"] == "0"} { proc_SendMSG $chan $nick addinfo "$Release_Name $release_file $release_size" }
	###### ADDINFO - END ######

	###### GO TO Check_Content_Dir - BEGIN ######
	Check_Content_Dir $chan $nick pre $top_name $Release_Name $Release_Section_dynamic
	###### GO TO Check_Content_Dir - END ######
	
	###### GO TO Check_Content_Dir - BEGIN ######
	Check_Content_Dir $chan $nick finish $top_name $Release_Name $Release_Section_dynamic
	###### GO TO Check_Content_Dir - END ######

}
proc ::topclient::Addinfo_DB { Release_Name Release_File Release_Size } {
	if { $Release_File == "-" || $Release_Size == "-" || $Release_File == "0" || $Release_Size == "0" } { return 0; }
	set Release_ID [::topclient::Get_Release_ID $Release_Name];
	::mysql::exec [OpenSQL] "INSERT IGNORE INTO `Infos` ( `Release_ID` , `Release_File` , `Release_Size` ) VALUES ( '$Release_ID', '$Release_File', '$Release_Size' );"; CloseSQL;
}
proc ::topclient::Add_File_in_DB { File_Type Release_Name File_Name File_Content } {
	set Release_ID [::topclient::Get_Release_ID $Release_Name];
	::mysql::exec [OpenSQL] "INSERT IGNORE INTO `$File_Type` ( `Release_ID` , `Content` , `Filename` ) VALUES ( '$Release_ID', '[::mysql::escape $File_Content]', '[::mysql::escape $File_Name]' );"; CloseSQL;
}


proc ::topclient::indexInCache {network type args} {
	set params [split [string trimright [join $args]] " "];
	if {$network == "ALL"} { set SQL_OPTION ""; } else { set SQL_OPTION "AND `network` = '[S2SQL $::server]'"; }
	set idx [::mysql::sel [OpenSQL] "SELECT count(*) FROM `indexInCache` WHERE `type` = '$type' AND `release` = '$params' $SQL_OPTION LIMIT 1;" -flatlist]; CloseSQL;
	if {$idx != "0"} { return 1; } else { return 0; }
}

proc ::topclient::Get_Release_ID { Release_Name } {
	return [::mysql::sel [OpenSQL] "SELECT `Release_ID` FROM `ReleaseTime` WHERE `Release_Name` = '$Release_Name' LIMIT 1;" -flatlist]; CloseSQL;
}

proc ::topclient::addToCache { chan nick type args } {
	::mysql::exec [OpenSQL] "INSERT INTO `indexInCache` ( `type` , `release` , `time` , `user` , `channel` , `bot` , `network` ) VALUES ( '$type', '$args', NOW( ) , '[S2SQL $nick]', '[S2SQL $chan]', '[S2SQL $::who_name]', '[S2SQL $::server]' );"; CloseSQL;
}
## zmodyfikowane ##
proc ::topclient::addToReleaseTime { Release_Name Release_Time Release_Section Release_Source} {
	if { $Release_Time == "" || $Release_Time == "-" } { set Release_Time [clock seconds]; }
	if { $Release_Section == "" || $Release_Section == "-" } { set Release_Section "Other"; }
	::mysql::exec [OpenSQL] "INSERT IGNORE INTO `ReleaseTime` ( `Release_Name` , `Release_Time` , `Release_Section` ) VALUES ( '[::mysql::escape $Release_Name]', '$Release_Time', '[::mysql::escape $Release_Section]' );"; CloseSQL;
	::topclient::Update_Source_Adding $Release_Name $Release_Source;
}
proc ::topclient::Update_Source_Adding { Release_Name Release_Source } {
	set Release_ID [::topclient::Get_Release_ID $Release_Name];
	::mysql::exec [OpenSQL] "INSERT IGNORE INTO `Index_Adding` ( `Release_ID` ) VALUES ( '$Release_ID' );"; CloseSQL;
	::mysql::exec [OpenSQL] "UPDATE `Index_Adding` SET `$Release_Source` =  '1' WHERE `Index_Adding`.`Release_ID` = '$Release_ID' LIMIT 1;"; CloseSQL;
}

proc ::topclient::ReleaseToTime { Release_Name } {
	set idx [::mysql::sel [OpenSQL] "SELECT `Release_Time` FROM `ReleaseTime` WHERE `Release_Name` = '$Release_Name' LIMIT 1;" -flatlist]; CloseSQL;
	if {$idx != ""} { return $idx; } else { return 0; }
}
proc ::topclient::ReleaseIsNew {release} {
	set timerls [::topclient::ReleaseToTime $release];
	if {$timerls==""} { 
		return 0; # Pas time => old
	} elseif {[expr [clock seconds] - $timerls] >= 3600} { 
		return 0; # time over 3600 => old
	} elseif {[expr [clock seconds] - $timerls] <= 3600} { 
		return 1; # => sinon new
	}
}

#####################################
# Check_Content_Dir                 ### zmiana ## if {[catch {set ftp_buffer [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ; ls /$Release_Section/$Release_Name |grep :;quit"]} error]} {
#####################################if {[catch {set ftp_buffer [exec -- lftp [FTPCONNECTSITE $top_name]/$Release_Section/$Release_Name -e " $::topsite($top_name\_LFTP_CONFIG) ; ls | tail -n +2;quit"]} error]} {
######                               if {[catch {set ftp_buffer [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name]/$Release_Section/$Release_Name -e " $::topsite($top_name\_LFTP_CONFIG) ;ls | tail -n +2"]} error]} {
proc Check_Content_Dir {chan nick type_content top_name Release_Name Release_Section} {
	if {![info exists ::topsite($top_name\_LFTP_CONFIG)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_LFTP_CONFIG) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_DL_NFO)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_DL_NFO) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_DL_M3U)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_DL_M3U) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_DL_JPG)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_DL_JPG) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_DL_SFV)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_DL_SFV) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_DL_SAMPLE)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_DL_SAMPLE) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_MP3INFO)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_MP3INFO) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_FILEINFO)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_FILEINFO) dans TopClient.Conf."; return 0; }
        if {[catch {set ftp_buffer [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ; ls /$Release_Section/$Release_Name/ | egrep \'Sample\\|sample\\|.r\[0-9\]\\|.avi\\|.mp4\\|.vob\\|.mkv\\|.wmv\\|.nfo\\|.sfv\\|.m3u\\|.zip\\|.flac\\|.cue\\|.jpg\\|.mp3\\|.rar\';quit"]} error]} {
	proc_SendMSG $chan $nick error "Error Check_Content_Dir listing $Release_Name : $error"
		if {[regexp "(.*)max-retries(.*)" [string tolower $error]]} { exec -- killall -9 lftp }
	} else {
		set a "";
		foreach {ftp_droit ftp_unknown ftp_owner ftp_grp ftp_file_bytes ftp_file_month ftp_file_day ftp_file_hour ftp_file_name} $ftp_buffer {
			append a "$ftp_file_name $ftp_file_bytes\n";
		}
		foreach {ftp_file_name ftp_file_bytes} $a {
			if {[regexp ".nfo$" [string tolower $ftp_file_name]] && [::topclient::indexInCache ALL Addnfo "$Release_Name/$ftp_file_name"] == "0" &&  $::topsite($top_name\_DL_NFO) == "1" && 1 < $ftp_file_bytes && [regexp "((.*)\\(\[0-9\]{1,2}\\).(.*)|imdb.nfo)" [string tolower $ftp_file_name]] == 0} { Get_NFO_On_FTP $chan $nick $top_name $Release_Name $Release_Section $ftp_file_name }
		}
		foreach {ftp_file_name ftp_file_bytes} $a {
			if {[regexp ".m3u$" [string tolower $ftp_file_name]] && [::topclient::indexInCache ALL Addm3u "$Release_Name/$ftp_file_name"] == "0" &&  $::topsite($top_name\_DL_M3U) == "1" && 1 < $ftp_file_bytes && [regexp "(.*)\\(\[0-9\]{1,2}\\).(.*)" [string tolower $ftp_file_name]] == 0} { Get_M3U_On_FTP $chan $nick $top_name $Release_Name $Release_Section $ftp_file_name }
		}
		foreach {ftp_file_name ftp_file_bytes} $a {
		       if {[regexp ".jpg$" [string tolower $ftp_file_name]] && [::topclient::indexInCache ALL Addjpg "$Release_Name/$ftp_file_name"] == "0" &&  $::topsite($top_name\_DL_JPG) == "1" && 1 < $ftp_file_bytes && [regexp "(.*)\\(\[0-9\]{1,2}\\).(.*)" [string tolower $ftp_file_name]] == 0} { Get_JPG_On_FTP $chan $nick $top_name $Release_Name $Release_Section $ftp_file_name }
		}
		foreach {ftp_file_name ftp_file_bytes} $a {
		       if {[regexp ".cue$" [string tolower $ftp_file_name]] && [::topclient::indexInCache ALL Addcue "$Release_Name/$ftp_file_name"] == "0" &&  $::topsite($top_name\_DL_CUE) == "1" && 1 < $ftp_file_bytes && [regexp "(.*)\\(\[0-9\]{1,2}\\).(.*)" [string tolower $ftp_file_name]] == 0} { Get_CUE_On_FTP $chan $nick $top_name $Release_Name $Release_Section $ftp_file_name }
		}
		foreach {ftp_file_name ftp_file_bytes} $a {
			if {[regexp ".sfv$" [string tolower $ftp_file_name]] && [::topclient::indexInCache ALL Addsfv "$Release_Name/$ftp_file_name"] == "0" &&  $::topsite($top_name\_DL_SFV) == "1" && 1 < $ftp_file_bytes && [regexp "(.*)\\(\[0-9\]{1,2}\\).(.*)" [string tolower $ftp_file_name]] == 0} { Get_SFV_On_FTP $chan $nick $top_name $Release_Name $Release_Section $ftp_file_name }
		}
		foreach {ftp_file_name ftp_file_bytes} $a {
		if {![regexp ".r\[0-9\]{2}\$|.rar$|.mp3$|.zip$|.mkv$|.\[0-9\]{3}\$" [string tolower $ftp_file_name]] && [regexp "cover" [string tolower $ftp_file_name]] && [::topclient::indexInCache ALL Addcover "$Release_Name/$ftp_file_name"] == "0" &&  $::topsite($top_name\_DL_COVER) == "1" && 1 < $ftp_file_bytes} { set file_name [Get_Cover_File_Name_On_FTP $chan $nick $top_name $Release_Name $Release_Section $ftp_file_name];Get_Cover_On_FTP $chan $nick $top_name $Release_Name $Release_Section $ftp_file_name $file_name  }
		}
		foreach {ftp_file_name ftp_file_bytes} $a {
		if {![regexp ".r\[0-9\]{2}\$|.rar$|.mp3$|.zip$|.mkv$|.\[0-9\]{3}\$" [string tolower $ftp_file_name]] && [regexp "covers" [string tolower $ftp_file_name]] && [::topclient::indexInCache ALL Addcover "$Release_Name/$ftp_file_name"] == "0" &&  $::topsite($top_name\_DL_COVER) == "1" && 1 < $ftp_file_bytes} { set file_name [Get_Cover_File_Name_On_FTP $chan $nick $top_name $Release_Name $Release_Section $ftp_file_name];Get_Cover_On_FTP $chan $nick $top_name $Release_Name $Release_Section $ftp_file_name $file_name  }
		}
		foreach {ftp_file_name ftp_file_bytes} $a {
			if {[regexp "sample" [string tolower $ftp_file_name]] &&  $::topsite($top_name\_DL_SAMPLE) == "1" && [regexp "(.*)\\(\[0-9\]{1,2}\\).(.*)" [string tolower $ftp_file_name]] == 0} { set file_name [Get_Sample_File_Name_On_FTP $chan $nick $top_name $Release_Name $Release_Section $ftp_file_name]; Get_Sample_On_FTP $chan $nick $top_name $Release_Name $Release_Section $ftp_file_name $file_name }
		}
		if { [regexp -nocase {(cd|dvd)[1-9]$} $Release_Name] } { regsub -expanded -nocase {/(cd|dvd)[1-9]$}  $Release_Name "" Release_Name;  }
		if { $type_content == "finish" } {
			foreach {ftp_file_name ftp_file_bytes} $a {
				if {[regexp ".mp3$" [string tolower $ftp_file_name]] &&  $::topsite($top_name\_MP3INFO) == "1" && [::topclient::indexInCache ALL Mp3info "$Release_Name/$ftp_file_name"] == "0" && 1 < $ftp_file_bytes } { proc_SendMSG $chan $nick mp3info "$Release_Name $ftp_file_name $ftp_file_bytes"; }
			}
			foreach {ftp_file_name ftp_file_bytes} $a {
                                if {[regexp ".flac$" [string tolower $ftp_file_name]] &&  $::topsite($top_name\_MP3INFO) == "1" && [::topclient::indexInCache ALL Mp3info "$Release_Name/$ftp_file_name"] == "0" && 1 < $ftp_file_bytes } { proc_SendMSG $chan $nick mp3info "$Release_Name $ftp_file_name $ftp_file_bytes"; }
                        }
			foreach {ftp_file_name ftp_file_bytes} $a {
			        if {![regexp ".flac$" [string tolower $ftp_file_name]] && [regexp "\.*\[\.\]\[\\w\]{3}$" [string tolower $ftp_file_name]] && [regexp "\[\\d\]" [string tolower $ftp_file_bytes]] && $::topsite($top_name\_FILEINFO) == "1" && [::topclient::indexInCache ALL Fileinfo "$Release_Name/$ftp_file_name"] == "0" && 1 < $ftp_file_bytes } { proc_SendMSG $chan $nick fileinfo "$Release_Name $ftp_file_name $ftp_file_bytes"; }
			}
			foreach {ftp_file_name ftp_file_bytes} $a {
				if {![regexp ".mp3$" [string tolower $ftp_file_name]] && [regexp "\.*\[\.\]\[\\w\]{3}$" [string tolower $ftp_file_name]] && [regexp "\[\\d\]" [string tolower $ftp_file_bytes]] && $::topsite($top_name\_FILEINFO) == "1" && [::topclient::indexInCache ALL Fileinfo "$Release_Name/$ftp_file_name"] == "0" && 1 < $ftp_file_bytes } { proc_SendMSG $chan $nick fileinfo "$Release_Name $ftp_file_name $ftp_file_bytes"; }
			}
		}
		foreach {ftp_file_name ftp_file_bytes} $a {
			if {[regexp -nocase {^(cd|dvd)[1-9]$} $ftp_file_name]} { Check_Content_Dir $chan $nick $type_content $top_name "$Release_Name/$ftp_file_name" $Release_Section; }
		}
	}
}
#####################################
# Get_Files                         #
#####################################
proc Get_NFO_Name_On_FTP {chan nick top_name Release_Name Release_Section} {
        if {[catch {set File_Name [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ; ls | grep .nfo"]} error]} {
                proc_SendMSG $chan $nick error "Error Get_NFO_Name_On_FTP: Get NFO for $Release_Section/$Release_Name : $error"
                if {[regexp "(.*)max-retries(.*)" [string tolower $error]]} { exec -- killall -9 lftp }
        } else { return [lindex [split $File_Name " "] end] }
}
proc Get_Cover_File_Name_On_FTP {chan nick top_name Release_Name Release_Section dir_name} {
        if {[catch {set File_Name [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ; cd $Release_Section/$Release_Name/$dir_name; ls | egrep .jpg"]} error]} {
                proc_SendMSG $chan $nick error "Error Get_Cover_File_Name_On_FTP: Get Cover for $Release_Section/$Release_Name/$dir_name : $error"
                if {[regexp "(.*)max-retries(.*)" [string tolower $error]]} { exec -- killall -9 lftp }
        } else { return [lindex [split $File_Name " "] end] }
}
proc Get_Sample_File_Name_On_FTP {chan nick top_name Release_Name Release_Section dir_name} {
	if {[catch {set File_Name [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ; cd /$Release_Section/$Release_Name/$dir_name ; ls | egrep \'.avi\\|.mov\\|.mp4\\|.vob\\|.mkv\\|.wmv\'"]} error]} {
		proc_SendMSG $chan $nick error "Error Get_Sample_File_Name_On_FTP: Get Sample for $Release_Section/$Release_Name/$dir_name : $error"
		if {[regexp "(.*)max-retries(.*)" [string tolower $error]]} { exec -- killall -9 lftp }
	} else { return [lindex [split $File_Name " "] end] }
}
proc Get_NFO_On_FTP {chan nick top_name Release_Name Release_Section file_name} {
        if {[catch {set result [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e  " $::topsite($top_name\_LFTP_CONFIG) ; cd /$Release_Section/$Release_Name ; get $file_name"]} error]} {
                proc_SendMSG $chan $nick error "Error dl NFO :$file_name for $Release_Name $Release_Section : $error"
                if {[regexp "(.*)max-retries(.*)" [string tolower $error]]} { exec -- killall -9 lftp }
                return 0;
        }
        set File_CRC [crc::crc32 -format %08X -filename $file_name];
        set File_md5 "[md5::md5 -hex $Release_Name$file_name].nfo";
        if { ![Move_File_to_dir $file_name $::top_config(www)/$File_md5] } { proc_SendMSG $chan $nick error "Nieistniej±cy plik $file_name lub niemo¿liwe do poruszania siê w katalogu WWW"; return 0; }
        if {[regexp -nocase {(cd|dvd)[1-9]$} $Release_Name]} { regsub -expanded -nocase {/(cd|dvd)[1-9]$}  $Release_Name "" Release_Name;  }
        proc_SendMSG $chan $nick addnfo "$Release_Name http://$::top_config(www_dns)$::top_config(www_path)/$File_md5 $file_name $File_CRC";
        utimer 180 [list tc:wipe $File_md5];
        
}

proc Get_SFV_On_FTP {chan nick top_name Release_Name Release_Section file_name} {
	if {[catch {set result [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ; cd /$Release_Section/$Release_Name ;get $file_name"]} error]} {
		proc_SendMSG $chan $nick error "Error dl SFV: $file_name for $Release_Name $Release_Section $error"
		if {[regexp "(.*)max-retries(.*)" [string tolower $error]]} { exec -- killall -9 lftp }
		return 0;
	}
	set File_CRC [crc::crc32 -format %08X -filename $file_name];
	set File_md5 "[md5::md5 -hex $Release_Name$file_name].sfv";
	if { ![Move_File_to_dir $file_name $::top_config(www)/$File_md5] } { proc_SendMSG $chan $nick error "Nieistniej±cy plik $file_name lub niemo¿liwe do poruszania siê w katalogu WWW"; return 0; }
	if {[regexp -nocase {(cd|dvd)[1-9]$} $Release_Name]} { regsub -expanded -nocase {/(cd|dvd)[1-9]$}  $Release_Name "" Release_Name;  }
        proc_SendMSG $chan $nick addsfv "$Release_Name http://$::top_config(www_dns)$::top_config(www_path)/$File_md5 $file_name $File_CRC"
        utimer 180 [list tc:wipe $File_md5];
}
proc Get_M3U_On_FTP {chan nick top_name Release_Name Release_Section file_name} {
	if {[catch {set result [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ; cd /$Release_Section/$Release_Name; get $file_name"]} error]} {
		proc_SendMSG $chan $nick error "Error dl M3U file_name for $Release_Name $Release_Section : $error"
		if {[regexp "(.*)max-retries(.*)" [string tolower $error]]} { exec -- killall -9 lftp }
		return 0;
	}
	set File_CRC [crc::crc32 -format %08X -filename $file_name];
	set File_md5 "[md5::md5 -hex $Release_Name$file_name].m3u";
	if { ![Move_File_to_dir $file_name $::top_config(www)/$File_md5] } { proc_SendMSG $chan $nick error "Nieistniej±cy plik $file_name lub niemo¿liwe do poruszania siê w katalogu WWW"; return 0; }
	if {[regexp -nocase {(cd|dvd)[1-9]$} $Release_Name]} { regsub -expanded -nocase {/(cd|dvd)[1-9]$}  $Release_Name "" Release_Name;  }
	proc_SendMSG $chan $nick addm3u "$Release_Name http://$::top_config(www_dns)$::top_config(www_path)/$File_md5 $file_name $File_CRC"
        utimer 180 [list tc:wipe $File_md5];
}
proc Get_JPG_On_FTP {chan nick top_name Release_Name Release_Section file_name} {
        if {[catch {set result [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ; cd /$Release_Section/$Release_Name; get $file_name"]} error]} {
                proc_SendMSG $chan $nick error "Error dl JPG file_name for $Release_Name $Release_Section : $error"
                if {[regexp "(.*)max-retries(.*)" [string tolower $error]]} { exec -- killall -9 lftp }
                return 0;
        }
        set File_CRC [crc::crc32 -format %08X -filename $file_name];
        set File_md5 "[md5::md5 -hex $Release_Name$file_name].jpg";
        if { ![Move_File_to_dir $file_name $::top_config(www)/$File_md5] } { proc_SendMSG $chan $nick error "Nieistniej±cy plik $file_name lub niemo¿liwe do poruszania siê w katalogu WWW"; return 0; }
        if {[regexp -nocase {(cd|dvd)[1-9]$} $Release_Name]} { regsub -expanded -nocase {/(cd|dvd)[1-9]$}  $Release_Name "" Release_Name;  }
        proc_SendMSG $chan $nick addjpg "$Release_Name http://$::top_config(www_dns)$::top_config(www_path)/$File_md5 $file_name $File_CRC"
        utimer 180 [list tc:wipe $File_md5];
}
proc Get_CUE_On_FTP {chan nick top_name Release_Name Release_Section file_name} {
        if {[catch {set result [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ; cd /$Release_Section/$Release_Name; get $file_name"]} error]} {
                proc_SendMSG $chan $nick error "Error dl CUE file_name for $Release_Name $Release_Section : $error"
                if {[regexp "(.*)max-retries(.*)" [string tolower $error]]} { exec -- killall -9 lftp }
                return 0;
        }
        set File_CRC [crc::crc32 -format %08X -filename $file_name];
        set File_md5 "[md5::md5 -hex $Release_Name$file_name].cue";
        if { ![Move_File_to_dir $file_name $::top_config(www)/$File_md5] } { proc_SendMSG $chan $nick error "Nieistniej±cy plik $file_name lub niemo¿liwe do poruszania siê w katalogu WWW"; return 0; }
        if {[regexp -nocase {(cd|dvd)[1-9]$} $Release_Name]} { regsub -expanded -nocase {/(cd|dvd)[1-9]$}  $Release_Name "" Release_Name;  }
        proc_SendMSG $chan $nick addcue "$Release_Name http://$::top_config(www_dns)$::top_config(www_path)/$File_md5 $file_name $File_CRC"
        utimer 180 [list tc:wipe $File_md5];
}
proc Get_Cover_On_FTP {chan nick top_name Release_Name Release_Section dir_name file_name} {
        if {[catch {set resultat [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ; cd /$Release_Section/$Release_Name/$dir_name;get $file_name"]} error]} {
                proc_SendMSG $chan $nick error "Error Get_Cover_On_FTP: Get $file_name for $Release_Section/$Release_Name/$dir_name : $error"
                if {[regexp "(.*)max-retries(.*)" [string tolower $error]]} { exec -- killall -9 lftp }
                return 0;
        }
        set File_CRC [crc::crc32 -format %08X -filename $file_name];
        set File_md5 "[md5::md5 -hex $Release_Name$file_name].jpg";
        if { ![Move_File_to_dir $file_name $::top_config(www)/$File_md5] } { proc_SendMSG $chan $nick error "Nieistniej±cy plik $file_name lub niemo¿liwe do poruszania siê w katalogu WWW"; return 0; }
        if {[regexp -nocase {(cd|dvd)[1-9]$} $Release_Name]} { regsub -expanded -nocase {/(cd|dvd)[1-9]$}  $Release_Name "" Release_Name;  }
        proc_SendMSG $chan $nick addjpg "$Release_Name http://$::top_config(www_dns)$::top_config(www_path)/$File_md5 $file_name $File_CRC";
        utimer 180 [list tc:wipe $File_md5];
}
proc Get_Sample_On_FTP {chan nick top_name Release_Name Release_Section dir_name file_name} {
        if {[::topclient::indexInCache ALL Addjpg "$Release_Name/$file_name"] != "0"} { return 0; }
        if {[catch {set result [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ;cd /$Release_Section/$Release_Name/$dir_name/; get $file_name"]} error]} {
                proc_SendMSG $chan $nick error "Error Get_Sample_On_FTP: Get $file_name for $Release_Section/$Release_Name/$dir_name : $error"
                if {[regexp "(.*)max-retries(.*)" [string tolower $error]]} { exec -- killall -9 lftp }

        } else {
                Sample_To_ADDViDEOiNFO $chan $nick $Release_Name $file_name
                File_To_MediaInfo $chan $nick $Release_Name $file_name
                Sample_To_ADDJPG_And_ADDViDEOiNFO $chan $nick $Release_Name $file_name
        }
}

proc Move_File_to_dir {file_name dir_name} {
	if {[catch {exec -- mv $file_name $dir_name} error]} { return 0 } else { return 1 }
}
proc Size_Of_File_Verif {file_name dir_name} {
	if {[file size $dir_name$file_name] == "0"} { return 0 } else { return 1 }
}
proc Sample_To_ADDViDEOiNFO {chan nick Release_Name file_name} {
        if { [catch {set videoinfo_data [exec -- mediainfo --full --output=XML $file_name]} error] } {
                proc_SendMSG error "Error videoinfo $error";
        } else {
                if { [regexp -nocase {<track type="Video">(.*)<track} $videoinfo_data -> Video] } {
                        if { ![regexp -nocase {<Codecs_Video>(.*)</Codecs_Video>} $Video -> V_Codec_ID] } {
                                if { ![regexp -nocase {<Codec_ID>(.*)</Codec_ID>} $Video -> V_Codec_ID] } { set V_Codec_ID "-"; }
                                if { ![regexp -nocase {<Codec>([A-Z]{1,})</Codec>} $Video -> V_Codec_ID] } { set V_Codec_ID "-"; }
                                if { ![regexp -nocase {<Codec>([A-Z0-9]{1,})</Codec>} $Video -> V_Codec_ID] } { set V_Codec_ID "-"; }
                        }
                        if { ![regexp -nocase {<Frame_rate>([0-9.]{1,}) fps</Frame_rate>} $Video -> V_Frame_rate] } { set V_Frame_rate "-"; }
                        if { ![regexp -nocase {<Height>([0-9]{1,}) pixels</Height>} $Video -> V_Height] } { set V_Height "-"; }
                        if { ![regexp -nocase {<Width>([0-9]{1,}) pixels</Width>} $Video -> V_Width] } { set V_Width "-"; }
                        if { ![regexp -nocase {<Height>([0-9]{1,})</Height>} $Video -> V_Height] } { set V_Height "-"; }
                        if { ![regexp -nocase {<Width>([0-9]{1,})</Width>} $Video -> V_Width] } { set V_Width "-"; }

                        if { ![regexp -nocase {<Display_aspect_ratio>([0-9]{1,}[.][0-9]{1,})[0-9]</Display_aspect_ratio>} $Video -> V_AR] } { set V_AR "-"; }
                } else {
                        return "-1";
                }
                if { [regexp -nocase {<track type="Audio">(.*)</track>} $videoinfo_data -> Audio] } {
                        if { ![regexp -nocase {<Codec_ID_Hint>([A-Z0-9]{1,})</Codec_ID_Hint>} $Audio -> A_Codec] } {
                                if { ![regexp -nocase {<Codec_Family>([A-Z0-9]{1,})</Codec_Family>} $Audio -> A_Codec] } { set A_Codec "-"; }
                        }
                        if { ![regexp -nocase {<Bit_rate>([0-9]{1,}) Kbps</Bit_rate>} $Audio -> A_Bit_rate] } { set A_Bit_rate "-"; }
                        if { ![regexp -nocase {<Sampling_rate>([0-9]{1,})</Sampling_rate>} $Audio -> A_Sampling_rate] } { set A_Sampling_rate "-"; }
                        if { ![regexp -nocase {<Channel_s_>([0-9]{1,})</Channel_s_>} $Audio -> A_Channel] } { set A_Channel "-"; }
                } elseif { [regexp -nocase {<track type="Audio" streamid="1">(.*)</track>} $videoinfo_data -> Audio] } {
                        set DATA        ""
                        set STATUS      "1"
                        foreach D [split $Audio "\n"] {
                                if { $STATUS == "1" } {
                                        regexp -nocase {<Format>([A-Z0-9]{1,})</Format>} $D -> A_Codec;
                                        regexp -nocase {<Codec_ID_Hint>([A-Z0-9]{1,})</Codec_ID_Hint>} $Audio -> A_Codec
                                        regexp -nocase {<Codec_Family>([A-Z0-9]{1,})</Codec_Family>} $Audio -> A_Codec
                                        regexp -nocase {<Codec>([A-Z0-9]{1,})</Codec>} $Audio -> A_Codec

                                        regexp -nocase {<Bit_rate>(.*) Kbps</Bit_rate>} $D -> A_Bit_rate;
                                        regexp -nocase {<Sampling_rate>([0-9]{1,})</Sampling_rate>} $D -> A_Sampling_rate;
                                        regexp -nocase {<Channel_s_>([0-9]{1,})</Channel_s_>} $D -> A_Channel;

                                }
                                if { [regexp -nocase {(.*)(</track>)(.*)} $D] }  { set STATUS   "0"; }
                        }
                } else {
                        return "-2";
                }
                set A_Bit_rate    [string map {" " ""} $A_Bit_rate];
                if {[regexp -nocase {(AVC)} $V_Codec_ID]} { set V_Codec_ID "H.264" }
                say #debug "\0034addvideoinfo $Release_Name $V_Codec_ID $V_Frame_rate ${V_Width}x${V_Height} $V_AR $A_Codec $A_Bit_rate $A_Sampling_rate $A_Channel";
                proc_SendMSG $chan $nick addvideoinfo "$Release_Name $V_Codec_ID $V_Frame_rate ${V_Width}x${V_Height} $V_AR $A_Codec $A_Bit_rate $A_Sampling_rate $A_Channel";
        }
}

#####################################
# Sample_To_ADDSAMPLE #
#####################################
proc File_To_MediaInfo { chan nick Release_Name file_name } {
                set File_md5    "[md5::md5 -hex [clock seconds]$Release_Name/$file_name].xml";
                set File_Path   "$File_md5";
                if { [catch { set mediainfo [exec -- mediainfo --full --output=XML $file_name --LogFile=${File_Path}] } error] } {
                         proc_SendMSG $chan $_nick error "File_To_MediaInfo -> $error.";
                } else {
                        set File_CRC [crc::crc32 -format %08X -file $File_Path];
                        if { ![Move_File_to_dir $File_md5 $::top_config(www)/$File_md5] } { proc_SendMSG $chan $nick error "Sample_To_ADDSAMPLE Nieistniej±cy plik $file_name lub niemo¿liwe do poruszania siê w katalogu WWW"; return 0; }
                        proc_SendMSG $chan $nick addmediainfo "$Release_Name http://$::top_config(www_dns)$::top_config(www_path)/$File_md5 $file_name $File_CRC";
                        utimer 180 [list tc:wipe $File_md5];
                }
        }

#####################################
# Sample_To_ADDJPG_And_ADDViDEOiNFO #
#####################################
proc Sample_To_ADDJPG_And_ADDViDEOiNFO {chan nick Release_Name file_name} {
	if {[file exists 1.jpg]} { exec rm 1.jpg }
	    catch {exec $::top_config(ffmpeg) -i $file_name -an -ss 00:00:05 -an -r 1 -vframes 1 -y %d.jpg} output
	if {[info exists output]} {
	if {[file exists $file_name]} { exec rm $file_name }
	if {[Move_File_to_dir 1.jpg $::top_config(www)/$file_name.jpg]} {
        set File_CRC [crc::crc32 -format %08X -filename $::top_config(www)/$file_name.jpg];
        set File_md5 "[md5::md5 -hex $Release_Name$file_name].jpg";
        if { ![Move_File_to_dir $::top_config(www)/$file_name.jpg $::top_config(www)/$File_md5] } { proc_SendMSG $chan $nick error "Sample_To_ADDJPG_And_ADDViDEOiNFO Nieistniej±cy plik $file_name lub niemo¿liwe do poruszania siê w katalogu WWW"; return 0; }
	proc_SendMSG $chan $nick addjpg "$Release_Name http://$::top_config(www_dns)$::top_config(www_path)/$File_md5 $file_name $File_CRC"
	utimer 180 [list tc:wipe $File_md5];
	}
	    } else {
	    if {[file exists $file_name]} { exec rm $file_name }
	    proc_SendMSG error "Error Sample_To_ADDJPG_And_ADDViDEOiNFO: Conversion failled for $file_name"
	}
}
bind pub -|- !last TopLast
#####################################
# TopLast                           #if { [catch {set result [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e "$::topsite($top_name\_LFTP_CONFIG) ;site new $Total_Check | tail -n +4"]} error] } {
#####################################
proc TopLast { nick uhost hand chan msg } {
	if {[lindex $msg 1] == ""} { proc_SendMSG $chan $nick error "!last <site_name> <number>"; return 0; }
	set top_name    [lindex $msg 0];
	set Total_Check [lindex $msg 1];
	if { $Total_Check == "" } { set Total_Check 5; }
	set uhost "bot"
	say $chan "\00313Check last site \0034->\00311 $top_name \00313-->\0034 $Total_Check"
	set result [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e "$::topsite($top_name\_LFTP_CONFIG) ;site new $Total_Check | tail -n +4"]
	if { $result != 0 } {
		foreach Ligne [split $result "\n"] {
			set Release_Name [lrange $Ligne end end];
			set idx [string first "/" $Release_Name]
			incr idx
			set Release_Name [string range $Release_Name $idx end]
			set idx [string first "/" $Release_Name]
			incr idx
			set Release_Name [string range $Release_Name $idx end]
			set idx [string first "/" $Release_Name]
			incr idx
			set Release_Name [string range $Release_Name $idx end]
			if { [regexp "^\[A-Z0-9\]{1}\[a-zA-Z0-9\\.\\(\\)_\\-\]{6,254}$" $Release_Name] == 0 } { continue; }
			set result [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e "$::topsite($top_name\_LFTP_CONFIG) ;site search $Release_Name"]
			if { $result != 0 } {
				set Section_Name [lindex [split $result "/"] 1]
				say $chan "\00313Check on site \0034-> \0039${top_name}\0034 ->\00311 $Release_Name \0030in\00311 $Section_Name"
				set uhost "bot"
				set hand "bot"
				proc_topcomplete $nick $uhost $hand $chan "$top_name $Release_Name $Section_Name - -";
			}
		}
	}
	say $chan "\00313End check last site \0034->\00311 $top_name"
}
#####################################
# SLEEP                             #
#####################################  
proc sleep { ms } {
	set uniq [ uniqkey ]
	set ::__sleep__tmp__$uniq 0
	after $ms set ::__sleep__tmp__$uniq 1
	vwait ::__sleep__tmp__$uniq
	unset ::__sleep__tmp__$uniq
}
#####################################
# UNIQKEY                           #
#####################################  
proc uniqkey { } {
	set key   [ expr { pow(2,31) + [ clock clicks ] } ]
	set key   [ string range $key end-8 end-3 ]
	set key   [ clock seconds ]$key
	return $key
}
#bind pub - !addold IRC:ADDOLD
proc IRC:ADDOLD { nick uhost handle chan arg } {
 	set Release_Name [lindex $arg 0];
	set Release_Section [lindex $arg 1];
	set Release_Time [lindex $arg 2];
	set Release_File [lindex $arg 3];
	set Release_Size [lindex $arg 4];
	set Release_Style [lindex $arg 5];
	::topclient::addToReleaseTime $Release_Name $Release_Time $Release_Section ADDOLD;
	if { $Release_Style != "-" } { BOT:STYLE "$chan/$nick" addstyle "$Release_Name $Release_Style"; }
	::topclient::Addinfo_DB $Release_Name $Release_File $Release_Size;
}
proc BOT:STYLE { bot handle arg } {
	global top_config
	set chan [lindex [split $bot "/"] 0]
	set nick [lindex [split $bot "/"] 1]
 	set Release_Name [lindex $arg 0];
	set Release_Style [lindex $arg 1];
	set Release_ID [::topclient::Get_Release_ID $Release_Name];
	if { $Release_ID == "" } { return 0; }
	if { [string match "*/*" $arg] } {
		foreach Release_Multi_Style [split $Release_Style "/"] {
			Add_Genre $Release_ID $Release_Name $Release_Multi_Style $nick $chan;
		}
	} else {
		Add_Genre $Release_ID $Release_Name $Release_Style $nick $chan;
	}
}
############# addpre
##bind pub - !addpre IRC:ADDPRE
proc IRC:ADDPRE { nick uhost handle chan arg } {
 	set Release_Name [lindex $arg 0];
	set Release_Section [lindex $arg 1];
        set check [::mysql::sel [OpenSQL] "SELECT * FROM `ReleaseTime` WHERE `Release_Name` LIKE '$Release_Name' LIMIT 1;" -flatlist]; CloseSQL;
        if {[llength $check] > 0} {
	#say #debug "\0034arleady addpre $Release_Name"
	return 0
	}
	#putallbots "addpre $Release_Name $Release_Section"
	putlog "ADDPRE $nick $chan -> $Release_Name $Release_Section"
	::topclient::addToReleaseTime $Release_Name - $Release_Section ADDPRE;
	::topclient::addToCache $chan $nick Addpre $Release_Name;
	::topclient::addToCache $chan $nick Newdir $Release_Name;
	putfast "privmsg #debug :\0034$nick\003 -> (\00310ADDPRE\003):\0037 $Release_Name $Release_Section";
}
#####################################
# Control                           #
#####################################
if {[file exists $::top_config(lftp)] == "0"} { die "\n\n################################################################\n#        -> TopClient.tcl can not work without LFTP. <-        #\n# -> Check top_config(lftp) variable in Scripts/TopClient.conf file. <- #\n################################################################" }
if {[file exists $::top_config(ffmpeg)] == "0"} { die "\n\n##################################################################\n#        -> TopClient.tcl can not work without FFmpeg. <-        #\n# -> Check top_config(ffmpeg) variable in Scripts/TopClient.conf file. <- #\n##################################################################" }
#####################################
# SPEED MAX                         #
#####################################
proc putfast {arg} {
  append arg "\n"
    putdccraw 0 [string length $arg] $arg
}
proc say {chanOrNick txt} {
 putfast "PRIVMSG $chanOrNick :$txt"
}
####################################
# wipe files                       #
####################################
proc filewipe {file_name} {
if {[file exists "$::top_config(www)/$file_name"]} {
file delete -force "$::top_config(www)/$file_name"
}
return 0
}
####################################
# wipe files  md5                  #
####################################
proc tc:wipe {File_md5} {
if {[file exists "$::top_config(www)/$File_md5"]} {
file delete -force "$::top_config(www)/$File_md5"
}
return 0
}
###################################
putlog "TC lftp loaded."
###################################
