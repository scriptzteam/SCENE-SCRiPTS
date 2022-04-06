#!/usr/bin/perl
#
##########################################################
# Script name: Autoclean 0.11 (for linux)
# Author: [Jedi] (jedi_il@hotmail.com)
# Description:
# This script is for SiTe machines with stuff to clean, it allows u to delete from specified 
# section, and only them so u wont accidently del something else on /site dir
# it allows u to add as many haddrives as u want, in case u got several sections on several
# drives. like most auto cleaners this one got minimum free space per disk.
# PLUS -> it got a nice feature where u can disable delete of specific dirs within the search 
# zone, staticly here in the config file, AND dynamicly from site command in glftpd :)
# yup, check out the neverdel.sh script for this neat function!
# Copyright: This program is under the The GNU General Public License (aka GNU GPL)
# URL: http://jedi.says.no/
#
# Installation notes: 
# chmod 755 autoclean.pl
# put it in crontab as root (crontab -e) for example (this checks every 30 mins):
# 0,30 * * * * /glftpd/bin/autoclean.pl -q
#
# Enjoy :)
###########################################################
$VER=0.11;
#
# Configure:
##########################################################
$PREFIX="/glftpd/site";		# location of site dir. e.x: /glftpd/site/incoming
$minfs=3000;			# minimum space in megabytes per drive
$nvdelfile="/glftpd/ftp-data/logs/nvdel.log";	# neverdel file (see neverdel.sh)
$autolog="/glftpd/ftp-data/logs/autoclean.log";	# autoclean log file
## Set the drives using the pattarn:
### $drive{'/dev/as-shown-in.df'}="DIR_INSIDE_PREFIX/* MUST_BE_IN_THIS_DRIVE_PHYSICALLY/*";
#########################################################################
#### Examples:
$drive{'/dev/hda1'}="GAMES/* CONSOLE/DC/* CONSOLE/GBA/* CONSOLE/PS1/* CONSOLE/PS2/* UTILS/*";
$drive{'/dev/hdb1'}="0DAY/_Archive*";
$drive{'/dev/sdc5'}="DIVX/*";
$drive{'/dev/sdd1'}="0DAY/* MP3/* XXX/*";
$drive{'/dev/sdd2'}="VCD/* SVCD/* TV-RIPS/ENTERPRISE/* TV-RIPS/DARKANGEL/*";

## a static neverdel list, examples
@NEVERDEL=('My_Audio','MP3/_Archive','DIVX/_my_movies');

########################################################################
### Dont edit below, unless u know what u'r doing
#######################

# Open a neverdel file

if (-e $nvdelfile) {
	open(FILE,"<$nvdelfile") or die $!;
	@TA=<FILE>;
	close(FILE);
}

if ($ARGC[0] eq '-q') {
        open($O,">>$autolog") or die $! ;
} else {
        $O=STDOUT;
}


chdir $PREFIX;
@df=`df -m`;
print $O "---> Autoclean V$VER by [Jedi] <-------> $date <-----------------------\n";

foreach $drv (keys %drive) {
	foreach $l (@df) {
		@fr=split(' ',$l);
		if ((uc $fr[0]) eq (uc $drv)) {
			$fsp=$fr[3];
			last;
		}
	}
	
	print $O "Drive $drv ($fsp) ";
	if ($fsp < $minfs) {
		@dirdb=`ls -Atrd1 $drive{$drv}`; 	# The oldest dirs...
		$mb_free=$minfs - $fsp;	 		# I need $mb_free space
		$tot_mb=0; $i=0; @delthis;
		while (( $tot_mb < $mb_free) && ($i <= $#dirdb) ) {
			$cdir=$dirdb[$i++];
			chomp($cdir);
			$dontadd=0;
			foreach $d (@NEVERDEL) {
				if ($d eq $cdir) { $dontadd=1; last; }
			}
			if ($dontadd==0) {
				$tmpb=`du -ms "$cdir"`;
				($tmb,$k)=split(' ',$tmpb);
				# check for integer
				$tot_mb += int($tmb);
				push @delthis,"\"$cdir\"";
			}
		}  
		
		print $O "--> $tot_mb / $mb_free ";
	}
	print $O "\n";
}
$date=localtime();
if ($#delthis>=0) {
	system("rm -rf @delthis");
	print $O "\n------------------------------------- Deleted directories ------------------------\n";
	print $O "rm -rf @delthis\n";  
	print $O "-----------------------------------------------------------------------------E O F----\n";
} else {
	print $O "\nAll drives free ----------------------------\n";
}

if ($ARGC[0] eq '-q') { 
        close $O;
}

