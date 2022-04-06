#################################################################################
# dZSbot/ngBot - Sitecmds Plug-in v0.2.4                                        #
#################################################################################
#
# Description:
# - You need to have NickDb.tcl loaded.
# - You need to install lftp
# - Thanks to neoxed AGAIN(!!) for helping with the pzs-ng part
#
# Installation:
# 1. add this to your glftpd.conf:
#    -emulate	-<emulate user>
#    if you leave the defaults of this script:
#    -emulate	-emulate
#    and add the user by:
#    site adduser emulate emulation *@127.0.0.1
#
# 2. Edit the configuration options below.
#
# 3. Add the following to your eggdrop.conf:
#    source pzs-ng/plugins/Sitecmds.tcl
#
# 4. Add the following line to your dZSbot.conf:
#    set variables(SITECMDS)   	"%msg"
#    set disable(SITECMDS)	0
#
#    Add SITECMDS at the end of your msgtypes(DEFAULT) line
#
#    Optionally:
#    set redirect(SITECMDS)     "#staffchannel"
#
# 5. Add the following line to your theme file:
#    announce.SITECMDS = "[%b{sitecmd}] %msg"
#
# 6. Rehash or restart your eggdrop for the changes to take effect.
#
#################################################################################

namespace eval ::ngBot::plugin::Sitecmds {
    variable ns [namespace current]

    ## Config Settings ###############################
    ##
    ## Choose one of two settings, the first when using ngBot, the second when using dZSbot
    variable np [namespace qualifiers [namespace parent]]
    #variable np ""
    ##
    ## Path to cpt-Sitecmds.sh (place it in your glftpd/bin directory please!)
#    variable cptSitecmds "/jail/glftpd/bin/cpt-Sitecmds.sh"
    variable lftp "/usr/bin/lftp"
    ##
    ## Username and password for the user that should execute the commands
    variable username "emulate"
    variable password "1eMuL!4T3"
    ##
    ## And where should we connect to?
    variable ftphost "127.0.0.1"
    variable port "39500"
    ##
    ## Change username if the user is privileged to execute those commands??
    ## For now, i'd certainly consider it desired behaviour :)
    variable emulate True
    ##
    ##
    ## Who can use the 'raw' !site command? It strongly recommended that you
    ## only allow very trusted folks to do that.
    variable permsraw "1 =siteops"
    ##
    ## Maximum number of lines... don't set this too high, or your channel will
    ## get flooded ;p
    variable maxlines 5
    ##
    ##################################################

    namespace import ${np}::plugin::NickDb::*
    #bind evnt -|- prerehash ${ns}::deinit

    interp alias {} IsTrue {} string is true -strict
    interp alias {} IsFalse {} string is false -strict


    if {[string equal "" $np]} {
        bind evnt -|- prerehash ${ns}::deinit
    }

    ####
    #  init
    #
    # Called on initialization; registers the event handler. Yeah, nothing fancy.
    #
    proc init {} {
	variable ns
        ## Bind event callbacks.
        bind pub -|- !site ${ns}::Cmd
        putlog "\[ngBot\] Sitecmds :: Loaded successfully."
        return
    }

    ####
    # Getinfo
    #
    # Get $group and $flags, needed for rightscheck
    #
    proc GetInfo {ftpUser groupVar flagsVar} {
        variable np
        global ${np}::location
        upvar $groupVar group $flagsVar flags
        set file "$location(USERS)/$ftpUser"
        # Linux will give an error if you open a directory and try to read from it.
        if {![file isfile $file]} {
            putlog "\[ngBot\] SiteCmds Error :: Invalid user file for \"$ftpUser\" ($file)."
            return 0
        }
        set group ""; set flags ""

        if {![catch {set handle [open $file r]} error]} {
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

    ####
    # deinit
    #
    # Called on rehash; unregisters the event handler.
    #
    proc deinit {} {
    variable ns
    ## Remove event callbacks.
    #catch {unbind evnt -|- prerehash ${ns}::DeInit}
    catch {unbind pub -|- !site ${ns}::Cmd}
    namespace delete $ns
    return
    }

    proc Cmd {nick host handle channel text} {
        variable np
        variable lftp
        variable username
        variable password
        variable ftphost
        variable port
        variable emulate
        variable permsraw
        variable maxlines
        set emulUser [GetFtpUser $nick]
        if {[string equal "" $nick]} {return}

        #regsub -all "$text"
        if {[regexp {\\n|\||\;} $text]} {
            set line "%b{ALERT:} $emulUser tried to execute these commands: \nsite $text"
            ${np}::sndall SITECMDS DEFAULT [${np}::ng_format "SITECMDS" "DEFAULT" \"$line\"]
            return
        }

        if {[GetInfo $emulUser group flags]} {
            if {[${np}::rightscheck $permsraw $ $group $flags]} {
	        set i 1
            	    foreach line [split [exec $lftp -u $username,$password $ftphost:$port -e "site emulate $emulUser\nsite $text"] "\n"] {
	    	        if { $i < $maxlines } {
    	    		    if { $line != "200 Command Successful."} {
			        ${np}::sndall SITECMDS DEFAULT [${np}::ng_format "SITECMDS" "DEFAULT" \"$line\"]
			    }
		        } else {
			    set line "Maximum number of lines($maxlines) has been reached."
			    ${np}::sndall SITECMDS DEFAULT [${np}::ng_format "SITECMDS" "DEFAULT" \"$line\"]
			    break
		        }
		        incr i
        	    }
            } else {
                set line "Sorry, you're not allowed to execute that command."
	        puthelp "PRIVMSG $channel :$line"
            }
        } else {
            set line "Sorry, you don't exist. Try inviting yourself again."
            puthelp "PRIVMSG $channel :$line"
        }
    }
}

if {[string equal "" $::ngBot::plugin::Sitecmds::np]} {
        ::ngBot::plugin::Sitecmds::init
}
