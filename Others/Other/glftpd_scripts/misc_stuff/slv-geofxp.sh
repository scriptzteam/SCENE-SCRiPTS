#!/bin/sh

###############################################################################
# slv-geofxp 20181507                                                         #
# Allow or deny FXP from/to countries using GeoIP2                            #
###############################################################################

# +++ INSTALLATION: +++

#  > STEP 1: Copy "slv-geofxp.sh" to /glftpd/bin (perms 755)
#  > STEP 2: If needed, change GLDIR and GCONF below to match your glftpd setup
#  > STEP 3: Run "slv-geofxp.sh install" and it should take care of all the
#            requirements automatically or tell you if something went wrong
#  > STEP 4: If all went well, add the script to glftpd.conf:
#            pre_fxp_check /bin/slv-geofxp.sh *
#  > DONE.

#  Or, if you want to manually install instead:
#    1.  Debian: apt install geoipupdate libmaxminddb0 mmdb-bin 
#        RedHat: yum install geoipupdate{-cron,} libmaxminddb{-devel,}
#        Or download from: https://github.com/maxmind/libmaxminddb/releases
#                          https://github.com/maxmind/geoipupdate/releases
#    2.  cp `which mmdblookup` /glftpd/bin
#    3.  Run glftpd's libcopy.sh (to copy libmaxminddb.so /glftpd/lib)
#    4.  mkdir -p /glftpd/var/lib/GeoIP
#    5a. Use default conf to setup /glftpd/etc/GeoIP.conf and add:
#          DatabaseDirectory /glftpd/var/lib/GeoIP
#    5b. Or use script to create conf:
#         . slv-geofxp.sh && func_geoipconf /glftpd/etc/GeoIP.conf
#    6.  geoipupdate -f /glftpd/etc/GeopIP.conf
#    7.  Setup weekly crontab for geoipupdate
#    6.  install -m 666 /dev/null /glftpd/ftp-data/logs/slv-geofxp.log
#        install -m 666 /dev/null /glftpd/ftp-data/logs/slv-geofxp.log.tmp

# +++ CONFIGURATION: +++

GLDIR="/glftpd"
GLCONF="$GLDIR/glftpd.conf"

# Use ISO Country Codes seperated by spaces e.g. "US RU CN"
# DENY_CC can also be set to "all", which means only
# CC's in ALLOWED_CC can fxp and all others are blocked
ALLOW_CC="NO"
DENY_CC="US"

# Set to "allow", "deny" or "all" or leave empty to disable logging
LOG="all"

# Set to 0/1, "1" logs 1 file and ip per path to prevent spam
LOGONCE="1"

LOGFILE="/ftp-data/logs/slv-geofxp.log"
MMDB="/var/lib/GeoIP/GeoLite2-Country.mmdb"

# Original example fxpscript functionality to deny ip's, uncomment to enable
#DENY_IP="127.0.0.2 127.0.0.3"

# END OF CONFIG

func_geoipconf () {
	cat <<-_EOF_ > "$1"
		# The following AccountID and LicenseKey are required placeholders.
		# For geoipupdate versions earlier than 2.5.0, use UserId here instead of AccountID.
		#AccountID 0
		UserId 0
		LicenseKey 000000000000
		# Include one or more of the following edition IDs:
		# * GeoLite2-City - GeoLite 2 City
		# * GeoLite2-Country - GeoLite2 Country
		# For geoipupdate versions earlier than 2.5.0, use ProductIds here instead of EditionIDs.
		#EditionIDs GeoLite2-City GeoLite2-Country
		ProductIds GeoLite2-Country
		DatabaseDirectory ${GLDIR}/var/lib/GeoIP
	_EOF_
}
func_geoipcron () {
	install -m 755 /dev/null "$1" && \
	cat <<-_EOF_ > "$1"
		#!/bin/sh
		geoipupdate -f "${GLDIR}/etc/GeoIP.conf" 
	_EOF_
}

if [ "$1" = "install" ]; then
	printf "\nChecking if $GLDIR exists... "
	if [ -d "$GLDIR" ]; then
		echo "OK"
	else
		printf "FAILED:\nSet GLDIR variable in %s correctly" "$(basename $0)"
	fi
	echo "Installing required packages using package manager... "
	if which yum >/dev/null 2>&1; then
		yum install geoipupdate{-cron,} libmaxminddb{-devel}
	else
		for i in apt apt-get; do
			if which $i >/dev/null 2>&1; then
				$i install geoipupdate libmaxminddb0 mmdb-bin; break
			fi
		done
	fi
	if [ "$?" -eq "0" ]; then
		printf "Packages installed... OK\n\n"
	else
		printf "FAILED:\nTry manually or download from:\n"
		echo "	https://github.com/maxmind/libmaxminddb/releases"
		echo "	https://github.com/maxmind/geoipupdate/releases"
		exit
	fi
	if [ ! -f "${GLDIR}/bin/mmdblookup" ]; then
		printf "Copying mmdblookup to glftpd's bin dir... "
		cp "$( which mmdblookup )" "${GLDIR}/bin" && echo "OK" || echo "FAILED"
	fi
	if [ ! -d "${GLDIR}/var/lib/GeoIP" ]; then
		printf "Creating /var/lib/GeoIP in glftpd dir... "
		mkdir -p "${GLDIR}/var/lib/GeoIP" && echo "OK" || echo "FAILED"
	fi
	if [ ! -d "/var/lib/GeoIP" ]; then
		printf "Creating /var/lib/GeoIP... "
		mkdir -p "/var/lib/GeoIP" && echo "OK" || echo "FAILED"
	fi
	if [ ! -f "${GLDIR}/etc/GeoIP.conf" ]; then
		printf "Creating GeoIP.conf in "${GLDIR}/etc"... "
		func_geoipconf "${GLDIR}/etc/GeoIP.conf" && echo "OK" || echo "FAILED"
	fi
	printf "Running geoipupdate to download latest GeoLite2-Country.mmdb... "
	geoipupdate -f "${GLDIR}/etc/GeoIP.conf" && echo "OK" || echo "FAILED"
	printf "Checking if mmdb exists in %s/var/lib/GeoIP... " "$GLDIR"
	if [ -f "${GLDIR}/var/lib/GeoIP/GeoLite2-Country.mmdb" ]; then
		echo "OK"
		#if [ ! -e "/var/lib/GeoIP/GeoLite2-Country.mmdb" ]; then
		#	ln -s "${GLDIR}/var/lib/GeoIP/GeoLite2-Country.mmdb" /var/lib/GeoIP/GeoLite2-Country.mmdb
		#fi
	else
		printf "FAILED:\nCheck geoipupdate config retry or manually download mmdb from:\n"
		echo "	http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz"
	fi
	if [ ! -f "/etc/cron.weekly/geoipupdate-gl" ]; then
		printf "Setting up cron for geoipupdate... "
		func_geoipcron "/etc/cron.weekly/geoipupdate-gl" && echo "OK" || echo "FAILED"
	fi
	for i in "$LOGFILE" "${LOGFILE}.tmp"; do
		if [ ! -f "${GLDIR}${i}" ]; then
			printf "Creating $i... "
			install -m 666 /dev/null "${GLDIR}/${i}" && echo "OK" || echo "FAILED"
		fi
	done	
	FOUND=0
	for i in "$GLDIR" . .. /glftpd /jail /jail/glftpd; do
		if [ -f "${i}/libcopy.sh" ]; then
			FOUND=1
			printf "Running libcopy.sh to copy libmaxminddb.so to glftpd's lib dir...\n"
			"${i}/libcopy.sh" | grep "libmaxminddb.*OK" || \
				printf "FAILED:\nRun libcopy.sh manually"
			break
		fi
	done
	if [ "$FOUND" -eq 0 ]; then
		echo "\nNOTICE: Run glftpd's libcopy.sh to copy libmaxminddb.so to lib dir\n"
	fi
	if [ -f "$GLCONF" ]; then
		printf "Checking glftpd.conf for pre_fxp_check... "
		grep -qi "pre_fxp_check.*$(basename $0)" "$GLCONF" && echo "OK" || { \
			printf "FAILED:\nSet GLCONF variable in %s correctly and retry or\n" "$(basename $0)"
			printf "Add \"pre_fxp_check /bin/%s *\" to glftpd.conf manually\n" "$(basename $0)"
		}
	fi
	printf "Done.\n"
	exit
fi

# $1 = Direction of FXP "from" or "to"
# $2 = IPv4
# $3 = Name of the file
# $4 = Actual path the file is stored in
#
# EXIT codes..
# 0 - Good
# 2 - Bad
# 1 - Ugly :-)

ARGS="$*"
func_log () {
	if [ "$1" = "$LOG" ] || [ "$LOG" = "all" ]; then
		if [ -w "$LOGFILE" ]; then
			if [ "$LOGONCE" -eq 1 ]; then
				if ! grep -q "$(awk -v a="$ARGS" 'BEGIN{$0=a;print $1,$2,".*",$4}') $1 $2" "${LOGFILE}.tmp"; then
					echo "$(date +%F\ %T) $ARGS $1 $2" >> "$LOGFILE"
				fi
				echo "$ARGS $1 $2" > "${LOGFILE}.tmp"
			else
				echo "$(date +%F\ %T) $ARGS $1 $2" >> "$LOGFILE"
			fi
		fi
	fi
}

if [ -f "$4/$3" ]; then
	if [ ! -z "$DENY_IP" ]; then
		for i in $DENY_IP; do
			if [ "$i" = "$2" ]; then
				func_log deny IP
				exit 2;
			fi
		done
	fi
        CC="$( /bin/mmdblookup --file "$MMDB" --ip "$2" country iso_code | awk -F\" '{ printf $2 }' )"
	if [ ! -z "$CC" ]; then
		if [ ! -z "$ALLOW_CC" ]; then
			for i in $ALLOW_CC; do
				if [ "$i" = "$CC" ]; then
					func_log allow $CC
					exit 0
				fi
			done
		fi
		if [ ! -z "$DENY_CC" ]; then
			if [ "$DENY_CC" = "all" ]; then
				func_log deny CC_ALL
				exit 2
			else
				for i in $DENY_CC; do
					if [ "$i" = "$CC" ]; then
						func_log deny $CC
						exit 2
					fi
			done
			fi
		fi
	func_log log $CC
	fi
fi
# vim: set noai tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab:
