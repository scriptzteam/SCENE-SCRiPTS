#!/bin/bash
# -------------------------------------------------------------------------
# Jehsom's RMDundupe v1.0 - Removes a dir from glftpd dupelog upon deletion
# Copyright (C) 2001 jehsom@jehsom.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# -------------------------------------------------------------------------
#
# Place this script in /glftpd/bin and implemented it by placing a line
#  similar to the following in your glftpd.conf:
#       cscript RMD post /bin/RMDundupe.sh
# Your ftp-data/logs dir should be chmod 777, and ftp-data/logs/dupelog 666.
# Your DATAPATH should be as it appears in glftpd.conf, relative to rootpath.

DATAPATH="/ftp-data"

#######################
### Ignore the rest ###
#######################

# User is unable to modify the dupelog?
{ [ -w $DATAPATH/logs ] && [ -w $DATAPATH/logs/dupelog ]; } || exit 1

umask 0
set -- $1
set -- "$(basename "$2")"
grep -Fvi " $1" $DATAPATH/logs/dupelog > $DATAPATH/logs/dupelog.new
mv -f $DATAPATH/logs/dupelog.new $DATAPATH/logs/dupelog

exit 0;
