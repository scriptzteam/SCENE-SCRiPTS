#!/bin/bash
# Hourly freespace script v1.1.1 by Jehsom
# Run from crontab each hour as root.
# Removes the oldest releases expanded from $RELS until there is enough free
# space. Does not remove files, only directories. Removes parent directory of
# $RELS items after they are deleted, if parent dir is empty of non-dotfiles.

RELS="/foo/data/1/*"  # Wildcard expanding to all the releases on your site.
MINMB="3000"  # Make sure this many MB are free every hour.
VOL="/dev/hda9"  # Volume name that your incoming dirs sit on.

### NO SETTINGS BELOW ###

allow_null_glob_expansion=1
shopt -s nullglob 2>/dev/null

df | grep "^$VOL " > /dev/null || {
    echo "Could not get free space for volume $VOL"
    exit 1
}

df -m | grep "^$VOL " | {
    read vol size rest;
    [ "$size" -lt "$MINMB" ] && {
        echo "Size of volume $VOL is less than requested freespace"
        exit 1
    }
    exit 0
} || exit 1

[ -z "$(echo $RELS)" ] && {
    echo "The wildcard $RELS did not expand."
    exit 1
}

/glftpd/bin/mtime $RELS 2>/dev/null | sort -n | {
    while read mtime name; do
        df -m | grep "^$VOL " | {
            read vol size used avail percent mount;
            if [ "$avail" -lt "$MINMB" ]; then
                exit 1
            else
                exit 0
            fi
        }
        if [ "$?" = "0" ]; then
            break
        elif [ -d "$name" -a ! -L "$name" ]; then
            rm -vrf "$name"
            [ -z "$(echo ${name%/*}/*)" ] && rm -vrf "${name%/*}"
        fi
    done
}
exit 0


