# incomplete-list.sh replacement for project-zs (included in the sitewho.tgz package available on dark0n3's website)<br>You can reach the new Guest section at the bottom, or by click the Scripts by guests button above.
# sitewho.tgz package available on dark0n3's website)
#
# some people complained about nested INCOMPLETES not reporting
# properly -- this is my own solution to the problem -- t0xic

#!/bin/bash

sections="/glftpd/site/iSO.GAMES /glftpd/site/iSO.APPS"
identifier="INCOMPLETE"

echo

for section in $sections; do

	counter=10
	sec=
	while [ $counter -le 10 ] && [ -z $sec ]; do

        	sec=`echo $section | cut -d/ -f$counter`
		let counter=counter-1
	done

	echo "[$sec] incomplete list:"

	incomplete=`ls -R $section | grep $identifier`
        for inc in $incomplete; do

                echo $inc

        done

	echo

done

