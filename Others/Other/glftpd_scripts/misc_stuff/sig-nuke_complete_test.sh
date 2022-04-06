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
# script to scan nuked directories, check for \[*\] COMPLETE * directories and
# then rescan to make sure whether it is complete or incomplete. if the release
# is complete, the script will automatically unnuke. this script is used in
# conjunction with sig-incompletes.sh.
###############################################################################
# glftpd root directory
gl_dir="/glftpd"
# glftpd bin directory
gl_bin="/glftpd/bin"
# directories to search for $nuke_label
test_dirs="
/glftpd/site/MP3
/glftpd/site/FLAC
/glftpd/site/MVID
"
# rescan binary
rescan_bin="/glftpd/bin/rescan"
# nuker binary
nuker_bin="/glftpd/bin/nuker"
# nuke user
nuke_user="NUKER"
#nuke label for directories
nuke_label="(nuked)-"
#nuke reason for automatic incomplete nukes
nuke_reason="auto.nuke"
###############################################################################
# don't edit below here!
###############################################################################

for test_dir in $test_dirs; do
	echo "[+] checking $test_dir for $nuke_label* symlinks, filtering with nuke reason $nuke_reason."
	find "$test_dir" -type d -name "$nuke_label*" | while read LINE
	do
		nuke_dir=`echo $LINE`
		nuke_rel=`basename $nuke_dir`
		nuke_ori=`echo $nuke_rel | sed 's/'$nuke_label'//g;'`
		nuke_sec=`basename $test_dir`
		echo " "
		echo "[+] found $nuke_rel in $nuke_sec, checking release."
		complete_dir=`ls -A $nuke_dir | grep -Ei "\[*\] COMPLETE *"`
		nuke_reason_dir=`ls -A $nuke_dir | grep -Ei "*$nuke_reason*"`
		if [ ! -z "$complete_dir" ] ; then
			if [ ! -z "$nuke_reason_dir" ] ; then
				unnuke_dir=`dirname $nuke_dir`
				unnuke_dir=${unnuke_dir#$gl_dir}
				echo "[+] found complete dir for $nuke_rel with nuke reason $nuke_reason*, rescanning!";
				rescan_op=`$rescan_bin --normal --chroot="$gl_dir" --dir="$unnuke_dir/$nuke_rel"`
				rescan_pa=$(echo "$rescan_op" | grep "Passed" | awk -F: '{print $2}')
				rescan_fa=$(echo "$rescan_op" | grep "Failed" | awk -F: '{print $2}')
				rescan_mi=$(echo "$rescan_op" | grep "Missing" | awk -F: '{print $2}')
				rescan_to=$(echo "$rescan_op" | grep "Total" | awk -F: '{print $2}')
				if [ "$rescan_fa" -gt "0" ]; then
					echo "[-] release $nuke_ori has failed files, skipping!"
					exit 0
				fi
				if [ "$rescan_mi" -gt "0" ]; then
					echo "[-] release $nuke_ori has missing files, skipping!"
					exit 0
				fi
				if [ "$rescan_pa" = "$rescan_to" ]; then
				echo "[+] release $nuke_ori is complete, unnuking with reason auto.unnuke_release.was.rescanned.and.is.complete"
				$nuker_bin -N $nuke_user -u "$unnuke_dir/$nuke_ori" auto.unnuke_release.was.rescanned.and.is.complete >/dev/null 2>&1
				fi
			else
				echo "[-] complete dir found for $nuke_rel with a different nuke reason, skipping!";
			fi
		else
			echo "[-] complete dir missing for $nuke_rel, skipping!";
		fi
	done
done