#
# release catcher v0.11 (c) unknown dude.
#
# very simple irssi release catcher.
#
# installation:
# ~
# 1) edit relcatch-irssi.pl, check variables in RELCONTEXT, they
#    should match settings of your pftp-daemon.
# 2) copy relcatch-irssi.pl to ~/.irssi/scripts/ catalog.
# 3) load it: /script load relcatch-irssi.pl
#
# configuration:
# ~
# run /catcher command for help.
#
# quick examples:
#
# /catcher + mybot PRE         : will find release names whenever 'mybot'
#                                says something with 'PRE' in the line.
# /catcher + mybot2 PRE NEWDIR : will find release names whenever 'mybot2'
#                                says either 'PRE' or 'NEWDIR'.
# /catcher - mybot2            : drops monitoring mybot2
# /catcher list                : view what we are monitoring.
#

#use strict;
use vars qw($VERSION %IRSSI %RELCONTEXT);

use Irssi;
use IO::File;
use IO::Socket::INET;

$VERSION = '0.11';
%IRSSI = (
	  author => 'Unknown Dude',
	  contact => 'no@email.com',
	  name => 'relcatch',
	  descriotion => 'Want to own releases ? :-)',
	  license => 'GPL',
);

#
# be sure to configure this to point to your pftp-daemon
#
%RELCONTEXT = (
	       configfile => "$ENV{HOME}/.relcatch.cfg",
           configfile2 => "$ENV{HOME}/autoconnect.cfg",
	       daemonpassword => 'password',
	       daemonhost => 'localhost',
	       daemonport => 4500,
	       );

####
# 
# No need to edit below :-)
#
#
#
#
#

 Irssi::print "relcatch-irssi $VERSION loaded :-)";

#
# bind catcher command
#
Irssi::command_bind('catcher', 'cmd_catcher');


#
# add signal to check announce.
#
Irssi::signal_add("message public", "public_checkannounce");

my $config = read_config($RELCONTEXT{configfile2});


#
# check announce routine.
#
sub public_checkannounce {
    my ($server, $msg, $nick, $address, $target) = @_;

    # check config.
    relcatch_load_config() unless $RELCONTEXT{config};

    my $match = $RELCONTEXT{config}->{lc($nick)};

    return unless $match;

    $msg  =~ s/(\cC(\d\d?(,\d\d?)?)?)|\cB//g;

    foreach my $m (@$match) {

	next unless $msg =~ /$m/i;

	relcatch_catch($msg,$nick) && return;

    }

}



sub relcatch_catch {
    my ($msg, $nick) = @_;
    #Irssi::print "TEST1: $msg";
 
    # remove control chars, like underline/bold, TODO: remove mirc colors.
    #$msg =~ s/[\001-\032]//g;

    # remove mirc colors
    $msg  =~ s/(\cC(\d\d?(,\d\d?)?)?)|\cB//g;

    # check if we can find something that looks like release name in line.
    # 
    # currently matches releasename with length >7 and groupname
    # with length >2, and a '-' to split.
    return unless $msg =~ /\b([\w\d\.\_\-]{8,}\-[\w\d]{2,})\b/i;

    my $rel = $1;

    # check if exists in cache.
    return if $RELCONTEXT{cache}->{$rel};

    # send to irssi.
    Irssi::print "NEW RELEASE by $nick: $rel -> notifying pftp-daemon ..";

    do_release($rel);


    # add it to cache, so we dont start pftp more than once for same
    # release in the irssi session.
    $RELCONTEXT{cache}->{$rel} = $msg;

}



sub relcatch_load_config {

    open FH, $RELCONTEXT{configfile} || return;

    while (my $l = <FH>) {
	chomp $l;

	my ($nick, @a) = split(/,,,,/, $l);

	$RELCONTEXT{config}->{lc($nick)} = \@a;
    }

    close FH;

}

sub relcatch_save_config {

    open FH, ">".$RELCONTEXT{configfile};
    foreach my $k (keys %{$RELCONTEXT{config}}) {
	my $a = $RELCONTEXT{config}->{$k};
	my $t = join ",,,,", @$a;

	print FH join(",,,,", $k, $t)."\n";
    }
    close FH;
}


sub cmd_catcher {
    my ($data, $server, $witem) = @_;

    relcatch_load_config() unless $RELCONTEXT{config};

    my ($cmd, @args) = split ' ', $data;
    $cmd = lc($cmd);

    if ($cmd eq '+') {
	my ($nick, @strings) = @args;

	return unless $nick;

	$RELCONTEXT{config}->{lc($nick)} = \@strings;
	Irssi::print("Added watching $nick .. @strings");

	relcatch_save_config();
    }
    elsif ($cmd eq '-') {
	my ($nick) = @args;

	return unless $nick;

	delete $RELCONTEXT{config}->{lc($nick)};
	Irssi::print("Removed watching $nick ..");

	relcatch_save_config();
    }
    elsif ($cmd eq 'list') {
	Irssi::print("Watching :");
	foreach my $k (keys %{$RELCONTEXT{config}}) {
	    Irssi::print("$k -> ".join(" ",@{$RELCONTEXT{config}->{$k}}));
	}
	Irssi::print("<EOL>");
    }
    else {
	Irssi::print("Usage: /catcher + <nick> <string1> <string2> .. <stringn>  (start watching nick with 'strings')");
	Irssi::print("Usage: /catcher - <nick> (drop watching nick)");
	Irssi::print("Usage: /catcher list (list whats being watched)");
    }

    # $witem (window item) may be undef.

}

sub read_config {
    my ($fn) = @_;

    my @data = ();
    my @dkeys = ();

    open FH, $fn || die "Cant read config file\n";
    while (<FH>) {

	chomp;
	next if /^\#/;

	my ($k, $v) = $_ =~ /([^=]+)=(.*)/;

	next unless $k && $v;

	if ($k eq 'pftpconnect') {
	    #printf("+ setting pftp line: %s\n", $v);
	    # $PFTPCONNECT = $v;
	    next;
	}
	elsif ($k eq 'daemonport') {
	    #printf("+ setting daemon port: %d\n", $v);
	    #$DAEMONPORT = $v;
	    next;
	}
	elsif ($k eq 'password') {
	    #printf("+ setting password: %s\n", $v);
	    #$PASSWORD = $v;
	    next;
	}

	$k =~ s/ +/ /g;

	$data{$k} = $v;
	push @dkeys, $k;

	printf("+ config -> '%s' -> '%s'\n", $k, $v);
    }

    close FH;

    my %c = (matchers => \@dkeys,
	     pftpv => \%data);

    return \%c;
}				
				
sub do_release {
    my ($rel) = @_;

    my $dk = $config->{matchers};

    foreach my $dset (@$dk) {

	my @av = split / /, $dset;

	my $m = 0;
	foreach my $k (@av) {
	    $m++ if $rel =~ /$k/i;
	}

	next unless $m == scalar(@av);

    # send to pftp daemon.
    my $sock = new IO::Socket::INET(PeerAddr => $RELCONTEXT{daemonhost},
				    PeerPort => $RELCONTEXT{daemonport},
				    Proto => "udp");

    $sock->send("$RELCONTEXT{daemonpassword} $config->{pftpv}->{$dset} $rel\n");

    $sock->close();

	last;
    }				
}


