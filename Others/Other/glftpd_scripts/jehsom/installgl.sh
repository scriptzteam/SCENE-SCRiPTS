#!/bin/sh
# jehsom's glftpd installer script
  VERSION="1.06"

# CHANGELOG
#
# v1.06 - maestro^
# new:    permissions set on ftp-data/users
# change: glftpd.conf now moved to glftpd.conf.dist after install
# fix:    not properly reinstalling on top of itself from the glroot dir
# fix:    some error messages werent printing properly

# Run the script with bash
[ "$foundbash" != "1" ] && {
    export foundbash="1"
    exec bash -x "$0" "$@" 2>./installgl.debug
}

# Be sure we're root
[ "$UID" = "0" ] || {
    echo "You must be root."
    exit 1
}

# Make sure we're in the right place
cd "$(dirname $0)"
[ -f "bin/glftpd" ] || {
    echo "Please run $(basename $0) from the glftpd installation dir."
    exit 1
}

# Set system type
case $(uname -s) in
    Linux)
        os=linux
        ;;
    *[bB][sS][dD]*)
        os=bsd
        ;;
    *)
        echo "Sorry, but this installer does not support the $(uname -s) platform."
        echo "You will have to install glftpd manually."
        exit 1
        ;;
esac

# Important bins to have in the glftpd bin dir
BINS="sh cat grep unzip wc find ldconfig ls bash mkdir rmdir rm mv cp \
ln basename dirname head tail grep cut tr wc sed date sleep touch gzip zip"

# Ensure we have all useful paths in our $PATH
PATH="$PATH:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:\
/usr/libexec:/usr/compat/linux/bin:/usr/compat/linux/sbin:/usr/compat/linux/usr/bin:\
/usr/compat/linux/usr/sbin"

echo "Welcome to jehsom's glFtpD installer, version $VERSION"

# Get a valid installation path
until [ -n "$glroot" -a "$glroot" != "/" ]; do
    echo -n "Please enter the directory to install glftpd to [/glftpd]: "
    read glroot
    [ -z "$glroot" ] && glroot="/glftpd"
    [ "$glroot" = "/" ] && {
        echo
        echo "Installing glftpd to / is not supported. You will have"
        echo "to install manually if you wish to do this. Aborting."
        exit 1
    }
    [ -d "$glroot" ] && {
        echo -n "Path already exists. [D]elete it, [A]bort, [T]ry again, [I]gnore? "
        read reply
        case $reply in
            [dD]*) rm -rf "$glroot" ;;
            [tT]*) glroot="./"; continue ;;
            [iI]*) ;;
            *) echo "Aborting."; exit 1 ;;
        esac
    }
    mkdir -p "$glroot" || unset glroot
done

echo
echo -ne "\nCopying glftpd files to $glroot . . . "
cp -Rf * .[^.]* "$glroot"
echo "Done."

echo -ne "Copying glftpd.conf to /etc . . . "
[ -f /etc/glftpd.conf ] && cp -v /etc/glftpd.conf /etc/glftpd.conf.bak
if [ -f glftpd.conf ]; then
    sed "s:^\([ 	]*rootpath[ 	]*\).*$:\1$glroot:" glftpd.conf > /etc/glftpd.conf
    mv glftpd.conf glftpd.conf.dist
    echo "Done."
elif [ -f glftpd.conf.dist ]; then
    sed "s:^\([ 	]*rootpath[ 	]*\).*$:\1$glroot:" glftpd.conf.dist > /etc/glftpd.conf
else
    echo "FAILED! You must find your conf and copy it to /etc manually."
fi

echo -e "\nCopying required binaries to $glroot/bin:"
for bin in $BINS; do
    echo -n "   $bin: "
    type $bin > /dev/null || {
        echo "FAILED! You must find & copy $bin manually."
        continue
    }
    cp -f "$(which $bin)" "$glroot/bin"
    echo "OK"
done

echo -ne "\nMaking glftpd's /dev/null & /dev/zero . . . "
case $os in
    linux)
        mknod -m666 "$glroot/dev/null" c 1 3
        mknod -m666 "$glroot/dev/zero" c 1 5
        ;;
    bsd)
        mknod "$glroot/dev/null" c 2 2
        mknod "$glroot/dev/zero" c 2 12
        chmod 666 "$glroot/dev/*"
        ;;
esac
echo "Done."

for cfile in $glroot/bin/sources/*.c; do
    base="$(basename "${cfile%.c}")"
    [ -f "$glroot/bin/$base" ] && rm -f "$glroot/bin/$base"
    echo -n "Compiling $cfile to $glroot/bin/$base . . . "
    gcc -o "$glroot/bin/$base" "$cfile" > /dev/null 2>&1 &&
        echo 'Success' || echo -e '\033[1;31mFailed!\033[0m'
done


echo -e "\nCopying required shared library files:"
ldd "$glroot"/bin/* | grep "=>" | sed 's:^.* => \(/[^ ]*\).*$:\1:' | 
sort | uniq | while read lib; do
    echo -n "   $(basename $lib): "
    if [ -f "$lib" ]; then
        cp -f "$lib" "$glroot/lib"
        echo "OK"
    elif [ -f "/usr/compat/linux/$lib" ]; then
        cp -f "/usr/compat/linux/$lib" "$glroot/lib"
        echo "OK"
    else
        echo -e '\033[1;31mFailed!\033[0m'" You must find & copy $(basename $lib) to $glroot/lib manually."
    fi
done

case $os in bsd)
    echo -ne "\nCopying ELF interpreter and linux libraries . . . "
    mkdir -p "$glroot/usr/libexec"
    cp -f /usr/libexec/ld-elf.so.1 "$glroot/usr/libexec"
    cp -f /usr/compat/linux/lib/ld-linux.so.1 "$glroot/lib"
    echo "Done." ;;
esac

echo -ne "\nConfiguring the shared library cache . . . "
case $os in
    linux)
        echo "/lib" > "$glroot/etc/ld.so.conf"
        chroot "$glroot" /bin/ldconfig
        ;;
    bsd)
        mkdir -p "$glroot/usr/lib"
        mkdir -p "$glroot/var/run"
        chroot "$glroot" /bin/ldconfig -elf /lib
        chroot "$glroot" /bin/ldconfig -aout /lib
        chroot "$glroot" /bin/ldconfig
        echo "/lib" > "$glroot/etc/ld.so.conf"
        /usr/compat/linux/sbin/ldconfig -r "$glroot"
        ;;
esac
echo "Done."

until echo "$port" | grep -E "^[0-9]+$" > /dev/null && [ "$port" -lt 65535 ]; do
    echo -en "\nEnter the port you woud like glftpd to listen on [21]: "
    read port
    [ -z "$port" ] && port=21
done

echo -ne "Setting permissions . . . "
chmod 755 "$glroot/ftp-data/users"
chmod 644 "$glroot/ftp-data/users/*"
echo "Done."


echo -n "Adding glftpd service to /etc/services . . . "

{ grep -v ^glftpd /etc/services;
  echo "glftpd   $port/tcp"
} > /etc/services.new
mv -f /etc/services.new /etc/services
echo "Done."

# Find tcpd
tcpd="$(which tcpd | grep "^/")"

# Configure inetd or xinetd as appropriate
if [ -f /etc/inetd.conf ]; then
    echo -en "\nConfiguring inetd for glftpd . . . "
    { grep -v ^glftpd /etc/inetd.conf
      echo "glftpd stream tcp nowait root $tcpd $glroot/bin/glftpd -l -o -i -n 1 -r /etc/glftpd.conf"
    } > /etc/inetd.conf.new
    mv -f /etc/inetd.conf.new /etc/inetd.conf
    echo "Done."
    echo -en "\nRestarting inetd . . . "
    if killall -HUP inetd; then
        echo "Success."
    else
        echo -e '\033[1;31mFailed!\033[0m You must start inetd before using glftpd.'
    fi
elif [ -d /etc/xinetd.d ]; then
    echo -en "\nConfiguring xinetd for glftpd . . . "
    cat <<EOF > /etc/xinetd.d/glftpd
service glftpd
{
    disable = no
    flags           = REUSE NAMEINARGS
    socket_type     = stream
    protocol        = tcp
    wait            = no
    user            = root
    server          = ${tcpd:-$glroot/bin/glftpd}
    server_args     = ${tcpd:+$glroot/bin/glftpd} -l -i -o -n 1 -r /etc/glftpd.conf
}
EOF
    echo "Done."
    echo -en "\nRestarting xinetd . . . "
    if killall -USR1 xinetd; then
        echo "Success."
    else
        echo -e '\033[1;31mFailed!\033[0m You must start xinetd before using glftpd.'
    fi
else
    echo -e "\nWARNING: Could not determine what version of inetd you are using."
    echo "You must configure inetd to handle incoming connections to glftpd."
    echo "Read the glftpd.docs for instructions on how to do this."
fi

echo -ne "\nAdding crontab entry to tabulate site stats nightly . . . "
{ crontab -l
  echo "0 0 * * *    $glroot/bin/reset -r /etc/glftpd.conf"
} | crontab - > /dev/null
echo "Done."
echo
echo "Congratulations, glFtpD has been installed. Scroll up and note any errors"
echo "  that need fixing. A log of the installation script is in ./installgl.debug"
echo "To get your site running, you must edit /etc/glftpd.conf according to the"
echo "  instructions in $glroot/glftpd.docs. For help, visit #glftpd on EFnet."
echo "After configuring glftpd, visit my scripts page at http://scripts.jehsom.com"
echo "  and the glftpd pages at http://www.glftpd.com and http://www.glftpd.org,"
echo "  and pick up some scripts to give your site some style!"
echo
echo "                                 Thanks for your support!"
echo "                                 jehsom and the glFtpD team"
echo
exit 0
