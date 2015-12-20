##############################################################################
##  Prebot v3 - Search script
##  =========================
##
##	This irssi scripts is a part of a larger script collection, which
##	implements prebot functionality to irssi. This particular script
##	enables search functions.
##
##  Channelrights
##  =============
##      a = admin channel
##	b = reads !addpre
## 	c = reads !info ja !gn
## 	d = reads !nuke / !unnuke / !modnuke  <--TARKISTA
## 	e = reads !addold
## 	f = reads !delpre / !undelpre
## 	g = relays !addpre
## 	h = relays !info
## 	i = relays !nuke / !unnuke / !modnuke
## 	j = relays !delpre / !undelpre
## 	k = relays !addold
##      l = permission to use prechannel searches !pre, !pred, !dupe, !group,
## 	m = !play trigger
## 	n = !getold trigger
## 	o = announce
##      p = nukenet search
##	q = lukee !sitepre
##	r = echoaa !sitepre
##	s = reads !addnfo
##	t = relays !addnfo
##	u = !getnfo trigger
##	v = freads !spreadnfo
##	w = relays !gn
##	x = relays !unnuke
##	y = reads !ginfo
##	z = relays !ginfo
##	1 = read !addurl
##	2 = relay !addurl
##
##  Triggers
##  ========
##
##	Addpre
## 	======
##	    !addpre <release> <section>
##
##	Infochannels
##	============
##	    !gn <release> <genre>
##	    !info <release> <files> <size>
##	    !ginfo <release> <files> <size>
##
##	Nukechannels
##	============
##	    !nuke <release> <reason> <source>
##	    !unnuke <release> <reason> <source>
##	    !modnuke <release> <updatedreason> <source>
##
##	Delprechannels
##	==============
##	    !delpre <release> <reason> <source>
##	    !undelpre <release> <reason> <source>
##
##	Siteprechannels
##	===============
##	    !sitepre <release> <section> <files> <size>
##
##	Addoldchannels
##	==============
##	    !addold <release> <section> <pretime> <files> <size> <genre> 
##                  <nukereason>
##	    !time
##	    !howmany <group>
##	    !convert <unixtime>
##
##	Searchchannels
##	==============
##	    !from <release>
##	    !bot <bot>
##	    !owner <owner>
##
##	Addnfochannels
##	==============
##	    !addnfo <release> <url> <nfoname>
##	    !oldnfo <release> <url> <nfoname>
##
##	Prechannels
##	===========
##	    !pre <search>
##	    !pred <release>
##	    !dupe <search>
##	    !group <group>
##	    !db
##	    !nfo <release>
##
##	Admin
##	======
##	    !stats <botname>
##	    !stats <channel>
##	    !addprestats
##	    !from <release>
##	    !blocknukenet <nukenet>
##	    !fix <release> <section>
##	    !spreadnfo <release>
##
###############################################################################

#use warnings;
use strict;

## We also need some modules
#use threads;

use vars qw($VERSION %IRSSI);
use DBI();
use IO::Socket;
use Number::Format;
use Date::Format;
use MIME::Base64;
use Digest::MD5 qw(md5_hex);
use Time::HiRes qw(usleep);
use Time::Local;
use String::CRC32;
use Irssi;

$VERSION = '3.00';
%IRSSI = (
    authors     => 'JH',
    contact     => 'haaja@iki.fi',
    name        => 'prebot_search',
    description => 'Prebot for irssi (search)',
    license     => 'WTFPL',
);

# MYSQL options
our %mysql = (
    user => 'username',
    pass => 'password',
    host => 'localhost',
    port => '3306',
    dbname => 'db_name',
);

# database handle
our $dbh;

# Output options
our %output = (
    announcePre	    => '1',
    announceOld	    => '1',
    announceNuke    => '1',
    announceGenre   => '0',
    announceDelpre  => '0',
    announceNfo	    => '0',
    announceError   => '1',
    echo	    => '0',
    debug	    => '1',
    triggers	    => '1'
);

our %limits = (
    releaseLength	=> '250',
    groupLength		=> '50',
    nukereasonLength	=> '250',
    sectionLength	=> '20',
    nukenetLength	=> '30',
    nfoHashLength	=> '32',
    nfonameLength	=> '100'
);


## nfo options
our $path = "/home/predb/workdir/";
our $shareurl = "http://yourho.st/nfo/view.php?id=";
our $nfodnurl =  "http://yourho.st/nfo/dn.php?id=";
our $blockednfo = "imdb.nfo|autotrader.nfo";

## Arrays for different type of channels, these are read from database.
our @admin_channels;
our @admin_channels_echo;
our @addpre_channels;
our @addpre_channels_echo;
our @info_channels;
our @info_channels_echo;
our @nuke_channels;
our @nuke_channels_echo;
our @addold_channels;
our @addold_channels_echo;
our @delpre_channels;
our @delpre_channels_echo;
our @sitepre_channels;
our @sitepre_channels_echo;
our @play_channels;
our @play_channels_echo;
our @getold_channels;
our @getold_channels_echo;
our @pre_channels;
our @pre_channels_echo;
our @search_channels;
our @search_channels_echo;
our @addnfo_channels;
our @addnfo_channels_echo;
our @nukenet_search_channels;
our @nukenet_search_channels_echo;
our @all_channels;
our @ginfo_channels;
our @ginfo_channels_echo;
our @gn_channels;
our @gn_channels_echo;
our @unnuke_channels;
our @unnuke_channels_echo;
our @addurl_channels;
our @addurl_channels_echo;

## Colours, used in themes
our $lightgrey	= "\00300";
our $black	= "\00301";
our $royalblue	= "\00302";
our $green	= "\00303";
our $red	= "\00304";
our $marroon	= "\00305";
our $purple	= "\00306";
our $orange	= "\00307";
our $yellow	= "\00308";
our $limegreen	= "\00309";
our $darkcyan	= "\00310";
our $cyan	= "\00311";
our $darkblue	= "\00312";
our $indigo	= "\00313";
our $darkgrey	= "\00314";
our $mediumgrey	= "\00315";
our $white	= "\00316";
our $bold 	= "\002";
our $underlined	= "\037";
our $reset	= "\017";

# lets fill those channel arrays from db
getChannels();

## Lets handle signals that irssi sends
Irssi::signal_add("message public", "prebotSearch");

#sub handleTriggers {
#	my ($server, $text, $nick, $address, $channel) = @_;
#
#	my $thr = threads->create(\&prebot_search, $server, $text, $nick, 
#	        $address, $channel);
#
#	if (!$thr) {
#		printDebug("[ERROR] handleTriggers()--[Unable to create new "
#		        ."thread]");
#	}
#
#	$thr->detach();
#}

## Function to handle signals
sub prebotSearch {

    my ($server, $text, $nick, $address, $channel) = @_;
    my $result;

    # Strips colours and formating from input text. 
    # Some chars removed to avoid mysql-injections but this is no way
    # bulletproof.
    $text = stripColor(stripFormatting($text));

    $text =~ s/'//gi;
    $text =~ s/;//gi;
    $text =~ s/&//gi;
    $text =~ s/\\//gi;
    $text =~ s/\///gi;

    if ($text !~ /^!/) {
        return 0;
    }

    my ($trigger, $query) = split(" ", $text, 2);

    sqlConnect();

    if (($trigger eq "!db") && $output{'triggers'} && 
        (length($query)==0) && checkChannelRights($channel, 'l')) {
        searchDb($server, $channel, $nick);
    }
    elsif (($trigger eq "!pre") && $output{'triggers'} && 
            checkChannelRights($channel, 'l')) {
        searchPre($server, $query, $channel, $nick);
    }
    elsif (($trigger eq "!dupe") && $output{'triggers'} && 
            checkChannelRights($channel, 'l')) {
        searchDupe($server, $query, $nick, $channel, $trigger);
    }
    elsif (($trigger eq "!rdupe") && $output{'triggers'} && 
            checkChannelRights($channel, 'l')) {
        searchDupe($server, $query, $nick, $channel, $trigger);
    }
    elsif (($trigger eq "!group") && $output{'triggers'} && 
            checkChannelRights($channel, 'l')) {
        searchGroup($server, $query, $channel, $nick);
    }
    elsif (($trigger eq "!grp") && $output{'triggers'} && 
            checkChannelRights($channel, 'l')) {
        searchGroup($server, $query, $channel, $nick);
    }
    elsif (($trigger eq "!howmany") && $output{'triggers'} && 
            checkChannelRights($channel, 'n')) {
        searchHowmany($server, $query, $channel, $nick);
    }
    elsif (($trigger eq "!getold") && $output{'triggers'} && 
            checkChannelRights($channel, 'n')) {
        searchGetold($server, $query, $channel, $nick);
    }
    elsif (($trigger eq "!play") && $output{'triggers'} && 
            checkChannelRights($channel, 'm')) {

        if (length($query) == 0) {
            $server->command("MSG $channel Usage:");
            $server->command("MSG $channel !play --between [--nfos] rls1 ",
                             "rls2");
            $server->command("MSG $channel !play --group [--nfos] ",
                             "groupname");
            $server->command("MSG $channel !play --dupe [--nfos] ",
                             "example*string");
            $server->command("MSG $channel !play --date [--nfos] ",
                             "YYYY-MM-DD");
            return 0;
        }
        else {
            searchPlay($server, $query, $channel, $nick);
        }
    }
    elsif (($trigger eq "!from") && $output{'triggers'} && 
            checkChannelRights($channel, 'p')) {
        searchFrom($server, $query, $channel, $nick);
    }
    elsif (($trigger eq "!nfo") && $output{'triggers'} && 
            checkChannelRights($channel, 'l')) {
        searchNfo($server, $query, $channel, $nick);
    }
    elsif (($trigger eq "!getnfo") && $output{'triggers'} && 
            checkChannelRights($channel, 'u')) {
        searchGetnfo($query, $server, $channel, $nick);
    }
    elsif (($trigger eq "!geturl") && $output{'triggers'} && 
            checkChannelRights($channel, '1')) {
        searchGeturl($query, $server, $channel, $nick);
    }
    elsif (($trigger eq "!spreadnfo") && $output{'triggers'} && 
            checkChannelRights($channel, 'v')) {
        searchSpreadNfo($query, $server, $channel, $nick);
    }
    elsif (($trigger eq "!uptime") && $output{'triggers'} && 
            checkChannelRights($channel, 'p')) {
        searchUptime($server, $query, $channel, $nick);
    }
    elsif (($trigger eq "!stats") && $output{'triggers'} && 
            checkChannelRights($channel, 'a')) {
        if($query =~ m/\#/gi) {
            searchStats($server, $query, $channel, $nick);
        }
    }
    elsif (($trigger eq "!top") && $output{'triggers'} && 
            checkChannelRights($channel, 'a')) {
        searchTop($server, $channel, $nick);
    }
    elsif (($trigger eq "!time") && $output{'triggers'} && 
            checkChannelRights($channel, 'n')) {
        searchTime($server, $channel, $nick);
    }
    elsif (($trigger eq "!convert") && $output{'triggers'} && 
            checkChannelRights($channel, 'a')) {
        searchConvert($server, $channel, $query, $nick);
    }
    elsif (($trigger eq "!triggers") && 
            checkChannelRights($channel, 'a')) {
        my $msg;

        if ($query eq "on" && !$output{'triggers'}) { 
            $output{'triggers'} = 1; 
            $msg = "ON"; 
        }
        elsif ($query eq "off" && $output{'triggers'}) { 
            $output{'triggers'} = 0; 
            $msg = "OFF"; 
        }
        else { 
            return 0; 
        }

        foreach my $channel (@admin_channels_echo) {
            my $message = "TRIGGERS: [$msg]";
            $server->command("MSG $channel $message");
        }
    }

    sqlDisconnect();
}

## Subroutine for !db
sub searchDb {
    my ($server, $channel, $nick) = @_;

    my $format = new Number::Format(-thousands_sep   => ',', 
                                    -decimal_point   => '.', 
                                    -int_curr_symbol => 'EUR');

    printDebug("searchDb()--[$nick]--[$channel]--START--");

    my $sql = "SELECT COUNT(*) FROM releases WHERE 1 = ?";
    my @params = (1);
    my $total = runSqlSingle($sql, @params);

    $sql = "SELECT COUNT(*) FROM releases WHERE status = ?";
    @params = (2);
    my $nuked = runSqlSingle($sql, @params);

    $sql = "SELECT COUNT(*) FROM releases WHERE status = ?";
    @params = (3);
    my $unnuked = runSqlSingle($sql, @params);

    $sql = "SELECT COUNT(*) FROM delpred WHERE 1 = ? LIMIT 1";
    @params = (1);
    my $deleted = runSqlSingle($sql, @params);

    $sql = "SELECT COUNT(*) FROM infos WHERE 1 = ? LIMIT 1";
    my $infos = runSqlSingle($sql, @params);

    $sql = "SELECT COUNT(*) FROM genres WHERE 1 = ? LIMIT 1";
    my $genres = runSqlSingle($sql, @params);

    $sql = "SELECT COUNT(*) FROM nfos WHERE 1 = ? LIMIT 1";
    my $nfos = runSqlSingle($sql, @params);

    $total = $total+$deleted;
    $total = $format->format_number($total);
    $nuked = $format->format_number($nuked);
    $unnuked = $format->format_number($unnuked);
    $deleted = $format->format_number($deleted);
    $infos = $format->format_number($infos);
    $genres = $format->format_number($genres);
    $nfos = $format->format_number($nfos);

    my $message = "[ ".$limegreen."DB".$reset." ]::[ ".$limegreen."RLS"
        .$reset.": ".$darkgrey."$total".$reset." ]::[ ".$limegreen."INFOS"
        .$reset.": ".$darkgrey."$infos".$reset." ]::[ ".$limegreen."GENRES"
        .$reset.": ".$darkgrey."$genres".$reset." ]::[ ".$limegreen."NUKES"
        .$reset.": ".$darkgrey."$nuked".$reset." ]::[ ".$limegreen."UNNUKES"
        .$reset.": ".$darkgrey."$unnuked".$reset." ]::[ "
        .$limegreen."DELETED".$reset.": ".$darkgrey."$deleted".$reset." ]::[ "
        .$limegreen."NFOS".$reset.": ".$darkgrey."$nfos".$reset." ]";
    $server->command("MSG $channel $message");

    printDebug("searchDb()--[$nick]--[$channel]--DONE--");

    return 0;
}

# Subroutine for !pre trigger
sub searchPre {
    my ($server, $query, $channel, $nick) = @_;
    $query = trim($query);
    my $search;
    my $filter;
    my $group;
    my $section;
    my @filterparams;

    printDebug("searchPre()--[!pre $query]--[$nick]--[$channel]--START--");

    my @search = split(" ", $query);

    foreach my $param (@search) {

        if (($param =~ m/-section=/i) || ($param =~ m/-s=/i)) {
            $param =~ s/-section=//i;
            $param =~ s/-s=//i;

            my $sql = "SELECT sectionid FROM sections WHERE sectionname = ? \
                LIMIT 1";
            my @params = ($param);
            $section = runSqlSingle($sql, @params);

            if (!$section) {
                return 0;
            }
        }
        elsif (($param =~ m/-group=/i) || ($param =~ m/-g=/i)) {
            $param =~ s/-group=//i;
            $param =~ s/-g=//i;

            my $sql = "SELECT groupid FROM groups WHERE groupname = ? LIMIT 1";
            my @params = ($param);
            $group = runSqlSingle($sql, @params);

            if (!$group) {
                return 0;
            }
        }
        elsif (($param =~ m/-not=/i) || ($param =~ m/-n=/i)) {
            $param =~ s/-not=//i;
            $param =~ s/-n=//i;
            my @filter_temp = split(/\|/, $param);

            foreach my $i (@filter_temp) {
                # Special langs rule which filters foreign releases
                if ($i eq "langs") {
                    $filter = $filter . "AND r.releasename NOT LIKE '%german%' \
                        AND r.releasename NOT LIKE '%french%' AND \
                        r.releasename NOT LIKE '%italian%' AND r.releasename \
                        NOT LIKE '%swedish%' AND r.releasename NOT LIKE \
                        '%flemish%' AND r.releasename NOT LIKE '%dutch%' AND \
                        r.releasename NOT LIKE '%.kr.%' AND r.releasename NOT \
                        LIKE '%.cz-%' AND r.releasename NOT LIKE '%.cz.%' AND \
                        r.releasename NOT LIKE '%.nl.%' AND r.releasename NOT \
                        LIKE '%.pl.%' AND r.releasename NOT LIKE '%.hun.%' \
                        AND r.releasename NOT LIKE '%.hun-%' AND r.releasename \
                        NOT LIKE '%.es-%' AND r.releasename NOT LIKE \
                        '%hungarian%' AND r.releasename NOT LIKE '%spanish%' \
                        AND r.releasename NOT LIKE '%greek%' AND r.releasename \
                        NOT LIKE '%BRAZiLiAN%' AND r.releasename NOT LIKE \
                        '%TRUEFRENCH%' AND r.releasename NOT LIKE \
                        '%NORWEGIAN%' AND r.releasename NOT LIKE '%.PT.%' AND \
                        r.releasename NOT LIKE '%CUSTOM.%.SUBS%' AND \
                        r.releasename NOT LIKE '%finnish%' ";
                }
                else {
                    $filter = $filter . "AND r.releasename NOT LIKE ? ";
                    push(@filterparams, "%$i%");
                }
            }
        }
        else {
            $search = $search." ".$param;
        }
    }

    $search = trim($search);
    $search =~ s/ /%/gi;
    $search =~ s/\*/%/gi;

    my $sql = "SELECT r.releaseid FROM releases AS r \
        LEFT JOIN sections AS s ON s.sectionid = r.sectionid \
        LEFT JOIN groups AS g ON g.groupid = r.groupid";
    my @params;
    my $releaseId;

    if (length($search) < 3 && !$section && !$group && !$filter) {
        $sql = $sql." WHERE r.pretime BETWEEN ? AND ? ORDER BY r.pretime \
            DESC LIMIT 1";
        @params = (time()-3600, time());

        $releaseId = runSqlSingle($sql, @params);
        if (!$releaseId) {
            my $message = "Nothing found for $query.";
            $server->command("MSG $channel $message");
            return 0;
        }
    }
    elsif (length($search) < 3) {
        $sql = $sql." WHERE 1=1";

        if ($group) {
            $sql = $sql." AND r.groupid = ?";
            push(@params, $group);
        }

        if ($section) {
            $sql = $sql." AND r.sectionid = ?";
            push(@params, $section);
        }

        if ($filter) {
            $sql = $sql.$filter;
            push(@params, @filterparams);
        }

        $sql = $sql." ORDER BY r.pretime DESC LIMIT 1";
        $releaseId = runSqlSingle($sql, @params);
        if (!$releaseId) {
            my $message = "Nothing found for $query.";
            $server->command("MSG $channel $message");
            return 0;
        }
    }
    else {
        $sql = $sql." WHERE r.releasename LIKE ?";
        @params = ("$search%");

        if ($group) {
            $sql = $sql." AND r.groupid = ?";
            push(@params, $group);
        }

        if ($section) {
            $sql = $sql." AND r.sectionid = ?";
            push(@params, $section);
        }

        if ($filter) {
            $sql = $sql.$filter;
            push(@params, @filterparams);
        }

        $sql = $sql." ORDER BY r.pretime DESC LIMIT 1";
        $releaseId = runSqlSingle($sql, @params);

        if (!$releaseId) {
            my @newParams = ("%$search%");
            shift(@params);
            push(@newParams, @params);
            $releaseId = runSqlSingle($sql, @newParams);

            if (!$releaseId) {
                my $message = "Nothing found for $query.";
                $server->command("MSG $channel $message");
                return 0;
            }
        }
    }

    $sql = "SELECT r.releaseid, r.releasename, r.pretime, r.status, \
        s.sectionname, a.genrename, i.files, i.size, n.releaseid, u.url \
        FROM releases AS r \
        LEFT JOIN sections AS s ON r.sectionid = s.sectionid \
        LEFT JOIN genres AS g ON r.releaseid = g.releaseid \
        LEFT JOIN allowedgenres AS a ON g.genreid = a.genreid \
        LEFT JOIN infos AS i ON r.releaseid = i.releaseid \
        LEFT JOIN nfos AS n ON r.releaseid = n.releaseid \
        LEFT JOIN urls AS u ON r.releaseid = u.releaseid \
        WHERE r.releaseid = ? LIMIT 1";
    @params = ($releaseId);

    my @result = runSqlMulti($sql, @params);

    my $releaseid = $result[0][0];
    my $pre = $result[0][1];
    my $pretime = $result[0][2];
    my $pretime_human = time2str("%T %Z", $result[0][2]);
    my $status = $result[0][3];
    $section = $result[0][4];
    my $genre = $result[0][5];
    my $files = $result[0][6];
    my $size = $result[0][7];
    my $nfo = $result[0][8];
    my $url = $result[0][9];
    my $nukereason;
    my $nukenet;
    my $infos;

    if ($nfo) { $nfo = "[ ".$limegreen."NFO ".$reset."]::"; }

    my @date = toDate($pretime);
    my $time = time();
    $pretime = $time - $pretime;
    my $ago = unixToHuman($pretime);

    if ($status != 1) {
        if ($status == 2) {
            $sql = "SELECT nukereason FROM nukes WHERE releaseid = ? ORDER \
                BY nuketime DESC LIMIT 1";
            @params = ($releaseid);
            $nukereason = $reset."[ ".$red."NUKED:".$reset." ";
        }
        else {
            $sql = "SELECT unnukereason, nukenetid FROM unnukes WHERE \
                releaseid = ? ORDER BY unnuketime DESC LIMIT 1";
            @params = ($releaseid);
            $nukereason = $reset."[ ".$limegreen."UNNUKED".$reset.": ";
        }

        my $nr = runSqlSingle($sql, @params);
        $nukereason = $nukereason.$darkgrey.$nr.$reset." ]::";
    }

    my $message = $reset."[ ".$limegreen.$section.$reset." ]::[ "
            .$darkgrey.$pre.$reset." ]::";
    if ($size) { 
        $infos = $reset."[ ".$darkgrey.$files."F/".$size."MB".$reset." ]::"; 
    }
    if ($genre) { 
        $genre = $reset."[ ".$darkgrey."$genre".$reset." ]::"; 
    }
    if ($url) { 
        $url = $reset."[ ".$darkgrey.$url.$reset." ]::"; 
    }
    $pretime = $reset."[ ".$darkgrey."PRETIME: $ago ago on $date[0].$date[1]
        .$date[2] ".$pretime_human.$reset." ]::";

    $message = $message.$pretime.$infos.$genre.$nukereason.$url.$nfo;

    $server->command("MSG $channel $message");

    printDebug("searchPre()--[!pre $query]--[$nick]--[$channel]--DONE--");
    return 0;
}

# Subroutine for !dupe
sub searchDupe {
    my ($server, $pre, $nick, $channel, $trigger) = @_;
    my $haku = $pre;
    my $sql;
    my @params;
    my $message;
    my $section;
    my $group;
    my $not;
    my $sort = "ORDER BY r.pretime DESC";
    my $limit = "LIMIT 15";

    my $pretime;
    my $infos;
    my $genre;
    my $nuke;
    my $sleeptime = getSleepTime($channel);

    my $nukereason;
    my $query;

    if ($trigger eq "!rdupe") {
        $sort = "ORDER BY r.pretime ASC";
    }

    printDebug("searchDupe()--[!dupe $haku]--[$nick]--[$channel]--START--");

    my @search = split(" ", $pre);
    undef($pre);

    foreach my $option (@search) {
        if (($option =~ m/-section=/i) || ($option =~ m/-s=/i)) {
            $option =~ s/-section=//i;
            $option =~ s/-s=//i;

            $sql = "SELECT sectionid FROM sections WHERE sectionname = ? \
                LIMIT 1";
            my @params = ($option);
            $section = runSqlSingle($sql, @params);

            if ($section == 0) {
                return 0;
            }
            $section = "AND r.sectionid = '$section'";
        }
        elsif (($option =~ m/-group=/i) || ($option =~ m/-g=/i)) {
            $option =~ s/-group=//i;
            $option =~ s/-g=//i;

            $sql = "SELECT groupid FROM groups WHERE groupname = ? LIMIT 1";
            @params = ($option);
            $group = runSqlSingle($sql, @params);

            if ($group == 0) {
                return 0;
            }
            $group = "AND groupid = '$group'";
        }
        elsif (($option =~ m/-limit=/i) || ($option =~ m/-l=/i)) {
            $option =~ s/-limit=//i;
            $option =~ s/-l=//i;

            if ($option > 30) {
                $limit = "LIMIT 30";
            }
            else {
                $limit = "LIMIT ".$option;
            }
        }
        elsif (($option =~ m/-not=/i) || ($option =~ m/-n=/i)) {
            $option =~ s/-not=//i;
            $option =~ s/-n=//i;
            my @not_temp = split(/\|/, $option);

            foreach my $i (@not_temp) {
                if ($i eq "langs") {
                    $not = $not . "AND r.releasename NOT LIKE '%german%' AND \
                        r.releasename NOT LIKE '%french%' AND r.releasename \
                        NOT LIKE '%italian%' AND r.releasename NOT LIKE 
                        '%swedish%' AND r.releasename NOT LIKE '%flemish%' \
                        AND r.releasename NOT LIKE '%dutch%' AND r.releasename \
                        NOT LIKE '%.kr.%' AND r.releasename NOT LIKE '%.cz-%' \
                        AND r.releasename NOT LIKE '%.cz.%' AND r.releasename \
                        NOT LIKE '%.nl.%' AND r.releasename NOT LIKE '%.pl.%' \
                        AND r.releasename NOT LIKE '%.hun.%' AND \
                        r.releasename NOT LIKE '%.hun-%' AND r.releasename \
                        NOT LIKE '%.es-%' AND r.releasename NOT LIKE \
                        '%hungarian%' AND r.releasename NOT LIKE '%spanish%' \
                        AND r.releasename NOT LIKE '%greek%' AND \
                        r.releasename NOT LIKE '%BRAZiLiAN%' AND r.releasename \
                        NOT LIKE '%TRUEFRENCH%' AND r.releasename NOT LIKE \
                        '%NORWEGIAN%' AND r.releasename NOT LIKE '%.PT.%' AND \
                        r.releasename NOT LIKE '%CUSTOM.%.SUBS%' AND \
                        r.releasename NOT LIKE '%DANISH%' AND r.releasename \
                        NOT LIKE '%finnish%' ";
                }
                else {
                    $not = $not . "AND r.releasename NOT LIKE '%$i%' ";
                }
            }
        }
        else {
            $pre = $pre." ".$option;
        }
    }

    $pre =~ s/^\s//gi;
    $pre =~ s/ /%/gi;
    $pre =~ s/\*/%/gi;

    if (length($pre) < 3) {
        $query = "1 = ?";
        @params = (1);
    }
    else {
        $query = "r.releasename LIKE ? ";
        @params = ("$pre%");
    }

    $sql = "SELECT r.releaseid, r.releasename, r.pretime, r.status, \
        s.sectionname, a.genrename, i.files, i.size, n.releaseid, u.url \
        FROM releases AS r LEFT JOIN genres AS g ON r.releaseid = g.releaseid \
        LEFT JOIN allowedgenres AS a ON g.genreid = a.genreid \
        LEFT JOIN infos AS i ON r.releaseid = i.releaseid \
        LEFT JOIN sections AS s ON r.sectionid = s.sectionid \
        LEFT JOIN nfos AS n ON r.releaseid = n.releaseid \
        LEFT JOIN urls AS u ON r.releaseid = u.releaseid \
        WHERE $query $section \
        $group $not $sort $limit";

    my @result = runSqlMulti($sql, @params);

    my $x = @result;
    my $i = 0;
    my $k;
    my $viesti;

    if ($result[0][0] == 0 && $query ne "WHERE 1 = ?") {
        $query = "r.releasename LIKE ?";
        $sql = "SELECT r.releaseid, r.releasename, r.pretime, r.status, \
            s.sectionname, a.genrename, i.files, i.size, n.releaseid, u.url \
            FROM releases AS r \
            LEFT JOIN genres AS g ON r.releaseid = g.releaseid \
            LEFT JOIN allowedgenres AS a ON g.genreid = a.genreid \
            LEFT JOIN infos AS i ON r.releaseid = i.releaseid \
            LEFT JOIN sections AS s ON r.sectionid = s.sectionid \
            LEFT JOIN nfos AS n ON r.releaseid = n.releaseid \
            LEFT JOIN urls AS u ON r.releaseid = u.releaseid \
            WHERE $query $section $group $not $sort $limit";
        @params = ("%$pre%");

        @result = runSqlMulti($sql, @params);
        $x = @result;
    }
    if (!$result[0][0]) {
        my $message = "Nothing found for $haku.";
        $server->command("MSG $channel $message");

        return 0;
    }
    else {
        $viesti = "Sending $x releases matching $haku to $nick";
        $pre =~ s/%/\*/ig;
        $server->command("MSG $channel $viesti");

        while ($i < $x) {

            my $releaseid = $result[$i][0];
            my $pre = $result[$i][1];
            my $pretime = $result[$i][2];
            my $pretime_human = time2str("%T %Z", $result[$i][2]);
            my $status = $result[$i][3];
            my $section = $result[$i][4];
            my $genre = $result[$i][5];
            my $files = $result[$i][6];
            my $size = $result[$i][7];
            my $nfo = $result[$i][8];
            my $url = $result[$i][9];

            # let's fetch the reason and network if status is nuked or unnuked.
            if ($status != 1) {
                if ($status == 2) {
                    $sql = "SELECT nukereason FROM nukes WHERE releaseid = ? \
                        ORDER BY nukeid DESC LIMIT 1";
                    $nukereason = $reset."[ ".$red."NUKED".$reset.": ";
                }
                else {
                    $sql = "SELECT unnukereason FROM unnukes WHERE \
                        releaseid = ? ORDER BY unnukeid DESC LIMIT 1";
                    $nukereason = $reset."[ ".$limegreen."UNNUKED".$reset.": ";
                }

                @params = ($releaseid);
                my $nukeresult = runSqlSingle($sql, @params);
                $nukereason = $nukereason.$darkgrey.$nukeresult.$reset." ]::";
            }

            my @date = toDate($pretime);
            my $time = time();
            $pretime = $time - $pretime;
            my $ago = unixToHuman($pretime);

            $k = $i + 1;
            if (length($k) == 1) { $k = "0" . $k; }

            $message = $reset." [".$limegreen.$k.$reset."]::[ ".$limegreen.
                    $section.$reset." ]::[ ".$darkgrey.$pre.$reset." ]::";
            if ($size) { 
                $files = $reset."[ ".$darkgrey.$files."F".$reset."/"
                    .$darkgrey.$size."MB ".$reset."]::"; 
            }
            if ($genre) { 
                $genre = $reset."[ ".$darkgrey.$genre.$reset." ]::"; 
            }
            if ($url) { 
                $url = $reset."[ ".$darkgrey.$url.$reset." ]::"; 
            }
            if (length($nfo) != 0) { 
                $nfo = "[ ".$limegreen."NFO ".$reset."]::"; 
            }
            
            $pretime = $reset."[ ".$limegreen."PRETiME".$reset.": ".$darkgrey
                ."$ago ago on $date[0].$date[1].$date[2] $pretime_human "
                .$reset."]::";
            $message = $message.$pretime.$files.$genre.$nukereason.$url.$nfo;
            $server->command("MSG $nick $message");
            usleep($sleeptime);
            undef($k);
            undef($nukereason);
            undef($status);
            $i++;
        }
    }

    printDebug("searchDupe()--[!dupe $haku]--[$nick]--[$channel]--DONE--");
}


# Function to fetch data for !getold query
sub searchGetold {
    my ($server, $pre, $channel, $nick) = @_;

    my $sect;
    my $time;
    my $files;
    my $size;
    my $section;
    my $status;
    my $genre;
    my $nuke;
    my $nukenet;
    my $nukeid;

    my $i = 0;
    my $addold;

    printDebug("searchGetold()--[!getold $pre]--[$nick]--[$channel]--START--");

    my $sql = "SELECT r.releaseid, r.releasename, r.pretime, r.status, \
        s.sectionname, a.genrename, i.files, i.size \
        FROM releases AS r \
        LEFT JOIN genres AS g ON r.releaseid = g.releaseid \
        LEFT JOIN allowedgenres AS a ON g.genreid = a.genreid \
        LEFT JOIN infos AS i ON r.releaseid = i.Releaseid \
        LEFT JOIN sections AS s ON r.sectionid = s.sectionid \
        LEFT JOIN groups AS gr ON r.groupid = gr.groupid \
        WHERE r.releasename = ? LIMIT 0,1";
    my @params = ($pre);

    my @Result = runSqlMulti($sql, @params);

    if ($Result[0][3] == 2) {
        $sql = "SELECT nukereason FROM nukes WHERE releaseid = ? ORDER BY \
            nukeid DESC LIMIT 1";
        @params = ($Result[0][0]);

        $nuke = runSqlSingle($sql, @params);
    }

    # 0 ReleaseID
    # 1 ReleaseName
    # 2 ReleaseTime
    # 3 ReleaseStatus
    # 4 SectionName
    # 5 GenreName
    # 6 Files
    # 7 Size
    $pre =  $Result[0][1];
    $section = $Result[0][4];
    $time = $Result[0][2];
    $files = $Result[0][6];
    $size = $Result[0][7];
    $genre = $Result[0][5];
    $status = $Result[0][3];

    if ( $Result[0][0] != 0 ) {
    # Let's check if release time is too old to be sure.
        if( $time < 1186483607 ) {
            printDebug("Pretime too old to be sure of correctness.");
            return 0;
        }

        if (($status == 1) || ($status == 3)) { $nuke = "-"; }
        if (!$size) { $files = "-"; $size = "-"; }
        if (!$genre) { $genre = "-"; }

        $addold = "$pre $section $time $files $size $genre $nuke";
        chomp($addold);
        printDebug("Reply: !addold $addold");
        $server->command("MSG $channel !addold $addold");
    }
    else {
        return 0;
    }

    printDebug("searchGetold()--[!getold $pre]--[$nick]--[$channel]--DONE--");
}

sub searchPlay {
    my ($server, $text, $channel, $nick) = @_;

    my @haku = split(" ", $text);
    my @params = (1);
    my $search;

    my $networkshort = $server->{'chatnet'};
    my $nfochannel;
    my $nfos;
    my $limit = 500;
    my $sleeptime = getSleepTime($channel);

    printDebug("searchPlay()--[!play $text]--[$nick]--[$channel]--START--");


    if ($haku[1] eq "--nfos") {
        $nfos = 1;

        $nfochannel = getNfoChannel($networkshort);

        if (length($nfochannel) == 0) {
            return 0;
        }
    }

    if ($haku[0] eq "--between") {

        my ($pre1, $pre2, $start, $end);

        if ($nfos) {
            my $sql = "SELECT pretime FROM releases WHERE releasename = ? \
                LIMIT 1";
            my @localParams = ($haku[2]);
            $pre1 = runSqlSingle($sql, @localParams);

            $sql = "SELECT pretime FROM releases WHERE releasename = ? \
                LIMIT 1";
            @localParams = ($haku[3]);
            $pre2 = runSqlSingle($sql, @localParams);
        }
        else {
            my $sql = "SELECT pretime FROM releases WHERE releasename = ? \
                LIMIT 1";
            my @localParams = ($haku[1]);
            $pre1 = runSqlSingle($sql, @localParams);

            $sql = "SELECT pretime FROM releases WHERE releasename = ? LIMIT 1";
            @localParams = ($haku[2]);
            $pre2 = runSqlSingle($sql, @localParams);
        }

        # if one or both is delpred
        if (!$pre1 || !$pre2) {
            return 0;
        }

        # lets check that pres are in cronological order
        if ($pre1 < $pre2) {
            $start = $pre1;
            $end = $pre2;
        }
        else {
            $start = $pre2;
            $end = $pre1;
        }

        $search = "AND r.pretime BETWEEN ? AND ?";
        push(@params, $start);
        push(@params, $end);
        $limit = 2000;

    }
    elsif ($haku[0] eq "--date") {
        my ($year, $month, $day) = split(/\-/, $haku[1], 3);

        if ($nfos) {
            ($year, $month, $day) = split(/\-/, $haku[2], 3);
        }

        $month--;
        my $start = timegm(0, 0, 0, $day, $month, $year);
        my $end = $start + 3600*24;
        my $time = time();

        if ($start > $time) { return 0; }

        $search = "AND r.pretime BETWEEN ? AND ?";
        push(@params, $start);
        push(@params, $end);
        $limit = 2000;
    }
    elsif ($haku[0] eq "--group") {
        my $group = $haku[1];

        if ($nfos) {
            $group = $haku[2];
        }

        if (length($group) > 0) {
            my $sql = "SELECT groupid FROM groups WHERE groupname = ? LIMIT 1";
            my @localParams = ($group);

            $group = runSqlSingle($sql, @localParams);
            if ($group) {
                $search = "AND r.groupid = ?";
                push(@params, $group);
            }
            else {
                return 0;
            }
        }

        $limit = 2000;
    }
    elsif ($haku[0] eq "--dupe") {
        my $i = 1;

        if ($nfos) {
            $i = 2;
        }

        my $dupe;
        while ($i < @haku) {
            $dupe = $dupe." ".$haku[$i];
            $i++;
        }

        $dupe =~ s/ /%/gi;
        $dupe =~ s/\*/%/gi;

        $search = "AND r.releasename LIKE ?";
        push(@params, $dupe);
        $limit = 500;
    }
    else {
        return 0;
    }

    my $sql = "SELECT r.releaseid, r.releasename, r.pretime, r.status, \
        s.sectionname, a.genrename, i.files, i.size, n.nfoname, n.nfo \
        FROM releases AS r \
        LEFT JOIN genres AS g ON r.releaseid = g.releaseid \
        LEFT JOIN allowedgenres AS a ON g.genreid = a.genreid \
        LEFT JOIN infos AS i ON r.releaseid = i.releaseid \
        LEFT JOIN sections AS s ON r.sectionid = s.sectionid \
        LEFT JOIN groups AS gr ON r.groupid = gr.groupid \
        LEFT JOIN nfos AS n ON n.releaseid = r.releaseid \
        WHERE 1 = ? $search ORDER BY r.pretime DESC LIMIT $limit";

    my @result = runSqlMulti($sql, @params);

    my $x = @result;
    if ($x == 1) { return 0; }

    $server->command("MSG $channel Found $x result(s) (max. $limit).");
    my $i = 0;
    while( $i < $x ) {

        # 0 ReleaseID
        # 1 ReleaseName
        # 2 ReleaseTime
        # 3 ReleaseStatus
        # 4 SectionName
        # 5 GenreName
        # 6 Files
        # 7 Size
        # 8 Nfoname
        # 9 Nfo
        my $releaseid = $result[$i][0];
        my $pre = $result[$i][1];
        my $section = $result[$i][4];
        my $time = $result[$i][2];
        my $files = $result[$i][6];
        my $size = $result[$i][7];
        my $genre = $result[$i][5];
        my $status = $result[$i][3];
        my $nfoname = $result[$i][8];
        my $nfo = $result[$i][9];
        my $nuke = "-";

        if ($status == 2) {
            $sql = "SELECT nukereason FROM nukes WHERE releaseid = ? ORDER \
                BY nuketime DESC LIMIT 1";
            my @localParams = ($releaseid);
            $nuke = runSqlSingle($sql, @localParams);
        }

        if (!$files) { $files = "-"; $size = "-"; }
        if (!$genre) { $genre = "-"; }

        my $addold = "$pre $section $time $files $size $genre $nuke";
        $server->command("MSG $channel !addold $addold");

        if ($nfos && length($nfoname) > 0) {
            my $time = (time()+60);
            my $sql = "UPDATE nfos SET timeout = $time WHERE releaseid = ?";
            my @localParams = ($releaseid);
            runSqlSave($sql, @localParams);
            my $crc = crc32(decode_base64($nfo));
            $crc = uc(sprintf("%08x", $crc));
            my $message = "!oldnfo $pre $nfodnurl$releaseid $nfoname $crc";
            $server->command("MSG $nfochannel $message");
        }

        usleep($sleeptime);
        $i++;
    }

    printDebug("searchPlay()--[!play $text]--[$nick]--[$channel]--DONE--");

    return 0;
}

# Function to getnfo
# input: VA-Capadocia_OST-SP-2008-BlaZe 
sub searchGetnfo {
    my ($text, $server, $channel, $nick) = @_;
    my $pre = $text;

    $pre = trim($pre);

    printDebug("searchGetnfo()--[!getnfo $pre]--[$nick]--[$channel]--START--");

    if (!checkIfNfoExists($pre)) {
        return 0;
    }

    my $sql = "SELECT n.releaseid, n.nfoname, n.nfo FROM nfos AS n LEFT JOIN \
        releases AS r ON r.releaseid = n.releaseid WHERE r.releasename = ? \
        LIMIT 1";
    my @params = ($pre);
    my @result = runSqlMulti($sql, @params);
    my $releaseid = $result[0][0];
    my $nfoname = $result[0][1];
    my $nfo = $result[0][2];

    my $crc = crc32(decode_base64($nfo));
    $crc = uc(sprintf("%08x", $crc));

    my $time = time();
    $time = $time + 60;
    $sql = "UPDATE nfos SET timeout = ? WHERE releaseid = ?";
    @params = ($time, $releaseid);
    $sql = runSqlSave($sql, @params);


    if ($output{'triggers'} && $releaseid) {
        my $message = "!oldnfo $pre $nfodnurl$releaseid $nfoname $crc";
        printDebug("Reply: $message");
        $server->command("MSG $channel $message");
    }

    printDebug("searchGetnfo()--[$pre]--[$nick]--[$channel]--DONE--");

    return 0;
}

## Function to geturl
## input: <release> 
sub searchGeturl {
    my ($pre, $server, $channel, $nick) = @_;
    $pre = trim($pre);

    printDebug("searchGeturl()--[!geturl $pre]--[$nick]--[$channel]--START--");

    if (!checkIfUrlExists($pre)) {
        return 0;
    }

    my $sql = "SELECT u.url FROM urls AS u LEFT JOIN releases AS r ON \
        r.releaseid = u.releaseid WHERE r.releasename = ? LIMIT 1";
    my @params = ($pre);
    my $url = runSqlSingle($sql, @params);

    if ($output{'triggers'} && length($url) > 1) {
        my $message = "!oldurl $pre $url";
        printDebug("Reply: $message");
        $server->command("MSG $channel $message");
    }

    printDebug("searchGeturl()--[$pre]--[$nick]--[$channel]--DONE--");

    return 0;
}

## Function to spread nfos
## input: <release>
sub searchSpreadNfo {
    my ($text, $server, $channel, $nick) = @_;
    my $pre = $text;

    printDebug("searchSpreadNfo()--[!spreadnfo $pre]--[$nick]--[$channel]"
        ."--START--");

    $pre = trim($pre);

    if (!checkIfNfoExists($pre)) {
        return 0;
    }

    my $sql = "SELECT n.releaseid, n.nfoname, n.nfo, r.pretime \
            FROM nfos AS n \
            LEFT JOIN releases AS r ON r.releaseid = n.releaseid \
            WHERE r.releasename = ? LIMIT 1";
    my @params = ($pre);
    my @result = runSqlMulti($sql, @params);
    my $releaseid = $result[0][0];
    my $nfoname = $result[0][1];
    my $nfo = $result[0][2];
    my $pretime = $result[0][3];

    if (!$releaseid) {
        return 0;
    }

    my $crc = crc32(decode_base64($nfo));
    $crc = uc(sprintf("%08x", $crc));

    my $time = time();
    $time = $time + 60;
    $sql = "UPDATE nfos SET timeout = ? WHERE releaseid = ? LIMIT 1";
    @params = ($time, $releaseid);
    $sql = runSqlSave($sql, @params);


    if ($output{'triggers'}) {
        my $message;
        if ($pretime > (time()-300)) {
            $message = "!addnfo $pre $nfodnurl$releaseid $nfoname $crc";
        }
        else {
            $message = "!oldnfo $pre $nfodnurl$releaseid $nfoname $crc";
        }

        foreach my $channel (@addnfo_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }

    printDebug("searchSpreadNfo()--[!spreadnfo $pre]--[$nick]--[$channel]"
        ."--DONE--");
    return 0;
}

## Checks if nfo is already exists.
## Returns 1 if found, else returns 0.
sub checkIfNfoExists {
    my $pre = shift;

    my $sql = "SELECT n.releaseid FROM nfos AS n \
            LEFT JOIN releases AS r ON r.releaseid = n.releaseid \
            WHERE r.releasename = ? LIMIT 1";
    my @params = ($pre);
    my $id = runSqlSingle($sql, @params);

    if ($id) {
        return 1;
    }

    return 0;
}

# Function to check if url exists in db
# Parameter: releaseid
# Returns: 1 if url is found, 0 otherwise
sub checkIfUrlExists {
    my $pre = shift;

    my $sql = "SELECT u.releaseid FROM urls AS u \
            LEFT JOIN releases as r ON r.releaseid = u.releaseid \
            WHERE r.releasename = ? LIMIT 1";
    my @params = ($pre);

    if (runSqlSingle($sql, @params)) {
        return 1;
    }

    return 0;
}

# Subroutine for !group trigger
sub searchGroup {
    my ($server, $group, $channel, $nick) = @_;

    printDebug("searchGroup()--[!grp $group]--[$nick]--[$channel]--START--");

    my $time = time();
    # remove _int at the end of group
    $group =~ s/_int$//i;

    my $sql = "SELECT count(r.releaseid) FROM releases AS r \
            INNER JOIN groups AS gr ON r.groupid = gr.groupid \
            WHERE gr.groupname = ? LIMIT 1";
    my @params = ($group);
    my $total = runSqlSingle($sql, @params);
    if (!$total) {
        $server->command("MSG $channel No pres from group $group in my db.");
        return 0;
    }

    $sql = "SELECT groupid FROM groups WHERE groupname = ? LIMIT 1";
    @params = ($group);
    my $groupid = runSqlSingle($sql, @params);

    $sql = "SELECT groupname FROM groups WHERE groupname = ? LIMIT 1";
    my $groupname = runSqlSingle($sql, @params);

    $sql = "SELECT COUNT(r.releaseid) FROM releases AS r \
            INNER JOIN groups AS gr ON r.groupid = gr.groupid \
            WHERE gr.groupname = ? AND r.status = ?";
    @params = ($group, 2);
    my $nuked = runSqlSingle($sql, @params);
    my $nukedpercentage = sprintf("%.2f", ($nuked / $total * 100));

    $sql = "SELECT COUNT(r.releaseid) FROM releases AS r \
            INNER JOIN groups AS gr ON r.groupid = gr.groupid \
            WHERE gr.groupname = ? AND r.status = ?";
    @params = ($group, 3);
    my $unnuked = runSqlSingle($sql, @params);
    my $unnukedpercentage = sprintf("%.2f", ($unnuked / $total * 100));

    my $groupinfo = $reset."[".$limegreen."$groupname".$reset."] ["
        .$limegreen."Total".$reset.": ".$darkgrey."$total / ".$red."Nuked"
        .$reset.": ".$darkgrey."$nuked ($nukedpercentage) / "
        .$limegreen."Unnuked".$reset.": "
        .$darkgrey."$unnuked ($unnukedpercentage)".$reset."] ";

    # first release
    my $first = "SELECT r.releaseid, r.releasename, r.pretime, r.status, \
        s.sectionname, a.genrename, i.files, i.size \
        FROM releases AS r \
        LEFT JOIN genres AS g ON r.releaseid = g.releaseid \
        LEFT JOIN allowedgenres AS a ON g.genreid = a.genreid \
        LEFT JOIN infos AS i ON r.releaseid = i.releaseid \
        LEFT JOIN sections AS s ON r.sectionid = s.sectionid \
        LEFT JOIN groups AS gr ON gr.groupid = r.groupid \
        WHERE r.groupid = ? ORDER BY r.pretime ASC LIMIT 0,1";
    @params = ($groupid);
    my @first = runSqlMulti($first, @params);

    my $freleaseid = $first[0][0];
    my $fpre = $first[0][1];
    my $fpretime = $first[0][2];
    my $fstatus = $first[0][3];
    my $fsection = $first[0][4];
    my $fgenre = $first[0][5];
    my $ffiles = $first[0][6];
    my $fsize = $first[0][7];

    if (length($fsize) == 0) { $ffiles = ""; $fsize = ""; }
    if (length($fgenre) == 0) { $fgenre = ""; }

    $first = $reset."[".$limegreen."FiRST".$reset."]::[ ".$darkgrey."$fpre"
        .$reset."]::[ ".$limegreen."$fsection ".$reset."]::";
    my $finfo;
    if ($fsize) { 
        $finfo = $reset."[ ".$darkgrey.$ffiles."F"
            .$reset."/".$darkgrey.$fsize."MB ".$reset."]::"; 
    }
    if ($fgenre) { 
        $fgenre = $reset."[ ".$darkgrey."$fgenre ".$reset."]::"; 
    }

    my $fpretime_human = time2str("%T %Z", $fpretime);
    my @fdate = toDate($fpretime);
    $fpretime = $time - $fpretime;
    $fpretime = unixToHuman($fpretime);
    $fpretime = $reset."[ ".$limegreen."PRETiME".$reset.": "
        .$darkgrey."$fpretime ago on $fdate[0].$fdate[1].$fdate[2] "
        ."$fpretime_human".$reset."]::";

    if ($fstatus != 1) {
        if ($fstatus == 2) {
            $fstatus = "SELECT nukereason FROM nukes WHERE releaseid = ? \
                ORDER BY nuketime DESC LIMIT 0,1";
            @params = ($freleaseid);
            my $nuke = runSqlSingle($fstatus, @params);
            $fstatus = $reset."[ ".$red."NUKED".$reset.": ".$darkgrey."$nuke "
                .$reset."]::";
        }
        else {
            $fstatus = "SELECT unnukereason FROM unnukes WHERE releaseid = ? \
                ORDER BY unnuketime DESC LIMIT 0,1";
            @params = ($freleaseid);
            my $nuke = runSqlSingle($fstatus, @params);
            $fstatus = $reset."[ ".$limegreen."UNNUKED".$reset.": "
                .$darkgrey."$nuke ".$reset."]::";
        }
    }
    else {
        undef($fstatus);
    }

    $first = $first.$finfo.$fgenre.$fstatus.$fpretime;

    # Last release
    my $last = "SELECT r.releaseid, r.releasename, r.pretime, r.status, \
            s.sectionname, a.genrename, i.files, i.size \
            FROM releases AS r \
            LEFT JOIN genres AS g ON r.releaseid = g.releaseid \
            LEFT JOIN allowedgenres AS a ON g.genreid = a.genreid \
            LEFT JOIN infos AS i ON r.releaseid = i.releaseid \
            LEFT JOIN sections AS s ON r.sectionid = s.sectionid \
            LEFT JOIN groups AS gr ON gr.groupid = r.groupid \
            WHERE r.groupid = ? ORDER BY r.pretime DESC LIMIT 0,1";
    @params = ($groupid);

    my @last = runSqlMulti($last, @params);

    my $lreleaseid = $last[0][0];
    my $lpre = $last[0][1];
    my $lpretime = $last[0][2];
    my $lstatus = $last[0][3];
    my $lsection = $last[0][4];
    my $lgenre = $last[0][5];
    my $lfiles = $last[0][6];
    my $lsize = $last[0][7];

    if (length($lsize) == 0) { $lfiles = ""; $lsize = ""; }
    if (length($lgenre) == 0) { $lgenre = ""; }

    $last = $reset."[".$limegreen."LAST".$reset."]::[ ".$darkgrey."$lpre "
        .$reset."]::[ ".$limegreen."$lsection ".$reset."]::";
    my $linfo;
    if ($lsize) { 
        $linfo = $reset."[ ".$darkgrey.$lfiles."F/".$lsize."MB ".$reset."]::"; 
    }

    if ($lgenre) { 
        $lgenre = $reset."[ ".$darkgrey."$lgenre ".$reset."]::"; 
    }

    my $lpretime_human = time2str("%T %Z", $lpretime);
    my @ldate = toDate($lpretime);
    $lpretime = $time - $lpretime;
    $lpretime = unixToHuman($lpretime);
    $lpretime = $reset."[ ".$limegreen."PRETiME".$reset.": ".$darkgrey."
        .$lpretime ago on $ldate[0].$ldate[1].$ldate[2] $lpretime_human "
        .$reset."]::";

    if ($lstatus != 1) {
        if ($lstatus == 2) {
            $lstatus = "SELECT nukereason FROM nukes WHERE releaseid = ? \
                ORDER BY nuketime DESC LIMIT 1";
            @params = ($lreleaseid);
            my $nuke = runSqlSingle($lstatus, @params);
            $lstatus = $reset."[ ".$red."NUKED".$reset.": ".$darkgrey."$nuke "
                .$reset."]::";
        }
        else {
            $lstatus = "SELECT unnukereason FROM unnukes WHERE releaseid = ? \
                ORDER BY unnuketime DESC LIMIT 1";
            @params = ($lreleaseid);
            my $nuke = runSqlSingle($lstatus, @params);
            $lstatus = $reset."[ ".$limegreen."UNNUKED".$reset.": "
                .$darkgrey."$nuke ".$reset."]::";
        }
    }
    else {
        undef($lstatus);
    }

    $last = $last.$linfo.$lgenre.$lstatus.$lpretime;

    $sql = "SELECT s.sectionname, COUNT(r.releaseid) AS lasku \
            FROM releases AS r, sections AS s \
            WHERE r.groupid = ? AND r.sectionid = s.sectionid \
            GROUP BY s.sectionname ORDER BY lasku desc LIMIT 3";
    @params = ($groupid);

    my @favsection = runSqlMulti($sql, @params);

    my $x = 0;
    my $y = @favsection;
    my $favourites = $reset."[".$limegreen."TOP SECTiONS".$reset.": ";
    while ($x < $y) {
        if ($x == 0) {
            $favourites = $favourites.$limegreen.$favsection[$x][0].$reset.":"
                .$darkgrey."$favsection[$x][1] (" .
                sprintf("%.2f",($favsection[$x][1] / $total * 100))."%)"
                .$reset;
        }
        else {
            $favourites = "$favourites / ".$limegreen."$favsection[$x][0]"
                .$reset.": ".$darkgrey."$favsection[$x][1] (" .
                sprintf("%.2f",($favsection[$x][1] / $total * 100))."%)"
                .$reset;
        }
        $x++;
    }

    $server->command("MSG $channel $groupinfo");
    $server->command("MSG $channel $first");
    $server->command("MSG $channel $last");
    $server->command("MSG $channel $favourites]");

    printDebug("searchGroup()--[!grp $group]--[$nick]--[$channel]--DONE--");

    return 0;
}

# Subroutine for !howmany <group> trigger
sub searchHowmany {
    my ($server, $group, $channel, $nick) = @_;

    printDebug("searchHowmany()--[!howmany $group]--[$nick]--[$channel]"
        ."--START--");

    my $sql = "SELECT count(releaseid) FROM releases AS r INNER JOIN groups \
        AS gr ON r.groupid = gr.groupid WHERE gr.groupname = ?";
    my @params = ($group);
    my $total = runSqlSingle($sql, @params);

    if (!$total) {
        $server->command("MSG $channel No pres from group $group in my db.");
        return 0;
    }
    else {
        my $message = $reset."[ ".$limegreen."HOWMANY".$reset." ]"
            .$darkgrey." $total releases from $group in my db.";
        $server->command("MSG $channel $message");
    }

    printDebug("searchHowmany()--[!howmany $group]--[$nick]--[$channel]"
        ."--DONE--");
    return 0;
}

# Stats for the past 24 hours
sub searchStats {
    my ($server, $statsChan, $channel, $nick) = @_;

    printDebug("searchStats()--[!stats $statsChan]--[$nick]--[$channel]"
        ."--START--");

    my $time = time();
    my $last24h = $time-(60*60*24);

    my $sql = "SELECT COUNT(r.releaseid) FROM releases AS r \
            LEFT JOIN channels AS c ON c.channelid = r.channelid \
            WHERE c.channelname = ? AND r.pretime BETWEEN ? AND ? LIMIT 1";
    my @params = ($statsChan, $last24h, $time);
    my $channelpres = runSqlSingle($sql, @params);

    $sql = "SELECT COUNT(releaseid) FROM releases WHERE pretime BETWEEN ? \
        AND ? LIMIT 1";
    @params = ($last24h, $time);
    my $allpres = runSqlSingle($sql, @params);

    $sql = "SELECT b.botname, COUNT(r.releaseid) AS pres FROM releases AS r \
        LEFT JOIN bots AS b ON b.botid = r.botid \
        LEFT JOIN channels AS c ON c.channelid = r.channelid \
        WHERE c.channelname = ? AND r.pretime BETWEEN ? AND ? \
        GROUP BY b.botname ORDER BY pres DESC LIMIT 5";

    @params = ($statsChan, $last24h, $time);
    my @Result = runSqlMulti($sql, @params);
    my $k = @Result;

    my $i=0;
    my $z=1;

    my $percent = sprintf("%.2f", (($channelpres/$allpres)*100));

    $server->command("MSG $channel ".$reset."[ ".$limegreen."STATS "
        .$reset."] -> ".$darkgrey."$statsChan stats for last 24h.".$reset);
    $server->command("MSG $channel ".$reset."[ ".$limegreen."STATS "
        .$reset."] -> ".$darkgrey."$channelpres out of $allpres releases were "
        ."added by $statsChan ($percent%)".$reset);

    if ($channelpres > 0 ) {
        $server->command("MSG $channel ".$reset."[ ".$limegreen."STATS "
            .$reset."] -> ".$darkgrey."TOP5:".$reset);
        while ($i < $k) {
            $server->command("MSG $channel ".$reset."[ ".$limegreen."STATS "
                .$reset."] -> ".$darkgrey."$z. $Result[$i][0] with "
                ."$Result[$i][1] pres".$reset);
            $z++;
            $i++;
        }
    }

    printDebug("searchStats()--[!stats $statsChan]--[$nick]--[$channel]"
        ."--DONE--");
}

sub searchTop {
    my ($server, $channel, $nick) = @_;

    printDebug("searchTop()--[!top]--[$nick]--[$channel]--START--");

    my $time = time();
    my $last24h = $time-86400;

    my $sql = "SELECT COUNT(releaseid) FROM releases WHERE pretime BETWEEN ? \
        AND ? LIMIT 1;";
    my @params = ($last24h, $time);
    my $allpres = runSqlSingle($sql);

    $sql = "SELECT b.botname, COUNT(r.releaseid) AS pres FROM releases AS r \
        LEFT JOIN bots AS b ON b.botid = r.botid \
        WHERE r.pretime BETWEEN ? AND ? GROUP BY b.botname \
        ORDER BY pres DESC LIMIT 5";

    my @Result = runSqlMulti($sql, @params);
    my $k = @Result;

    my $i=0;
    my $z=1;

    $server->command("MSG $channel ".$reset."[ ".$limegreen."TOP"
        .$reset." ] -> $darkgrey$allpres releases added in last 24h.".$reset);
    while ($i < $k) {
        $server->command("MSG $channel ".$reset."[ ".$limegreen."TOP "
            .$reset."] -> $darkgrey$z. $Result[$i][0] with $Result[$i][1] "
            ."pres".$reset);
        $z++;
        $i++;
    }

    printDebug("searchTop()--[!top]--[$nick]--[$channel]--DONE--");
    return 0;
}

# Subroutine for !uptime
sub searchUptime {
    my($server, $teksti, $channel, $nick) = @_;

    printDebug("searchUptime()--[!uptime]--[$nick]--[$channel]--START--");

    my $uptime = `uptime`;
    my $time = time();
    my $irssiuptime = $time - $^T;

    $irssiuptime = int($irssiuptime/3600/24)."d ".int($irssiuptime/3600%24).
        "h ".int($irssiuptime/60%60)."m ".int($irssiuptime%60)."s";

    chop($uptime);
    $uptime =~ /.+ up (.+),.+[0-9]+ user/;
    $uptime = $1;
    $uptime =~ s/,  / /;
    $uptime =~ s/ days,/d/;
    $uptime =~ s/:/h /;
    $uptime .= "m";

    $uptime = "[ ".$limegreen."UPTiME".$reset." ]::[ ".$limegreen."BOT"
        .$reset.": ".$darkgrey."$irssiuptime".$reset." ]::[ ".$limegreen
        ."SERVER".$reset.": ".$darkgrey."$uptime".$reset." ]";

    $server->command("MSG $channel $uptime");

    printDebug("searchUptime()--[!uptime]--[$nick]--[$channel]--DONE--");
    return 0;
}

# Subroutine to search nfos from db.
sub searchNfo {
    my ($server, $text, $channel, $nick) = @_;
    my $time = time();
    my $pre = $text;

    $pre = trim($pre);

    printDebug("searchNfo()--[!nfo $pre]--[$nick]--[$channel]--START--");

    my $sql = "SELECT n.releaseid FROM nfos AS n LEFT JOIN releases AS r ON \
        r.releaseid = n.releaseid WHERE r.releasename = ? LIMIT 1";
    my @params = ($pre);
    my $releaseid = runSqlSingle($sql, @params);

    if (!$releaseid) {
        return 0;
    }

    $time = $time + 60;
    $sql = "UPDATE nfos SET timeout = ? WHERE releaseid = ?";
    @params = ($time, $releaseid);
    $sql = runSqlSave($sql, @params);


    if ($output{'triggers'}) {
        my $message = "[ ".$limegreen."NFO".$reset." ]::[ ".$darkgrey."$pre"
            .$reset." ]::[ ".$darkgrey."$shareurl$releaseid".$reset." ]::["
            .$darkgrey." You have 60 seconds".$reset." ]";
        $server->command("MSG $channel $message");
    }

    printDebug("searchNfo()--[!nfo $pre]--[$nick]--[$channel]--DONE--");
    return 0;
}

# Subroutine for !from trigger
sub searchFrom {
    my ($server, $pre, $channel, $nick) = @_;
    my $message;
    my $info;
    my $genre;
    my $nuke;

    if (length($pre) < 8) {
        printDebug("searchFrom()--[Dirname too short!]");
        return 0;
    }

    printDebug("searchFrom()--[!from $pre]--[$nick]--[$channel]--START--");

    my $sql = "SELECT r.releaseid, r.status, c.channelname, c.networkname, \
        b.botname FROM releases AS r \
        LEFT JOIN channels AS c ON r.channelid = c.channelid \
        LEFT JOIN bots AS b ON r.botid = b.botid \
        WHERE r.releasename = ? LIMIT 1";
    my @params = ($pre);
    my @result = runSqlMulti($sql, @params);

    if ($result[0][0]) {
        my $releaseid = $result[0][0];
        my $status = $result[0][1];
        my $addchannel = $result[0][2];
        my $addnet = $result[0][3];
        my $addbot = $result[0][4];

        $message = $reset."[ ".$limegreen."FROM ".$reset."]::[ "
            .$darkgrey."$pre ".$reset."]::[ ".$limegreen."ADDED".$reset.": "
            .$darkgrey."$addbot/$addchannel/$addnet".$reset." ]";
        $server->command("MSG $channel $message");

        return 0;
    }
    else {
        $sql = "SELECT c.channelname, c.networkname, b.botname \
            FROM delpred as d \
            LEFT JOIN channels as c ON d.channelid = c.channelid \
            LEFT JOIN bots as b ON d.botid = b.botid \
            WHERE d.releasename = ? LIMIT 1";
        @result = runSqlMulti($sql, @params);

        if ($result[0][0]) {
            my $deletebot = $result[0][2];
            my $deletechan = $result[0][0];
            my $deletenet = $result[0][1];

            $sql = "SELECT c.channelname, c.networkname, b.botname \
                FROM delpred as d \
                LEFT JOIN channels as c ON d.origchannelid = c.channelid \
                LEFT JOIN bots as b ON d.origbotid = b.botid \
                WHERE d.releasename = ? LIMIT 1";
            my @origresult = runSqlMulti($sql, @params);

            if ($origresult[0][0]) {

                my $origchan = $origresult[0][0];
                my $orignetwork = $origresult[0][1];
                my $origbot = $origresult[0][2];

                $message = $reset."[ ".$limegreen."FROM".$reset." ]::[ "
                    .$darkgrey."$pre ".$reset."]::[ ".$limegreen."ADDED"
                    .$reset.": ".$darkgrey."$origbot/$origchan/$orignetwork"
                    .$reset." ]::[ ".$limegreen."DELETED".$reset.": "
                    .$darkgrey."$deletebot/$deletechan/$deletenet".$reset." ]";
                $server->command("MSG $channel $message");
            }
            else {
                $message = $reset."[ ".$limegreen."FROM".$reset." ]::[ "
                    .$darkgrey."$pre ".$reset."]::[ ".$limegreen."DELETED"
                    .$reset.": ".$darkgrey."$deletebot/$deletechan/$deletenet"
                    .$reset." ]";
                $server->command("MSG $channel $message");
            }
        }
    }

    printDebug("searchFrom()--[!from $pre]--[$nick]--[$channel]--DONE--");
    return 0;
}

## [Current Time] Current unixtime is 1243671519 (30.05.2009 - 10:18:39 CET)
sub searchTime {
    my ($server, $channel, $nick) = @_;

    printDebug("searchTime()--[!time]--[$nick]--[$channel]--START--");

    my $unixtime = time();
    my $time = time2str("%T %Z", time);
    my $date = time2str("%x", time);

    $server->command("MSG $channel [ ".$limegreen."TIME ".$reset."]::[ "
        .$limegreen."UNIXTIME".$reset.": ".$darkgrey."$unixtime "
        .$reset."]::[ ".$darkgrey."$date $time ".$reset."]");

    printDebug("searchTime()--[!time]--[$nick]--[$channel]--DONE--");
    return 0;
}

# Subroutine for converting unixtime to human readable time 
# !convert <unixtime>
sub searchConvert {
    my ($server, $channel, $unixtime, $nick) = @_;

    printDebug("searchConvert()--[!convert $unixtime]--[$nick]--[$channel]"
        ."--START--");

    my $now = time();
    my $start = 1256748600;

    my $time = time2str("%T", $unixtime);
    my $date = time2str("%x", $unixtime);
    my $ago = unixToHuman($now-$unixtime);

    $server->command("MSG $channel [ ".$limegreen."CONVERT".$reset." ]::[ "
        .$darkgrey."$unixtime".$reset." ]::[ ".$darkgrey."$date$time"
        .$reset." ]::[ ".$darkgrey."$ago ago.".$reset." ]");

    printDebug("searchConvert()--[!convert $unixtime]--[$nick]--[$channel]"
        ."--DONE--");
}

# Simple subroutine to return idletime for specified network
# @return microtime to idle between announces
sub getSleepTime {
    my $channel = shift;

    my $sql = "SELECT networkname FROM channels WHERE channelname = ? LIMIT 1";
    my @params = ($channel);
    my $network = runSqlSingle($sql, @params);

    if ($network eq "EXAMPLE_NETWORK_1") {
        return 25000;
    }
    elsif ($network eq "EXAMPLE_NETWORK_2") {
        return 1000;
    }
    else {
        return 1000000; # one second
    }
}

# Subroutine to check channel rights
# @param $channel channel which rights are being checked
# @param $right - right we are testing
# @return 1 if channels has right given as a parameter
# @return 0 if not.
sub checkChannelRights {
    my ($channel, $right) = @_;
    my $admin = "a";

    my $i = 0;
    while ($i < @all_channels) {

        if (($channel =~ /^$all_channels[$i][0]$/i) && ($all_channels[$i][1])) {
            if (($right =~ m/$all_channels[$i][1]/i) || 
                ($admin =~ m/$all_channels[$i][1]/i)) {
                return 1;
            }
        }
        $i++;
    }
    return 0;
}

# subroutine to get channelname with nfo relay access
sub getNfoChannel {
    my $networkShort = shift;
    $networkShort = "-$networkShort";

    my $channelright = 't|u'; # !getnfo ja !oldnfo

        my $sql = "SELECT channelname FROM channels \
            WHERE networkshort = ? AND (channelrights \
            LIKE ? OR channelrights = 'a') LIMIT 1";
    my @params = ($networkShort, "%$channelright%");

    my $nfoChannel = runSqlSingle($sql, @params);

    if (!$nfoChannel) {
        return 0;
    }

    my $result = $networkShort." ".$nfoChannel;

    return $result;
}

# Subroutine that reads channels, networks and channelrights from db.
# Inserts data into appropriate arrays.
# Called everytime the script is loaded.
sub getChannels {

    sqlConnect();

    my $sql = "SELECT channelid, channelname, channelrights, networkshort, \
        networkname FROM channels WHERE 1 = ? ORDER BY priority ASC";
    my @params = (1);

    my @result = runSqlMulti($sql, @params);

    # if no channels in db
    if ($result[0][0] == 0) {
        printDebug("getChannels()--[No channels set in database.]--");
        return 0;
    }

    my $i = 0;
    while ($i < @result) {
        my $channel = $result[$i][1];
        my $channelWithNetwork = $result[$i][3]." ".$result[$i][1];
        my @allFlags = split(/\|/, $result[$i][2]);

        $all_channels[$i][0] = $channel;
        $all_channels[$i][1] = $result[$i][2];

        my $network = $result[$i][4];

        foreach (@allFlags) {

            printDebug("getChannels()--[Network: $network]--[Channel: "
                ."$channel]--[Flag: $_]");

            if ($_ eq 'l') { 
                push(@search_channels, $channel); 
                push(@search_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'o') { 
                push(@pre_channels, $channel); 
                push(@pre_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'b') { 
                push(@addpre_channels, $channel); 
            }
            if ($_ eq 'g') { 
                push(@addpre_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'c') { 
                push(@info_channels, $channel); 
            }
            if ($_ eq 'h') { 
                push(@info_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'c') { 
                push(@gn_channels, $channel); 
            }
            if ($_ eq 'w') { 
                push(@gn_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'f') { 
                push(@delpre_channels, $channel); 
            }
            if ($_ eq 'j') { 
                push(@delpre_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'e') { 
                push(@addold_channels, $channel); 
            }
            if ($_ eq 'k') { 
                push(@addold_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'd') { 
                push(@nuke_channels, $channel); 
            }
            if ($_ eq 'i') { 
                push(@nuke_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'd') { 
                push(@unnuke_channels, $channel); 
            }
            if ($_ eq 'x') { 
                push(@unnuke_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'm') { 
                push(@play_channels, $channel); 
                push(@play_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'n') { 
                push(@getold_channels, $channel); 
                push(@getold_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'q') { 
                push(@sitepre_channels, $channel); 
            }
            if ($_ eq 'r') { 
                push(@sitepre_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'a') { 
                push(@admin_channels, $channel); 
                push(@admin_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'p') { 
                push(@nukenet_search_channels, $channel); 
                push(@nukenet_search_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 's') { 
                push(@addnfo_channels, $channel); 
            }
            if ($_ eq 't') { 
                push(@addnfo_channels_echo, $channelWithNetwork); 
            }
            if ($_ eq 'y') { 
                push(@ginfo_channels, $channel); 
            }
            if ($_ eq 't') { 
                push(@ginfo_channels_echo, $channelWithNetwork); 
            }
            if ($_ == 1) { 
                push(@addurl_channels, $channel); 
            }
            if ($_ == 2) { 
                push(@addurl_channels_echo, $channelWithNetwork); 
            }
        }
        $i++;
    }

    sqlDisconnect();

    return 1;
}


# Runs sql query with multiple possible results
# Meaning SELECT something, something FROM...
# Returns array with results or zero if nothing is found.
sub runSqlMulti {
    my ($query, @params) = @_;
    my @result;
    my $i =0 ;

    my $sth = $dbh->prepare($query) or return 0;

    if ($sth->execute(@params)) {
        while (my @currow = $sth->fetchrow_array()) {
            $result[$i] = \@currow;
            $i++;
        }
    }

    $sth->finish;

    if (!$i) {
        $result[0][0] = 0;
        return @result;
    }

    return @result;
}

# Runs sql query with single possible result
# Meaning SELECT justthis FROM somewhere...
# Returns array with results or zero if nothing is found.
sub runSqlSingle {
    my ($query, @params) = @_;
    my @result;
    my $i =0 ;

    my $sth = $dbh->prepare($query) or return 0;

    if ($sth->execute(@params)) {
        while (my @currow = $sth->fetchrow_array()) {
            $result[$i] = \@currow;
            $i++;
        }
    }

    $sth->finish;

    if (!$i) {
        return 0;
    }

    return $result[0][0];
}

# This function is used when we want to save something into db
# Takes SQL statement as a parameter
# Returns 1 if save succeeded, returns 0 otherwise
sub runSqlSave {
    my ($query, @params) =  @_;
    my @result;

    my $sth = $dbh->prepare($query) or return 0;

    if ($sth->execute(@params)) {
        $sth->finish;
        return 1;
    }

    $sth->finish;
    return 0;
}

# initialize connection
sub sqlConnect {
    my $data_source = "DBI:mysql:database=$mysql{'dbname'};host=",
                      "$mysql{'host'};$mysql{'port'}";

    $dbh = DBI->connect($data_source, $mysql{'user'}, $mysql{'pass'}, {
            'RaiseError' => 1
            }) or die "could not connect to mysql database";
}

# close connection
sub sqlDisconnect {
    $dbh->disconnect();
}


## Perl trim function to remove whitespace
## from the start and end of the string
sub trim {
    my $string = shift;

    $string =~ s/^\s+//;
    $string =~ s/\s+$//;

    return $string;
}

## Strip letters from input
sub stripLetters {
    my $text = shift;

    $text =~ s/^a-zA-Z//gi;

    return $text;
}

## Strip colors form input
sub stripColor {
    my $string = shift;

# mIRC colors
    $string =~ s/\x03(?:\d{1,2}(?:,\d{1,2})?)?//g;
    $string =~ s/\x0f//g;

# RGB colors supported by some clients
    $string =~ s/\x04[0-9a-f]{0,6}//ig;

    return $string;
}

## Strip formating from input
sub stripFormatting {
    my $string = shift;
    $string =~ s/[\x0f\x02\x1f\x16\x1d\x11]//g;

    return $string;
}

# Tarkistaa onko syöte numero. Palauttaa 1 jos true
sub isNumeric {
    my $text = shift;
    if ($text =~ /^(\d+\.?\d*|\.\d+)$/) {
        return 1;
    }

    return 0;
}

sub toDate {
    my $time = shift;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($time);

    $year += 1900;
    $mon++;

    if ($mon < 10) {
        $mon="0".$mon;
    }

    if($mday < 10) {
        $mday = "0".$mday;
    }

    my $date_string = $mon.$mday." @ ".$year;

    ## Return in arrray 0 = dd, 1 = mm, 2 = YYYY
    my @time;
    $time[0] = $mday;
    $time[1] = $mon;
    $time[2] = $year;

    return @time;
}

sub unixToHuman {
    my ($utime) = @_;
    my $result;
    my $years;
    my $months;
    my $weeks;
    my $days;
    my $hours;
    my $minutes;
    my $seconds;

    $years = int($utime / 31556926);
    if ($years > 0) {
        $utime = $utime - (31556926 * $years);
        $result = $years ."y ";
    }

    $weeks = int($utime / 604800);
    if ($weeks > 0) {
        $utime = $utime - (604800 * $weeks);
        $result = $result . "" . $weeks . "w ";
    }

    $days = int($utime / 86400);
    if ($days > 0) {
        $utime = $utime - (86400 * $days);
        $result = $result . "" . $days . "d ";
    }

    $hours = int($utime / 3600);
    if ($hours > 0) {
        $utime = $utime - (3600 * $hours);
        $result = $result . "" . $hours . "h ";
    }

    $minutes = int($utime / 60);
    if ($minutes > 0) {
        $utime = $utime - (60 * $minutes);
        $result = $result . "" . $minutes . "min ";
    }

    $result = $result . "" . $utime . "s";

    return $result;
}

# prints debugmessages
sub printDebug {
    my $message = shift;

    if ($output{'debug'}) {
        print " ".$message;
    }

    return 0;
}
