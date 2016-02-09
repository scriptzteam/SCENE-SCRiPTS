package require mysqltcl
###################################################
#            PR3_ANNOUNCE_SCRIPT                  #
#             CODED_BY_SOMEONE                    #
################################################### 


#########################################################
#Enter you mysql details below ##########################
#########################################################

set mysql_(user) "XXXX"
set mysql_(password) "XXX"
set mysql_(host) "XXXX"
set mysql_(db) "predb"
set mysql_(pretable) "predb"
set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]


##########################################################
#Set channel info below for the Main announce & search ###
##########################################################

set annprechan "#pre"
set chann_(search) "#pre"
set chann_(nuke) "#nuke"
set anninfochan "#pre"
set prechan      "#pre"
##########################################################
#Set Binds and brackets below ############################ 
##########################################################

set bopen "\002\[\002"
set bclose "\002\]\002"
set bdiv "\002\/\002"


bind pub - !pre isy:pre
bind pub - !dupe isy:dupe
bind pub - !uptime pre:uptime


##########################################################
#Set the predb settings below ############################ 
##########################################################

set predb_(id) "id"
set predb_(rlsname) "rlsname"
set predb_(section) "section"
set predb_(unixtime) "unixtime"
set predb_(nukestatus) "nukestatus"
set predb_(nukereason) "nukereason"
set predb_(nukenet) "nukenet"
set predb_(files) "files"
set predb_(size) "size"
set predb_(genre) "genre"
set predb_(grp) "grp"


##########################################################
#Set the prefixes for announce & search ##################
##########################################################

set prefix_(nuke) "$bopen\0034NUKE\003$bclose"
set prefix_(modnuke) "$bopen\0034MODNUKE\003$bclose"
set prefix_(unnuke) "$bopen\0033UNNUKE\003$bclose"
set prefix_(undelpre) "$bopen\0033UNDELPRE\003$bclose"
set prefix_(delpre) "$bopen\0034DELPRE\003$bclose"
set prefix_(info) "$bopen\00310INFO\003$bclose"
set prefix_(genre) "$bopen\00307GENRE\003$bclose"
set prefix_(pretime) "\002\[\002\00306PRETiME\003\002\]\002"




bind bot - PR3ADD getprerls
bind bot - NUKE nukerls
bind bot - UNNUKE unnukerls
bind bot - MODNUKE modnukerls
bind bot - DELPRE delprerls
bind bot - UNDELPRE undelprerls
bind bot - PREINF0 getinforls
bind bot - GENRE getgenrerls



proc mysql:keepalive {} {
	global db_handle mysql_
	
	if {[catch {mysql::ping $db_handle} error] || ![mysql::ping $db_handle]} {
		set db_handle [mysqlconnect -host $mysql_(host) -user $mysql_(user) -password $mysql_(password) -db $mysql_(db)]
	}

	utimer 120 [list mysql:keepalive]
	
	return 0
}

mysql:keepalive



##########################################################
#Set the filter colour below #############################
##########################################################

proc isy:trimcolors { nostring } {

 regsub -all -- {[0-9][0-9],[0-9][0-9]}  $nostring ""   nostring
 regsub -all -- {[0-9][0-9],[0-9]}       $nostring ""   nostring
 regsub -all -- {[0-9][0-9]}             $nostring ""   nostring
 regsub -all -- {[0-9]}                  $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {}                        $nostring ""   nostring
 regsub -all -- {}                        $nostring ""   nostring
 regsub -all -- {}                       $nostring ""   nostring
 regsub -all -- {\002|\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\026|\037|\0036|\022} $nostring ""   nostring
 
 return [string trim $nostring]
 
}



##########################################################
#Set the format pre proc below ###########################
###############################################################################################################################################################

proc isy:formatpre {rls type timestamp files mb nuke reason nukenet genre} {
	global bopen bclose bdiv prefix_
	set predago	[getpred $timestamp]
	set section	[isy:sectioncolor $type]
	set genred	""
	set infod	""
	
	set dv "\002\0034/\003\002"
	set bo "\002\[\002"
	set bc "\002\]\002"
	
	
	if { $genre != "" } { set genred "$bo\00307$genre\003$bc" }
	if { $files != "" && $mb != "" } { set infod "$bo\00314$files\003$dv\00314Files\003$bc $bo\00314$mb\003$dv\00314MB\003$bc" }
	
	set nuked ""
	if { $nuke == "Nuked" } { set nuked "$bopen$prefix_(nuke) \0034$reason $nukenet$bclose\003" }
	if { $nuke == "ModNuked" } { set nuked "$bopen$prefix_(nuke) \0034$reason $nukenet$bclose\003" }
	if { $nuke == "UnNuked" } { set nuked "$bopen$prefix_(unnuke) \0033$reason $nukenet$bclose\003" }
	if { $nuke == "DelPre" } { set nuked "$bopen$prefix_(delpre) \0034$reason $nukenet$bclose\003" }
	if { $nuke == "UndelPre" } { set nuked "$bopen$prefix_(undelpre) \0033$reason $nukenet$bclose\003" }
	
	return [list $section $predago $infod $nuked $genred]
}




##########################################################
#Set the Dupe proc below #################################
###############################################################################################################################################################

proc isy:dupe {nick uhost hand chan arg} {
    global mysql_ predb_ prefix_ bopen bclose bdiv chann_ db_handle
        
        set sea1 [string map [list "*" "%" " " "%"] $arg];
        set sea2 [string map [list "%" "*"] $sea1];
		set count 0
		
        set query1 [mysqlsel $db_handle "SELECT $predb_(rlsname),$predb_(section),$predb_(unixtime),$predb_(files),$predb_(size),$predb_(nukestatus),$predb_(nukereason),$predb_(nukenet),$predb_(genre) FROM $mysql_(pretable) WHERE $predb_(rlsname) LIKE '%$sea1%' ORDER BY $predb_(unixtime) DESC LIMIT 10 " -flatlist];
        
		if {$query1 != ""} {
			
			putquick "PRIVMSG $chan :$bopen \00314Sending last 10 results to\003 $bclose\00312-\003$bopen \0037$nick\003 $bclose"
			
            foreach {rls type timestamp files mb nuke reason nukenet genre} $query1 {
				set count [expr $count + 1]
				
				foreach {section predago infod nuked genred} [isy:formatpre $rls $type $timestamp $files $mb $nuke $reason $nukenet $genre] {}
				
				putquick "PRIVMSG $nick :$bopen $count $bclose  $bopen$section$bclose $bopen\00314$rls\003$bclose $infod$genred \0033$predago\003 \0034$nuked\003"
			}
	
		} else {
			putquick "PRIVMSG $chan :Nothing found for $arg"			
		}
}

##########################################################
#Set the Pre proc below ##################################
###############################################################################################################################################################

proc isy:pre {nick uhost hand chan arg} {
    global mysql_ predb_ prefix_ bopen bclose bdiv chann_ db_handle
        
        set sea1 [string map [list "*" "%" " " "%"] $arg];
        set sea2 [string map [list "%" "*"] $sea1];
		
        set query1 [mysqlsel $db_handle "SELECT $predb_(rlsname),$predb_(section),$predb_(unixtime),$predb_(files),$predb_(size),$predb_(nukestatus),$predb_(nukereason),$predb_(nukenet),$predb_(genre) FROM $mysql_(pretable) WHERE $predb_(rlsname) LIKE '%$sea1%' ORDER BY $predb_(unixtime) DESC LIMIT 1 " -flatlist];
        
		if {$query1 != ""} {
			
            foreach {rls type timestamp files mb nuke reason nukenet genre} $query1 {
				foreach {section predago infod nuked genred} [isy:formatpre $rls $type $timestamp $files $mb $nuke $reason $nukenet $genre] {}
				
				putquick "PRIVMSG $chan :$bopen$section$bclose \00314$rls\003 $infod $genred $predago $nuked "
			}
	
		} else {
			putquick "PRIVMSG $chan :Nothing found for $arg"			
		}
}

##########################################################
#Set Group                   #############################
##########################################################
proc isy:group {nick uhost hand chan arg} {
    global mysql_ predb_ db_handle bopen bclose
		
		putquick "PRIVMSG $chan :\002Group \00309$arg\003 Info:\002"
		
		::mysql::sel $db_handle "SELECT COUNT(id) AS numreleases FROM $mysql_(pretable) WHERE $predb_(grp) = '$arg'"
		::mysql::map $db_handle {numreleases} {append grpinfo "$bopen\002\00310Releases in DB\003:\002 $numreleases$bclose "}
        
		if {$numreleases != "" && $numreleases != "0"} {
			
			::mysql::sel $db_handle "SELECT COUNT(id) AS numnuked FROM $mysql_(pretable) WHERE $predb_(grp) = '$arg' AND $predb_(nukestatus) IN ('Nuked','ModNuked')"
			::mysql::map $db_handle {numnuked} {
				
				set pernuked [expr (($numnuked * 100) / $numreleases)]
				append grpinfo "$bopen\002\00304Nuked in DB\003:\002 $numnuked$bclose ($pernuked %)"
			
			}
			
			::mysql::sel $db_handle "SELECT COUNT(id) AS numunnuked FROM $mysql_(pretable) WHERE $predb_(grp) = '$arg' AND $predb_(nukestatus) = 'UnNuked'"
			::mysql::map $db_handle {numunnuked} {
				
				set perunnuked [expr (($numunnuked * 100) / $numreleases)]
				append grpinfo "$bopen\002\00309UnNuked in DB\003:\002 $numunnuked$bclose ($perunnuked %)"
			
			}
			
			::mysql::sel $db_handle "SELECT COUNT(id) AS numdelpre FROM $mysql_(pretable) WHERE $predb_(grp) = '$arg' AND $predb_(nukestatus) = 'DelPre'"
			::mysql::map $db_handle {numdelpre} {
				
				set perdelpre [expr (($numdelpre * 100) / $numreleases)]
				append grpinfo "$bopen\002\00304DelPred in DB\003:\002 $numdelpre$bclose ($perdelpre %)"
			
			}
			
			::mysql::sel $db_handle "SELECT COUNT(id) AS numundelpre FROM $mysql_(pretable) WHERE $predb_(grp) = '$arg' AND $predb_(nukestatus) = 'UnDelPre'"
			::mysql::map $db_handle {numundelpre} {
				
				set perundelpre [expr (($numundelpre * 100) / $numreleases)]
				append grpinfo "$bopen\002\00309UnDelPred in DB\003:\002 $numundelpre$bclose ($perundelpre %)"
			
			}
			
			::mysql::sel $db_handle "SELECT COUNT(id) AS numint FROM $mysql_(pretable) WHERE ($predb_(rlsname) LIKE '%iNT%' OR $predb_(rlsname) LIKE '%iNTERNAL%') AND $predb_(grp) = '$arg'"
			::mysql::map $db_handle {numint} {
				
				set perint [expr (($numint * 100) / $numreleases)]
				append grpinfo "$bopen\002\00307INTERNALS in DB\003:\002 $numint$bclose ($perint %)"
			
			}
			
			::mysql::sel $db_handle "SELECT COUNT(id) AS numrerip FROM $mysql_(pretable) WHERE $predb_(rlsname) LIKE '%RERIP%' AND $predb_(grp) = '$arg'"
			::mysql::map $db_handle {numrerip} {
				
				set perrerip [expr (($numrerip * 100) / $numreleases)]
				append grpinfo "$bopen\002\00314RERIPS in DB\003:\002 $numrerip$bclose ($perrerip %)"
			
			}
			
			putquick "PRIVMSG $chan :$grpinfo"
			
			::mysql::sel $db_handle "SELECT $predb_(rlsname),$predb_(section),$predb_(unixtime),$predb_(files),$predb_(size),$predb_(nukestatus),$predb_(nukereason),$predb_(nukenet),$predb_(genre) FROM $mysql_(pretable) WHERE $predb_(grp) = '$arg' ORDER BY $predb_(unixtime) ASC LIMIT 1"
			::mysql::map $db_handle {rlsname section unixtime files size nukestatus nukereason nukenet genre} {
				
				foreach {sect predago infod nuked genred} [isy:formatpre $rlsname $section $unixtime $files $size $nukestatus $nukereason $nukenet $genre] {}
				
				putquick "PRIVMSG $chan :\002\00308First Pre in DB\003:\002 $bopen$sect$bclose \00314$rlsname\003 $infod $genred $predago $nuked "
			
			}
			
			::mysql::sel $db_handle "SELECT $predb_(rlsname),$predb_(section),$predb_(unixtime),$predb_(files),$predb_(size),$predb_(nukestatus),$predb_(nukereason),$predb_(nukenet),$predb_(genre) FROM $mysql_(pretable) WHERE $predb_(grp) = '$arg' ORDER BY $predb_(unixtime) DESC LIMIT 1"
			::mysql::map $db_handle {rlsname section unixtime files size nukestatus nukereason nukenet genre} {
			
				foreach {sect predago infod nuked genred} [isy:formatpre $rlsname $section $unixtime $files $size $nukestatus $nukereason $nukenet $genre] {}
				
				putquick "PRIVMSG $chan :\002\00305Last Pre in DB\003:\002 $bopen$sect$bclose \00314$rlsname\003 $infod $genred $predago $nuked "
			
			}
			
		}  else {
		
			putquick "PRIVMSG $chan :Group Name $arg not found."
			
		}	

}

proc isy:dbinfo {nick uhost hand chan arg} {
    global mysql_ predb_ db_handle
		
        ::mysql::sel $db_handle "SELECT COUNT(id) AS numreleases FROM $mysql_(pretable)"
		::mysql::map $db_handle {numreleases} {append dbinfo "Releases in DB: $numreleases "}
		
		::mysql::sel $db_handle "SELECT COUNT(DISTINCT grp) AS numgrps FROM $mysql_(pretable)"
		::mysql::map $db_handle {numgrps} {append dbinfo "Groups in DB: $numgrps "}
		
		::mysql::sel $db_handle "SELECT COUNT(id) AS numnuked FROM $mysql_(pretable) WHERE $predb_(nukestatus) IN ('Nuked','ModNuked')"
		::mysql::map $db_handle {numnuked} {append dbinfo "Nuked in DB: $numnuked "}
		
		::mysql::sel $db_handle "SELECT COUNT(id) AS numunnuked FROM $mysql_(pretable) WHERE $predb_(nukestatus) = 'UnNuked'"
		::mysql::map $db_handle {numunnuked} {append dbinfo "UnNuked in DB: $numunnuked "}
		
		::mysql::sel $db_handle "SELECT COUNT(id) AS numdelpre FROM $mysql_(pretable) WHERE $predb_(nukestatus) = 'DelPre'"
		::mysql::map $db_handle {numdelpre} {append dbinfo "DelPred in DB: $numdelpre "}
		
		::mysql::sel $db_handle "SELECT COUNT(id) AS numundelpre FROM $mysql_(pretable) WHERE $predb_(nukestatus) = 'UnDelPre'"
		::mysql::map $db_handle {numundelpre} {append dbinfo "UnDelPred in DB: $numundelpre "}

		putquick "PRIVMSG $chan :$dbinfo"			

}

proc isy:timenow { nick uhost hand chan arg } {
		
		set unixtime [clock seconds]
		set humandate [clock format $unixtime -format %D]
		set humantime [clock format $unixtime -format %H:%M:%S]
		
		append var "\[ TiME N0W \] "
		append var "\[ UNiX TiME -> $unixtime \] "
		append var "\[ HUMAN TiME -> $humandate $humantime \]"
		
		putquick "PRIVMSG $chan :$var"
	
}


##########################################################
#Set the getPred rls proc below ##########################
###############################################################################################################################################################

proc getpred { timeis } {
	global bopen bclose 
	
	set timestamp [lindex $timeis 0]
	set added [ctime $timestamp]
    set time1 [clock seconds]
    incr time1 -$timestamp
	set ago [string map {" years" "y" " weeks" "w" " days" "d" " hours" "h" " minutes" "m" " seconds" "s" " year" "y" " week" "w" " day" "d" " hour" "h" " minute" "m" " second" "s"} [duration $time1]]
	set predago " $bopen\00311Pre\'d $ago ago\003$bclose"
	
	return $predago
}


##########################################################
#Set the getPredrls rls proc below #######################
###############################################################################################################################################################

proc getprerls {bot com args} {
	global prechan  bopen bclose
	
	set rlsname [lindex [lindex $args 0] 0]
	set sec [lindex [lindex $args 0] 1]
	set section [isy:sectioncolor $sec]
	
	putquick "PRIVMSG $prechan :$bopen\00308PRE\003$bclose $bopen$section$bclose $bopen$rlsname$bclose"
	
}


##########################################################
#Set the nukerls rls proc below ##########################
###############################################################################################################################################################


proc nukerls {bot com args} {
	global annprechan prefix_ bopen bclose bdiv chann_ 
	
	set rlsname [lindex [lindex $args 0] 0]
	set rls [lindex [lindex $args 0] 0]
	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

	putquick "PRIVMSG $annprechan :$prefix_(nuke) $bopen$rlsname$bclose $bopen\00304$reason\003\00314$bdiv\003\00304$nukenet\003$bclose"
	putquick "PRIVMSG $chann_(nuke) :!nuke $rlsname 1 $reason"
	
	
}


##########################################################
#Set the unnukerls rls proc below ########################
###############################################################################################################################################################


proc unnukerls {bot com args} {
	global annprechan prefix_ bopen bclose bdiv chann_ 
	
	set rlsname [lindex [lindex $args 0] 0]
	set rls [lindex [lindex $args 0] 0]
	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

	putquick "PRIVMSG $annprechan :$prefix_(unnuke) $bopen$rlsname$bclose $bopen\00303$reason\003\00314$bdiv\003\00303$nukenet\003$bclose"
	putquick "PRIVMSG $chann_(nuke) :!unnuke $rlsname $reason"
	
}


##########################################################
#Set the modnukerls rls proc below #######################
###############################################################################################################################################################


proc modnukerls {bot com args} {
	global annprechan prefix_ bopen bclose bdiv chann_ 
	
	set rlsname [lindex [lindex $args 0] 0]
	set rls [lindex [lindex $args 0] 0]
	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

	putquick "PRIVMSG $annprechan :$prefix_(modnuke) $bopen$rlsname$bclose $bopen\00304$reason\003\00314$bdiv\003\00304$nukenet\003$bclose"
	putquick "PRIVMSG $chann_(nuke) :!nuke $rlsname 1 $reason"
	
}


##########################################################
#Set the delpre rls proc below ###########################
###############################################################################################################################################################


proc delprerls {bot com args} {
	global anninfochan prefix_ bopen bclose bdiv chann_
	
	set rlsname [lindex [lindex $args 0] 0]
	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

	putquick "PRIVMSG $anninfochan :$prefix_(delpre) $bopen$rlsname$bclose $bopen\00304$reason\003\00314$bdiv\003\00304$nukenet\003$bclose"
	
}


##########################################################
#Set the undelpre rls proc below #########################
###############################################################################################################################################################


proc undelprerls {bot com args} {
	global anninfochan prefix_ bopen bclose bdiv chann_
	
	set rlsname [lindex [lindex $args 0] 0]
	set reason [lindex [lindex $args 0] 1]
	set nukenet [lindex [lindex $args 0] 2]

	putquick "PRIVMSG $anninfochan :$prefix_(undelpre) $bopen$rlsname$bclose $bopen\00303$reason\003\00314$bdiv\003\00303$nukenet\003$bclose"
	
}

##########################################################
#Set the info rls proc below #############################
###############################################################################################################################################################


proc getinforls {bot com args} {
	global anninfochan prefix_ bopen bclose bdiv 
	
	set rlsname [lindex [lindex $args 0] 0]
	set fles [lindex [lindex $args 0] 1]
	set size [lindex [lindex $args 0] 2]
	
	putquick "PRIVMSG $anninfochan :$prefix_(info) $bopen$rlsname$bclose $bopen\00307$size MB\00314$bdiv\003\00307$fles Files\003$bclose"
	
}


##########################################################
#Set the genre rls proc below ############################
###############################################################################################################################################################


proc getgenrerls {bot com args} {
	global anninfochan prefix_ bopen bclose 
	
	set rlsname [lindex [lindex $args 0] 0]
	set gnre [lindex [lindex $args 0] 1]
		
	putquick "PRIVMSG $anninfochan :$prefix_(genre) $bopen$rlsname$bclose $bopen\00307$gnre\003$bclose"
	
}

##########################################################
#Set the uptime proc below ###############################
###############################################################################################################################################################


proc pre:uptime {nick host hand chan arg} {
	set x 			[string map {, "" : " "} [join [lrange [exec -- uptime] 2 4]]]
	set	sysuptime	0
	incr sysuptime	[expr {[lindex $x 3] * 60}]
	incr sysuptime	[expr {[lindex $x 2] * 60 * 60}]
	switch [lindex $x 1] {
		days	{	incr sysuptime [expr {[lindex $x 0] * 60 * 60 * 24}]	}
	}
	set	sysuptime	[duration $sysuptime]
	putquick "PRIVMSG $chan \00311PR3 has been online for [duration [expr {[unixtime] - $::uptime}]]\003"
}


##########################################################
#Set the colours for the pre announce and search #########
###############################################################################################################################################################

proc isy:sectioncolor { secti } {

	set secc [isy:sectioncolornotempty $secti]
	
	if { $secc == "" } {
	
		set secc "\002$secti\002"
		
	}
	
	return $secc
	
}


proc isy:sectioncolornotempty { arg } {
	
	set sec [lindex $arg 0]
	
	array set sectionColors {
	        "0DAY"          "\00311\002\0020DAY\003"
	        "EBOOK"         "\0032EBOOK\003"
			"APPS"          "\00311APPS\003"
	        "MP3"           "\0036MP3\003"
			"MVID"          "\0039MVID\003"
			"FLAC"          "\0038FLAC\003"
			"DOX"           "\0037DOX\003"
			"MDVDR"         "\00310MDVDR\003"
			"MBLURAY"       "\00312MBLURAY\003"
			"XXX-DVDR"      "\00313XXX-DVDR\003"
	        "XXX-X264"      "\00313XXX-X264\003"
			"XXX-IMG"       "\00313XXX-IMG\003"
			"XXX"           "\00313XXX\003"
			"XXX-WEB"       "\00313XXX-0DAY\003"
			"NDS"           "\00311NDS\003"
			"PSP"           "\00311PSP\003"
			"PS2"           "\00311PSP\003" 
			"PS3"           "\00311PS3\003"
			"TV-DVDRIP"     "\0037TV-DVDRIP\003"
			"TV-DVDR"       "\0037TV-DVDR\003"
			"TV-HR"         "\0037TV-HR\003"
			"TV-XVID"       "\0037TV-XVID\003"
			"TV-WMV"        "\00312TV-WMV\003"
			"TV-BLURAY"     "\00312TV-BLURAY\003"
			"TV-X264"       "\0037TV-X264\003"
			"WMV"           "\00310WMV\003"
			"DVDR"          "\0035DVDR\003"
			"BLURAY"        "\00312BLURAY\003"
			"X264"          "\00312X264\003"
			"GAMES"         "\00311GAMES\003"
			"XVID"          "\00312XVID\003" 
			"WII"           "\00311WII\003"
			"XBOX360"       "\0039XBOX360\003" 			
            "PRE"           "\00310PRE\003"		
            "SCENENOTICE"   "\00310SCENENOTICE\003"
            "SUBPACK"       "\0037SUBPACK\003"			
			
	}
	
    foreach {section replace} [array get sectionColors] {
        if {[string equal -nocase $section $sec]} {
			return $replace
		} 
    }
}


putlog "Pre.announce.coded.By.someone Successfully loaded"
