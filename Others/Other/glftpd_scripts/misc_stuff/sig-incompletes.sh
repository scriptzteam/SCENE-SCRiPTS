#!/bin/bash
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################
# this script will search for incomplete/nosfv/nonfo symlinks, and compile them
# into a nice list inside (default) /site/INCOMPLETE/<SECTION>/
# it will also NUKEWARN that the <RELEASE> is still incomplete, if the <RELEASE>
# is still incomplete after a certain time period, it will NUKE it!
#
# put the following line into crontab
# 0,5,10,15,20,25,30,35,40,45,50,55  * * * *      /glftpd/bin/sig-incompletes.sh >/dev/null 2>&1
###############################################################################

# glftpd path stuff
gl_root="/glftpd"
site_root="/site"
data_path="/glftpd/ftp-data"
# make sure this path exists! /site/<inc_dir>
inc_dir="/INCOMPLETE"
# what symlinks to search for?
inc_labels="
(incomplete)-
(no-sfv)-
(no-nfo)-
"
# full path to the nuker binary
nuker_bin="/glftpd/bin/nuker"
# nuke_warn must be in minutes, and only 15 30 60 is valid!
nuke_warn="30"
# nuke_limit must be in minutes, 3 hours * 60 = 180 minutes
nuke_limit="180"
# make sure this is a valid user on site with +AB flags (and =NUKER if needed)
nuke_user="NUKER"

###############################################################################
# don't edit below here, goto end of file to edit directory search strings!
###############################################################################

function delete_links () {
        echo "deleting current symlinks for "$1" please wait..."              
		rm -rf $1/*
}

function find_inc_links () {
        cd $gl_root$site_root
        echo "checking incomplete symlinks for "$1" please wait..."
		for cur_label in $inc_labels; do
			find "$1" -mindepth 1 -maxdepth 2 -type l -name "$cur_label*" | while read LINE
			do
				inc_sym_link=`echo $LINE`
				real_dir=`echo $inc_sym_link | sed 's/'$cur_label'//g;'`
				rescan_it "$real_dir"
				nuke_it "$real_dir" "$inc_sym_link"
				real_dir=${real_dir#$gl_root$site_root}
				inc_release=`basename $real_dir`
				inc_sym_dir=`basename $inc_sym_link`
				inc_section=`basename $1`
				if [ ! -d "$gl_root$site_root$inc_dir/$inc_section" ]; then
					mkdir -m777 -p "$gl_root$site_root$inc_dir/$inc_section"
				fi
				if [ ! -e "$gl_root$site_root$inc_dir/$inc_section/$inc_release" ]; then
					ln -s "../..$real_dir" "$gl_root$site_root$inc_dir/$inc_section/$inc_release"
					echo "found $cur_label release $real_dir"
				fi
			done
		done
}

function nuke_it () {
		if [ -d "$1" ]; then
			curr_time=`date --date "now" +"%Y-%m-%d %T"`
			date_time=`stat -c %y "$1" | awk -F. '{print $1}'`
			nuke_elapsed=`echo $"(( $(date --date="$curr_time" +%s) - $(date --date="$date_time" +%s) ))/60" | bc`
			nuke_time_left=$(( $nuke_limit - $nuke_elapsed ))
			nuke_path=${1#$gl_root$site_root}
			nuke_rel=`basename $nuke_path`
			if [ "$nuke_elapsed" -gt "$nuke_limit" ]; then
				$nuker_bin -N $nuke_user -n "$site_root$nuke_path" 3 auto.nuke_still.incomplete.after.$nuke_elapsed.minutes_limit.is.$nuke_limit.minutes.old
				rm -f "$2"
			fi
			if [ "$nuke_elapsed" -lt "$nuke_limit" -a "$nuke_elapsed" -gt "$(( $nuke_warn / 2 ))" ]; then
				nuke_warn_time=`date +%M`
				if [ "$nuke_warn" == "15" ]; then
					if [ "$nuke_warn_time" == "00" -o "$nuke_warn_time" == "15" -o "$nuke_warn_time" == "30" -o "$nuke_warn_time" == "45" ]; then
						echo `date "+%a %b %d %T %Y"` NUKEWARN: \"$nuke_rel\" \"$nuke_elapsed\" \"$nuke_time_left\" \"$nuke_limit\" >> $data_path/logs/glftpd.log
					fi
				fi

				if [ "$nuke_warn" == "30" ]; then
					if [ "$nuke_warn_time" == "00" -o "$nuke_warn_time" == "30" ]; then
						echo `date "+%a %b %d %T %Y"` NUKEWARN: \"$nuke_rel\" \"$nuke_elapsed\" \"$nuke_time_left\" \"$nuke_limit\" >> $data_path/logs/glftpd.log
					fi
				fi

				if [ "$nuke_warn" == "60" ]; then
					if [ "$nuke_warn_time" == "00" ]; then
						echo `date "+%a %b %d %T %Y"` NUKEWARN: \"$nuke_rel\" \"$nuke_elapsed\" \"$nuke_time_left\" \"$nuke_limit\" >> $data_path/logs/glftpd.log
					fi
				fi
			fi
		fi
}

function check_dead_links () {
	find "$1" -type l | (while read FN ; do test -e "$FN" || ls -ld "$FN"; done) | while read LINE
	do
		bad_sym_link=`echo $LINE | awk '{print $(NF-2)}'`
		rm "$bad_sym_link"
		echo "found bad symlink, deleted -> $bad_sym_link"
	done
}

function rescan_it () {
        if [ -d "$1" ]; then
                echo "rescanning $1"
                rescan_dir=${1#$gl_root}
                /glftpd/bin/rescan --chroot=$gl_root --dir=$rescan_dir --normal >/dev/null 2>&1
        fi
}

###############################################################################
# edit below here for paths to check!
###############################################################################

check_dead_links "/glftpd/site/MP3"
check_dead_links "/glftpd/site/FLAC"

delete_links "/glftpd/site/INCOMPLETE/MP3"
delete_links "/glftpd/site/INCOMPLETE/FLAC"

find_inc_links "/glftpd/site/MP3"
find_inc_links "/glftpd/site/FLAC"