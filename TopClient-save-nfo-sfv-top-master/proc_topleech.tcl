#####################################
# Binds
#####################################
bind pub -|- ${::CMD(trigger)}topleech proc_topleech

#####################################
# proc_topleech #
#####################################
proc proc_topleech { nick uhost hand chan arg } {
	if { [lindex $arg 1] == "" } { proc_SendMSG $chan $nick error "!topleech <site_name> <section_name>"; return 0; }
	
	set top_name [lindex $arg 0];
	set Release_Section [lindex $arg 1];
	
	if {![info exists ::topsite($top_name\_host)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_host) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_user)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_user) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_pass)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_pass) dans TopClient.Conf."; return 0; }
	if {![info exists ::topsite($top_name\_port)]} { proc_SendMSG $chan $nick error "Le site $top_name m'ait inconu. Veuillez m'ajouter ::topsite($top_name\_port) dans TopClient.Conf."; return 0; }
	set Content [exec -- $::top_config(lftp) [FTPCONNECTSITE $top_name] -e " $::topsite($top_name\_LFTP_CONFIG) ; ls /$Release_Section |grep : ;quit"];
	set Content [string map {" " " " } [string map { "    " " " "   " " " "  " " " } $Content]];
	set Count "10";
	foreach {ftp_droit ftp_unknown ftp_owner ftp_grp ftp_file_bytes ftp_file_month ftp_file_day ftp_file_hour ftp_file_name} ${Content} {
		set Count [expr $Count+10];
		utimer $Count "proc_SendMSG $chan $nick error \"Top-Leech->Get release: ${ftp_file_name}\"; proc_topcomplete $nick $uhost $hand $chan \"${top_name} ${ftp_file_name} ${Release_Section}\";		";
	}
}
