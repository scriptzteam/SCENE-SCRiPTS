# The MIT License (MIT)
#
# PreBW v0.1 Copyright (c) 2014 Biohazard
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

namespace eval ::ngBot::plugin::prebw {
    variable binary "$::ngBot::glroot/bin/prebw"
    variable events [list "PRE"]

    variable ns [namespace current]
    variable np [namespace qualifiers [namespace parent]]

    variable scriptname ${ns}::log_event

    proc init {} {
        variable ns
        variable np
        variable events
        variable scriptname

        variable ${np}::precommand

        foreach event $events {
            lappend precommand($event) $scriptname
        }
    }

    proc deinit {} {
        variable ns
        variable np
        variable events
        variable scriptname

        variable ${np}::precommand

        foreach event $events {
            if {[info exists precommand($event)] && [set pos [lsearch -exact $precommand($event) $scriptname]] !=  -1} {
                set precommand($event) [lreplace $precommand($event) $pos $pos]
            }

            namespace delete $ns
        }
    }

    proc log_event { event section logdata } {
        variable binary
        variable events
        if {[lsearch -nocase $events $event] != -1} {
            exec $binary [lindex $logdata 0] &
        }
        return 1
    }
}