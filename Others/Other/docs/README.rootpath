This is a small Tutorial on how to set glftpd to use root_path /. You may
want to do this in order to be able to access directories in several
different mountpoints, like /home and /glftpd/site.

1. Change all instances of /site to /glftpd/site in your config file

2. Add the pwd_path and grp_path settings to the config file:
pwd_path /glftpd/etc/passwd
grp_path /glftpd/etc/group

3. Change datapath from /ftp-data to /glftpd/ftp-data

4. Edit /glftpd/etc/passwd and change every user's homedir from /site to
/glftpd/site.

5. Edit /glftpd/ftp-data/users/default.* and change the HOMEDIR line from /site
to /glftpd/site.

6. You also need to change paths in some help files in /glftpd/ftp-data/help,
possibly some more in /glftpd/ftp-data/text.


* The stuff below is for I don't know what - you certainly don't need it, but it can't hurt. *

Make a user, lets say root
site adduser root root *@127.0.0.1
site grpadd wheel root group (or root, depending on the OS you are running)

Now go edit /glftpd/etc/passwd, you will see that glftpd has the 0:0 uid and gid
just give it 10:100 or 20:200 and give root 0:0, also change root's homedir -
default is /site, change it to /.

Now edit the group file and move the number of glftpd to 100 or 200 and change roots to 0.

Now login and try it and you should see the full root path.
