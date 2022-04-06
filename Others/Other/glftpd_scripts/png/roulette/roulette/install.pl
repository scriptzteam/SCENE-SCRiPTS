#!/usr/bin/perl
## Install script for roulette
print "Where is your glftpd dir? (/glftpd)\n";
$gldir = <STDIN>;
$gldir =~ s/\n//;
if ($gldir eq "") {$gldir = "/glftpd"};

print "\nCopying perl binary and libs...";
$copylines = "cp -f /usr/bin/perl $gldir/bin;cp -f /lib/libcrypt.so.1 $gldir/lib";
system ($copylines);
print "Done.\n";

print "Copying roulette.pl...";
$copyline = "cp -f roulette.pl $gldir/bin";
system ($copyline);
print "Done.\n";

print "Changing permissions...";
$changeper = "chmod a+x $gldir/bin/roulette.pl; chmod a+x $gldir/bin/perl";
system ('$changeper');
print "Done.\n";

print "Verifying set-up...\n";
open TEST, "< $gldir/bin/perl" or print "!!! Couldnt find your perl binary, please copy perl to $gldir/bin manually !!!\n";
close TEST;
open TEST, "< $gldir/lib/libcrypt.so.1" or print "!!! Couldnt find libcrypt.so.1, please copy libcrypt.so.1 to $gldir/lib manually !!!\n";
close TEST;
open TEST, "< $gldir/bin/roulette.pl" or print "!!! Couldnt find roulette.pl, please copy roulette.pl to $gldir/bin manually !!!\n";
close TEST;
print "... done.\n";

print "\nNow your soon ready to play some roulette!\n";
print "--------------------------------------------\n";
print "#1. Add this to your glftpd.conf file:\n";
print " site_cmd ROULETTE       EXEC    /bin/roulette.pl\n";
print " custom-roulette !8 *\n\n";
print "#2. Config your roulette.pl located in $gldir/bin\n\n";
print "#3. Add this to your bots config file:\n";
print " in \"set msgtypes(DEFAULT)\" add ROULETTE\n";
print " add: set disable(ROULETTE)        0\n";
print " add: set variables(ROULETTE)    \"%user %result %bet %tot %num %unum %col %ucol %wcred\"\n";
print " add: set announce(ROULETTE)     \":%sitename::%boldROULETTE%bold -%user- tries his luck over at the roulette table. He bets %bold%bet%bold mB credits on %bold%ucol %unum%bold. The ball stops on %bold%col %num%bold. %user just %bold%result%bold %wcred mB, that makes his new total: %tot mB\"\n";
print "--------------------------------------------\n";
print "..And rehash your bot and play the game!\n";
print "(install script by pnG)\n\n";
