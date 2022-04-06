#!/usr/bin/perl
##########################################################
# Script name: raidenftpd to glftpd convertor 0.03 beta
# Author: [Jedi] (jedi_il@hotmail.com)
# Description:
# This prog will save u a lot of time ! it was made for site owners who wish to move from
# windows (raiden) to linux (glftpd), read carefully the variables, and set them up carefully.
# i recommend to try it on some temp dir, and if u'r newbie u shuoldnt be using this..
# Copyright: This program is under the The GNU General Public License (aka GNU GPL)
# URL: http://jedi.says.no/
# Enjoy :)
###########################################################

use POSIX qw(strftime);

# variables u gotta set, read what they do on the right:
############################################################################
$gldata = '/glftpd/ftp-data/users';	# user dir location, or wherever u wanna make the output
$glpass = '/glftpd/etc/passwd';		# passwd file, or wherever u wanna make the output
$glgrp = '/glftpd/etc/group';		# group file, or the group output...
$me = 'glftpd';		# who added the users
$defpass = 'tlrrulez';	# default password for unset password (used alot)
#$defpass = 6;		# set it to a number, to create a random password, $defpass is the length of it
$passout = 'plain.txt';	# plain user:pass output goes to $passout, comment this line to cancel output
$idletime = 300;	# max idle time in seconds
$sections = 6;		# this is important so listen up:
			# this set the number of sections u got, defined in /etc/glftpd.conf
			# if u got 6 sections + default u type 6 here;
$uid = 110;		# uid zero point, each user will get an increased +1 uid;
$gid = 200;		# gid zero point, each group will get an increased +100 gid;
$site = '/site';	# Users homedir, u dont really need to change it...

############################################################################
#### Dont edit blow.... unless, of course, u know what u'r doing :)
############################################################################

@arr=('a'..'z','A'..'Z');
$salt=$arr[int(rand 50)+1].$arr[int(rand 25)+1];

print qq~
 ,----------------------------------------------------------.
|  Welcome to RaidenFTP->Glftpd convertor aka raid2gl.....   |
|        v0.03 beta by [Jedi] - jedi_il\@hotmail.com          |
 `----------------------------------------------------------'

Make sure to edit this file's variables...
You should also backup your passwd file and users dir...
-----> Step I: Collecting info <-----
Enter userfile (file.user): ~;
$userfile=<STDIN>; chomp $userfile;
print "Enter allowfile (file.allow): ";
$allowfile=<STDIN>; chomp $allowfile;
if (!(-f $userfile) || !(-f $allowfile)) { die "File(s) doesnt exist... run this again and make sure
your files exist."; }
print "-----> Step II: Processing files <-----";

# Declaring variables
$f_passwd; $f_group;
$z; $m; $ze;

for ($i=0;$i<$sections;$i++) { $z.=" 0 0 0"; $m.=" -1"; $ze.=" 0"; }
$now=localtime();
$date = strftime "%m-%d-%y", localtime;

open (ALLOWFILE,"<$allowfile");
@ipdb=<ALLOWFILE>;
close (ALLOWFILE);

foreach $ip (@ipdb) {
	chomp($ip);
	@i=split('@',$ip);
	$i[1] =~ s/\.\*\.\*\.\*/\.\*/;	# convers x.*.*.* to x.* (and x.x.*.* to x.x.*);
	$i[1] =~ s/\.\*\.\*/\.\*/;
	if (defined $uip{$i[0]}) {
		$uip{$i[0]}.="IP *\@$i[1]\n";	# more than 1 ip
	} else {
		$uip{$i[0]} ="IP *\@$i[1]\n";	# user's *@ip
	}
}

open (USERFILE,"<$userfile");
@userdb=<USERFILE>;
close USERFILE;

 
foreach $uline (@userdb) {
	chomp $uline;
	@u=split(/:/,$uline);
	$username =	$u[0];	# user's name
	$level = 	$u[1];	# 0=root, other=normal
	$passwd = 	$u[2];	# user's pass if there...
	$ugroup = 	$u[3];	# user's grp
	$enabled = 	$u[4];	# is enabled
	$maxdlspeed =	$u[5];	# Max down speed
	$maxulspeed =	$u[6];	# Max up speed
	$ratio =	$u[7];	# ratio-> 1:$ratio 
	$maxlogins =	$u[8];	# Max logins (-1 = unlimited)
	$dis_ipchk =	$u[9];	# Disable ip checking
	$downloaded =	$u[10];	# Downloaded sum
	$uploaded =	$u[11];	# Uploaded sum
	$tagline =	$u[12];	# Comment ( tagline )
	$language = 	$u[13]; # lang.. not needed in gl
	$number =	$u[14];	# unkown number, suspected as a hash
	$credits = 1024*$u[15]; # credits user's earned
	$kickself =	$u[16]; # build in glftpd
	$number2 = 	$u[17];	# unknown number...
	if ($username eq "") { next; }
	$ips = $uip{$username};
	if ($level==0) { $flags = "13"; } else { $flags="3"; }
	@ugroups=split(',',$ugroup);
	$grpline='';
	foreach $group (@ugroups) { 
		if ($group eq 'nukers') { $flags.="AB"; } 
		else { $grpline.="GROUP $group\n"; }
	}

$user_out = qq~USER added by $me
GENERAL 0,0 $idletime $maxdlspeed $maxulspeed
LOGINS $maxlogins 0 -1 -1
TIMEFRAME 0 0
FLAGS $flags
TAGLINE $tagline
DIR /
CREDITS $credits $ze
RATIO $ratio $m
ALLUP 1 $uploaded 1 $z
ALLDN 1 $downloaded 1 $z
WKUP 0 0 0 $z
WKDN 0 0 0 $z
DAYUP 0 0 0 $z
DAYDN 0 0 0 $z
MONTHUP 0 0 0 $z
MONTHDN 0 0 0 $z
NUKE 0 0 0 $z
TIME 1 $now 0 0
SLOTS -1 -1
$grpline
$ips~;
	print "Writing user file ($username)...";
	$filepath="$gldata/$username";
	if (!( -f $filepath )) { 
	  open(UF,">$filepath") or die $!;
	  print UF $user_out;
	  close(UF);
	  print "Done!\n";
	} else { print "Exists, skipping.\n"; }
	foreach $group (@ugroups) {
		chomp $group;
		if (defined $grps{$group}) {	
			$ugid = $grps{$group};	
		} else {
			$ugid=$gid;
			$grps{$group} = $gid;
			$gid+=100;
		}
	}
	# checking password...
	if ($passwd eq "") {
		if ($defpass eq int($defpass)) { #create a random password
			for (1..$defpass) { $passwd.=$arr[int(rand 50)+1];}
		} else { $passwd = $defpass; }
	}
	if (defined $passout) { $f_pout .= "$username:$passwd\n"; }
	$phash = crypt($passwd,$salt);
	$f_passwd .= "$username:$phash:$uid:$ugid:$date:$site:/bin/false\n";
	$uid++;

}

if (defined $passout) {
	print "++ Writing plain password file ($passout)...";
	open(PWDOUT,">$passout");
	print PWDOUT $f_pout;
	close(PWDOUT);
	print "Done!\n";
}

print "-------> Step III: Generating and writing <-------\n";
print "Generating group file...";
foreach $g (keys %grps) {
	
	$ggid = $grps{$g};
	$f_group .= "$g:" . ":$ggid:\n";
}
print qq~Done!
Do u want to write passwd and group files?
Note 1: the files are being appended, not overwritten so it keeps ur current users and groups
Note 2: if u answer N, files will be outputed to screen instead of the actual files.
So, do i write them ? [Y/N]~;

$yesno=<STDIN>; chomp($yesno);
if ($yesno =~ /[Yy]/) {
	print "Writing pass file ($glpass)... ";
	open(PASS,">>$glpass") or die $!;
	print PASS $f_passwd;
	close(PASS);
	print "Done!\n";
	print "Writing group file ($glgrp)... ";
	open (GRP,">>$glgrp");
	print GRP $f_group;
	close(GRP);
	print "Done!\n";
} else {
	print "------------------------- passwd file ------------------------------\n";
	print $f_passwd;
	print "------------------------- E O F ------------------------------------\n\n";
	print "------------------------- group file -------------------------------\n";
	print $f_group;
	print "------------------------- E O F ------------------------------------\n";
}
print "------> Convertion complete <------\n";
print "All done, enjoy ! \n ---> raiden2gl script by [Jedi]\n";
