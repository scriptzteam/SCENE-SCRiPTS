#!/usr/bin/perl
##
## pDayUp.pl
##
## This little script logs dayup to glftpd.log file
## so you can set your bot to output it. Its a good idea to run
## this script everyday round midnight, so that your users can enjoy
## watching stats everyday!
##
## Crontab example:
## 30 23 * * * /glftpd/bin/pdayup.pl
##
## // pnG
############
# Settings #
##################################
## glftpd dir?                  ##
##################################
$gldir = "/glftpd";

##############
## Sections #################################################################### 
##  this should be the number of your section orderd by your glftpd.conf file ##
##  This can be max 3							      ##
################################################################################
$section = "1";

##################
## Section name ##
##################
$sectionname = "default";

##########################[ Thats all, now watch the magic ]##
print "-- pdayup.pl by pnG --\n\n";
print "Todays upload for section: $sectionname\n";
$cnt = 0;
opendir(DIR, "$gldir/ftp-data/users");
my @files = readdir(DIR);
for my $file (@files) {
        $readfile = "$gldir/ftp-data/users/$file";
        open(INFO, $readfile) or die "Cant open $readfile stupid!\n";
        @lines = <INFO>;
        close(INFO);
        foreach $thing (@lines) {
                if ($thing =~ /GROUP (\w*)/) {$group = $1};
		if ($section == 1) {
			if ($thing =~ /DAYUP (\d*) (\d*) (\d*)/) {if ($2) {$up = $2/1024^2}};
		} elsif ($section == 2) {
			if ($thing =~ /DAYUP (\d*) (\d*) (\d*) (\d*) (\d*) (\d*)/) {if ($5) {$up = $5/1024^2}};
		} elsif ($section == 3) {
			if ($thing =~ /DAYUP (\d*) (\d*) (\d*) (\d*) (\d*) (\d*) (\d*) (\d*) (\d*)/) {if ($8) {$up = $8/1024^2}};
		} else {
			print "This script only supports 3 sections, sorry\n";
		}
	};
        if ($up) {
		if (!$group) {$group = "noGroup"};
	        $dayup[$cnt] = "$up!!$file!!$group";
                $cnt++;
        };
        $group = "";
        $up = "";

};

$counter = 1;
$date = scalar localtime(time);
$log = "$date DAYUP \"$sectionname\" ";
@ranked = reverse sort { $a <=> $b } @dayup;
foreach $thing (@ranked) {
	($mbup, $user, $grp) = split(/!!/, $thing);
	$log .= "\"$user\@$grp\" \"$mbup mB\" ";
	print "$counter: $user\@$grp with $mbup mBs up\n";
	$counter++;
};

if ($counter < 6) {
	while ($counter != 6) {
		print "$counter: noone\n";
		$log .= "\"noone\" \"nothing\" ";
		$counter++;
	};
};

print "\nLoggin to glftpd.log\n";
open LOG, ">> $gldir/ftp-data/logs/glftpd.log" or die "Cant open glftpd.log!\n";
print LOG "$log\n";
close LOG;
