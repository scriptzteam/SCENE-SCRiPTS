#!/bin/bash -x
# Nuke releases that are not completed within 20 minutes.
# Warn releases that are not completed within 10 minutes.
WAGE=10
NAGE=20

SECTIONS=$(</etc/gensite/SECTIONS)
cd /site/incoming &>/dev/null || exit 2
ls -lad ${SECTIONS} &>/dev/null || exit 2
test -x /bin/nuker || exit 2
test -w /ftp-data/logs/glftpd.log || exit 2

WRELEASES=$(find ${SECTIONS} -maxdepth 1 -mindepth 1 -type d -mmin ${WAGE} -not -name \*COMPLETE\*)
NRELEASES=$(find ${SECTIONS} -maxdepth 1 -mindepth 1 -type d -mmin +${NAGE} -not -name \*COMPLETE\*)

#debg
WRELEASES=NRELEASES

if [ ! -z "$WRELEASES" ]; then
    for RELEASE in ${WRELEASES}; do
        true;
        echo "$(date "+%a %b %e %T %Y") ANUKEINC: \"${RELEASE}\" \"${WAGE}min\" \"${NAGE}min\"" >> /ftp-data/logs/glftpd.log
    done
fi
if [ ! -z "${NRELEASES}" ]; then
        for RELEASE in ${NRELEASES}; do
        true;
        echo /glftpd/bin/nuker -N nuker -n "/site/incoming/${RELEASE}" 5 incomplete &>/dev/null
        sleep 1
        echo /usr/sbin/chroot /home/jail/glftpd /bin/cleanup >/dev/null 2>&1
        done
fi