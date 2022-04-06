#!/bin/bash

# --------------------------------------------------------------------------- #
# sorted-links-by-artist.sh (v0.1)                                 2002-09-18 #
#                                                                             #
# NOTE: this script is to be used mainly with glFTPd (http://www.glftpd.com/) #
#                                                                             #
# DESCRIPTION: it scans all daydirs under a dir of your choice and creates    #
#              symlinks to the releases found in them, based on the artist    #
#              name. it is able to distinguish Various Artists ("VA") rels    #
#              and put them under VA/ instead of V/.                          #
#                                                                             #
# AUTHOR: flib0 (flibo@hack.gr)                                               #
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# YOU MAY NEED TO MODIFY SOME OF THE VARIABLES LISTED BELOW                   #
# THE ONES THAT ARE REALLY IMPORTANT ARE MARKED AS SUCH.                      #
# --------------------------------------------------------------------------- #

# ----------------------------------------------------------- ** IMPORTANT ** #
# change this to the path you have glFTPd installed at.                       #
# --------------------------------------------------------------------------- #

FTPROOT="/glftpd"

# ----------------------------------------------------------- ** IMPORTANT ** #
# change this to the dir containing your mp3 daydirs.                         #
# --------------------------------------------------------------------------- #

SOURCE="/site/incoming/mp3"

# ----------------------------------------------------------- ** IMPORTANT ** #
# change this to the path you want the links to be at.                        #
# --------------------------------------------------------------------------- #

DEST="/site/incoming/_sorted/mp3.by.artist"

# --------------------------------------------------------------------------- #
# when the links are updated, we inform the user by creating a dir-message.   #
# upon script completion, this notification dir is deleted, and we create one #
# new message-dir containing date and time of last update.                    #
# --------------------------------------------------------------------------- #
 
WRN_MSG="_DIR.CONTENTS.CURRENTLY.BEING.UPDATED.PLEASE.WAIT"
UPD_MSG="_LAST.UPDATED."

# ----------------------------------------------------------- ** IMPORTANT ** #
# directory and file names that will be excluded in listings.                 #
# --------------------------------------------------------------------------- #

SKIP="(incomplete)|other-notes.txt|${WRN_MSG}|${UPD_MSG}"

# --------------------------------------------------------------------------- #
# this is the location of a message informing about the frequency of updates. #
# --------------------------------------------------------------------------- #

NFO_MSG="/glftpd/ftp-data/misc/sorted-by-group-dir-notes.txt"

# --------------------------------------------------------------------------- #
# make a fresh start by removing everything under the destination dir.        #
# --------------------------------------------------------------------------- #

rm -rf "${FTPROOT}${DEST}"/*

# --------------------------------------------------------------------------- #
# create the warning message.                                                 #
# --------------------------------------------------------------------------- #

mkdir "${FTPROOT}${DEST}/${WRN_MSG}"

# --------------------------------------------------------------------------- #
# change to the directory containing the mp3 daydirs.                         #
# --------------------------------------------------------------------------- #

cd "${FTPROOT}${SOURCE}"

# --------------------------------------------------------------------------- #
# get the list of daydirs.                                                    #
# --------------------------------------------------------------------------- #

DAYS="$( ls | egrep -vi ${SKIP} )"

# --------------------------------------------------------------------------- #
# start working on each daydir found above.                                   #
# --------------------------------------------------------------------------- #

for DAY in ${DAYS} ;
do
	cd "${FTPROOT}${SOURCE}/${DAY}"

# --------------------------------------------------------------------------- #
# start working on each release found in the current daydir examined.         #
# --------------------------------------------------------------------------- #

	for DIR in `ls -f -A | egrep -vi ${SKIP}` ;
	do

# --------------------------------------------------------------------------- #
# make sure ${DIR} is a proper release, by looking for at least one hyphen.   #
# --------------------------------------------------------------------------- #

		PROPER="$( echo ${DIR} | grep -- "-" )"

		if [ "${PROPER}" != "" ] ;
		then

# --------------------------------------------------------------------------- #
# get the first letter of the release name and uppercase it. this way, we     #
# place "dEUS" and "Depeche Mode" artist links under /D/                      #
# --------------------------------------------------------------------------- #

			FIRST_LETTER="$( echo ${DIR} | cut -b 1 | tr a-z A-Z )"

# --------------------------------------------------------------------------- #
# this is for Various Artists ("VA-") releases. since there are a lot of them #
# these days, we don't want to put them all under /V/ along with the artists  #
# whose name starts with "V". so, we detect those releases and create links   #
# for them under a separate folder, /VA/                                      #
# --------------------------------------------------------------------------- # 

			if [ "${FIRST_LETTER}" == "V" ] ;
			then
				VA_CHECK="$( echo ${DIR} | cut -b 1-3 | tr a-z A-Z )"

				if [ "${VA_CHECK}" == "VA-" ] ;
				then
					ARTIST="VA"
				else
					ARTIST=${FIRST_LETTER}
				fi
			else
				ARTIST=${FIRST_LETTER}
			fi

# --------------------------------------------------------------------------- #
# Create letter folder if it doesn't exist.                                   #
# --------------------------------------------------------------------------- #

			if [ -e "${FTPROOT}${DEST}/${ARTIST}" ] ;
			then
				ARTIST_DIR=1
			else
				mkdir -m755 "${FTPROOT}${DEST}/${ARTIST}"
			fi

# --------------------------------------------------------------------------- #
# Create the symlinks.                                                        #
# --------------------------------------------------------------------------- #

			ln -s "${SOURCE}/${DAY}/${DIR}" "${FTPROOT}${DEST}/${ARTIST}/${DIR}" >/dev/null 2>&1
		fi

	done
done

ARTISTS="$( ls "${FTPROOT}${DEST}" | egrep -v ${SKIP} )"

for ARTIST in ${ARTISTS} ;
do

# --------------------------------------------------------------------------- #
# these lines are responsible for getting the release count for each letter,  #
# and then create the first part of the new summary/header dir accordingly.   #
# the total size of all the releases under each letter dir is also calculated #
# and this is reflected in the second part of the header dir, formed below.   #
# --------------------------------------------------------------------------- #

        REL_COUNT=`ls -1 "${FTPROOT}${DEST}/${ARTIST}" | wc -l | xargs`

	if [ "${REL_COUNT}" == "1" ] ;
	then
		HEADER_PART_A=".(..1.RELEASE."
	else
		HEADER_PART_A=".(..${REL_COUNT}.RELEASES."
	fi

	TOT_SIZE=0

	for TARGET in `ls -l "${FTPROOT}${DEST}/${ARTIST}" | grep -v "total " | cut -b 57- | awk -F' ' '{ print $3 }'` ;
	do
		TEMP="$( echo ${TARGET} | sed 's/\// /g' )"

		for FIELD in ${TEMP} ;
		do
			SRC="${FIELD}"
		done

		if [ -e "${FTPROOT}${TARGET}" ] ;
		then
			DIR_SIZE=`ls -l --block-size=1 ${FTPROOT}${TARGET} | grep "total " | awk -F' ' '{ print $2 }'`
			(( TOT_SIZE=${TOT_SIZE}+${DIR_SIZE} ))
		else
			rm "${FTPROOT}${DEST}/${ARTIST}/${SRC}"
		fi
	done

# --------------------------------------------------------------------------- #
# this part deletes the artist letter if there were no releases found for it, #
# otherwise it forms the 2nd part of the new header dir, and then mkdirs it.  #
# it also checks for existance of an old header dir, which will be deleted.   #
# --------------------------------------------------------------------------- #

	if [ ${TOT_SIZE} != 0 ] ;
	then
		TOT_SIZE_MB=$(( ${TOT_SIZE}/1048576 ))

		HEADER_PART_B="@.${TOT_SIZE_MB}.MBytes..)."

		OLD_HEADER=`ls -a1 "${FTPROOT}${DEST}/${ARTIST}/" | egrep "RELEASE|MBytes"`

		NEW_HEADER="${HEADER_PART_A}${HEADER_PART_B}"

		if [ "${OLD_HEADER}" == "" ] ;
		then
			mkdir -m755 "${FTPROOT}${DEST}/${ARTIST}/${NEW_HEADER}"
		else
			rmdir "${FTPROOT}${DEST}/${ARTIST}/${OLD_HEADER}"
			mkdir -m755 "${FTPROOT}${DEST}/${ARTIST}/${NEW_HEADER}"
		fi
	else
		rm -rf "${FTPROOT}${DEST}/${ARTIST}/"
	fi
done

# --------------------------------------------------------------------------- #
# see if the warning message still exists; if it does, delete it              #
# --------------------------------------------------------------------------- #

if [ -e "${FTPROOT}${DEST}/${WRN_MSG}" ] ;
then
	rmdir "${FTPROOT}${DEST}/${WRN_MSG}"
fi

# --------------------------------------------------------------------------- #
# if a "_LAST.UPDATED" message exists, delete it and create a new one         #
# --------------------------------------------------------------------------- #

NEW_UPD=`date "+%b %d @ %H:%M" | sed 's/ /./g' | tr a-z A-Z`

OLD_UPD=`ls -a1 ${FTPROOT}${DEST}/ | grep ${UPD_MSG}`

if [ "${OLD_UPD}" == "" ] ;
then
	mkdir "${FTPROOT}${DEST}/${UPD_MSG}${NEW_UPD}"
else
	rmdir "${FTPROOT}${DEST}/${OLD_UPD}"
	mkdir "${FTPROOT}${DEST}/${UPD_MSG}${NEW_UPD}"
fi

# --------------------------------------------------------------------------- #
# since all the contents of the sorted directory are deleted on start-up, we  #
# have to cp the message informing about the frequency of updates each time.  #
# --------------------------------------------------------------------------- #

cp -p "${NFO_MSG}" "${FTPROOT}${DEST}/sorted-notes.txt"

# --------------------------------------------------------------------------- #
# END OF SCRIPT                                                               #
# --------------------------------------------------------------------------- #
