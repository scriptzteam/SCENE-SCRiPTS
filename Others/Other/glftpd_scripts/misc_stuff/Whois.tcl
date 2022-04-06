#################################################################################
# dZSbot/ngBot - Whois (quick example script for _nmz__)                        #
#################################################################################
#
# Description:
# - You need to have NickDb.tcl loaded.
# - Thanks to _nmz__ for the idea. !whois is actually a nice idea (and very extendable)
# - Original by Compieter, modified by E-Liquid
#
# Installation:
# 1. Add the following to your eggdrop.conf:
#    source pzs-ng/plugins/Whois.tcl
#
# 2. Add the following lines to your dZSbot.conf:
#    set variables(WHOIS)   "%msg"
#    set redirect(WHOIS)    $staffchan
#    set disable(WHOIS)     0
#
#    and add "WHOIS" at the end of your msgtypes(DEFAULT) line.
#
# 4. Add the following line to your theme file:
#    announce.WHOIS = "%b{[WHOIS]} %msg"
#
# 5. Rehash or restart your eggdrop for the changes to take effect.
#
#################################################################################

namespace eval ::ngBot::plugin::Whois {
    variable ns [namespace current]

    ## Config Settings ###############################
    ##
    ## Choose one of two settings, the first when using ngBot, the second when using dZSbot
    variable np [namespace qualifiers [namespace parent]]
    #variable np ""
    ##
    ## Permissions! who can use whois?
    ## Leave the default to allow siteops, nukers and users with flag +J to request
    variable permswhois "1 A J =siteops"
    ##################################################

    namespace import ${np}::plugin::NickDb::*
    #bind evnt -|- prerehash ${ns}::deinit

    interp alias {} IsTrue {} string is true -strict
    interp alias {} IsFalse {} string is false -strict

    if {[string equal "" $np]} {
            bind evnt -|- prerehash ${ns}::deinit
    }

    ####
    # init
    #
    # Called on initialization; registers the event handler. Yeah, nothing fancy.
    #
    if {[string equal "" $np]} {
        bind evnt -|- prerehash ${ns}::deinit
    }

    proc init {} {
        variable ns
        ## Bind event callbacks.
        bind pub -|- !whoisnick ${ns}::Nick
        bind pub -|- !whoisuser ${ns}::User
        putlog "\[ngBot\] Whois :: Loaded successfully."
        return
    }

    ####
    # deinit
    #
    # Called on rehash; unregisters the event handler.
    #
    proc deinit {} {
        variable ns
        ## Remove event callbacks.
        #catch {unbind evnt -|- prerehash ${ns}::deinit}
        catch {unbind pub -|- !whoisnick ${ns}::Nick}
        catch {unbind pub -|- !whoisuser ${ns}::User}
    
        namespace delete ${ns}::
        return
    }

    ####
    # GetInfo
    #
    # gets $group and $flags from the userfile
    #
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
                putlog "dZSbot error: Unable to open user file for \"$ftpUser\" ($error)."
                return 0
            }
        }

    ####
    # Nick
    #
    # Gives you the ftp username of $text (irc username)
    #
    proc Nick {nick host handle channel text} {
        variable np
        variable permswhois
    #    global redirect
    #    set redirect(WHOIS) "$channel"    
        set ftpUser [GetFtpUser $nick]
 
        if {![string equal "" $text]} {
            if {![string equal "" $nick]} {
                if {[GetInfo $ftpUser group flags]} {
                    if {[${np}::rightscheck $permswhois $ftpUser $group $flags]} {
                        set realUser [GetFtpUser $text]
    	            if {![string equal "" $realUser]} { 
                            set line "$text is user $realUser." 
                        } else { set line "Could not find $text in the database." }
                    } else { set line "Sorry, you are not allowed to use whois." }
                } else { set line "Sorry, something went wrong." }
            } else { set line "Sorry, you don't exist. Try inviting yourself again." } 
        } else { set line "Usage: !whoisnick <irc nickname> (gives ftp username)." }

        ${np}::sndall WHOIS DEFAULT [${np}::ng_format "WHOIS" "DEFAULT" \"$line\"]
    }

    ####
    # User
    #
    # Gives you the irc username of $text (ftp username)
    #
    proc User {nick host handle channel text} {
    variable np
    variable permswhois
    #    global redirect
    #    set redirect(WHOIS) "$channel"
        set ftpUser [GetFtpUser $nick]
        if {![string equal "" $text]} {
            if {![string equal "" $nick]} {
                if {[GetInfo $ftpUser group flags]} {
                    if {[${np}::rightscheck $permswhois $ftpUser $group $flags]} {
                        set realUser [GetIrcUser $text]
	                if {![string equal "" $realUser]} {
                            set line "User $text has $realUser as nickname."
                        } else { set line "Could not find $text in the database." }
                    } else { set line "Sorry, you are not allowed to use whois." }
                } else { set line "Sorry, something went wrong." }
            } else { set line "Sorry, you don't exist. Try inviting yourself again." } 
        } else { set line "Usage: !whoisuser <ftp username> (gives irc username)." }
        ${np}::sndall WHOIS DEFAULT [${np}::ng_format "WHOIS" "DEFAULT" \"$line\"]
    }
}

if {[string equal "" $::ngBot::plugin::Whois::np]} {
        ::ngBot::plugin::Whois::init
}
