#!/bin/bash
###############################################################################
#                                                                             #
#            .    _ ______ _                     _ ___________ _.             #
#            .__ _)                             _)            __.             #
#            |__\\                              \            /__|             #
#_ __  _ ___ .___ \ _______ _  _ ____. _  _____ _.___ .___ _ ___. ___ _ ____ _#
#       _/  \|   \_/  __   \_   _/   |  __\___/__/   \|   \_/   |/  \_        #
# _ __ _\_   \    \_  |/  __/_ _\_   |__\__     \_    \    \_  _/   _/_ __ _  #
# \\\ \\__  _/   __/  /____\ \\\__   |  __/    __/   \ \  __/  _    __// ///  #
#  ¯ ¯¯ /   \|    \_     \_ ____ /   :   \_     \_    \    \_   \    \ ¯¯ ¯   #
#       \    ._____/______//____\\________/______/____|\____/___|\___/        #
#¯ ¯¯¯¯  \___|©d   Y    .                 Y      Y    .     Y   .     ¯¯¯¯¯¯ ¯#
#         ___·     .     \                .      .     \_   .                 #
#         \__|          (¯                               )                    #
#            . ¯ ¯¯¯¯¯¯ ¯                                ¯ ¯¯¯¯¯¯¯¯ ¯         #
#                       UP-link v1.9 by dMG/dS!^UP!^t!s                       #
#                                                                             #
#             Send bugreports/feature requests to dmg@spetsnaz.su             #
#                                                                             #
#                         http://www.trueschool.org                           #
#                         http://www.asciiarena.com                           #
#                         http://www.uprough.net                              #
#                                                                             #
#     Thanks to dalek, mb, krk and 2 unnamed guys for your assistance. :)     #
#                                                                             #
#-----------------------------------------------------------------------------#
#                                WHAT IS IT?                                  #
#-----------------------------------------------------------------------------#
#                                                                             #
# Indexing script for glftpd+pzs-ng or shell to create a symlink for releases #
# sorted under dated and/or group directories.                                #
#                                                                             #
# - Runs from either shell or glftpd (glftpd is not needed to run this)       #
# - Creates missing group or date dirs if needed                              #
# - Will skip dirs or links if already present                                #
# - In shell mode it can create dirs/release links by recursively stepping    #
#   through a source directory. Optionally source depth can be set            #
# - Can create absolute or relative paths (depending on which mode is active) #
# - Can index either groupdirs, dated dirs or both, and in which ever order   #
# - Does extremely flexible dated dirs indexing                               #
# - Has an optionally case sensitive denydirs function to not create dirs/    #
#   symlinks for certain directory or group names                             #
# - Has an exclusions function to be combined with the denydirs function      #
# - Can search for and move dead symlinks to a configurable path. Used with a #
#   shell option or by a glftpd custom command                                #
# - Optionally creates the parent directory structure before moving dead      #
#   symlinks                                                                  #
# - Automatically unzips file_id.diz if it's missing from 0DAY/DOX release    #
#   dirs                                                                      #
#                                                                             #
# This is not (purely) a 0DAY/DOX indexing script, but a general purpouse     #
# one. There are plans to implement at least mp3 specific indexing            #
# functionality too. It should(tm) work with bookware and pda stuff rels too  #
#                                                                             #
# Unexpected things might happen if you run this with non-scene standard      #
# releases. I.e. don't expect it to operate fully with dir/filenames          #
# including spaces or weird characters                                        #
#                                                                             #
#-----------------------------------------------------------------------------#
#                               PREREQUISITES                                 #
#-----------------------------------------------------------------------------#
#                                                                             #
# - libpcre (perl compatible runtime environment) because of the use of perl  #
#   style regular expressions (grep -P option)                                #
#                                                                             #
#-----------------------------------------------------------------------------#
#                               GENERAL SETUP                                 #
#-----------------------------------------------------------------------------#
#                                                                             #
# - Change mode to reflect either glftpd (0) or shell (1) usage.              #
#                                                                             #
#   You don't need glftpd installed to run this script. You can just skip     #
#   some of the settings if you wish, but in theory you should still be able  #
#   to use the --glftpd-links option if you set some paths. This is untested  #
#   so if you don't have any success with it you can send me an email.        #
#                                                                             #
# - Edit linkpath to fit your needs. Linkpath is the directory within your    #
#   glftpd ftp root directory (default: /site) in which to create dated       #
#   and/or group name dirs and under those, the release symlinks with         #
#   relative paths. Make sure there is no trailing slash. This is used in     #
#   glftpd for normal usage, and in shell mode by the --glftpd-links option.  #
#   This setting is optional for shell usage unless you want to make relative #
#   links.                                                                    #
#                                                                             #
# - Edit indexgroup to choose whether to index groups or not. 0=no, 1=yes.    #
#                                                                             #
# - Edit indexdate to choose whether to index dated directories or not.       #
#   0=no, 1=yes.                                                              #
#                                                                             #
# - Edit indexorder setting. 0=dated dirst first, 1=group dirs first          #
#   This only makes sense if both indexgroup and indexdate are set to 1.      #
#                                                                             #
#   Example: "yy/mmdd/groupname" vs "groupname/yy/mmdd"                       #
#                                                                             #
# - Edit index to change the date indexing format. Valid options are: yy for  #
#   year, ww for week, mm for month, dd for day, either put together or       #
#   separated by slash (/). This should work with any combination of the      #
#   above options in any order. If it doesn't, please send me an email with   #
#   the non matching combination. Maximum length for this setting is 11 chars #
#   (xx/xx/xx/xx). Any excess characters will be ignored. Use anything else   #
#   than a single / as separator and you loose.                               #
#                                                                             #
#   Example: "yymmdd" indexes as "20110508", "yy/mmdd" indexes as "2011/0508",#
#   "ww/yydd/mm" indexes as "19/201108/05" (wtf?) and so on...                #
#                                                                             #
# - Edit denydirs to fit your needs. Denydirs is a list of directories or     #
#   group names you do not want to create groupdirs/symlinks for, separated   #
#   by | (pipe). Don't use wildcards. Denydirs implicitly assumes *foo*       #
#   matching, i.e. "sample" matches "vobsample", "cd" matches "cd1", "cd2"    #
#   and so on. Parantheses need to be escaped. Use exclusions to omit matches.#
#                                                                             #
#   Example: "cd|DVD|sample|subs|PROPER|proof|Lamegroup1|Lamegroup2"          #
#                                                                             #
# - Edit exclusions if you want to exclude certain things from denydirs.      #
#                                                                             #
#   Example: "CDS|CDR|CDM|CD-|\(CD\)". This example string excludes mp3       #
#   releases from the matching. Same rules as for denydirs applies.           #
#                                                                             #
#   You should, at least in theory, be able to leave denydirs blank and add   #
#   any specific groupnames to exclusions, and thus be able to only allow     #
#   links to be created for specific groupnames. Been too lazy to check if    #
#   this is a script breaker or not tho... If it is, send me an email.        #
#                                                                             #
# - Set cases to either 0 or 1 to toggle case sensitivity for the above       #
#   denydirs and exclusions settings. 0=Case insensitive matching, 1=Case     #
#   sensitive matching. 0 is the recommended setting.                         #
#                                                                             #
# - Set the deadlink path. This is used by the --dead-links and               #
#   --glftpd-links options combination aswell as the glftpd custom linkscan   #
#   command. These commands scan $glpath$linkpath (or $linkpath) and move any #
#   dead symlinks found to $glpath$deadlink (or $deadlink). This was a design #
#   choice because i figured a SOP would want to manually check any dead      #
#   links before deleting them.                                               #
#                                                                             #
# - Set deadparent to either 0 or 1. The deadparent setting is used with the  #
#   --dead-links option and custom linkscan command. If set to 1, it will     #
#   create the parent directory structure in the destination path before      #
#   moving dead links.                                                        #
#                                                                             #
#-----------------------------------------------------------------------------#
#                               GLFTPD SETUP                                  #
#-----------------------------------------------------------------------------#
#                                                                             #
# Install                                                                     #
# -------                                                                     #
#                                                                             #
# - Copy /lib/libpcre.so.* to your glftpd/lib directory.                      #
# - Copy date, unzip and up-link.sh to your glftpd/bin directory.             #
# - chmod +x up-link.sh                                                       #
#                                                                             #
# - Add or edit the following 2 lines in your pzs-ng zsconfig.h:              #
#                                                                             #
#   #define enable_complete_script       TRUE                                 #
#   #define complete_script              "/bin/up-link.sh"                    #
#                                                                             #
#   Remove ,diz from #define ignored_types                                    #
#                                                                             #
#   Recompile pzs-ng                                                          #
#                                                                             #
# - Add the following things to your glftpd.conf:                             #
#                                                                             #
#   site_cmd    LINKSCAN    EXEC    /bin/up-link.sh[:space:]linkscan          #
#   custom-linkscan    !8 1 2 7                                               #
#                                                                             #
# - If you want script benchmarking in glftpd debug mode, you will also need  #
#   to copy /lib/libreadline.so.* to glftpd/lib and bc to glftpd/bin.         #
#                                                                             #
# Configure                                                                   #
# ---------                                                                   #
#                                                                             #
# - Change debug to suit your needs. Debugging off=0, on=1.                   #
#                                                                             #
# - Edit gldebug to set the path and filename to the debug log file.          #
#   /gldebug.txt matches your glftpd root directory.                          #
#                                                                             #
# Usage                                                                       #
# -----                                                                       #
#                                                                             #
# In normal mode it will do things automagically. In debug mode it will do    #
# the same, but will append to a log file in the path you set in the gldebug  #
# setting.                                                                    #
#                                                                             #
#-----------------------------------------------------------------------------#
#                               SHELL SETUP                                   #
#-----------------------------------------------------------------------------#
#                                                                             #
# Install                                                                     #
# -------                                                                     #
#                                                                             #
# - chmod +x up-link.sh                                                       #
#                                                                             #
# - If you for some reason want to run shell mode in a glftpd chroot (or any  #
#   other chroot for that matter), you will need to copy readlink, getopt,    #
#   test, unzip and bc to a path within your chroot.                          #
#                                                                             #
# Configure                                                                   #
# ---------                                                                   #
#                                                                             #
# - Change glpath to match where your glftpd is installed (default: /glftpd). #
#   This is needed by the --glftpd-links option in combination with the       #
#   linkpath setting. If you don't have glftpd installed you can in theory    #
#   still use this option, but it's untested.                                 #
#                                                                             #
# - Edit shellpath to fit your needs. Shellpath is a directory that can be    #
#   located anywhere on your system. In it will be created the dated and/or   #
#   group name dirs, and under those, the release symlinks with absolute      #
#   paths. Make sure there is no trailing slash. This path is used by the     #
#   --shell-links option.                                                     #
#                                                                             #
# - Set the deadshell path. This is used by the --dead-links and              #
#   --shell-links options combination. --dead-links scans $shellpath and      #
#   moves any dead symlinks it finds to  $deadshell. This was a design choice #
#   because i figured you would want to manually check any dead links before  #
#   deleting them.                                                            #
#                                                                             #
# - Edit shelldebug to set the path and filename to the debug log file.       #
#   /shelldebug.txt matches your root directory.                              #
#                                                                             #
#  The following two settings are for the shell --recursive option only.      #
#  Be careful with these. For the average user it's recommended that          #
#  minlevel and maxlevel are set with the same value.                         #
#                                                                             #
# - Edit the mindepth setting. Mindepth means that no action at levels less   #
#   than the command line argument level is taken.                            #
#                                                                             #
# - Edit the maxdepth setting. Maxdepth means decend at most N levels of      #
#   directories below the command line argument.                              #
#                                                                             #
#   Examples: The command used for these examples is:                         #
#   $ ./up-link.sh -r -gl /jail/glftpd/site/0DAY                              #
#                                                                             #
#   mindepth="1" and maxdepth="1" will traverse /jail/glftpd/site/0DAY/*      #
#   but not /jail/glftpd/site/0DAY or /jail/glftpd/site/0DAY/*/* ...          #
#   mindepth="2" and maxdepth="2" will traverse /jail/glftpd/site/0DAY/*/*    #
#   but not /jail/glftpd/site/0DAY/* or /jail/glftpd/site/0DAY/*/*/* ...      #
#   mindepth="3" and maxdepth="3" will traverse /jail/glftpd/site/0DAY/*/*/*  #
#   but not /jail/glftpd/site/0DAY/*/* or /jail/glftpd/site/0DAY/*/*/*/* ...  #
#   mindepth="2" and maxdepth="3" will traverse /jail/glftpd/site/0DAY/*/*    #
#   AND /jail/glftpd/site/0DAY/*/*/* but not /jail/glftpd/site/0DAY/* ...     #
#                                                                             #
#   and so on...                                                              #
#                                                                             #
# Usage                                                                       #
# -----                                                                       #
#                                                                             #
# up-link.sh [--version|-v] [--debug|-d] [OPTIONS] [RELEASE NAME]             #
#                                                                             #
# -v,  --version      Displays version and exits.                             #
# -d,  --debug        Runs the script in debug mode. This will create a debug #
#                     log in the path set in the shelldebug setting.          #
# -dl, --dead-links   Scans and moves dead symlinks to the path set in        #
#                     the deadshell setting. Use together with -gl or -sl     #
#                     with no trailing release name.                          #
# -gl, --glftpd-links Creates symlinks relative to the glftpd path.           #
#                     These will be accessible from inside glftpd, but not    #
#                     from the shell.                                         #
# -sl, --shell-links  Creates symlinks with an absolute path. These will be   #
#                     accessible from the shell but not from inside glftpd.   #
# -r, --recursive     Adds recursion to the -gl and -sl options.              #
#                                                                             #
#-----------------------------------------------------------------------------#
#                                CHANGELOG                                    #
#-----------------------------------------------------------------------------#
#                                                                             #
# v1.0 - Initial release                                                      #
# v1.1 - Removed unneccecary regex                                            #
#      - Minor changes in format                                              #
# v1.2 - Changed $2 var to $PWD to get relative release path in pzs-ng        #
#      - Should run from pzs-ng, and not by post_check in glftpd.conf!        #
# v1.3 - Rewrote and reformated parts of the script                           #
#      - Made a shell mode and separate debug modes                           #
#      - Shell mode handles relative and absolute paths for input names       #
#      - Made 2 regex's to match either number of disks or date from          #
#        file_id.diz. Only used when debugging atm however :)                 #
#      - Changed the name to UP-link because it's funnier that way            #
# v1.4 - Timestamps and script execution time now available in the debug logs #
#      - Restructured the script again. Removed option 3 (shell debug mode)   #
#        and added it as a shell option instead (--debug)                     #
#      - Shell mode is now agnostic to whether the input release name has a   #
#        trailing slash or not                                                #
#      - You should now be able to use the shell options --shell-links or     #
#        --glftpd-links to choose what kind of symlink you want created       #
# v1.5 - More cleanup (does this ever end? :))                                #
#      - Denydirs setting. You can toggle case sensitivity, and use * as a    #
#        wildcard for the matching. There's also a possibility to exclude     #
#        certain matches using the exclusions setting                         #
# v1.6 - Found some bugs in the --glftpd-links option that hopefully should   #
#        be fixed now                                                         #
#      - Total resctructure of the code. Less code needed for the same        #
#        functionality                                                        #
#      - Using wildcard for denydirs/exclusions didn't quite work as I had    #
#        hoped. Then again, no need to use wildcards at all now since the     #
#        matching is already being done thanks to the =~ operand :)           #
#      - Added a separate glftpd debug setting instead of a third mode        #
# v1.7 - Added an incredibly flexible date indexing function which optionally #
#        can be used together with group indexing                             #
#      - Added a bunch of comments to the code                                #
#      - Added an option to sort dated dirs or group dirs first. Had to       #
#        rewrite create_dir() and create_link(), and parts of debug_info()    #
# v1.8 - Found small bug in date format which reversed month and day in date  #
#        dir indexing                                                         #
#      - Now unzips file_id.diz from zip releases if it doesn't exist         #
#      - exec_func(), create_dir() and create_link() optimized for size       #
#      - Renamed some functions and changed the execution order for some      #
#      - Added a standalone function to move dead symlinks to a path set by   #
#        $deadlinks or $deadshell, with or without parent dir structure       #
#      - Rewrote options(). I can now easily add more standalone functions    #
#      - like dead_link() in the future. Can't believe how long it took to    #
#        learn how to use getopt                                              #
# v1.9 - Minor cosmetic changes                                               #
#      - Minor bugfixes                                                       #
#      - Removed some unused code                                             #
#      - Added --recursive option for -gl and -sl                             #
#                                                                             #
#-----------------------------------------------------------------------------#
#                                   TODO                                      #
#-----------------------------------------------------------------------------#
#                                                                             #
#(GLFTPD) -Currently checking all dirs. This isn't the prefered way ofcourse. #
#  (BOTH) -Some kind of sections indexing?                                    #
#(GLFTPD) -On rescan, also check if symlink exists and create it if it        #
#          doesn't?                                                           #
# (SHELL) -Using the --glftpd-links currently only makes sense if your        #
#          source release is within your glftpd ftp root path. Maybe I can    #
#          change this behavior somehow later. That would require the script  #
#          to move the release inside of the glftpd chroot ofcourse.          #
#  (BOTH) -Mp3 genre sorting?                                                 #
#  (BOTH) -Mp3 artist sorting?                                                #
#  (BOTH) -Mp3 label sorting?                                                 #
#  (BOTH) -Mp3 bitrate sorting?                                               #
#  (BOTH) -(vob)sample bitrate sorting?                                       #
#  (BOTH) -Making it possible to create group/dated dirs and symlinks in more #
#          than one place simultaniously?                                     #
#                                                                             #
# The dated directories will always be created with the current date Maybe i  #
# can change this behaviour by somehow grabbing the source path, at least for #
# already sorted dirs. I think it's not possible to make dirs parsed from     #
# file_id dates anyway for obvious reasons. If you have any ideas regarding   #
# this, please email me or catch me on efnet                                  #
#                                                                             #
#-----------------------------------------------------------------------------#
#                              OTHER STUFF                                    #
#-----------------------------------------------------------------------------#
#                                                                             #
# THIS IS NOT A PUBLIC RELEASE!                                               #
#                                                                             #
# Please do not redistribute or reuse any parts of the code without           #
# permission from the developer. When it's ready for public release, you will #
# find the latest version on http://www.uprough.net or                        #
# http://www.trueschool.org                                                   #
#                                                                             #
###############################################################################

### Config

# modes: 0=glftpd, 1=shell
mode="1"

# path to your glftpd install
glpath="/jail/glftpd"

# path to group dirs/dated dirs and symlinks within glftpd chroot
# used by glftpd mode and --glftpd-links in shell
linkpath="/site/_grouplinks"

# path to group dirs/dated dirs and symlinks. can be located
# anywhere on the system. used by --shell-links in shell
shellpath="/home/dmg/test/skope/_grouplinks"

# path to move dead symlinks to. needs to be within glftpd chroot for glftpd
# usage. used by --glftpd-links in shell
deadlink="/site/_deadlinks"

# shell specific path to move dead symlinks to. used with --shell-links
deadshell="/home/dmg/test/skope/_deadlinks"

# create parent directory structure when moving dead links? 0=no, 1=yes
deadparent="1"

# index with group dirs? 0=no, 1=yes
indexgroup="1"

# index with date dirs? 0=no, 1=yes
indexdate="1"

# 0=dated dirs first, 1=group dirs first
indexorder="0"

# date indexing format. available options are: yy, ww, mm, dd. use / to separate
index="yy/mmdd"

# list of dirs to deny, separated by | (pipe)
denydirs="ac3|cd|dvd|sample|sub|PROPER|extra|proof|Lamegroup1|Lamegroup2"

# allow exclusions to denydirs for dirs containing the following things
exclusions="CDS|CDR|CDM|CD-|\(CD\)|.PROPER.|.SUBS.|.EXTRAS.|DVD.|.DVD|.DVD.|DVD-R|DVDR"

# toggle case sensitivity for the denydirs and exclusions settings
# 0=Case insensitive, 1=Case sensitive
cases="0"

# glftpd mode only debug (shell users use the --debug option). 0=off, 1=on
debug="0"

# glftpd mode debug log path
gldebug="/gldebug.txt"

# shell mode debug log path
shelldebug="shelldebug.txt"

# min depth for the shell --recursive option
mindepth="1"

# max depth for the shell --recursive option
maxdepth="1"

### You shouldn't really need to edit anything below this line

scrver="UP-link v1.9"
scrauth="dMG/dS!^UP!^t!s 2011-05-23"

main() {
	# Tells user that the debug log is updated. Ends benchmarking and exits the script with great success
	end_script() {
		if [[ ${debugmode} == 0 ]] || [[ ${debugmode} == 0 && ${deadmode} == 0 ]]; then
			case ${mode} in
				0) echo "${gldebug} generated/updated";;
				1) echo "${shelldebug} generated/updated";;
			esac

			end_time=$(date +%s.%N)
			debug "--- SCRIPT ENDED @ ${timestamp}. Script executed in: 0$(echo "${end_time} - ${start_time}"| bc) seconds."
			debug ""
		fi
		# If recursive is off or deadmode is on, if recursive is on and the loop in recursion() is done say baibai
		if [[ ${recursive} == 1 || ${deadmode} == 0 ]] || [[ ${recursive} == 0 && ${recount} == ${#recurse[@]} ]]; then
			exit 0
		fi
	}

	# Chooses whether to echo stuff to stdout or debug log depending on the debug mode status
	log() {
		if [[ ${debugmode} == 0 ]]; then
			case ${mode} in
				0) echo "$@" >> ${gldebug};; # Glftpd mode
				1) echo "$@" >> ${shelldebug};; # Shell mode
			esac
		else
			echo "$@"
		fi
	}

	# If you don't want debug info echoed to stdout
	debug() {
		[[ ${debugmode} == 0 ]] && log "$@"
	}

	create_link() {
		# Creates symlink
		mk_link() {
			if [[ ! -L ${destname} ]]; then
				case ${shellmode} in
					shm) # --shell-links absolute link
						log "Creating symlink to ${destname}"
						eval `ln -s ${fullpath} ${destname} 2> /dev/null`;;
					glm) # --glftpd-links relative link
						log "Creating symlink to ${destname2}"
						eval `ln -s ${relpath} ${destname} 2> /dev/null`;;
				esac
			else
				case ${shellmode} in
					shm)
						log "Symlink ${destname} already exists";;
					glm)
						log "Symlink ${destname2} already exists";;
				esac
			fi
		}

		# If only indexgroup is set
		if [[ ${indexdate} == 0 && ${indexgroup} == 1 ]]; then
			destname=${destpath}/${groupname}${releasename}
			destname2=${reldest}/${groupname}${releasename}
		# If only indexdate is set
		elif [[ ${indexdate} == 1 && ${indexgroup} == 0 ]]; then
			destname=${destpath}/${destdate}${releasename}
			destname2=${reldest}/${destdate}${releasename}
		elif [[ ${indexdate} == 1 && ${indexgroup} == 1 ]]; then
			# If indexorder is 0 (date first)
			if [[ ${indexorder} == 0 ]]; then
				destname=${destpath}/${destdate}${groupname}${releasename}
				destname2=${reldest}/${destdate}${groupname}${releasename}
			# If indexorder is 1 (group first)
			elif [[ ${indexorder} == 1 ]]; then
				destname=${destpath}/${groupname}${destdate}${releasename}
				destname2=${reldest}/${groupname}${destdate}${releasename}
			fi
		fi
		# Gotta unset $destdate if we want to use the --recursive flag
		unset destdate
		mk_link "$@"
	}

	create_dir() {
		# Glftpd mode uses the same var format as shell mode --shell-links option. We want to use this for create_dir() and create_link()
		if [[ ${mode} == 0 ]]; then
			shellmode="shm"
		fi

		if [[ ! ${groupname} =~ /$ ]]; then # If the last char isn't a /, add it
			groupname=$(echo ${groupname}/)
		fi

		# Creates dirs, outputs stuff to debug log or stdout
		mk_dir() {
			if [[ ! -d ${destname} ]]; then
				case ${shellmode} in
					shm)
						log "Creating ${destname} directory";;
					glm)
						log "Creating ${destname2} directory";;
				esac
				eval `mkdir -p ${destname} 2> /dev/null`
			else
				case ${shellmode} in
					shm)
						log "Directory ${destname} already exists";;
					glm)
						log "Directory ${destname2} already exists";;
				esac
			fi
		}

		# If only indexgroup is set
		if [[ ${indexdate} == 0 && ${indexgroup} == 1 ]]; then
			destname=${destpath}/${groupname}
			destname2=${reldest}/${groupname}
		# If only indexdate is set
		elif [[ ${indexdate} == 1 && ${indexgroup} == 0 ]]; then
			destname=${destpath}/${destdate}
			destname2=${reldest}/${destdate}
		elif [[ ${indexdate} == 1 && ${indexgroup} == 1 ]]; then
			# If indexorder is 0 (date first)
			if [[ ${indexorder} == 0 ]]; then
				destname=${destpath}/${destdate}${groupname}
				destname2=${reldest}/${destdate}${groupname}
			# If indexorder is 1 (group first)
			elif [[ ${indexorder} == 1 ]]; then
				destname=${destpath}/${groupname}${destdate}
				destname2=${reldest}/${groupname}${destdate}
			fi
		fi
		mk_dir "$@"
	}

	# Writes debug info to logs
	debug_info() {
		debug "Full path..................................: ${fullpath}"
		debug "Destination path...........................: ${destpath}"
		case ${mode} in
			0) # Glftpd mode specific debug info
				debug "Argument gotten from pzs-ng................: ${PWD}";;
			1) # Shell mode specific debug info
				debug "Current path...............................: ${PWD}"
				debug "Argument passed to the script..............: ${parameter}";;
		esac
		# Sets debug info for group name indexing
		if [[ ${indexgroup} == 1 ]]; then
			debug "Group name.................................: ${groupname}"
		fi
		debug "Release name...............................: ${releasename}"
		# Sets debug info for --glftpd-links and --shell-links options
		case ${shellmode} in
			shm)
				if [[ ${indexdate} == 0 && ${indexgroup} == 1 ]]; then
					debug "Absolute path to the symlink...............: ${destpath}/${groupname}/${releasename}"
				fi

				if [[ ${indexdate} == 1 && ${indexgroup} == 0 ]]; then
					debug "Absolute path to the symlink...............: ${destpath}/${destdate}${releasename}"
				fi

				if [[ ${indexdate} == 1 && ${indexgroup} == 1 ]]; then
					if [[ ${indexorder} == 0 ]]; then
						debug "Absolute path to the symlink...............: ${destpath}/${destdate}${groupname}/${releasename}"
					elif [[ ${indexorder} == 1 ]]; then
						debug "Absolute path to the symlink...............: ${destpath}/${groupname}/${destdate}${releasename}"
					fi
				fi;;
			glm)
				if [[ ${indexdate} == 0 && ${indexgroup} == 1 ]]; then
					debug "Relative path to the symlink...............: ${reldest}/${groupname}/${releasename}"
				fi

				if [[ ${indexdate} == 1 && ${indexgroup} == 0 ]]; then
					debug "Relative path to the symlink...............: ${reldest}/${destdate}${releasename}"
				fi

				if [[ ${indexdate} == 1 && ${indexgroup} == 1 ]]; then
					if [[ ${indexorder} == 0 ]]; then
						debug "Relative path to the symlink...............: ${reldest}/${destdate}${groupname}/${releasename}"
					elif [[ ${indexorder} == 1 ]]; then
						debug "Relative path to the symlink...............: ${reldest}/${groupname}/${destdate}${releasename}"
					fi
				fi;;
		esac
		# Adds debug info for date indexing stuff
		if [[ ${indexdate} == 1 ]]; then
			if [[ ${destdate} =~ /$ ]]; then # If the last char is a /, remove it
				destdate2=$(echo ${destdate} | sed 's/\/$//')
			fi
			debug "Index variable contents....................: ${index}"
			debug "Format of the indexed dated directories....: ${destdate2}"
		fi
	}

	# Adds debug info for release containing zip files (0DAY/DOX)
	zip_debug_info() {
		if [[ ${nozip} == 0 ]]; then
			debug "Release date parsed from file_id.diz.......: ${dizdate}"
			debug "Number of zip files parsed from file_id.diz: ${numfilesdiz}"
		fi
		debug "Number of zip files according to shell.....: ${numzipfiles}"
		unset numfilesdiz
	}

	# Checks $index format and creates vars to be appended to $destdate using the list of functions below this
	index_lookup() {
		if [[ `echo ${index} | grep 'yy'` ]]; then
			dy=$(echo -n ${year})
			sdy=$(echo -n /${year})
		fi

		if [[ `echo ${index} | grep 'ww'` ]]; then
			dw=$(echo -n ${week})
			sdw=$(echo -n /${week})
		fi

		if [[ `echo ${index} | grep 'mm'` ]]; then
			dm=$(echo -n ${month})
			sdm=$(echo -n /${month})
		fi

		if [[ `echo ${index} | grep 'dd'` ]]; then
			dd=$(echo -n ${day})
			sdd=$(echo -n /${day})
		fi
	}

	# The following functions are executed by compare_strings() and check if $destdate does not contain a / or if it is 10 chars long. Then they append the appropriate vars defined in index_lookup() to $destdate for further usage by create_dir()
	even_year() {
		if [[ ! ${destdate} =~ / ]]; then
			destdate="${destdate}${dy}"
		elif [[ ${#destdate} == 10 ]]; then
			destdate="${destdate}${dy}"
		else
			destdate="${destdate}${sdy}"
		fi
	}

	even_week() {
		if [[ ! ${destdate} =~ / ]]; then
			destdate="${destdate}${dw}"
		elif [[ ${#destdate} == 10 ]]; then
			destdate="${destdate}${dw}"
		else
			destdate="${destdate}${sdw}"
		fi
	}

	even_month() {
		if [[ ! ${destdate} =~ / ]]; then
			destdate="${destdate}${dm}"
		elif [[ ${#destdate} == 10 ]]; then
			destdate="${destdate}${dm}"
		else
			destdate="${destdate}${sdm}"
		fi
	}

	even_day() {
		if [[ ! ${destdate} =~ / ]]; then
			destdate="${destdate}${dd}"
		elif [[ ${#destdate} == 10 ]]; then
			destdate="${destdate}${dd}"
		else
			destdate="${destdate}${sdd}"
		fi
	}

	uneven_year() {
		if [[ ! ${destdate} =~ / ]]; then
			destdate="${destdate}${sdy}"
		elif [[ ${#destdate} == 10 ]]; then
			destdate="${destdate}${sdy}"
		else
			destdate="${destdate}${dy}"
		fi
	}

	uneven_week() {
		if [[ ! ${destdate} =~ / ]]; then
			destdate="${destdate}${sdw}"
		elif [[ ${#destdate} == 10 ]]; then
			destdate="${destdate}${sdw}"
		else
			destdate="${destdate}${dw}"
		fi
	}

	uneven_month() {
		if [[ ! ${destdate} =~ / ]]; then
			destdate="${destdate}${sdm}"
		elif [[ ${#destdate} == 10 ]]; then
			destdate="${destdate}${sdm}"
		else
			destdate="${destdate}${dm}"
		fi
	}

	uneven_day() {
		if [[ ! ${destdate} =~ / ]]; then
			destdate="${destdate}${sdd}"
		elif [[ ${#destdate} == 10 ]]; then
			destdate="${destdate}${sdd}"
		else
			destdate="${destdate}${dd}"
		fi
	}

	# Compares positions in $index and executes the appropriate functions to create the correct $destdate format
	compare_strings() {
		if [[ ${index:0:2} == yy ]]; then
			even_year
		elif [[ ${index:0:2} == ww ]]; then
			even_week
		elif [[ ${index:0:2} == mm ]]; then
			even_month
		elif [[ ${index:0:2} == dd ]]; then
			even_day
		fi

		if [[ ${index:1:2} == yy ]]; then
			uneven_year
		elif [[ ${index:1:2} == ww ]]; then
			uneven_week
		elif [[ ${index:1:2} == mm ]]; then
			uneven_month
		elif [[ ${index:1:2} == dd ]]; then
			uneven_day
		fi

		if [[ ${index:2:2} == yy ]]; then
			even_year
		elif [[ ${index:2:2} == ww ]]; then
			even_week
		elif [[ ${index:2:2} == mm ]]; then
			even_month
		elif [[ ${index:2:2} == dd ]]; then
			even_day
		fi

		if [[ ${index:3:2} == yy ]]; then
			uneven_year
		elif [[ ${index:3:2} == ww ]]; then
			uneven_week
		elif [[ ${index:3:2} == mm ]]; then
			uneven_month
		elif [[ ${index:3:2} == dd ]]; then
			uneven_day
		fi

		if [[ ${index:4:2} == yy ]]; then
			even_year
		elif [[ ${index:4:2} == ww ]]; then
			even_week
		elif [[ ${index:4:2} == mm ]]; then
			even_month
		elif [[ ${index:4:2} == dd ]]; then
			even_day
		fi

		if [[ ${index:5:2} == yy ]]; then
			uneven_year
		elif [[ ${index:5:2} == ww ]]; then
			uneven_week
		elif [[ ${index:5:2} == mm ]]; then
			uneven_month
		elif [[ ${index:5:2} == dd ]]; then
			uneven_day
		fi

		if [[ ${index:6:2} == yy ]]; then
			even_year
		elif [[ ${index:6:2} == ww ]]; then
			even_week
		elif [[ ${index:6:2} == mm ]]; then
			even_month
		elif [[ ${index:6:2} == dd ]]; then
			even_day
		fi

		if [[ ${index:7:2} == yy ]]; then
			uneven_year
		elif [[ ${index:7:2} == ww ]]; then
			uneven_week
		elif [[ ${index:7:2} == mm ]]; then
			uneven_month
		elif [[ ${index:7:2} == dd ]]; then
			uneven_day
		fi

		if [[ ${index:8:2} == yy ]]; then
			even_year
		elif [[ ${index:8:2} == ww ]]; then
			even_week
		elif [[ ${index:8:2} == mm ]]; then
			even_month
		elif [[ ${index:8:2} == dd ]]; then
			even_day
		fi

		if [[ ${index:9:2} == yy ]]; then
			uneven_year
		elif [[ ${index:9:2} == ww ]]; then
			uneven_week
		elif [[ ${index:9:2} == mm ]]; then
			uneven_month
		elif [[ ${index:9:2} == dd ]]; then
			uneven_day
		fi

		if [[ ! ${destdate} =~ /$ ]]; then # Check for trailing slash and add it
			destdate=`echo ${destdate}/`
		fi
	}

	# Makes it possible to deny directories in $denydirs and to allow exclusions in $exclusions. On denydirs match, adds some info to debug log and jumps to end_script()
	deny_dirs() {
		case ${cases} in
			0) shopt -sq nocasematch;; # Case insensitive matching
			1) shopt -uq nocasematch;; # Case sensitive matching
		esac

		if [[ ! ${releasename} =~ (${exclusions}) && ${releasename} =~ (${denydirs}) ]]; then
			log "${releasename} Denied by denydirs setting"
			if [[ ${debugmode} == 0 ]]; then
				log "Contents of denydirs: \"${denydirs}\""
				log "Contents of exclusions: \"${exclusions}\""
				end_script
			fi
		else
			shopt -uq nocasematch # Not needed outside of this function
		fi
	}

	# Sets needed vars (orly?)
	vars() {
		case ${mode} in
			0) # Glftpd mode specific
				releasepath=${PWD}
				releasename=${PWD##*/};;
			1) # Shell mode specific
				releasepath=$(echo ${parameter} | sed 's/\/*$//')
				releasename=$(basename ${parameter});; # releasename=${2##*/} # Breaks stuff if the last script argument is fed with a trailing /. local a=${2%/}; echo ${a##*/}; might fix that.
		esac
		# General
		groupname=$(echo ${releasename} | grep -oP '[[:alnum:]]+$')
		relpath=$(echo ${fullpath} | sed "s|^${glpath}||") # Creates relative path from full path by stripping $glpath
		reldest=$(echo ${destpath} | sed "s|^${glpath}||") # Same:ish.. Can't remember, too lazy to check :D
	}

	# Sets the vars needed if the release contains zip files (0DAY/DOX ...)
	zip_vars() {
		numzipfiles=$(ls "${fullpath}" 2> /dev/null | grep "\.[zZ][iI][pP]$" | wc -l) # Checks the number of zip files according to the shell
		# Only set the following if file_id.diz exists
		if [[ -f ${fullpath}/${file_id} ]]; then
			numfilesdiz=`cat ${fullpath}/${file_id} | sed 'y/oOX/00x/' | grep -oP '(?<![\dxX]{2}[-/|\\+])[\dxX]{2}\s?[-/|\\+]\s?[\dxX]{2}(?![-/|\\+][\dxX]{2})'` # Epic regex is epic. Parses number of zip files from file_id.diz
			dizdate=$(cat ${fullpath}/${file_id} | sed 'y/oOX/00x/' | grep -oP '\d{2,4}\D?\d{2}\D?\d{2,4}') # Parses date from file_id.diz
		fi
	}

	# Sets the vars needed by index_lookup()
	date_vars() {
		date=$(date '+%d%m%Y%V')
		day=`echo ${date} | grep -oP '^\d{2}'`
		week=`echo ${date} | grep -oP '\d{2}$'`
		month=`echo ${date} | grep -oP '(?<=\d{2})\d{2}(?=\d{6})'` # Look around you
		year=`echo ${date} | grep -oP '(?<=\d{4})\d{4}(?=\d{2})'`
	}

	# Checks for file_id.diz and extracts it
	diz_check() {
		file_id=$(ls "${fullpath}" 2> /dev/null | grep "[fF][iI][lL][eE]_[iI][dD].[dD][iI][zZ]")
		if [[ ! -f ${fullpath}/${file_id} ]]; then
			# We have to limit ourselves somehow, so one solution is to extract only from the latest zip file
			zipfile=$(ls -t "${fullpath}" 2> /dev/null | grep "\.[zZ][iI][pP]$" | head -n 1)
			unzip -Cnqq ${fullpath}/${zipfile} [fF][iI][lL][eE]_[iI][dD].[dD][iI][zZ] -d ${fullpath}/ 2>/dev/null # We also want unzip to shut up if there is no file_id in the zip file
			# Gotta set the var a second time, or it will still be blank
			file_id=$(ls "${fullpath}" 2> /dev/null | grep "[fF][iI][lL][eE]_[iI][dD].[dD][iI][zZ]")
			if [[ ! -f ${fullpath}/${file_id} ]]; then
				log "Could not find file_id.diz in release zip"
			fi
		fi
	}

	# Initiates scrip benchmarking and adds some debug log header output
	start_script() {
		timestamp=$(date '+%a %b %d %C%y %T')
		start_time=$(date +%s.%N)

		if [[ ${mode} == 0 ]]; then
			debug "---SCRIPT STARTED IN GLFTPD DEBUG MODE @ ${timestamp}" # glftpd debug
		else
			case ${shellmode} in
				shm) debug "---SCRIPT STARTED IN SHELL LINK DEBUG MODE @ ${timestamp}";; # --shell-links
				glm) debug "---SCRIPT STARTED IN GLFTPD LINK DEBUG MODE @ ${timestamp}";;  # --glftpd-links
			esac
		fi
	}

	# Allows --recursive option
	recursion() {
		IFSBAK=${IFS}
		# Setting IFS (to be able to catch dirs containing spaces)
		IFS='
		'
		# Remove trailing /
		parameter=$(echo ${parameter} | sed 's/\/*$//')
		# List all dirs to recurse array. This is where the mindepth and maxdepth options kick in
		recurse=($(find "${parameter}" -mindepth ${mindepth} -maxdepth ${maxdepth} -type d | sed 's/\/*$//'))
		recount="0"
		# If $recount value isn't the same as the number of elements in $recurse, keep going
		while [[ ! ${recount} == ${#recurse[@]} ]]; do
			# Set up a check so that recursion() won't execute more than once by exec_func()
			recursion_done="0"
			fullpath="${recurse[${recount}]}"
			let recount=( ${recount} + 1 )
			# Back to exec_func() to execute the rest of the script for each element in $fullpath
			exec_func "${fullpath}"
		done
	}

	# Sets $fullpath for glftpd or shell modes. Checks if the release contains zip files (0DAY/DOX). Executes the appropriate functions for the rest of the script
	exec_func() {
		if [[ ! ${recursive} == 0 ]]; then
			case ${mode} in
				0) fullpath=${PWD};; # Glftpd mode
				1) fullpath=$(echo $(readlink -f "${parameter}"));; # Shell mode
			esac
		elif [[ ${recursion_done} == 0 ]]; then
			parameter="${fullpath}"
		fi

		nozip="1"
		if [[ ! $(ls "${fullpath}" 2> /dev/null | grep "\.[zZ][iI][pP]$" | wc -l) == 0 ]]; then # if [ -f ... ] accepts only one argument. need to work around that
			nozip="0"
		fi

		# Don't want recursion() run more than once
		if [[ ${recursive} == 0 && ! ${recursion_done} == 0 ]]; then
			recursion "$@"
		fi

		start_script

		# Adding some recursion specific debug info
		if [[ ${recursive} == 0 ]]; then
			debug "Recursive mode.............................: YES"
			debug "Recursive count............................: ${recount}/${#recurse[@]}"
		else
			debug "Recursive mode.............................: NO"
		fi

		# If release contains zip files (0DAY/DOX), run some functions
		if [[ ${nozip} == 0 ]]; then
			diz_check "$@"
			zip_vars "$@"
		fi

		vars "$@"
		date_vars "$@"
		deny_dirs "$@"
		index_lookup "$@"
		compare_strings "$@"

		# If debug mode is on, run some functions
		if [[ ${debugmode} == 0 ]]; then
			debug_info "$@"
			if [[ ${nozip} == 0 ]]; then # Does release contain zip files (0DAY/DOX)?
				zip_debug_info "$@"
			else
				debug "No zip release under this path. No more information available"
			fi
		fi

		create_dir "$@"
		create_link "$@"
		end_script
	}

	not_exist() {
		echo "${scrver}: ${destpath} does not exist! This is a configuration error"
		exit 1
	}

	# Finds and moves dead symlinks
	dead_link() {
		# --glftpd-links only
		rel_link() {
			log "Scanning ${destpath} for dead links"
			# Find and add "broken" symlinks to an array
			filepath=(`find "${destpath}" -type l ! -exec test -r {} \; -print`)

			if [[ ${deadparent} == 1 ]]; then
				dirpath=(`find "${destpath}" -type l ! -exec test -r {} \; -print | sed -e "s|${glpath}${linkpath}||" -e 's/[^\/]*$//'`)
			fi

			# Prepend $glpath while listing each element in $filepath and stripping everything until the space after the >. This way we get the absolute path to the relative source of the symlinks
			count="0"
			for element in ${filepath[@]}; do
				relarray1[${count}]=$(echo ${glpath})$(ls -l ${element} 2> /dev/null | sed -n 's/[^$]*> //p')
				let count=( ${count} + 1 )
			done

			# Find the release from $relarray1, strip its entire path and add to relarray2. Now we have something to compare $filepath against
			count="0"
			for element in ${relarray1[@]}; do
				relarray2[${count}]=$(eval find "${element}" -maxdepth 0 -type d \; 2> /dev/null | sed -n 's/.*\///p')
				let count=( ${count} + 1 )
			done

			# Check if $filepath contains $relarray2, return the diff and mkdir and/or move the links
			count="0"
			count2="0"
			for element1 in ${filepath[@]}; do
				found="0"
				for element2 in ${relarray2[@]}; do
					if [[ ${element1} =~ ${element2} ]]; then
						found="1"
					fi
				done
				# If we want parent dirs
				if [[ ${deadparent} == 1 && ${found} == 0 ]]; then
						eval `mkdir -p ${deadpath}${dirpath[$count]}`
						eval `mv ${element1} ${deadpath}${dirpath[$count]} 2> /dev/null`
						let count2=( ${count2} +1 )
				else
					if [[ ${found} == 0 ]]; then
						eval `mv ${element1} ${deadpath} 2> /dev/null`
						let count2=( ${count2} +1 )
					fi
				fi
				let count=( ${count} + 1 )
			done
			log "${count2} dead links moved to ${deadpath}"
		}

		# --shell-links and glftpd mode only
		abs_link() {
			log "Scanning ${destpath} for dead links"
			count=$(find "${destpath}" -type l ! -exec test -r {} \; -print | wc -l)
			# If we want parent dirs
			if [[ ${deadparent} == 1 ]]; then
				# Find the broken symlinks
				filepath=(`find "${destpath}" -type l ! -exec test -r {} \; -print`)
				if [[ ${mode} == 0 ]]; then
					# Stripping linkpath and releasename yields what's left of the path
					dirpath=(`find "${destpath}" -type l ! -exec test -r {} \; -print | sed -e "s|${linkpath}||" -e 's/[^\/]*$//'`)
				elif [[ ${mode} == 1 && ${shellmode} == shm ]]; then
					dirpath=(`find "${destpath}" -type l ! -exec test -r {} \; -print | sed -e "s|${shellpath}||" -e 's/[^\/]*$//'`)
				fi

				count2="0"
				for element in ${dirpath[@]}; do
					eval `mkdir -p ${deadpath}${element} 2> /dev/null`
					eval `mv ${filepath[$count2]} ${deadpath}${element} 2> /dev/null`
					let count2=( ${count2} + 1 )
				done
			else
				# Way easier if you don't want parent dirs
				eval `find "${destpath}" -type l ! -exec test -r {} \; -exec mv {} ${deadpath} \; 2> /dev/null`
			fi
			log "${count} dead links moved to ${deadpath}"
		}

		# Check which mode is active and set some vars accordingly before jumping to abs_link() or rel_link() and end_script()
		if [[ ${mode} == 0 ]]; then
			if [[ ! -d ${deadlink} ]]; then
				not_exist
			else
				destpath="${linkpath}"
				deadpath="${deadlink}"
				abs_link "$@"
			fi
		elif [[ ${mode} == 1 ]]; then
			case ${shellmode} in
				shm)
					if [[ ! -d ${deadshell} ]]; then
						not_exist
					else
						deadpath="${deadshell}"
						abs_link "$@"
					fi;;
				glm)
					if [[ ! -d ${glpath}${deadlink} ]]; then
						not_exist
					else
						deadpath="${glpath}${deadlink}"
						rel_link "$@"
					fi;;
			esac
		fi
	}

	# Checks if the $destpath and $parameter paths exist. Then jumps to exec_func()
	if_exists() {
		case ${mode} in
			0) # Glftpd mode
				destpath=${linkpath}
				if [[ ! -d ${destpath} ]]; then
					not_exist
				fi;;
			1) # Shell mode
				if [[ ! -d ${destpath} ]]; then
					not_exist
				elif [[ ! -d $(readlink -f ${parameter}) ]]; then
					echo "${scrver}: ${parameter} does not exist"
					exit 1
				fi;;
		esac
		exec_func "$@"
	}

	usage() {
		echo "up-link.sh [--version|-v] [--debug|-d] [OPTIONS] [RELEASE NAME]"
		echo ""
		echo "-v,  --version      Displays version and exits."
		echo "-d,  --debug        Runs the script in debug mode. This will create a debug"
		echo "                    log in the path set in the shelldebug setting."
		echo "-dl, --dead-links   Scans and moves dead symlinks to the path set in"
		echo "                    the deadshell setting. Use together with -gl or -sl"
		echo "                    with no trailing release name."
		echo "-gl, --glftpd-links Creates symlinks relative to the glftpd path."
		echo "                    These will be accessible from inside glftpd, but not"
		echo "                    from the shell."
		echo "-sl, --shell-links  Creates symlinks with an absolute path. These will be"
		echo "                    accessible from the shell but not from inside glftpd."
		echo "-r, --recursive     Adds recursion to the -gl and -sl options."
		echo ""
	}

	# Checks the args passed to the script. Sets up correct vars and sends you to if_exists() above. Otherwise displays usage and options. Also launches dead_link() (or any other arbitrary external function I might add in the future...)
	options() {
		case ${mode} in
			0)
				if [[ ${TERM} != dumb ]]; then # Can't guarantee $TERM is dumb on all setups however...
					echo "${scrver} - Don't run mode 0 from the shell!"
					exit 1
				fi
				# Check if script is run from glftpd with linkscan arg
				if [[ ${1} == linkscan ]]; then
					start_script
					dead_link "$@"
					end_script
					exit 0
				fi
				if_exists "$@";;
			1)
				if [[ ${TERM} == dumb ]]; then
					echo "${scrver} - Don't run mode 1 from glftpd!"
					exit 1
				fi;;
		esac

		# Used in loop below to find out if an option has been set or not
		argset=( [0]="0" [1]="0" [2]="0" [3]="0" [4]="0" )

		# Sets up the allowed arguments and modes
		set -- $(getopt -nup-link.sh -a -l=,version,debug::,recursive::,dead-links::,dl::,glftpd-links::,gl::,shell-links::,sl:: d::vr:: $@) || usage
			while [[ ${#} -gt 0 ]]; do
				case ${1} in
					--version|-v)
						echo "${scrver} by ${scrauth}"
						echo ""
						exit 0;;
					--dead-links|--dl)
						# We only want an arg to be used once, hence the if statements in this case
						if [[ ! ${argset[0]} == 0 ]]; then
							echo "up-link.sh: wrong number of arguments '-dl'"
							usage
							exit 1
						else
							argset[0]="1"
							deadmode="0"
							shift
						fi;;
					--glftpd-links|--gl)
						if [[ ! -d ${glpath} ]]; then
							echo "up-link.sh: ${glpath} does not exist."
							exit 1
						fi

						if [[ ! ${argset[1]} == 0 ]]; then
							echo "up-link.sh: wrong number of arguments '-gl'"
							usage
							exit 1
						else
							argset[1]="1"
							shellmode="glm"
							destpath=${glpath}${linkpath}
							# Gotta export the arg outside the loop
							parameter="${4}"
							shift
						fi;;
					--shell-links|--sl)
						if [[ ! ${argset[2]} == 0 ]]; then
							echo "up-link.sh: wrong number of '-sl'"
							usage
							exit 1
						else
							argset[2]="1"
							shellmode="shm"
							destpath=${shellpath}
							parameter="${4}"
							shift
						fi;;
					--recursive|-r)
						if [[ ! ${argset[3]} == 0 ]]; then
							echo "up-link.sh: wrong number of arguments '-r'"
							usage
							exit 1
						else
							argset[3]="1"
							recursive="0"
							parameter="${4}"
							shift
						fi;;
					--debug|-d)
						if [[ ! ${argset[4]} == 0 ]]; then
							echo "up-link.sh: wrong number of arguments '-d'"
							usage
							exit 1
						else
							argset[4]="1"
							debugmode="0"
							parameter="${4}"
							shift
						fi;;
					--)
						shift
						break;;
					*)
						usage
						break;;
				esac
				shift
			done

		# dead_link() needs to be accompanied by either -gl or -sl
		if [[ ${deadmode} == 0 ]]; then
			if [[ ${shellmode} == shm || ${shellmode} == glm ]]; then
				start_script
				dead_link "$@"
				end_script
			else
				echo "up-link.sh: syntax error in arguments"
				usage
				exit 1
			fi
		fi

		# '' need to be stripped from $parameter for reuse
		parameter=$(echo ${parameter} | sed -e "s/^'//" -e "s/'$//")
		# If we feed the script with no parameter or no args, we have failed at life
		if [[ $parameter == "" || ${#} == 0 ]]; then
			echo "up-link.sh: wrong number of arguments"
			usage
			exit 1
		else
			if_exists "$@"
		fi
	}
	options "$@"
}

# Checks for glftpd debug mode and executes main(), which in turn executes options()
modes() {
	case ${mode} in
		0)
			if [[ ${debug} == 1 ]]; then
				debugmode="0" # Glftpd debug mode ON
			fi
			main "$@";;
		1)
			main "$@";; # Bringing special vars inside a function must be linked all the way
	esac
}
modes "$@"
