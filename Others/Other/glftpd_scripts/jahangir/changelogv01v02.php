<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"><html><head><title>-= Changelog v0.1-v0.2 for ftp2mysql scriptpack =-</title><style type="text/css"><!--A:link { color: blue; text-decoration : none; }A:visited { color: gray; text-decoration : none; }A:active { color: black; text-decoration : none; }--> </style></head><body bgcolor="#ffffcc"><h3><tt>Changelog + Bugfixes v0.1-v0.2 (2003-01-14)</tt></h3><table border="0" cellspacing="3" cellpadding="3" width="90%" align="left">
<tr><td width="5%" valign="top"><tt>.o.</td><td><tt>
  one script directory for all files relating to the script
  in /glftpd/bin/ (default: ftp2mysql)
	</td></tr>
	<tr><td valign="top"><tt>.o.</td><td><tt>
	added install.sh script for easy installing script and 
	database...try!
	</td></tr>
	<tr><td valign="top"><tt>.o.</td><td><tt>
	added shellnukerel.sh to nuke releases directly from shell
  instead of nuking from bot or from php-page.
	</td></tr>
<tr><td valign="top"><tt>.o.</td><td><tt>
  deleted txt2mysql.sh and instead wrote a c-program
  (txt2mysql) to insert the releases directly into the
  MYSQL database (instead of storing the release-
  information to a txt-file for further adding it per cron).
	</td></tr>
<tr><td valign="top"><tt>.o.</td><td><tt>
  script ftp2txt.sh renamed to ftp2mysql.sh and modified
  to launch the new c-program add2mysql
	</td></tr>
<tr><td valign="top"><tt>.o.</td><td><tt>
  added script rmrel.sh to delete releases from all your
  releases-txt files and the MYSQL-database and add it to 
	deleted.txt.
	</td></tr>
<tr><td valign="top"><tt>.o.</td><td><tt>
	one directory to store all txt-files
	</td></tr>
<tr><td valign="top"><tt>.o.</td><td><tt>
	logfiles in scriptpath/log/ for script and errors (not yet ready)
	</td></tr>
<tr><td valign="top"><tt>.o.</td><td><tt>
	written one config file 'inc.conf' with all variables for
  ftp2mysql.sh, old-insert.sh, rmrel.sh, db.sh,shellnukerel.sh and eggdropnuke.sh
  and renamed some variables.
	</td></tr>
<tr><td valign="top"><tt>.o.</td><td><tt>
	remade architecture of the php-page and cleaned up the
  source.
  Now one config-file conf.inc.php.
	</td></tr>
<tr><td valign="top"><tt>.o.</td><td><tt>
 added tablefield '#' to php-output which contains the
  number of the release in the output-list.
 </td></tr>
 <tr><td valign="top"><tt>.o.</td><td><tt>
 enhanced db.sh (now works with mysql and has more usefull functions,
  so to say the php-functions for the eggdrop)
  - the botscripts have now a list of channels in which they can
    only be executed by !triggers
 </td></tr>
 <tr><td valign="top"><tt>.o.</td><td><tt>
  written a little backup-script to backup txt-files, log-files and 
  the content of the MYSQL-database
 </td></tr>
 
 <tr><td>&nbsp;</td></tr>
<tr><td valign="top"><tt>.o.</td><td><tt>
  fixed bug with "+" as delimiter in _script_ftp2txt.sh
  (old txt2mysql.sh) and _bot_/db.sh
  changed "+" to "=" because of genres like Funk+Jazz.
	</td></tr>
<tr><td valign="top"><tt>.o.</td><td><tt>
  fixed Bug in old-insert.sh so that now releases with
  "-" in the artistname in the .message are inserted correctly
  into MYSQL.
	</td></tr>
</table>