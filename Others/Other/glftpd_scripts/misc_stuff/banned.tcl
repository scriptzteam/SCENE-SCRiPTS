# The MIT License (MIT)
#
# Copyright (c) 2014 Biohazard
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

namespace eval ::banned {
    variable install_path   "./scripts/banned"
    variable prefix         "!"
    variable channels       [list "#testing321" ]
    variable version        "0.1"

    bind evnt -|- prerehash [namespace current]::deinit
}

proc ::banned::init { args } {
    variable prefix
    variable version
    bind pub -|- ${prefix}ban    [namespace current]::ban
    bind pub -|- ${prefix}unban  [namespace current]::unban
    bind pub -|- ${prefix}banned [namespace current]::banned
    putlog "banned v${version} script loaded!"
}

proc ::banned::deinit { args } {
    variable version
    catch { bind pub -|- ${prefix}ban    [namespace current]::ban    }
    catch { bind pub -|- ${prefix}unban  [namespace current]::unban  }
    catch { bind pub -|- ${prefix}banned [namespace current]::banned }
    putlog "banned v${version} script unloaded!"
}

proc ::banned::chan_is_allowed { chan } {
    variable channels
    return [expr [lsearch -nocase $channels $chan] != -1]
}

proc ::banned::reply { chan message } {
    putquick "PRIVMSG $chan :$message"
}

proc ::banned::reply_usage { chan trigger usage } {
    variable prefix
    reply $chan "${prefix}$trigger $usage"
}

proc ::banned::load_ips { } {
    variable install_path
    set path "$install_path/ips.dat"
    if {![file exists $path]} { return [list] }
    set f [open $path r]
    set data [read $f]
    catch { close $f }
    return [split $data "\n"]
}

proc ::banned::save_ips { ips } {
    variable install_path
    set path "$install_path/ips.dat"
    set f [open $path w]
    puts -nonewline $f [join $ips "\n"]
    catch { close $f }
}

proc ::banned::iptables_update { action ip } {
    variable install_path
    if {[catch { exec $install_path/iptables.sh $action $ip } err]} {
        putlog $err
        return 0
    }
    return 1
}

proc ::banned::is_valid_ip { ip } {
    if {![regexp {^(\d+)\.(\d+)\.(\d+)\.(\d+)$} $ip match a b c d]} { return 0 }
    return [expr $a <= 255 && $b <= 255 && $c <= 255 && $d <= 255]
}

proc ::banned::ban { nick uhost handle chan arg } {
    if {![chan_is_allowed $chan]} { return }

    if {[llength $arg] == 0} {
        reply_usage $chan "ban" "<ip> \[<ip>..\]"
        return
    }

    set updated 0
    set ips [load_ips]

    foreach ip $arg {
        if {![is_valid_ip $ip]} {
            reply $chan "Skipping invalid IP: $ip"
            continue
        }

        if {[lsearch $ips $ip] != -1} {
            reply $chan "Skipping already banned IP: $ip"
            continue
        }

        if {![iptables_update "A" $ip]} {
            reply $chan "Error while updating iptables: $ip"
            continue
        }

        set ips [lappend ips $ip]
        set updated 1
    }

    if {$updated} {
        save_ips $ips
        reply $chan "Banned IP list updated."
    }
}

proc ::banned::unban { nick uhost handle chan arg } {
    if {![chan_is_allowed $chan]} { return }

    if {[llength $arg] == 0} {
        reply_usage $chan "unban" "<ip> \[<ip>..\]"
        return
    }

    set updated 0
    set ips [load_ips]

    foreach ip $arg {
        set index [lsearch $ips $ip]
        if {$index == -1} {
            reply $chan "Skipping not banned IP: $ip"
            continue
        }

        if {![iptables_update "D" $ip]} {
            reply $chan "Error while updating iptables: $ip"
            continue
        }

        set ips [lreplace $ips $index $index]
        set updated 1
    }

    if {$updated} {
        save_ips $ips
        reply $chan "Banned IP list updated."
    }
}

proc ::banned::banned { nick uhost handle chan arg } {
    variable ip_file
    if {![chan_is_allowed $chan]} { return }

    if {[llength $arg] != 0} {
        reply_usage "banned" ""
        return
    }

    set ips [load_ips]
    if {[llength $ips] == 0} {
        reply $chan "No IPs banned."
        return
    }

    reply $chan "Banned IP listing:"
    set count 0
    set line ""
    foreach ip $ips {
        incr count
        set line [format "%-15.15s %s" $ip $line]
        if {[expr $count % 4] == 0} {
            reply $chan $line
            set line ""
            set count 0
        }
    }

    if {$line != ""} {
        reply $chan $line
    }

    reply $chan ""
}

::banned::init