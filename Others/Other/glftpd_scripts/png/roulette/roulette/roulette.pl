#!/bin/perl
### Roulette script by pnG
## Settings:
## --------
##
## Want me to output to glftpd.log?
$output = 1;
##
###########[ Script starts here]

$username = $ENV{'USER'};
open USERFILE, "< /ftp-data/users/$username" or die "Couldnt open your userfile!\n";
while (<USERFILE>) {
	if (/CREDITS (\d*)/) {
		$credits = $1 / 1024^2;
	}
}
close USERFILE;

if ($ARGV[0] > $credits) {
	print "You dont have $ARGV[0] credits to gamble with";
} elsif ($ARGV[0] and $ARGV[1] and $ARGV[2]) {
	print "You have $credits mB of Credits\n";
	print "Doing roulette with $ARGV[0] of your credits\n";
	print "your betting on color $ARGV[1] and number $ARGV[2]\n";
	print "\nThe roulette spins...\n\n";
	$roulette = rand(32);
	$roulette =~ s/\.(\d*)//;
	$color = rand(3);
	$color =~ s/\.(\d*)//;
	if ($color <= 1 and $color >= 0) {$color = "red"} elsif ($color > 1 and $color <= 2) {$color = "black"};
	print "The ball stops on $color $roulette\n\n";
	print "That makes you a ";
	if ($color eq $ARGV[1]) {
		print "WINNER!\n";
		$newcreds = $ARGV[0] * 1.3;
		print "You won $newcreds credits, that makes your new total: "; 
                $newtot = $credits+$newcreds;
                print $newtot;
		print "mB\n";
                &doLog($username, $ARGV[0], "WON", "$newtot", "$roulette", "$color", $ARGV[1], $ARGV[2], $newcreds);
                &doCred($newtot, $username);
	} elsif ($roulette eq $ARGV[2]) {
		print "WINNER!\n";
		$newcreds = $ARGV[0] * 3;
                print "You won $newcreds credits, that makes your new total: ";
                $newtot = $credits+$newcreds;
                print $newtot;
                print "mB\n";
                &doLog($username, $ARGV[0], "WON", "$newtot", "$roulette", "$color", $ARGV[1], $ARGV[2], $newcreds);
                &doCred($newtot, $username);
	} elsif ($roulette eq $ARGV[2] and $color eq $ARGV[1]) {
                print "BIG TIME WINNER!\n";
                $newcreds = $ARGV[0] * 4;
                print "You won $newcreds credits, that makes your new total: ";
                $newtot = $credits+$newcreds;
		print $newtot;
                print "mB\n";
		&doLog($username, $ARGV[0], "WON BIGTIME", "$newtot", "$roulette", "$color", $ARGV[1], $ARGV[2], $newcreds);
		&doCred($newtot, $username);
	} else {
		print "LOOSER!\n";
		$newcreds = $credits - $ARGV[0];
                print "You lost $ARGV[0] credits, that makes your new total: ";
                print $newcreds;
		&doLog($username, $ARGV[0], "lost", $newcreds, "$roulette", "$color", $ARGV[1], $ARGV[2], $ARGV[0]);
		&doCred($newcreds, $username);
	}
} else {
	print "Wrong syntax. Try:\n";
	print "site roulette <bet in mb> <color> <number>\n";
	print "Roulette script by pnG\n";
};

sub doLog {
  if ($output == 1) {
	my($nick, $cre, $res, $tot, $num, $col, $ucol, $unum, $wcred) = @_;
	$date = scalar localtime(time);
	$out = "$date ROULETTE: $nick $res $cre $tot $num $unum $col $ucol $wcred";
	open GL, ">> /ftp-data/logs/glftpd.log";
	print GL "$out\n";
	close GL;
  };
};

sub doCred {
	my($cre, $nic) = @_;
	$cre = $cre * 1024^2;

	$file = "/ftp-data/users/$nic";
	open(INFO, $file);          
	@lines = <INFO>;                    
	close(INFO);
	foreach (@lines) {s/CREDITS (\d*)/CREDITS $cre/};

	open USERFILE, "> /ftp-data/users/$username";
	@file = <USERFILE>;
	print USERFILE @lines;
	close USERFILE;
};
