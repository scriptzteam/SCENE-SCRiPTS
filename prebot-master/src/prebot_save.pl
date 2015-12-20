########################################
##  Prebot v3 - Save script
##  =======================================
##	This irssi scripts is a part of a larger script collection, which
##	implements prebot functionality to irssi. This particular script
##	enables save functions.
##
##
##  Channelrights
##  ========================
##	a = admin channel
##	b = reads !addpre
## 	c = reads !info ja !gn
##	d = reads !nuke / !unnuke / !modnuke  
##	e = reads !addold
##	f = reads !delpre / !undelpre
## 	g = relays !addpre
## 	h = relays !info
## 	i = relays !nuke / !unnuke / !modnuke
## 	j = relays !delpre / !undelpre
## 	k = relays !addold
## 	l = permission to use prechannel searches !pre, !pred, !dupe, !group,
## 	m = !play trigger
## 	n = !getold trigger
##	o = announce
##	p = nukenet search
##	q = lukee !sitepre
##	r = echoaa !sitepre
##	s = reads !addnfo
##	t = relays !addnfo
##	u = !getnfo trigger
##	v = reads !spreadnfo
##	w = relays !gn
##	x = relays !unnuke
##	y = reads !ginfo
##	z = relays !ginfo
##	1 = read !addurl
##	2 = relay !addurl
##
##      Channel rights are separated with | character in database.
##
##  Triggers
##  ========================
##
##	Addpre
##	======
##	    !addpre <release> <section>
##
##	Infochannels
##	============
##	    !gn <release> <genre>
##	    !info <release> <files> <size>
##
##	Nukechannels
##	============
##	    !nuke <release> <reason> <source>
##	    !unnuke <release> <reason> <source>
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
##	    !from <pre>
##	    !bot <bot>
##	    !owner <owner>
##
##      Addnfochannels
##	==============
##	    !addnfo <release> <url> <nfoname>
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
##	    !fix <rellu> <section>
##	    !spreadnfo <release>
##
###############################################################################

#use warnings;
use strict;

use vars qw($VERSION %IRSSI);
use DBI();
use IO::Socket;
use MIME::Base64;
use Digest::MD5 qw(md5_hex);
use String::CRC32;
use Irssi;
use LWP::Simple;
use JSON;
#use IMDB::Film;

$VERSION = '3.00';
%IRSSI = (
    authors     => 'JH',
    contact     => 'haaja@iki.fi',
    name        => 'prebot_save',
    description => 'Prebot for irssi',
    license     => 'WTFPL',
);

# MYSQL options
our %mysql = (
    user => 'user',
    pass => 'password',
    host => 'localhost',
    port => '3306',
    dbname => 'db_name',
);

# database handle
our $dbh;

# Output options
our %output = (
    announcePre		=> '1',
    announceOld		=> '1',
    announceNuke	=> '1',
    announceGenre	=> '0',
    announceDelpre	=> '0',
    announceNfo		=> '0',
    announceError	=> '1',
    echo		=> '1',
    debug		=> '1',
    triggers		=> '1'
);

our %limits = (
    releaseLength	=> '250',
    groupLength		=> '50',
    nukereasonLength	=> '250',
    sectionLength	=> '20',
    nukenetLength	=> '30',
    nfoHashLeng		=> '32',
    nfonameLgth		=> '100',
);

our $blockednfo = "imdb.nfo|autotrader.nfo|scc.nfo|hqscene.nfo|unknown.nfo";

our $valid_sections = "XVID|XXX|MP3|AUDIOBOOK|X264|DVDR|BLURAY|TV|0DAY|APPS",
                      "|ANIME|MVID|EBOOK|IMGSET|MDVDR|X360|XBOX|PS3|PS2|PSP|",
                      "NDS|GBA|WII|GAMES|DOX|SUBPACK|COVERS|SVCD|VCD|VC1|PDA|",
                      "NGC|DIVX|NOTICE|BDR|TV-X264|TV-XVID|TV-DVDR|DC|MBLURAY";

our $gamegroups	= "RELOADED|Razor1911|DEViANCE|FLT|HATRED|ViTALiTY";
our $porngroups	= "Pr0nStars|DivxFactory|swe6rus|pornolation|xcite|nympho|",
                  "imnaked|tesoro";
our $problemgroups = "VH-PROD|get.proper|S.W.A.T|HELLS.ANGELS|EnDoR.Internal|",
                     "T.E.D|XPERT_HD|XPERT.Internal";

# Variables used in skiplist
our $allowedchars = "^[a-zA-Z0-9\_\.\(\)\&\-]*\$";
our $allowed_nukechars = "^[a-zA-Z0-9\_\.\(\)\-]*\$";

our $allowed = "GREATEST|TESTEES|SWEETEST|ActualTests|TESTAMENT|FLATTEST|",
               "CONTEST|HOTTEST";
our $filter = "SPAM|TEST|T3ST|DONT.TRADE|NO.TRADE|SPAM|Sorry.|TESTING|P2P|",
              "REQ\-|FILLED\-|no\-nfo|no\-sfv";
our $p2p_groups = "DEViSE|KingBen|aXXo|EOSiNT|AJP|AXIAL|CtrlHD|DNR|EOS|ESiR|",
                  "Funner|GHEYLARD|G0LDz|HDB|HDC|HDV|HDxT|HDmonSK|iAPULA|iLL|",
                  "iRO|M14CH0|M794|McFly|MMI|PerfectionHD|PoTuS|STG|TDM|THS|",
                  "TFE|THORA|tK|TriggeR|XSHD|Stuffies|FpTV";

our $allowedUrls = "tvrage|epguide|imdb";

###############################################################################
#                              CONFIGURATION ENDS                             #
###############################################################################

# Arrays for different type of channels, these are read from database.
our @admin_channels;
our @admin_channels_echo;
our @addpre_channels;
our @addpre_channels_echo;
our @info_channels;
our @info_channels_echo;
our @gn_channels;
our @gn_channels_echo;
our @nuke_channels;
our @nuke_channels_echo;
our @unnuke_channels;
our @unnuke_channels_echo;
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
our @addurl_channels;
our @addurl_channels_echo;

# lets read those channels from db
getChannels();

# Temp variables used to store last saved pre of the type
our %last = (
    pre 	=> 'null',
    info 	=> 'null',
    gn		=> 'null',
    sitepre	=> 'null',
    nuke	=> 'null',
    unnuke	=> 'null',
    nfo		=> 'null',
    delpre	=> 'null',
    modnuke	=> 'null',
    addold	=> 'null',
    ginfo	=> 'null',
    url		=> 'null'
);

our %error = (
    pre 	    => 'null',
    info 	    => 'null',
    gn		    => 'null',
    sitepre	    => 'null',
    nuke	    => 'null',
    nukereason 	    => 'null',
    unnuke	    => 'null',
    unnukereason    => 'null',
    modnuke	    => 'null',
    modnukereason   => 'null',
    nfo		    => 'null',
    delpre	    => 'null',
    addold	    => 'null',
    ginfo	    => 'null',
    url		    => 'null'
);

# IRC colors
our $lightgrey	= "\00300";
our $black	= "\00301";
our $royalblue	= "\00302";
our $green	= "\00303";
our $red	= "\00304";
our $marroon	= "\00305";
our $purple     = "\00306";
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

# lets bind our script to irssi message public signal
Irssi::signal_add("message public", "handleTriggers");

# lets handle signals irssi throws
sub handleTriggers {

    my ($server, $msg, $nick, $address, $channel) = @_;
    my $old = 0;

    $msg = stripColor(stripFormatting($msg));

    my ($trigger, $text) = split(" ", $msg, 2);
    $text = stripSqlInjection($text);

    sqlConnect();

    # lets identify the trigger and call the right subroutine 
    if (($trigger eq "!addpre") && checkChannelRights($channel, 'b')) {
        savePre($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!info") && checkChannelRights($channel, 'c')) {
        saveInfo($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!oldinfo") && checkChannelRights($channel, 'c')) {
        saveInfo($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!ginfo") && checkChannelRights($channel, 'y')) {
        saveGinfo($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!gn") && checkChannelRights($channel, 'c')) {
        saveGenre($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!oldgn") && checkChannelRights($channel, 'c')) {
        saveGenre($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!addnfo") && checkChannelRights($channel, 's')) {
        saveNfo($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!oldnfo") && checkChannelRights($channel, 's')) {
        saveNfo($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!sitepre") && checkChannelRights($channel, 'q')) {
        saveSitepre($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!nuke") && checkChannelRights($channel, 'd')) {
        saveNuke($text, $server, $channel, $nick, $old);
    }
    elsif (($trigger eq "!modnuke") && checkChannelRights($channel, 'd')) {
        saveModnuke($text, $server, $channel, $nick, $old);
    }
    elsif (($trigger eq "[MODNUKE]") && checkChannelRights($channel, 'd')) {
        my ($prefix, $text) = split(" ", $text, 2);
        saveModnuke($text, $server, $channel, $nick, $old);
    }
    elsif (($trigger eq "[NUKE]") && checkChannelRights($channel, 'd')) {
        my ($prefix, $text) = split(" ", $text, 2);
        saveNuke($text, $server, $channel, $nick, $old);
    }
    elsif (($trigger eq "!unnuke") && checkChannelRights($channel, 'd')) {
        saveUnnuke($text, $server, $channel, $nick, $old);
    }
    elsif (($trigger eq "[UNNUKE]") && checkChannelRights($channel, 'd')) {
        my ($prefix, $text) = split(" ", $text, 2);
        saveUnnuke($text, $server, $channel, $nick, $old);
    }
    elsif (($trigger eq "!delpre") && checkChannelRights($channel, 'f')) {
        saveDelpre($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!olddelpre") && checkChannelRights($channel, 'f')) {
        saveDelpre($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "[DELPRE]") && checkChannelRights($channel, 'f')) {
        my ($prefix, $text) = split(" ", $text, 2);
        saveDelpre($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!addold") && checkChannelRights($channel, 'e')) {
        saveAddold($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!fix") && checkChannelRights($channel, 'a')) {
        saveFix($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!updatetime") && checkChannelRights($channel, 'e')) {
        saveUpdatetime($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!undelpre") && checkChannelRights($channel, 'f')) {
        saveUndelpre($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "[UNDELPRE]") && checkChannelRights($channel, 'f')) {
        my ($prefix, $text) = split(" ", $text, 2);
        saveUndelpre($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!addurl") && checkChannelRights($channel, '1')) {
        saveUrl($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!oldurl") && checkChannelRights($channel, '1')) {
        saveUrl($text, $server, $channel, $nick);
    }
    elsif (($trigger eq "!announce") && checkChannelRights($channel, 'a')) {
        my $status;

        if (($text eq "on") && (!$output{'announcePre'})) {
            $output{'announcePre'} = 1;
            $status = "ON";
        }
        elsif (($text eq "off") && $output{'announcePre'}) {
            $output{'announcePre'} = 0;
            $status = "OFF";
        }
        else {
            return 0;
        }
        $status = "ANNOUNCE: $status";
        announceError($server, $status);
    }
    elsif (($trigger eq "!echo") && checkChannelRights($channel, 'a')) {
        my $status;

        if (($text eq "on") && (!$output{'echo'})) {
            $output{'echo'} = 1;
            $status = "ON";
        }
        elsif (($text eq "off") && $output{'echo'}) {
            $output{'echo'} = 0;
            $status = "OFF";
        }
        else {
            return 0;
        }

        $status = "ECHO: $status";
        announceError($server, $status);
    }

    # For testing purposes only!
    elsif (($trigger eq "!checksection") && checkChannelRights($channel, 'a')) {
        my $result = checkSection($text);
        $server->command("MSG $channel SECTIONS: $result");
    }
    elsif (($trigger eq "!sections") && checkChannelRights($channel, 'a')) {
        $server->command("MSG $channel SECTIONS: $valid_sections");
    }
    elsif (($trigger eq "!groupcheck") && checkChannelRights($channel, 'a')) {
        $text = check_group($text);
        $server->command("MSG $channel GROUP: $text");
    }

    sqlDisconnect();
}

# Function to save pre into db from !addpre trigger
# input: <release> <section>
sub savePre {
    my ($text, $server, $channel, $nick) = @_;
    my ($pre, $section) = split(" ", $text, 2);

    my $pretime = time();
    my $noecho = 0;

    $pre = trim($pre);
    $section = trim($section);

    # Simple filter to avoid unnecessary db queries
    if ($last{'pre'} eq $pre) {
        return 0;
    }

    if (checkIfPreExists($pre)) {
        $last{'pre'} = $pre;
        return 0;
    }

    my $botId = checkBot($nick, "addpre");
    if (!$botId) {
        return 0;
    }

    printDebug("savePre()--[!addpre $pre $section]--[$nick]--[$channel]"
        ."--START--");

    if (!checkPre($pre)) {
        if ($pre ne $error{'pre'}) {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."savePre()",
                          "--[Invalid dirname $pre]--[$nick]";
            announceError($server, $message);
            printDebug("[ERROR] savePre()--[Invalid dirname $pre]--[$nick]");
            $error{'pre'} = $pre;
        }
        return 0;
    }

    if (!filterPre($pre)) {
        if ($pre ne $error{'pre'}) {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."savePre()",
                          "--[Possibly something wrong with dirname $pre]",
                          "--[$nick]--[$channel]";
            announceError($server, $message);
            printDebug("[ERROR] savePre()--[Possibly something wrong with "
                ."dirname $pre]--[$nick]--[$channel]");
        }
        $error{'pre'} = $pre;
        $noecho = 1;
    }

    my $groupId = getGroupId($pre);
    if (!$groupId) {
        printDebug("[ERROR] Unable to get group from $pre");
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."savePre()--",
                      "[Unable to get group from $pre]--[$nick]--[$channel]";
        announceError($server, $message);
        return 0;
    }

    $section = checkSection($pre, $section);
    if (!$section) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."savePre()--[",
                      "Unable to define section for $pre]--[$nick]--[$channel]";
        printDebug("[ERROR] savePre()--[Unable to define section for $pre]"
            ."--[$nick]--[$channel]");
        announceError($server, $message);
        return 0;
    }

    $section = uc($section);

    if (!$noecho) {
        my $message = "!addpre $pre $section";
        if ($output{'echo'}) {
            echoPre($server, $message);
        }
    }

    my $sectionId = getSectionId($section);
    my $releaseId = getReleaseId($pre);
    my $channelId = getChannelId($channel);

    my $sql = "INSERT INTO releases(releasename, pretime, groupid, sectionid, ",
              "channelid, botid) VALUES (?, ?, ?, ?, ?, ?)";
    my @params = ($pre, $pretime, $groupId, $sectionId, $channelId, $botId);

    if (!runSqlSave($sql, @params)) {
        printDebug("[ERROR] savePre()--[Unable to save $pre into db]--[$nick]"
            ."--[$channel]");
        $error{'pre'} = $pre;
        return 0;
    }

    if ($output{'announcePre'}) {
        my $message = "$pre $section";
        announcePre($server, $message);
    }
    $last{'pre'} = $pre;

    fetchDataFromNet($pre, $server);

    printDebug("savePre()--[!addpre $pre $section]--[$nick]--[$channel]"
        ."--DONE--");
    return 0;
}

# Save info
# input: <release> <files> <size>
sub saveInfo {
    my ($text, $server, $channel, $nick) = @_;
    my ($pre, $files, $size) = split(" ", $text, 3);

    $pre = trim($pre);
    $files = stripLetters(trim($files));
    $size = stripLetters(trim($size));

    if ($last{'info'} eq $pre) {
        return 0;
    }

    if ($size =~ /\.$/) {
        printDebug("[ERROR] saveInfo()--[Size ends with dot]--[!info $pre "
            ."$files $size]--[$nick]--[$channel]");
        return 0;
    }

    if (checkIfInfoExists($pre)) {
        $last{'info'} = $pre;
        return 0;
    }

    my $releaseId = getReleaseId($pre);
    if (!$releaseId) {
        if ($pre ne $error{'info'}) {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveInfo()",
                          "--[No such pre in db]--[!info $pre $files $size]",
                          "--[$nick]--[$channel]";
            announceError($server, $message);
        }
        $error{'info'} = $pre;
        return 0;
    }

    printDebug("saveInfo()--[!info $pre $files $size]--[$nick]--[$channel]"
        ."--START--");

    my $botId = checkBot($nick, "info");
    if (!$botId) {
        return 0;
    }

    if (!checkInfos($files, $size)) {
        if ($pre ne $error{'info'}) {
            my $msg = "[".$red."ERROR".$reset."] ".$darkgrey."saveInfo()",
                      "--[Invalid infos]--[!info $pre $files $size]--[$nick]",
                      "--[$channel]";
            announceError($server, $msg);
            $error{'info'} = $pre;
        }
        return 0;
    }

    if ($output{'echo'}) {
        echoInfo($server, $pre, $files, $size);
    }

    my $tmp = sprintf("%.1f", $size);
    if (!$tmp) {
        $size = sprintf("%.2f", $size);
    }
    else {
        $size = $tmp;
    }

    my $channelId = getChannelId($channel);

    my $sql = "INSERT INTO infos(releaseid, files, size, channelid, botid) ",
              "VALUES (?, ?, ?, ?, ?)";
    my @params = ($releaseId, $files, $size, $channelId, $botId);

    if (!runSqlSave($sql, @params)) {
        printDebug("[ERROR] saveInfo()--[Unable to save infos to db]--[!info"
            ." $pre $files $size]--[$nick]--[$channel]");
        $error{'info'} = $pre;
        return 0;
    }

    $last{'info'} = $pre;
    printDebug("saveInfo()--[!info $pre $files $size]--[$nick]--[$channel]"
        ."--DONE--");
    return 0;
}

# Function to save !ginfo.
# !ginfo comes straight from sites so we can assume them being correct and 
# ignore existing infos
# input: <release> <files> <size>
sub saveGinfo {
    my ($text, $server, $channel, $nick) = @_;
    my ($pre, $files, $size) = split(" ", $text, 3);
    my $result;

    $pre = trim($pre);
    $files = stripLetters(trim($files));
    $size = stripLetters(trim($size));

    if ($pre eq $last{'ginfo'}) {
        return 0;
    }

    if (!checkInfos($files, $size)) {
        if ($pre ne $error{'info'}) {
            my $msg = "[".$red."ERROR".$reset."] ".$darkgrey."saveGinfo()",
                      "--[Invalid infos]--[!ginfo $pre $files $size]--[$nick]",
                      "--[$channel]";
            announceError($server, $msg);
            $error{'ginfo'} = $pre;
        }
        return 0;
    }

    my $releaseId = getReleaseId($pre);
    if (!$releaseId) {
        if ($pre ne $error{'info'}) {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveGinfo()",
                          "--[No such pre in db]--[!ginfo $pre $files $size]",
                          "--[$nick--[$channel]]";
            announceError($server, $message);
        }
        $error{'ginfo'} = $pre;
        return 0;
    }

    printDebug("saveGinfo()--[!ginfo $pre $files $size]--[$nick]--[$channel]"
        ."--START--");

    my $tmp = sprintf("%.1f", $size);
    if ($tmp == 0) {
        $size = sprintf("%.2f", $size);
    }
    else {
        $size = $tmp;
    }

    my $botId = checkBot($nick, "info");
    if (!$botId) {
        return 0;
    }

    my $channelId = getChannelId($channel);

    if (checkIfInfoExists($pre)) {
        my $sql = "UPDATE infos SET files = ?, size = ?, channelid = ?, ",
                  "botid = ? WHERE releaseid = ? LIMIT 1";
        my @params = ($files, $size, $channelId, $botId, $releaseId);
        $result = runSqlSave($sql, @params);
    }
    else {
        my $sql = "INSERT INTO infos(releaseid, files, size, channelid, ",
                  "botid) VALUES (?, ?, ?, ?, ?)";
        my @params = ($releaseId, $files, $size, $channelId, $botId);
        $result = runSqlSave($sql, @params);
    }

    if (!$result) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveGinfo()",
                      "--[Unable to save ginfo to db]--[!ginfo $pre $files ",
                      "$size]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("saveGinfo()--[Unable to save ginfo to db]--[!ginfo $pre "
            ."$files $size]--[$nick]--[$channel]");
        $error{'ginfo'} = $pre;
        return 0;
    }

    $last{'ginfo'} = $pre;
    printDebug("saveGinfo()--[!ginfo $pre $files $size]--[$nick]--[$channel]"
        ."--DONE--");
}

# Function to save sitepres
# input: <release> <files> <size>
sub saveSitepre {
    my ($text, $server, $channel, $nick) = @_;
    my ($pre, $section, $files, $size) = split(" ", $text, 4);
    my $addresult = 0;

    $pre = trim($pre);
    $section = trim($section);
    $files = stripLetters(trim($files));
    $size = stripLetters(trim($size));

    if ($pre eq $last{'pre'}) {
        return 0;
    }

    my $pretime = time();

    $files =~ s/\-//g;
    $size =~ s/\-//g;

    if (checkIfPreExists($pre)) {
        $last{'pre'} = $pre;
        return 0;
    }

    my $botId = checkBot($nick, "addpre");
    if (!$botId) {
        return 0;
    }

    my $channelId = getChannelId($channel);

    if ($size) {
        printDebug("saveSitepre()--[!sitepre $pre $section $files $size]--["
            ."$nick]--[$channel]--START--");
    }
    else {
        printDebug("saveSitepre()--[!sitepre $pre $section - -]--[$nick]--["
            ."$channel]--START--");
    }

    my $temp = $section;
    $section = checkSection($pre, $section);
    if (!$section) {
        printDebug("[ERROR] saveSitepre()--[Unable to define section]--["
            ."!sitepre $pre $temp $files $size]--[$nick]--[$channel]");
        return 0;
    }

    my $sectionId = getSectionId($section);
    my $groupId = getGroupId($pre);
    if (!$groupId) {
        printDebug("[ERROR] saveSitepre()--[Unable to get group from $pre]"
            ."--[$nick]--[$channel]");
        return 0;
    }

    if ($output{'announcePre'}) {
        my $message = "$pre $section";
        announcePre($server, $message);
    }

    my $sql = "INSERT INTO releases(releasename, pretime, groupid, sectionid,",
              "channelid, botid) VALUES (?, ?, ?, ?, ?, ?)";
    my @params = ($pre, $pretime, $groupId, $sectionId, $channelId, $botId);

    $addresult = runSqlSave($sql, @params);
    if (!$addresult) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveSitepre()",
                      "--[Unable to save sitepre]--[!sitepre $pre $files ",
                      "$size]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("[ERROR] saveSitepre()--[Unable to save sitepre]--["
            ."!sitepre $pre $files $size]--[$nick]--[$channel]");
        return 0;
    }

    # Try fetching additional data from internet
    fetchDataFromNet($pre, $server);

    my $releaseId = getReleaseId($pre);
    if (!$releaseId) {
        printDebug("[ERROR] saveSitepre()--[Unable to get releaseid]--[$pre]"
            ."--[$nick]--[$channel]");
        return 0;
    }

    if (checkIfInfoExists($pre)) {
        return 0;
    }

    if (!checkInfos($files, $size)) {
        if ($pre ne $error{'info'}) {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."",
                          "saveSitepre()--[Invalid infos]--[!sitepre $pre ",
                          "$files $size]--[$nick]--[$channel]";
            announceError($server, $message);
            $error{'pre'} = $pre;
        }

        $last{'pre'} = $pre;
        printDebug("saveSitepre()--[!sitepre $pre $section - -]--[$nick]--["
            ."$channel]--DONE--");

        return 0;
    }

    $temp = sprintf("%.1f", $size);
    if (!$temp) {
        $size = sprintf("%.2f", $temp);
    }
    else {
        $size = $temp;
    }

    $sql = "INSERT INTO infos(releaseid, files, size, botid, channelid) ",
           "VALUES (?, ?, ?, ?, ?)";
    @params = ($releaseId, $files, $size, $botId, $channelId);
    my $infoResult = runSqlSave($sql, @params);
    if (!$infoResult) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."",
                      "saveSitepre()--[Unable to save infos]--[!sitepre $pre",
                      "$files $size]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("[ERROR]: saveSitepre()--[Unable to save infos]--[!info "
            ."$pre $files $size]--[$nick]--[$channel]");
        return 0;
    }

    $last{'pre'} = $pre;
    printDebug("saveSitepre()--[!sitepre $pre $section $files $size]--"
        ."[$nick]--[$channel]--DONE--");

    return 0;
}

# Function to save genres for pres
# input: <release> <genre>
sub saveGenre {
    my ($text, $server, $channel, $nick) = @_;
    my ($pre, $genre) = split(" ", $text, 2);

    $pre = trim($pre);
    $genre = trim($genre);

    my $genretime = time();

    if (($last{'gn'} eq $pre) || ($error{'gn'} eq $genre) || 
        (length($genre) <= 1)) {
        return 0;
    }

    if (checkIfPreExists($pre) != 1) {
        if ($error{'gn'} ne $pre) {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveGenre()",
                          "--[No such pre in db]--[!gn $pre $genre]--[$nick]",
                          "--[$channel]";
            announceError($server, $message);
            printDebug("[ERROR] saveGenre()--[No such pre in db]--[!gn $pre "
                ."$genre]--[$nick]--[$channel]");
        }
        $error{'gn'} = $genre;
        return 0;
    }

    if (checkIfGenreExists($pre)) {
        $last{'gn'} = $pre;
        return 0;
    }

    my $botId = checkBot($nick, "genre");
    if (!$botId) {
        return 0;
    }

    my $genreCheck = checkIfAllowedGenre($pre, $genre);

    if (!$genreCheck) {
        my @genres;

        if ($genre =~ /\_/) {
            @genres = split(/\_/, $genre);
            for my $gn (@genres) {
                if (checkIfAllowedGenre($pre, $gn)) {
                    $genreCheck = 1;
                    $genre = $gn;
                    last; 
                }
            }
        }
        elsif ($genre =~ /\//) {
            @genres = split(/\//, $genre);
            for my $gn (@genres) {
                if (checkIfAllowedGenre($pre, $gn)) {
                    $genreCheck = 1;
                    $genre = $gn;
                    last; 
                }
            }
        }
        else {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveGenre()",
                          "--[Invalid genre]--[!gn $pre $genre]--[$nick]",
                          "--[$channel]";
            announceError($server, $message);
            printDebug("[ERROR] saveGenre()--[Invalid genre]--[!gn $pre "
                ."$genre]--[$nick]--[$channel]");
            $error{'gn'} = $genre;

            return 0;
        }

        if (!$genreCheck) {
            if ($error{'gn'} ne $pre) {
                my $message = "[".$red."ERROR".$reset."] ".$darkgrey."",
                              "saveGenre()--[Invalid genre]--[!gn $pre $genre",
                              "]--[$nick]--[$channel]";
                announceError($server, $message);
                printDebug("[ERROR] saveGenre()--[Invalid genre]--[!gn $pre "
                    ."$genre]--[$nick]--[$channel]");
            }
            $error{'gn'} = $genre;

            return 0;
        }
    }
    else {
        $genre = $genreCheck;
    }

    printDebug("saveGenre()--[!gn $pre $genre]--[$nick]--[$channel]--START--");

    my $msg;

    if ($output{'echo'}) {
        echoGenre($server, $pre, $genre);
    }

    my $releaseId = getReleaseId($pre);
    if (!$releaseId) {
        return 0;
    }

    my $channelId = getChannelId($channel);
    if (!$channelId) {
        return 0;
    }

    my $genreId = getGenreId($genre);
    if (!$genreId) {
        return 0;
    }

    my $sql = "INSERT INTO genres(releaseid, genreid, genretime, channelid, ",
              "botid) VALUES (?, ?, ?, ?, ?)";
    my @params = ($releaseId, $genreId, $genretime, $channelId, $botId);

    if (!runSqlSave($sql, @params)) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveGenre()--[",
                      "Unable to save genre]--[!gn $pre $genre]--[$nick]",
                      "--[$channel]";
        announceError($server, $message);
        printDebug("[ERROR] saveGenre()--[Unable to save genre]--[!gn $pre "
            ."$genre]--[$nick]--[$channel]");
        return 0;
    }

    $last{'gn'} = $pre;
    printDebug("saveGenre()--[!gn $pre $genre]--[$nick]--[$channel]--DONE--");

    return 0;
}

# Function to save nuke
# input: <release> <reason> <nukenet>
sub saveNuke {
    my ($text, $server, $channel, $nick, $old) = @_;
    my ($pre, $reason, $nukenet) = split(" ", $text, 3);

    my $nuketime = time();

    $pre = trim($pre);
    $reason = trim($reason);
    $nukenet = trim($nukenet);

    if ($pre eq $error{'nuke'}) {
        return 0;
    }

    my $prestatus = getPreStatus($pre);

    if ($prestatus == 2) {
        $error{'nuke'} = $pre;
        return 0;
    }
    elsif ($prestatus == 3) {
        my $sql = "SELECT u.unnuketime FROM unnukes AS u \
                LEFT JOIN releases AS r ON r.releaseid = u.releaseid \
                WHERE r.releasename = ? ORDER BY u.unnuketime DESC LIMIT 1";
        my @params = ($pre);

        my $unnuketime = runSqlSingle($sql, @params);

        if (($nuketime-$unnuketime) < 5) {
            $error{'nuke'} = $pre;
            return 0;
        }
    }

    if ($reason !~ m/$allowed_nukechars/gi) {
        if ($error{'nuke'} ne $pre) {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveNuke()",
                          "--[Invalid characters in nukereason]--[!nuke $pre ",
                          "$reason $nukenet]--[$nick]--[$channel]";
            announceError($server, $message);
            printDebug("[ERROR] saveNuke()--[Invalid characters in nukereason"
                ."]--[!nuke $pre $reason $nukenet]--[$nick]--[$channel]");
        }
        $error{'nuke'} = $pre;
        return 0;
    }

    if (checkIfPreExists($pre) != 1) {
        if ($error{'nuke'} ne $pre) {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveNuke()",
                          "--[No such pre in db]--[!nuke $pre $reason ",
                          "$nukenet]--[$nick]--[$channel]";
            announceError($server, $message);
            printDebug("[ERROR] saveNuke()--[No such pre in db]--[!nuke $pre "
                ."$reason $nukenet]--[$nick]--[$channel]");
        }
        $error{'nuke'} = $pre;
        return 0;
    }

    my $botid = checkBot($nick, "nuke");
    if (!$botid) {
        return 0;
    }

    my $nukenetid = checkNukenet($nukenet, "nuke");
    if (!$nukenetid) {
        return 0;
    }

    printDebug("saveNuke()--[!nuke $pre $reason $nukenet]--[$nick]--["
        ."$channel]--START--");

#   if ($output{'echo'} && !$old) {
#       echoNukes($server, $pre, $reason, $nukenet, "nuke");
#   }

    my $channelid = getChannelId($channel);
    if (!$channelid) {
        printDebug("[ERROR] saveNuke()--[Unable to get channelid for "
            ."$channel]--[$nick]--[$channel]");
        return 0;
    }

    my $releaseid = getReleaseId($pre);

    my $sql = "INSERT INTO nukes(releaseid, nukereason, nukenetid, nuketime",
              ", channelid, botid) VALUES (?, ?, ?, ?, ?, ?)";
    my @params = ($releaseid, $reason, $nukenetid, $nuketime, $channelid, 
                  $botid);

    if (!runSqlSave($sql, @params)) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveNuke()",
                      "--[Unable to save nuke]--[!nuke $pre $reason $nukenet]",
                      "--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("[ERROR] saveNuke()--[Unable to save nuke]--[!nuke $pre "
            ."$reason $nukenet]--[$nick]--[$channel]");
    }

    $sql = "UPDATE releases SET status = ? WHERE releaseid = ? LIMIT 1";
    @params = (2, $releaseid);
    runSqlSave($sql, @params);

    my $message = "$pre $reason $nukenet";
    announceNuke($server, $message);

    $last{'nuke'} = $pre;
    printDebug("saveNuke()--[!nuke $pre $reason $nukenet]--[$nick]--[$channel"
        ."]--DONE--");

    return 0;
}

# Function to save unnuke
# input: <release> <reason> <nukenet>
sub saveUnnuke {
    my ($text, $server, $channel, $nick, $old) = @_;
    my ($pre, $reason, $nukenet) = split(" ", $text, 3);

    my $unnuketime = time();

    $pre = trim($pre);
    $reason = trim($reason);
    $nukenet = trim($nukenet);

    if ($pre eq $error{'unnuke'} || $pre eq  $last{'unnuke'}) {
        return 0;
    }

    my $prestatus = getPreStatus($pre);

    if ($prestatus == 3) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveUnnuke()",
                      "--[Release is already unnuked]--[!unnuke $pre $reason ",
                      "$nukenet]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("[ERROR] saveUnnuke()--[Release is already unnuked]--["
            ."!unnuke $pre $reason $nukenet]--[$nick]--[$channel]");
        $error{'unnuke'} = $pre;
        return 0;
    }
    elsif ($prestatus == 2) {
        my $sql = "SELECT n.nuketime FROM nukes AS n \
                LEFT JOIN releases AS r ON r.releaseid = n.releaseid \
                WHERE r.releasename = ? ORDER BY n.nuketime DESC LIMIT 1";
        my @params = ($pre);

        my $nuketime = runSqlSingle($sql, @params);

        if (($unnuketime - $nuketime) < 5) {
            $error{'unnuke'} = $pre;
            return 0;
        }
    }

    if ($reason !~ m/$allowed_nukechars/gi) {
        if ($error{'unnuke'} ne $pre) {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."",
                          "saveUnnuke()--[Invalid characters in reason]--[",
                          "!unnuke $pre $reason $nukenet]--[$nick]--[$channel]";
            announceError($server, $message);
            printDebug("[ERROR] saveUnnuke()--[Invalid characters in reason]"
                ."--[!unnuke $pre $reason $nukenet]--[$nick]--[$channel]");
        }
        $error{'unnuke'} = $pre;
        return 0;
    }

    my $botId = checkBot($nick, "nuke");
    if (!$botId) {
        return 0;
    }

    my $exists = checkIfPreExists($pre);
    if ($exists != 1) {
        if ($error{'unnuke'} ne $pre) {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."",
                          "saveUnnuke()--[No such pre in db]--[!unnuke $pre ",
                          "$reason $nukenet]--[$nick]--[$channel]";
            announceError($server, $message);
            printDebug("[ERROR] saveUnnuke()--[No such pre in db]--[!unnuke "
                ."$pre $reason $nukenet]--[$nick]--[$channel]");
        }
        $error{'unnuke'} = $pre;
        return 0;
    }

    printDebug("saveUnnuke()--[!unnuke $pre $reason $nukenet]--[$nick]--["
        ."$channel]--START--");

    my $nukenetId = checkNukenet($nukenet, "nuke");

    if (!$nukenetId) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."",
                      "saveUnnuke()--[Nukenet not allowed]--[!unnuke $pre ",
                      "$reason $nukenet]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("[ERROR] saveUnnuke()--[Nukenet not allowed]--[!unnuke "
            ."$pre $reason $nukenet]--[$nick]--[$channel]");
        return 0;
    }

    my $releaseId = getReleaseId($pre);
    my $channelId = getChannelId($channel);
    if (!$channelId) {
        printDebug("[ERROR]: saveUnnuke()--[Unable to get channelid for "
            ."$channel]--[$nick]--[$channel]");
        return 0;
    }

    my $sql = "INSERT INTO unnukes(releaseid, unnukereason, nukenetid, ",
              "unnuketime, channelid, botid) VALUES (?, ?, ?, ?, ?, ?)";
    my @params = ($releaseId, $reason, $nukenetId, $unnuketime, $channelId, 
                  $botId);

    if(!runSqlSave($sql, @params)) {
        printDebug("[ERROR] saveUnnuke()--[Unable to save unnuke into db]--["
            ."!unnuke $pre $reason $nukenet]--[$nick]--[$channel]");
        $error{'unnuke'} = $pre;
        return 0;
    }

    $sql = "UPDATE releases SET status = ? WHERE releaseid = ? LIMIT 1";
    @params = (3, $releaseId);
    runSqlSave($sql, @params);

    my $message = "$pre $reason $nukenet";
    announceUnnuke($server, $message);

    $last{'unnuke'} = $pre;
    printDebug("saveUnnuke()--[!unnuke $pre $reason $nukenet]--[$nick]--["
        ."$channel]--DONE--");

    return 0;
}

# Function to save !modnuke
# input: <release> <reason> <nukenet>
sub saveModnuke {
    my ($text, $server, $channel, $nick) = @_;
    my ($pre, $reason, $nukenet) = split(" ", $text, 3);

    $pre = trim($pre);
    $reason = trim($reason);
    $nukenet = trim($nukenet);

    if ($last{'modnuke'} eq $pre) {
        return 0;
    }

    if (checkIfPreExists($pre) != 1) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveModnuke()",
                      "--[No such pre in db]--[!modnuke $pre $reason ",
                      "$nukenet]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("[ERROR] saveModnuke()--[No such pre in db]--[!modnuke "
            ."$pre $reason $nukenet]--[$nick]--[$channel]");
        return 0;
    }

    my $botid = checkBot($nick, "nuke");
    if (!$botid) {
        return 0;
    }

    my $modnuketime = time();
    my $nukenetid = checkNukenet($nukenet, "nuke");

    if (!$nukenetid) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveModnuke()",
                      "--[Nukenet is not allowed]--[!modnuke $pre $reason ",
                      "$nukenet]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("[ERROR] saveModnuke()--[Nukenet is not allowed]--["
            ."!modnuke $pre $reason $nukenet]--[$nick]--[$channel]");
        return 0;
    }

    my $prestatus = getPreStatus($pre);
    my $releaseid = getReleaseId($pre);
    my $channelid = getChannelId($channel);
    my $update;
    my @params;

    if ($prestatus == 1) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveModnuke()",
                      "--[Release is not (un)nuked]--[!modnuke $pre $reason ",
                      "$nukenet]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("[ERROR] saveModnuke()--[Release is not (un)nuked]--["
            ."!modnuke $pre $reason $nukenet]--[$nick]--[$channel]");
        return 0;
    }
    elsif ($prestatus == 2) {
        my $query = "SELECT nukeid, nukereason, nukenetid FROM nukes \
                WHERE releaseid = ? ORDER BY nuketime DESC LIMIT 1";
        @params = ($releaseid);

        my @old = runSqlMulti($query, @params);

        if ($old[0][1] eq $reason && $old[0][2] eq $nukenetid) {
            printDebug("[ERROR] saveModnuke()-[modnuke changes nothing]--["
                ."!modnuke $pre $reason $nukenet]--[$nick]--[$channel]");
            return 0;
        }

        my $nukeid = $old[0][0];

        $update= "UPDATE nukes SET nukereason = ?, nukenetid = ?, nuketime \
                = ?, channelid = ?, botid = ? WHERE nukeid = ? LIMIT 1";
        @params = ($reason, $nukenetid, $modnuketime, $channelid, $botid, 
                   $nukeid);
    }
    elsif ($prestatus == 3) {
        my $query = "SELECT unnukeid, unnukereason, nukenetid FROM unnukes \
                WHERE releaseid = ? ORDER BY unnuketime DESC LIMIT 1";
        @params = ($releaseid);

        my @old = runSqlMulti($query, @params);

        if ($old[0][1] eq $reason && $old[0][2] eq $nukenetid) {
            printDebug("[ERROR] saveModnuke()-[modnuke changes nothing]--["
                ."!modnuke $pre $reason $nukenet]--[$nick]--[$channel]");
            return 0;
        }

        my $unnukeid = $old[0][0];

        $update = "UPDATE unnukes SET unnukereason = ?, nukenetid = ?, ",
                  "unnuketime = ?, channelid = ?, botid = ? WHERE unnukeid ",
                  "= ? LIMIT 1";
        @params = ($reason, $nukenetid, $modnuketime, $channelid, $botid, 
                   $unnukeid);
    }
    elsif ($prestatus == 6) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveModnuke()",
                      "--[Release is delpred]--[!modnuke $pre $reason ",
                      "$nukenet]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("[ERROR] saveModnuke()--[Release is delpred]--[!modnuke "
            ."$pre $reason $nukenet]--[$nick]--[$channel]");
        return 0;
    }
    else {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveModnuke()",
                      "--[Invalid status for a release in db]--[!modnuke ",
                      "$pre $reason $nukenet]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("[ERROR] saveModnuke()--[Invalid status for a release in "
            ."db]--[!modnuke $pre $reason $nukenet]--[$nick]--[$channel]");
        return 0;
    }

    printDebug("saveModnuke()--[!modnuke $pre $reason $nukenet]--[$nick]--["
        ."$channel]--START--");

    if (!runSqlSave($update, @params)) {
        printDebug("[ERROR] saveModnuke()--[Unable to save modnuke]--["
            ."!modnuke $pre $reason $nukenet]--[$nick]--[$channel]");
        return 0;
    }

    my $message = "$pre $reason $nukenet";
    announceModnuke($server, $message);
    $last{'modnuke'} = $pre;
    printDebug("saveModnuke()--[!modnuke $pre $reason $nukenet]--[$nick]"
        ."--[$channel]--DONE--");

    return 0;
}

# Function to save olddelpres
# input: <release> <time> <reason> <nukenet>
sub saveOldDelpre {
    my ($text, $server, $channel, $nick) = @_;
    my ($pre, $delpretime, $deletereason, $nukenet) = split(" ", $text, 4);
    my $noecho = 0;

    $pre = trim($pre);
    $delpretime = trim($delpretime);
    $deletereason = trim($deletereason);
    $nukenet = trim($nukenet);

    if (checkIfPreExists($pre) != 1) {
        return 0;
    }

    if (!$deletereason) {
        return 0;
    }

    my $botid = checkBot($nick, "delpre");
    if (!$botid) {
        return 0;
    }

    if (!$nukenet && $channel eq "#botadmin") {
        $nukenet = "OldDB";
        $noecho = 1;
    }

    my $nukenetid = checkNukenet($nukenet, "delpre");
    if ($nukenetid == 0) {
        my $msg = "[".$red."ERROR".$reset."] ".$darkgrey."saveOldDelpre()--[",
                  "Source not allowed]--[!delpre $pre $deletereason $nukenet]",
                  "--[$nick]--[$channel]";
        announceError($server, $msg);
        return 0;
    }

    printDebug("saveOldDelpre()--[!delpre $pre $deletereason $nukenet]--["
        ."$nick]--[$channel]--START--");

    my $channelid = getChannelId($channel);
    if (!$channelid) {
        return 0;
    }

    my $sql = "SELECT r.releaseid, r.pretime, r.status, s.sectionname, \
            a.genrename, i.files, i.size, gr.groupid, r.channelid, r.botid, \
            n.nfo, n.nfoname \
            FROM releases AS r \
            LEFT JOIN genres AS g ON r.releaseid = g.releaseid \
            LEFT JOIN allowedgenres AS a ON g.genreid = a.genreid \
            LEFT JOIN infos AS i ON r.releaseid = i.releaseid \
            LEFT JOIN sections AS s ON r.sectionid = s.Sectionid \
            LEFT JOIN groups AS gr ON r.groupid = gr.groupid \
            LEFT JOIN nfos AS n ON r.releaseid = n.releaseid \
            WHERE r.releasename = ? LIMIT 1";
    my @params = ($pre);

    my @old = runSqlMulti($sql, @params);

    my $releaseid = $old[0][0];
    my $pretime = $old[0][1];
    my $status = $old[0][2];
    my $section = $old[0][3];
    my $genre = $old[0][4];
    my $files = $old[0][5];
    my $size = $old[0][6];
    my $groupid = $old[0][7];
    my $origchannelid = $old[0][8];
    my $origbotid = $old[0][9];
    my $nfo = $old[0][10];
    my $nfoname = $old[0][11];

    if (!$genre) { undef($genre); }
    if (!$files) { undef($size); undef($files); }
    if (!$nfoname) { undef($nfo); undef($nfoname); }

    if ($status == 2) {
        $sql = "SELECT nukereason FROM nukes WHERE releaseid = ? LIMIT 1";
        @params = ($releaseid);
        my $reason = runSqlSingle($sql, @params);
        @params = ($pre, $section, $pretime, $files, $size, $genre, $reason, 
                   $nukenetid, $channelid, $botid, $origchannelid, $origbotid, 
                   $deletereason, $delpretime, $nfo, $nfoname);
    }
    else {
        @params = ($pre, $section, $pretime, $files, $size, $genre, undef, 
                   $nukenetid, $channelid, $botid, $origchannelid, $origbotid, 
                   $deletereason, $delpretime, $nfo, $nfoname);
    }

    $sql = "INSERT INTO delpred(releasename, section, pretime, files, size, ",
           "genre, nukereason, nukenetid, channelid, botid, origchannelid, ",
           "origbotid, deletereason, deletetime, nfo, nfoname) VALUES ",
           "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    my $result = runSqlSave($sql, @params);

    if (!$result) {
        printDebug("[ERROR] saveDelpre()--[Unable to save delpre]--[!delpre "
            ."$pre $deletereason $nukenet]--[$nick]--[$channel]");
        return 0;
    }

    $sql = "SELECT COUNT(r.releaseid) FROM releases as r \
            LEFT JOIN groups AS g ON g.groupid = r.groupid \
            WHERE g.groupid = ? LIMIT 1";
    @params = ($groupid);

    if (!runSqlSingle($sql, @params)) {
        $sql = "DELETE FROM groups WHERE groupid = ? LIMIT 1";
        my @params = ($groupid);

        runSqlSave($sql, @params);
    }

    $sql = "DELETE FROM releases WHERE releaseid = ?";
    @params = ($releaseid);
    runSqlSave($sql, @params);

    if ($nfoname) {
        $sql = "DELETE FROM nfos WHERE releaseid = ? LIMIT 1";
        runSqlSave($sql, @params);
    }

    if ($size) {
        $sql = "DELETE FROM infos WHERE releaseid = ? LIMIT 1";
        runSqlSave($sql, @params);
    }

    if ($genre) {
        $sql = "DELETE FROM genres WHERE releaseid = ? LIMIT 1";
        runSqlSave($sql, @params);
    }

    if ($status == 3) {
        $sql = "DELETE FROM unnukes WHERE releaseid = ?";
        runSqlSave($sql, @params);
    }
    elsif ($status == 2) {
        $sql = "DELETE FROM nukes WHERE releaseid = ?";
        runSqlSave($sql, @params);
    }

    $last{'delpre'} = $pre;
    printDebug("saveOldDelpre()--[!olddelpre $pre $delpretime $deletereason "
        ."$nukenet]--[$nick]--[$channel]--DONE--");
    return 0;
}

# Function to save !delpres
# input: <release> <reason> <nukenet>
sub saveDelpre {
    my ($text, $server, $channel, $nick) = @_;
    my ($pre, $deletereason, $nukenet) = split(" ", $text, 3);
    my $delpretime = time();

    $pre = trim($pre);
    $deletereason = trim($deletereason);
    $nukenet = trim($nukenet);

    my $noecho = 0;

    if (checkIfPreExists($pre) != 1) {
        return 0;
    }

    if (!$deletereason) {
        return 0;
    }

    my $botid = checkBot($nick, "delpre");
    if (!$botid) {
        return 0;
    }

    if (!$nukenet && $channel eq "#botadmin") {
        $nukenet = "OldDB";
        $noecho = 1;
    }

    my $nukenetid = checkNukenet($nukenet, "delpre");
    if ($nukenetid == 0) {
        my $msg = "[".$red."ERROR".$reset."] ".$darkgrey."saveDelpre()--[",
                  "Source not allowed]--[!delpre $pre $deletereason $nukenet]",
                  "--[$nick]--[$channel]";
        announceError($server, $msg);
        return 0;
    }

    printDebug("saveDelpre()--[!delpre $pre $deletereason $nukenet]--[$nick]"
        ."--[$channel]--START--");

    my $channelid = getChannelId($channel);
    if (!$channelid) {
        return 0;
    }

    my $sql = "SELECT r.releaseid, r.pretime, r.status, s.sectionname, \
            a.genrename, i.files, i.size, gr.groupid, r.channelid, r.botid, \
            n.nfo, n.nfoname \
            FROM releases AS r \
            LEFT JOIN genres AS g ON r.releaseid = g.releaseid \
            LEFT JOIN allowedgenres AS a ON g.genreid = a.genreid \
            LEFT JOIN infos AS i ON r.releaseid = i.releaseid \
            LEFT JOIN sections AS s ON r.sectionid = s.Sectionid \
            LEFT JOIN groups AS gr ON r.groupid = gr.groupid \
            LEFT JOIN nfos AS n ON r.releaseid = n.releaseid \
            WHERE r.releasename = ? LIMIT 1";
    my @params = ($pre);

    my @old = runSqlMulti($sql, @params);

    my $releaseid = $old[0][0];
    my $pretime = $old[0][1];
    my $status = $old[0][2];
    my $section = $old[0][3];
    my $genre = $old[0][4];
    my $files = $old[0][5];
    my $size = $old[0][6];
    my $groupid = $old[0][7];
    my $origchannelid = $old[0][8];
    my $origbotid = $old[0][9];
    my $nfo = $old[0][10];
    my $nfoname = $old[0][11];

    if (!$genre) { undef($genre); }
    if (!$files) { undef($size); undef($files); }
    if (!$nfoname) { undef($nfo); undef($nfoname); }

    if ($status == 2) {
        $sql = "SELECT nukereason FROM nukes WHERE releaseid = ? LIMIT 1";
        @params = ($releaseid);
        my $reason = runSqlSingle($sql, @params);
        @params = ($pre, $section, $pretime, $files, $size, $genre, $reason, 
                   $nukenetid, $channelid, $botid, $origchannelid, $origbotid, 
                   $deletereason, $delpretime, $nfo, $nfoname);
    }
    else {
        @params = ($pre, $section, $pretime, $files, $size, $genre, undef, 
                   $nukenetid, $channelid, $botid, $origchannelid, $origbotid, 
                   $deletereason, $delpretime, $nfo, $nfoname);
    }

    $sql = "INSERT INTO delpred(releasename, section, pretime, files, size, ",
           "genre, nukereason, nukenetid, channelid, botid, origchannelid, ",
           "origbotid, deletereason, deletetime, nfo, nfoname) VALUES ",
           "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    my $result = runSqlSave($sql, @params);

    if (!$result) {
        printDebug("[ERROR] saveDelpre()--[Unable to save delpre]--[!delpre "
            ."$pre $deletereason $nukenet]--[$nick]--[$channel]");
        return 0;
    }

    $sql = "SELECT COUNT(r.releaseid) FROM releases as r \
        LEFT JOIN groups AS g ON g.groupid = r.groupid \
        WHERE g.groupid = ? LIMIT 1";
    @params = ($groupid);

    if (!runSqlSingle($sql, @params)) {
        $sql = "DELETE FROM groups WHERE groupid = ? LIMIT 1";
        my @params = ($groupid);

        runSqlSave($sql, @params);
    }

    $sql = "DELETE FROM releases WHERE releaseid = ?";
    @params = ($releaseid);
    runSqlSave($sql, @params);

    if ($nfoname) {
        $sql = "DELETE FROM nfos WHERE releaseid = ? LIMIT 1";
        runSqlSave($sql, @params);
    }

    if ($size) {
        $sql = "DELETE FROM infos WHERE releaseid = ? LIMIT 1";
        runSqlSave($sql, @params);
    }

    if ($genre) {
        $sql = "DELETE FROM genres WHERE releaseid = ? LIMIT 1";
        runSqlSave($sql, @params);
    }

    if ($status == 3) {
        $sql = "DELETE FROM unnukes WHERE releaseid = ?";
        runSqlSave($sql, @params);
    }
    elsif ($status == 2) {
        $sql = "DELETE FROM nukes WHERE releaseid = ?";
        runSqlSave($sql, @params);
    }

#   if ($result && !$noecho) {
#	echoDelpre($server, $pre, $deletereason, $nukenet, "delpre");
#   }

    $last{'delpre'} = $pre;
    printDebug("saveDelpre()--[!delpre $pre $deletereason $nukenet]--[$nick]"
        ."--[$channel]--DONE--");
    return 0;
}

# Function to save !undelpres
# input: <release> <reason> <nukenet>
sub saveUndelpre {
    my ($text, $server, $channel, $nick) = @_;
    my ($pre, $reason, $nukenet) = split(" ", $text, 3);
    my $undelpretime = time();
    my $noecho = 0;

    $pre = trim($pre);
    $reason = trim($reason);
    $nukenet = trim($nukenet);

    if (checkIfPreExists($pre) != 6) {
        return 0;
    }

    my $botId = checkBot($nick, "delpre");
    if (!$botId) {
        return 0;
    }

    printDebug("saveUndelpre()--[!undelpre $pre $reason $nukenet]--START--");

    if (!$nukenet && $channel eq "#botadmin") { 
        $nukenet = "OldDB"; $noecho = 1; 
    }

    my $nukenetid = checkNukenet($nukenet, "delpre");
    if (!$nukenetid) {
        my $msg = "[".$red."ERROR".$reset."] ".$darkgrey."saveUndelpre()--[",
                  "Source is not allowed]--[!undelpre $pre $reason $nukenet]",
                  "--[$nick]--[$channel]";
        announceError($server, $msg);
        return 0;
    }

    my $sql = "SELECT delpreid FROM delpred WHERE releasename = ? LIMIT 1";
    my @params = ($pre);

    my $delpreid =  runSqlSingle($sql, @params);

    $sql = "SELECT releasename, section, pretime, files, size, genre, \
        nukereason, nfo, nfoname FROM delpred WHERE delpreid = ? LIMIT 0, 1";
    @params = ($delpreid);

    my @release = runSqlMulti($sql, @params);

    $pre = $release[0][0];
    my $section = $release[0][1];
    my $time = $release[0][2];
    my $files = $release[0][3];
    my $size = $release[0][4];
    my $genre = $release[0][5];
    my $nukereason = $release[0][6];
    my $nfo = $release[0][7];
    my $nfoname = $release[0][8];

    if (!$size) {
        $files = "-";
        $size = "-";
    }
    if (!$genre) {
        $genre = "-";
    }

    if (length($nukereason) == 0 ) {
        $nukereason = "-";
    }

    $sql = "DELETE FROM delpred WHERE delpreid = ?";
    my $result = runSqlSave($sql, @params);

    $text = "$pre $section $time $files $size $genre $nukereason";
    saveAddold($text, $server, $channel, $nick);

    if ($nfoname) {
        my $releaseId = getReleaseId($pre);
        my $hash = md5_hex($pre);
        my $channelId = getChannelId($channel);

        my $sql = "INSERT INTO nfos(releaseid, hash, nfo, nfoname, time, ",
                  "channelid, botid) VALUES (?, ?, ?, ?, ?, ?, ?)";
        my @params = ($releaseId, $hash, $nfo, $nfoname, $undelpretime, 
                      $channelId, $botId);

        if (!runSqlSave($sql, @params)) {
            my $msg = "[".$red."ERROR".$reset."] ".$darkgrey."saveUndelpre()",
                      "--[Unable to resave nfo]--[!undelpre $pre $reason ",
                      "$nukenet]--[$nick]--[$channel]";
            announceError($server, $msg);
            printDebug("saveUndelpre()--[Unable to resave nfo]--[!undelpre "
                ."$pre $reason $nukenet]--[$nick]--[$channel]");
        }
    }

    printDebug("saveUndelpre()--[!undelpre $pre $reason $nukenet]--[$nick]"
        ."--[$channel]--DONE--");
    return 0;
}

# Function to save !addolds
# note: Missing fields are marked with hyphen (-)
# input: <release> <section> <time> <files> <size> <genre> <nuke_reason>
sub saveAddold {
    my ($text, $server, $channel, $nick) = @_;
    my ($pre, $origSection, $pretime, $files, 
            $size, $genre, $nuke) = split(" ", $text, 7);

    my $currenttime = time();

    $pre = trim($pre);
    $origSection = trim($origSection);
    $pretime = trim($pretime);
    $files = trim($files);
    $size = trim($size);
    $genre = trim($genre);
    $nuke = trim($nuke);

    my $noecho = 0;
    my $result = 0;

    if ($currenttime < $pretime) {
        printDebug("[ERROR] saveAddold--[Pretime in future]--[!addold $pre "
            ."$origSection $pretime $files $size $genre $nuke]--[$nick]"
            ."--[$channel]");
        return 0;
    }

    if (!checkPre($pre)) {
        if ($pre ne $error{'addold'}) {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."",
                          "saveAddold()--[Invalid dirname]--[!addold $pre ",
                          "$origSection $pretime $files $size $genre $nuke]",
                          "--[$nick]--[$channel]";
            announceError($server, $message);
            $error{'addold'} = $pre;
        }
        return 0;
    }

    if (!filterPre($pre)) {
        if ($pre ne $error{'addold'}) {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."",
                          "saveAddold()--[Dirname matched filters]--[!addold ",
                          "$pre $origSection $pretime $files $size $genre ",
                          "$nuke]--[$nick]--[$channel]";
            announceError($server, $message);
        }
        $noecho = 1;
    }

    my $exists = checkIfPreExists($pre);
    if ($exists == 1) {
        if ($nick eq "ZickZack") {
            my $sql = "SELECT pretime FROM releases WHERE releasename = ? \
                    LIMIT 1";
            my @params = ($pre);

            my $time = runSqlSingle($sql, @params);

            if ($pretime < $time) {
                saveUpdatetime("$pre $pretime", $server, $channel, $nick);
                $last{'addold'} = $pre;
            }
        }

        if (!checkIfInfoExists($pre)) {
            if (isNumeric($files)) {
                saveInfo("$pre $files $size", $server, $channel, $nick);
            }
        }

        if (!checkIfGenreExists($pre)) {
            saveGenre("$pre $genre", $server, $channel, $nick);
            fetchDataFromNet($pre, $server);
        }

        if ((length($nuke) > 3) && (getPreStatus($pre) == 1)) {
            my $nukenet = "OldDB";
            # last arg means that nuke comes from addold
            saveNuke("$pre $nuke $nukenet", $server, $channel, $nick, 1); 
        }

        return 0;
    }
    elsif ($exists == 6) {
        return 0;
    }

    my $botId = checkBot($nick, "addpre");
    if ($botId == 0) {
        return 0;
    }

    my $section = uc(checkSection($pre, $origSection));
    if (!$section) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveAddold()--[",
                      "Invalid section]--[!addold $pre $origSection $pretime ",
                      "$files $size $genre $nuke]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("saveAddold()--[Invalid section]--[!addold $pre "
            ."$origSection $pretime $files $size $genre $nuke]--[$nick]"
            ."--[$channel]");
        return 0;
    }

    $files =~ s/\-//g;
    $size =~ s/\-//g;
    if (length($genre) == 1) { $genre =~ s/\-//g; }
    if (length($nuke) == 1) { $nuke =~ s/\-//g; }


    printDebug("saveAddold()--[!addold $pre $section $pretime $files $size "
        ."$genre $nuke]--[$nick]--[$channel]--START--");

    my $sectionId = getSectionId($section);
    my $releaseId = getReleaseId($pre);
    my $groupId = getGroupId($pre);
    if (!$groupId) {
        return 0;
    }
    my $channelId = getChannelId($channel);
    if ($channelId == 0) {
        return 0;
    }

    my $sql = "INSERT INTO releases(releasename, pretime, groupid, sectionid,",
              "channelid, botid) VALUES (?, ?, ?, ?, ?, ?)";
    my @params = ($pre, $pretime, $groupId, $sectionId, $channelId, $botId);

    if (!runSqlSave($sql, @params)) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveAddikd()--",
                      "[Unable to save addold into db]--[!addold $pre ",
                      "$origSection $pretime $files $size $genre $nuke]",
                      "--[$nick]";
        announceError($server, $message);
        printDebug("saveAddold()--[Unable to save addold into db]--[!addold "
            ."$pre $origSection $pretime $files $size $genre $nuke]"
            ."--[$nick]--[$channel]");

        return 0;
    }

    $noecho = 1;

    if (!checkIfInfoExists($pre)) {
        if (isNumeric($files)) {
            # last arg means that info comes from addold
            saveInfo("$pre $files $size", $server, $channel, $nick, 1); 
        }
    }
    if (!checkIfGenreExists($pre)) {
        saveGenre("$pre $genre", $server, $channel, $nick);
    }
    if ((length($nuke) > 3) && (getPreStatus($pre) == 1)) {
        my $nukenet = "OldDB";
        # last arg means that info comes from addold
        saveNuke("$pre $nuke $nukenet", $server, $channel, $nick, 1); 
    }

    #echoAddold($server, $text);
    announceAddold($server, "$pre $section");

    $last{'addold'} = $pre;
    printDebug("saveAddold()-[!addold $pre $section $pretime $files $size "
        ."$genre $nuke]--[$nick]--[$channel]--DONE--");
    return 0;
}

# Function to save nfos
# input: <release> <url> <filename>
sub saveNfo {
    my ($text, $server, $channel, $nick) = @_;
    my $time = time();
    my ($pre, $url, $nfoname, $checksum) = split(" ", $text);

    $pre = trim($pre);
    $url = trim($url);
    $nfoname = trim($nfoname);

    if (length($checksum) != 8 && $pre eq $last{'nfo'}) {
        return 0;
    }

    if (length($nfoname) > $limits{'nfonameLength'}) {
        return 0;
    }

    my $nfo2 = stripBadCharsFile($nfoname);
    my $url2 = stripBadCharsUrl($url);

    # escape ( and ) chars
    $nfo2 =~ s/\(/\\\(/g;
    $nfo2 =~ s/\)/\\\)/g;
    $url2 =~ s/\(/\\\(/g;
    $url2 =~ s/\)/\\\)/g;

    my $hash = md5_hex($pre);

    my $botId = checkBot($nick, "nfo");
    if (!$botId) {
        return 0;
    }

    if (checkIfPreExists($pre) != 1) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveNfo()--[No ",
                      "such pre in db]--[!addnfo $pre $url $nfoname ]",
                      "--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("saveNfo()--[No such pre in db]--[!addnfo $pre $url "
            ."$nfoname ]--[$nick]--[$channel]");
        return 0;
    }

    if (checkIfNfoExists($pre)) {
        my $sql = "SELECT n.nfo FROM nfos AS n LEFT JOIN releases AS r ON \
                r.releaseid = n.releaseid WHERE r.releasename = ? LIMIT 1";
        my @params = ($pre);

        my $nfo = runSqlSingle($sql, @params);

        my $crc = crc32(decode_base64($nfo));
        $crc = uc(sprintf("%08x", $crc));

        if ($checksum && ($checksum ne $crc) && ($nick eq "ZickZack")) {
            saveUpdatenfo($pre, $nfoname, $hash, $nfo2, $url2, $server, 
                          $channel, $nick);
            undef($checksum);
        }

        return 0;
    }

    printDebug("saveNfo()--[!addnfo $pre $url $nfoname]--[$nick]--[$channel]"
        ."--START--");

    # jos tiedostopääte != .nfo
    my @suffix = split(/\./, $nfoname);
    if ($suffix[-1] !~ /^nfo$/i) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveNfo()",
                      "--[Suffix is not .nfo]--[!addnfo $pre $url $nfoname]",
                      "--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("saveNfo()--[Suffix is not .nfo]--[!addnfo $pre $url "
            ."$nfoname]--[$nick]--[$channel]");
        return 0;
    }

    if ($nfoname =~ m/^($blockednfo)$/i) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveNfo()--[",
                      "Blocked filename]--[!addnfo $pre $url $nfoname]--[",
                      "$nick]--[$channel]";
        announceError($server, $message);
        printDebug("saveNfo()--[Blocked filename]--[!addnfo $pre $url "
            ."$nfoname]--[$nick]");
        return 0;
    }

    my $releaseId = getReleaseId($pre);
    my $channelId = getChannelId($channel);

    my $command = "wget -q -T 1 -t 1 --no-check-certificate ",
                  "--content-disposition -O $nfo2 $url2";
    system($command);
    rename("$nfoname", "$hash");

    my $filesize = -s "$hash";

    if ($filesize < 40 || $filesize > 512000 ) {
        unlink("$hash");
        return 0;
    }

    open(FILE, "$hash") or die $!;
    my @data = <FILE>;
    close FILE;

    if (!checkIfGenreExists($pre)) {
        my $genre = stripGenreFromNfo($pre, @data);
        if ($genre) {
            saveGenre("$pre $genre", $server, "fromnfo", "fromnfo");
        }
    }

    if (!checkIfUrlExists($pre)) {
        my $nfourl = stripUrlFromNfo(@data);
        if (length($nfourl) > 10) {
            saveUrl("$pre $nfourl", $server, "fromnfo", "fromnfo");
        }
    }

    my $nfodata = join('',@data);
    $nfodata = encode_base64($nfodata);

    my $sql = "INSERT INTO nfos(releaseid, hash, nfo, nfoname, time, ",
              "channelid, botid) VALUES (?, ?, ?, ?, ?, ?, ?)";
    my @params = ($releaseId, $hash, $nfodata, $nfoname, $time, $channelId, 
                  $botId);

    if (!runSqlSave($sql, @params)) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveNfo()--[",
                      "Unable to save nfo into db]--[!addnfo $pre $url ",
                      "$nfoname]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("saveNfo()--[Unable to save nfo into db]--[!addnfo $pre "
            ."$url $nfoname]--[$nick]--[$channel]");
        unlink("$hash");

        return 0;
    }

    unlink("$hash");
    $last{'nfo'} = $pre;
    printDebug("saveNfo()--[!addnfo $pre $url $nfoname]--[$nick]--[$channel]"
        ."--DONE--");

    return 0;
}

# Function to save !fix <pre> <section>
# input: <release> <section>
sub saveFix {
    my ($text, $server, $channel, $nick) = @_;
    my ($pre, $section) = split(" ", $text, 2);

    $pre = trim($pre);
    $section = trim($section);

    printDebug("saveFix()--[!fix $pre $section]--[$nick]--[$channel]--START--");

    my $sectionId = getSectionId($section);
    my $sql = "UPDATE releases SET sectionid = ? WHERE releasename = ? LIMIT 1";
    my @params = ($sectionId, $pre);

    if (runSqlSave($sql, @params)) {
        print " saveFix()--[!fix $pre $section]--DONE--";
        return 0;
    }
    else {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveFix()--[",
                      "Unable to fix section]--[!fix $pre $section]--[$nick]",
                      "--[$channel]";
        announceError($server, $message);
        return 0;
    }
}

# Function to save !updatetime
# input: <release> <time>
sub saveUpdatetime {
    my ($text, $server, $channel, $nick) = @_;
    my ($pre, $newtime) = split(" ", $text, 2);

    $pre = trim($pre);
    $newtime = trim($newtime);

    my $botId = checkBot($nick, "updatetime");
    if (!$botId) {
        return 0;
    }

    printDebug("saveUpdatetime()--[!updatetime $pre $newtime]--[$nick]--["
        ."$channel]--START--");

    my $time = time();
    if ($newtime > $time) { return 0; }

    my $sql = "UPDATE releases SET pretime = ? WHERE releasename = ? LIMIT 1";
    my @params = ($newtime, $pre);

    if (!runSqlSave($sql, @params)) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."",
                      "saveUpdatetime()--[Unable to save updatetime]--[",
                      "!updatetime $pre $newtime]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("[ERROR] saveUpdatetime()--[Unable to save updatetime]--["
            ."!updateime $pre $newtime]--[$nick]--[$channel]");

        return 0;
    }

    my $message = "[".$limegreen."UPDATE".$reset."] ".$darkgrey."",
                  "saveUpdatetime()--[Pretime updated for $pre]--[$nick]--[",
                  "$channel]";
    announceError($server, $message);
    printDebug("saveUpdatetime()--[!updatetime $pre $newtime]--[$nick]--["
        ."$channel]--DONE--");

    return 0;
}

# Subroutine to update nfofile for a release. Usually called when trusted
# bot adds nfo with dirrerent crc sum than one already in db.
sub saveUpdatenfo {
    my ($pre, $nfoname, $hash, $nfoname_fixed, $url_fixed, $server, 
        $channel, $nick) = @_;
    my $time = time();

    printDebug("saveUpdatenfo()--[!updatenfo $pre $url_fixed $nfoname]--["
        ."$nick]--[$channel]--START--");

    my $releaseid = getReleaseId($pre);
    my $channelid = getChannelId($channel);
    my $botid = checkBot($nick, "nfo");

    my $command = "wget -q -T 1 -t 1 --no-check-certificate ",
                  "--content-disposition -O $nfoname_fixed $url_fixed";
    system($command);
    rename("$nfoname", "$hash");

    my $filesize = -s "$hash";

    if ($filesize < 30 || $filesize > 512000) {
        unlink("$hash");
        return 0;
    }

    open(FILE, "$hash") or die $!;
    my @data = <FILE>;
    close FILE;

    if (!checkIfGenreExists($pre)) {
        my $genre = stripGenreFromNfo($pre, @data);
        if ($genre) {
            saveGenre("$pre $genre", $server, "fromnfo", "fromnfo");
        }
    }

    if (!checkIfUrlExists($pre)) {
        my $nfourl = stripUrlFromNfo(@data);
        if (length($nfourl) > 10) {
            saveUrl("$pre $nfourl", $server, "fromnfo", "fromnfo");
        }
    }

    my $nfodata = join('',@data);
    $nfodata = encode_base64($nfodata);

    my $sql = "UPDATE nfos SET hash = ?, nfo = ?, nfoname = ?, time = ?, ",
              "channelid = ?, botid = ? WHERE releaseid = ? LIMIT 1";
    my @params = ($hash, $nfodata, $nfoname, $time, $channelid, $botid, 
                  $releaseid);

    if (!runSqlSave($sql, @params)) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveUpdatenfo()",
                      "--[Updating nfo failed for $pre]--[$nick]--[$channel]";
        announceError($server, $message);
        printDebug("saveUpdatenfo()--[Updating nfo failed for $pre]--[$nick]"
            ."--[$channel]");
    }

    unlink("$hash");
    my $message = "[".$limegreen."UPDATE".$reset."] ".$darkgrey."",
                  "saveUpdatenfo()--[Nfo updated for $pre]--[$nick]",
                  "--[$channel]";
    announceError($server, $message);
    printDebug("saveUpdatenfo()--[!updatenfo $pre $url_fixed $nfoname]--["
        ."$nick]--[$channel]--DONE--");

    return 0;
}

# Subroutine to save urls
sub saveUrl {
    my ($text, $server, $channel, $nick) = @_;
    my ($pre, $url) = split(" ", $text, 2);
    my $urltime = time();

    $pre = trim($pre);
    $url = stripBadCharsUrl(trim($url));

    if (length($url) < 10) {
        return 0;
    }

    if (checkIfPreExists($pre) != 1) {
        if ($error{'url'} ne $pre) {
            my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveUrl()",
                          "--[No such pre in db]--[!addurl $pre $url]--[",
                          "$nick]--[$channel]";
            announceError($server, $message);
            printDebug("[ERROR] saveUrl()--[No such pre in db]--[!addurl "
                ."$pre $url]--[$nick]--[$channel]");
        }
        $error{'url'} = $pre;
        return 0;
    }

    if (checkIfUrlExists($pre)) {
        $last{'url'} = $pre;
        return 0;
    }

    printDebug("saveUrl()--[!addurl $pre $url]--[$nick]--[$channel]--START--");

    my $botId = checkBot($nick, "url");
    if (!$botId) {
        return 0;
    }

    my $releaseId = getReleaseId($pre);
    my $channelId = getChannelId($channel);

    if (!checkIfAllowedUrl($url)) {
        printDebug("[ERROR] saveUrl()--[Url is not allowed]--[!addurl $pre "
            ."$url]--[$nick]--[$channel]");
        return 0;
    }

    my $sql = "INSERT INTO urls(releaseid, url, urltime, channelid, botid) ";
              "VALUES (?, ?, ?, ?, ?)";
    my @params = ($releaseId, $url, $urltime, $channelId, $botId);

    if (!runSqlSave($sql, @params)) {
        my $message = "[".$red."ERROR".$reset."] ".$darkgrey."saveUrl()--[",
                      "Unable to save url]--[!addurl $pre $url]--[$nick]--[",
                      "$channel]";
        announceError($server, $message);
        printDebug("[ERROR] saveUrl()--[Unable to save url]--[!addurl $pre "
            ."$url]--[$nick]--[$channel]");
        return 0;
    }

    $last{'url'} = $pre;
    printDebug("saveUrl()--[!addurl $pre $url]--[$nick]--[$channel]--DONE--");

    return 0;
}

# Function to echo !addpres
sub echoPre {
    my ($server, $message) = @_;

    if ($output{'echo'}) {
        printDebug("Echo: $message");

        foreach my $channel (@addpre_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }
    return 0;
}

# Function to echo !infos
sub echoInfo {
    my ($server, $pre, $files, $size) = @_;

    if ($output{'echo'}) {
        my $message;
        my $pretime = "SELECT pretime FROM releases WHERE releasename = ? \
                LIMIT 1";
        my @params = ($pre);

        $pretime = runSqlSingle($pretime, @params);
        if ($pretime > (time()-300)) {
            $message = "!info $pre $files $size";
        }
        else {
            $message = "!oldinfo $pre $files $size";
        }

        printDebug("Echo: $message");

        foreach my $channel (@info_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }
    return 0;
}

# Function to echo !gns
sub echoGenre {
    my ($server, $pre, $genre) = @_;

    if ($output{'echo'}) {

        my $message;
        my $pretime = "SELECT pretime FROM releases WHERE releasename = ? \
                LIMIT 1";
        my @params = ($pre);

        $pretime = runSqlSingle($pretime, @params);
        if ($pretime > (time()-300)) {
            $message = "!gn $pre $genre";
        }
        else {
            $message = "!oldgn $pre $genre";
        }

        printDebug("Echo: $message");

        foreach my $channel (@gn_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }
    return 0;
}

# Subroutine to echo !nuke, !unnuke and !modnuke triggers
# Be sure to double check channel rights!!!
sub echoNukes {
    my ($server, $pre, $reason, $nukenet, $type) = @_;
    my $nukeecho;

    if ($output{'echo'}) {
        my $message;
        if ($type eq "nuke") {
            if ($last{'nuke'} eq $pre && $last{'nukereason'} eq $reason) {
                return 0;
            }
            $message = "!nuke";
            $last{'nuke'} = $pre;
            $last{'nukereason'} = $reason;
            $nukeecho = 'i';
        }
        elsif ($type eq "unnuke") {
            if ($last{'unnuke'} eq $pre && $last{'unnukereason'} eq $reason) {
                return 0;
            }
            $message = "!unnuke";
            $last{'unnuke'} = $pre;
            $last{'unnukereason'} = $reason;
            $nukeecho = 'x';
        }
        elsif ($type eq "modnuke") {
            if ($last{'modnuke'} eq $pre && $last{'modnukereason'} eq $reason) {
                return 0;
            }
            $message = "!modnuke";
            $last{'modnuke'} = $pre;
            $last{'modnukereason'} = $reason;
            $nukeecho = 'i';
        }
        else {
            return 0;
        }

        my $sql = "SELECT networkshort, channelname FROM channels WHERE \
            BINARY allowednukenets LIKE ? AND BINARY channelrights LIKE ?";
        my @params = ("%$nukenet%", "%$nukeecho%");

        my @channels = runSqlMulti($sql, @params);
        my $i = 0;

        # if network isnt allowed on any channel -> quit here
        if (!$channels[0][0]) {
            return 0;
        }

        printDebug("Echo: $message $pre $reason $nukenet");

        while ($i < @channels) {
            $server->command("MSG $channels[$i][0] $channels[$i][1] $message ",
                             "$pre $reason $nukenet");
            $i++;
        }
        undef($message);
    }
    return 0;
}

# Subroutine to echo !delpre and !undelpre
sub echoDelpre {
    my ($server, $pre, $reason, $nukenet, $status) = @_;
    my $delpreecho = 'j';

    if ($output{'echo'}) {
        my $message;
        if ($status eq "delpre") {
            $message = "!delpre";
        }
        elsif ($status eq "undelpre") {
            $message = "!undelpre";
        }
        else {
            return 0;
        }

        my $sql = "SELECT networkshort, channelname FROM channels WHERE \
            BINARY alloweddelprenets LIKE ? AND BINARY channelrights LIKE ?";
        my @params = ("%$nukenet%", "%$delpreecho%");

        my @channels = runSqlMulti($sql, @params);
        my $i = 0;

        # if nerwork isnt allowed on any channel -> quit here
        if (!$channels[0][0]) {
            return 0;
        }

        printDebug("Echo: $message $pre $reason $nukenet");

        while ($i < @channels) {
            $server->command("MSG $channels[$i][0] $channels[$i][1] $message ",
                             "$pre $reason $nukenet");
            $i++;
        }
    }
    return 0;
}

# Subroutine to echo !addolds
sub echoAddold {
    my ($server, $message) = @_;

    $message = "!addold $message";

    if ($output{'echo'}) {
        printDebug("Echo: $message");

        foreach my $channel (@addold_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }
    return 0;
}

# Subroutine to echo !sitepres
sub echoSitepre {
    my ($server, $message, $botid) = @_;

    $message = "!sitepre $message";

    if ($output{'echo'}) {
        printDebug("Echo: $message");

        foreach my $channel (@sitepre_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }
    return 0;
}

# Subroutine to echo !addnfo
sub echoAddnfo {
    my ($server, $message) = @_;

    $message = "!addnfo $message";

    if ($output{'echo'}) {
        printDebug("Echo: $message");

        foreach my $channel (@addnfo_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }
    return 0;
}

# Subroutine to echo !addurl
sub echoUrl {
    my ($server, $pre, $url) = @_;
    my $time = time();
    my $message = "!addurl $pre $url";
    
    my $sql = "SELECT pretime FROM releases WHERE releasename = ? LIMIT 1";
    my @params = ($pre);
    my $result = runSqlSingle($sql, @params);
    
    if ($result < ($time-60*5)) {
            $message = "!oldurl $pre $url";
    }

    if ($output{'echo'}) {
        printDebug("Echo: $message");

        foreach my $channel (@addurl_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }
    return 0;
}

# Subroutine to announce pres in prechannel
sub announcePre {
    my ($server, $message) = @_;
    my ($pre, $section) = split(" ", $message, 3);

    $message = $orange."PRE".$reset.": ".$mediumgrey."$pre".$yellow." $section";

    if ($output{'announcePre'}) {
        foreach my $channel (@pre_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }
    return 0;
}

# Subroutine to announce nukes in prechannel
sub announceNuke {
    my ($server, $message) = @_;
    my ($pre, $reason, $network) = split(" ", $message, 3);

    $message = $red."NUKE".$reset.": ".$mediumgrey."$pre".$darkgrey." ",
               "$reason".$green." $network";

    if ($output{'announceNuke'}) {
        foreach my $channel (@pre_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }
    return 0;
}

# Subroutine to announce unnukes in prechannel
sub announceUnnuke {
    my ($server, $message) = @_;
    my ($pre, $reason, $network) = split(" ", $message, 3);

    $message = $limegreen."UNNUKE".$reset.": ".$mediumgrey."$pre".$darkgrey."",
               "$reason".$green." $network";

    if ($output{'announceNuke'}) {
        foreach my $channel (@pre_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }
    return 0;
}

# Subroutine to announce unnukes in prechannel
sub announceModnuke {
    my ($server, $message) = @_;
    my ($pre, $reason, $network) = split(" ", $message, 3);

    $message = $yellow."MODNUKE".$reset.": ".$mediumgrey."$pre".$darkgrey." ",
               "$reason".$green." $network";

    if ($output{'announceNuke'}) {
        foreach my $channel (@pre_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }
    return 0;
}

# Subroutine to announce addolds in prechannel
sub announceAddold {
    my ($server, $message) = @_;
    my ($pre, $section) = split(" ", $message, 2);

    $message = $yellow."OLD".$reset.": ".$mediumgrey."$pre".$yellow." $section";

    if ($output{'announceOld'}) {
        foreach my $channel (@pre_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }
    return 0;
}

# Subroutine to announce errors
sub announceError {
    my ($server, $message) = @_;

    if ($output{'announceError'}) {
        foreach my $channel (@admin_channels_echo) {
            $server->command("MSG $channel $message");
        }
    }
    return 0;
}

# Subroutine to check prename for spam etc.
# Returns 0 if something bad is found
# returns 1 otherwise.
sub checkPre {
    my $pre = shift;

    if (length($pre) < 13 || length($pre) > $limits{'releaseLength'}) {
        return 0;
    }

    if ($pre =~ /[^a-zA-Z0-9\_\.\(\)\&\-]/) {
        return 0;
    }

    if (($pre =~ m/^\-/) || ($pre =~ m/\-$/) || 
        ($pre =~ m/^\_/) || ($pre =~ m/\_$/)) {
        return 0;
    }

    if ($pre !~ /\-/) {
        return 0;
    }

    return 1;
}

# Subroutine to check if infos are valid
# Returns 0 if error is found, 1 otherwise
sub checkInfos {
    my ($files, $size) = @_;

    if (($size < $files) && ($size >= 1) && ($files > 5) || ($size == 0) || 
        ($files == 0) || ($files > 500) || ($size > 100000)) {
        return 0;
    }

    if (isNumeric($files) && isNumeric($size)) {
        return 1;
    }

    return 0;
}

# subroutine runs filters against dirname
# returns 0 if filter matches, 1 otherwise
sub filterPre {
    my $pre = shift;

    if (($pre =~ m/.*($filter).*/i) && ($pre !~ m/.*($allowed).*/i)) {
        return 0;
    }

    return 1;
}

# Checks if genre is allowed.
sub checkIfAllowedGenre {
    my ($pre, $genre) = @_;
    my $sql;
    
    if ($pre =~ m/.*\.(XXX|IMGSET|IMAGESET).*/i) {
        $sql = "SELECT genrename FROM allowedgenres WHERE genrename = ? AND \
            porn = ? LIMIT 1";
    }
    elsif ($pre =~ m/.*(-|_|\.)(XVID|x264|DVDR|HDTV|PDTV|SDTV|BLURAY|BDRip|BD5|
           BD9|720p|1080p|MBLURAY|MDVDR|VC1|DIVX|NTSC)(-|_|\.)/i) {
        $sql = "SELECT genrename FROM allowedgenres WHERE genrename = ? AND \
            video = ? LIMIT 1";
    }
    else {
        $sql = "SELECT genrename FROM allowedgenres WHERE genrename = ? AND \
            audio = ? LIMIT 1";
    }

    my @params = ($genre, 1);
    $sql = runSqlSingle($sql, @params);
    
    return $sql;
}

# Checks if url is allowed
sub checkIfAllowedUrl {
    my $url = shift;
    
    if ($url =~ m/.*($allowedUrls).*/i) {
        return 1;
    }
    
    return 0;
}

# Extracts groupname from prename
# Returns groupname upon success and 0 upon failure.
sub getGroupName {
    my $pre = shift;

    $pre =~ s/_iNT$//i;

    if ($pre =~ m/-($problemgroups)$/i) {
        my @pGroups = split(/\|/, $problemgroups);

        if (!@pGroups) {
            return 0;
        }

        foreach my $group (@pGroups) {
            if ($pre =~ m/-($group)$/i) {
                return $group;
            }
        }
    }

    my @group = split(/\-/, $pre);
    my $groupName = $group[-1];
    $groupName =~ s/^_*//i;

    return $groupName;
}

# Subroutine to check if group exists in db. If group is found, returns groupid.
# If group is not in db, we shall save it and then return groupid
# input: <groupname>
# returns: groupid
sub getGroupId {
    my $pre = shift;

    my $group = getGroupName($pre);
    if (length($group) < 2 || length($group) > $limits{'groupLength'}) {
        return 0;
    }

    # lets check for known p2p groups
    my @p2p = split(/\|/, $p2p_groups);
    foreach my $p2pgroup (@p2p) {
        if ($group eq $p2pgroup) {
            return 0;
        }
    }

    my $sql = "SELECT groupid FROM groups WHERE groupname = ? LIMIT 1";
    my @params = ($group);

    my $groupId = runSqlSingle($sql, @params);

    if (!$groupId) {
        $groupId = saveGroup($group);
        $groupId = runSqlSingle($sql, @params);

        return $groupId;
    }

    return $groupId;
}

# Subroutine to query status of a release.
# input: <dirname>
# returns:
# 1 if fine
# 2 if nuke
# 3 if unnuke
# 6 if deleted
sub getPreStatus {
    my $pre = shift;

    my $query = "SELECT status FROM releases WHERE releasename = ? LIMIT 1";
    my @params = ($pre);

    my $status = runSqlSingle($query, @params);

    return $status;
}

# Subroutine to query sectionid
# input: <section>
# returns secrionid if found, 0 otherwise
sub getSectionId {
    my $section = shift;

    my $query = "SELECT sectionid FROM sections WHERE sectionname = ? LIMIT 1";
    my @params = ($section);

    my $sectionId = runSqlSingle($query, @params);

    return $sectionId;
}

# Subroutine to save a new group into db.
# input: <groupname>
# returns 1 on success, 0 on failure
sub saveGroup {
    my $group = shift;

    my $sql = "INSERT INTO groups(groupname) VALUES (?)";
    my @params = ($group);
    my $result = runSqlSave($sql, @params);

    return $result;
}

# Subroutine to query channelid from db
# input: <channelname>
# returns channelid or 0 if nothing found
sub getChannelId {
    my $channel = shift;

    my $sql = "SELECT channelid FROM channels WHERE channelname = ? LIMIT 1";
    my @params = ($channel);

    my $channelId = runSqlSingle($sql, @params);

    return $channelId;
}

# Subroutine to query releaseid from db
# input: <dirname>
# returns releaseid or 0 if not found
sub getReleaseId {
    my $pre = shift;

    my $query = "SELECT releaseid FROM releases WHERE releasename = ? LIMIT 1";
    my @params = ($pre);

    my $releaseId = runSqlSingle($query, @params);

    return $releaseId;
}

# Subroutine to query genreid from db
# input: <genre>
# returns releaseid or 0 if not found
sub getGenreId {
    my $genre = shift;

    my $query = "SELECT genreid FROM allowedgenres WHERE genrename = ? LIMIT 1";
    my @params = ($genre);

    my $genreId = runSqlSingle($query, @params);

    return $genreId;
}

# Subroutine to check channel rights
# input: <channel> <channelright>
# returns 1 if channels has right given as a parameter
# returns 0 if not.
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

# Subroutine that reads channels, networks and channelrights from db.
# Inserts data into appropriate arrays.
# Called everytime the script is loaded.
sub getChannels {

    sqlConnect();

    my $sql = "SELECT channelid, channelname, channelrights, networkshort, \
              networkname FROM channels ORDER BY priority ASC";
    my @params = ();

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

# Subroutine that tries to define section from dirname. 
# input: <pre> <section>
# returns section if found 0 otherwise
sub checkSection {
    my ($pre, $section) = @_;

    if (length($section) < 2) {
        return 0;
    }

    # XXX filters
    if ($pre =~ m/.*\.XXX\.*/i) {
        if (($pre =~ m/.*\.(IMAGESET|IMGSET|PIC[X]+)|PHOTOSET\.*/i)) {
            return "IMGSET";
        }
        elsif (($section =~ m/.*\.IMGSET\.*/i) || ($section =~ m/.*\.IMAGESET\.*/i)) {
            return "IMGSET";
        }
        else {
            return "XXX";
        }
    }
    elsif (($pre =~ m/.*(\.|_|-)(IMAGESET|IMGSET|PIC[X]+)|PHOTOSET(\.|_|-).*/i)) {
        return "IMGSET";
    }
    # ANIME
    elsif ($pre =~ m/.*\.ANIME\.*/i) {
        return "ANIME";
    }
    # DVDRipit
    elsif ($pre =~ m/.*\.(DVDRip|R5|CAM|TS|Telesync|HDRip|HDDVDRIP|DVD|BLURAY|BDRip|BD5|BD9)(-|\.)/i) {
        if ($pre =~ m/.*\.S[0-9][0-9]?.?E[0-9][0-9]?.?\./i) {
            if ($pre =~ m/.*\.x264(\.|-|_)/i) {
                return "TV-X264";
            }
            elsif ($pre =~ m/.*\.XviD(-|\.)/i) {
                return "TV-XVID";
            }
            elsif ($pre =~ m/.*\.DVDR(-|\.)/i) {
                return "TV-DVDR";
            }
            else {
                return "TV";
            }
        }
        elsif ($pre =~ m/(_|\.)E[0-9][0-9]?.?\./i) {
            if ($pre =~ m/.*\.x264(\.|-|_)/i) {
                return "TV-X264";
            }
            elsif ($pre =~ m/.*\.XviD(-|\.)/i) {
                return "TV-XVID";
            }
            elsif ($pre =~ m/.*\.DVDR(-|\.)/i) {
                return "TV-DVDR";
            }
            else {
                return "TV";
            }
        }
        elsif ($pre =~ m/.*\.XviD(-|\.)/i) {
            return "XVID";
        }
        elsif ($pre =~ m/.*\.x264(-|\.)/i) {
            return "x264";
        }
        elsif ($pre =~ m/.*\.SVCD(-|\.)/i) {
            return "SCVD";
        }
        elsif ($pre =~ m/.*\.PSP(-|\.)/i) {
            return "PSP";
        }
        elsif ($pre =~ m/.*\.CVCD(-|\.)/i) {
            return "VCD";
        }
        elsif ($pre =~ m/.*\.XVCD(-|\.)/i) {
            return "VCD";
        }
        elsif ($pre =~ m/.*\.DVDR(-|\.)/i) {
            return "DVDR";
        }
        else {
            return "XVID";
        }
    }
    # TV Ripit - DSR / DSRip / SATRIP / PDTV / HDTV
    elsif ($pre =~ m/(\.|_)(DSR|DSRip|SATRip|dTV|HDTV|PDTV|SDTV)(\.|_)/i) {
        if ($pre =~ m/.*\.S[0-9][0-9]?.?E[0-9][0-9]?.?\./i) {
            if ($pre =~ m/(_|\.)x264(-|\.)/i) {
                return "TV-X264";
            }
            elsif ($pre =~ m/(_|\.)XviD(-|\.)/i) {
                return "TV-XVID";
            }
            else {
                return "TV";
            }
        }
        elsif ($pre =~ m/(_|\.)E[0-9][0-9]?.?\./i) {
            if ($pre =~ m/.*\.x264(\.|-|_)/i) {
                return "TV-X264";
            }
            elsif ($pre =~ m/.*\.XviD(-|\.)/i) {
                return "TV-XVID";
            }
            elsif ($pre =~ m/.*\.DVDR(-|\.)/i) {
                return "TV-DVDR";
            }
            else {
                return "TV";
            }
        }
        elsif ($pre =~ m/(_|\.)XviD(-|\.)/i) {
            return "TV-XVID";
        }
        elsif ($pre =~ m/(_|\.)x264(-|\.)/i) {
            return "TV-X264";
        }
        else {
            return "TV";
        }
    }
    # BluRay
    elsif ($pre =~ m/.*\.BluRay\.*/i) {
        if ($pre =~ m/.*\.x264(\.|-)/i) {
            return "X264";
        }
        elsif ($pre =~ m/.*\.VC1(\.|-)/i) {
            return "VC1";
        }
        else {
            return "BLURAY";
        }
    }
    elsif ($pre =~ m/.*\.MBluRay\.*/i) {
        return "MBLURAY";
    }
    # HDDVD
    elsif ($pre =~ m/.*\.HDDVD\.*/i) {
        if ($pre =~ m/.*\.x264(\.|-)/i) {
            return "X264";
        }
        elsif ($pre =~ m/.*\.VC1(\.|-)/i) {
            return "VC1";
        }
        else {
            return "HDDVD";
        }
    }
    # DVDR
    elsif ($pre =~ m/.*(_|\.)DVDR(\.|-|_).*/i) {
        return "DVDR";
    }
    # MDVDR
    elsif ($pre =~ m/.*(_|\.)MDVDR(\.|-|_).*/i) {
        return "MDVDR";
    }
    # COVERS
    elsif (($pre =~ m/(-|_|\.)(COVERS|COVER)(\.|-|_)/i) && 
          ($pre !~ m/(-|_|\.)(RECOVER)(\.|-|_)/i)) {
        return "COVERS";
    }
    # SUBPACK
    elsif ($pre =~ m/.*\.SUBPACK\.*/i) {
        return "SUBPACK";
    }
    # MS consoles - XBOX - X360
    elsif ($pre =~ m/(_|\.)(X|XBOX)360(\.|-|_)/i) {
        return "X360";
    }
    elsif ($pre =~ m/(_|\.)XBOX(\.|-|_)/i) {
        return "XBOX";
    }
    # Sony consoles
    elsif ($pre =~ m/.*(_|\.)(PS2|PS2DVD)(\.|-|_).*/i) {
        return "PS2";
    }
    elsif ($pre =~ m/.*\.PS3\.*/i) {
        return "PS3";
    }
    elsif ($pre =~ m/.*(_|\.)(PSP|PSXPSP)(\.|-|_).*/i) {
        return "PSP";
    }
    elsif ($pre =~ m/.*(_|\.)WII(\.|-|_).*/i) {
        return "WII";
    }
    elsif ($pre =~ m/.*(_|\.)NDS(\.|-|_).*/i) {
        return "NDS";
    }
    elsif ($pre =~ m/.*(_|\.)NGC(\.|-|_).*/i) {
        return "NGC";
    }
    elsif ($pre =~ m/.*(_|\.)GBA(\.|-|_).*/i) {
        return "GBA";
    }
    elsif ($pre =~ m/.*(_|\.)EBOOK(\.|-|_).*/i) {
        return "EBOOK";
    }
    elsif ($pre =~ m/.*(_|-|\.)AUDIOBOOK(\.|-|_).*/i){
        return "AUDIOBOOK";
    }
    elsif ($pre =~ m/.*NOTICE.*/i){
        return "NOTICE";
    }
    # MVID Viikate-Live_At_CCCK_Kuopio_(12-12-2009)-DVDRip-x264-FI-2010-KALAVALE
    elsif ($pre =~ m/(_|-)?(DVDRip|HDTV|PDTV|DSR|DSRip|SATRip|dTV)?-?(XviD|x264)-[0-9]{4}-(iNT|iNTERNAL)?-?/i) {
        return "MVID";
    }
    elsif ($pre =~ m/(_|-)?(DVDRip|HDTV|PDTV|DSR|DSRip|SATRip|dTV)?-?(XviD|x264)-.?[0-9]{4}-/i) {
        return "MVID";
    }
    elsif ($pre =~ m/.*\COMICS\.*/i) {
        return "EBOOK";
    }
    # If we cant get section from dirname
    else {
        if ($pre =~ m/-($gamegroups)$/i){
            return "GAMES";
        }
        elsif ($pre =~ m/-($porngroups)$/i) {
            return "XXX";
        }
        elsif ($section =~ m/^($valid_sections)$/i) {
            return $section;
        }
        elsif ($section =~ m/MP3.*/i) {
            return "MP3";
        }
        elsif ($section eq "MV") {
            return "MVID";
        }
        else {
            return 0;
        }
    }
    return 0;
}

# Subroutine to check bots status
# Returns id if ok, 0 if banned
# input: <botname> <statustype>
sub checkBot {
    my ($bot, $query) = @_;
    my $sql;
    
    if ($query eq "addpre") {
        $sql = "SELECT botid, status FROM bots WHERE botname = ? LIMIT 1";
    }
    elsif ($query eq "info") {
        $sql = "SELECT botid, info FROM bots WHERE botname = ? LIMIT 1";
    }
    elsif ($query eq "genre") {
        $sql = "SELECT botid, genre FROM bots WHERE botname = ? LIMIT 1";
    }
    elsif ($query eq "nuke") {
        $sql = "SELECT botid, nuke FROM bots WHERE botname = ? LIMIT 1";
    }
    elsif ($query eq "delpre") {
        $sql = "SELECT botid, delpre FROM bots WHERE botname = ? LIMIT 1";
    }
    elsif ($query eq "nfo") {
        $sql = "SELECT botid, nfo FROM bots WHERE botname = ? LIMIT 1";
    }
    elsif ($query eq "url") {
        $sql = "SELECT botid, url FROM bots WHERE botname = ? LIMIT 1";
    }
    elsif ($query eq "updatetime") {
        $sql = "SELECT botid, updatetime FROM bots WHERE botname = ? LIMIT 1";
    }
    else {
        return 0;
    }

    my @params = ($bot);

    my @bot = runSqlMulti($sql, @params);

    my $id = $bot[0][0];
    my $status = $bot[0][1];

    if (!$id) {
        my $id = saveBot($bot);
        $sql = "SELECT botid FROM bots WHERE botname = ? LIMIT 1";
        $id = runSqlSingle($sql, @params);

        return $id;
    }
    elsif ($status) {
        return $id;
    }
    
    return 0;
}

# Subroutine to save new bot to db, without owner
# input: <botname>
sub saveBot {
    my $bot = shift;

    my $sql = "INSERT INTO bots(botname) VALUES (?)";
    my @params = ($bot);
    my $result = runSqlSave($sql, @params);

    return $result;
}

# Checks nukenets status. Status for nukes and delrpes are separated, for
# instance nukes from one nukenet may be blocked but delpres allowed and
# vise versa.
#
# input: <nukenet> <status_type>
# returns nukenetid if ok, 0 if blocked
sub checkNukenet {
    my ($nukenet, $type) = @_;
    my $sql;

    if ($type eq "delpre") {
        $sql = "SELECT nukenetid, delprestatus FROM nukenets WHERE \
            nukenetname = ? LIMIT 1";
    }
    elsif ($type eq "nuke") {
        $sql = "SELECT nukenetid, nukestatus FROM nukenets WHERE \
            nukenetname = ? LIMIT 1";
    }
    else {
        return 0;
    }

    my @params = ($nukenet);
    my @result = runSqlMulti($sql, @params);

    my $nukenetId = $result[0][0];
    my $status = $result[0][1];

    if (!$status) {
        return 0;
    }

    return $nukenetId;
}

# Subroutine to save new nukenet into db
sub saveNukenet {
    my $nukenet = shift;

    my $sql = "INSERT INTO nukenets(nukenetname) VALUES (?)";
    my @params = ($nukenet);

    my $result = runSqlSave($sql, @params);

    return $result;
}

# Checks if pre is already exists, checks both releases and delpred tables.
# Returns 1 if found in releasedb, 0 if not anywhere and 6 if delpred
sub checkIfPreExists {
    my $pre = shift;

    my $sql = "SELECT releaseid FROM releases WHERE releasename = ? LIMIT 1";
    my @params = ($pre);

    if (runSqlSingle($sql, @params)) {
        return 1; # found in releases table
    }
    else {
        my $sql = "SELECT delpreid FROM delpred WHERE releasename = ? LIMIT 1";

        if (runSqlSingle($sql, @params)) {
            return 6; # found in delpred
        }
    }

    return 0; # not in releases nor in delpred
}

# Function to check if infos exists for parameter releaseid
# Returns 1 if infos already in db, 0 otherwise
sub checkIfInfoExists {
    my $pre = shift;

    my $sql = "SELECT i.releaseid FROM infos as i LEFT JOIN releases AS r ON \
            r.releaseid = i.releaseid WHERE r.releasename = ? LIMIT 1";
    my @params = ($pre);

    if (runSqlSingle($sql, @params)) {
        return 1;
    }

    return 0;
}

# Function to check if infos exists.
# Parameter: releasename
# Returns: 1 if genre is found, 0 otherwise
sub checkIfGenreExists {
    my $pre = shift;

    my $sql = "SELECT g.genreid FROM genres AS g LEFT JOIN releases AS r ON \
            r.releaseid = g.releaseid WHERE r.releasename = ? LIMIT 1";
    my @params = ($pre);

    if (runSqlSingle($sql, @params)) {
        return 1;
    }

    return 0;
}

# Function to check if url exists in db
# Parameter: releaseid
# Returns: 1 if url is found, 0 otherwise
sub checkIfUrlExists {
    my $pre = shift;

    my $sql = "SELECT u.releaseid FROM urls AS u LEFT JOIN releases as r ON \
            r.releaseid = u.releaseid WHERE r.releasename = ? LIMIT 1";
    my @params = ($pre);

    if (runSqlSingle($sql, @params)) {
        return 1;
    }

    return 0;
}

# Checks if nfo is already exists.
# Returns 1 if found, else returns 0.
sub checkIfNfoExists {
    my $pre = shift;

    my $sql = "SELECT n.releaseid FROM nfos AS n LEFT JOIN releases AS r ON \
            r.releaseid = n.releaseid WHERE r.releasename = ? LIMIT 1";
    my @params = ($pre);

    if (runSqlSingle($sql, @params)) {
        return 1;
    }

    return 0;
}

#
# SQL routines
#

# initialize connection
sub sqlConnect {
    my $data_source = 
        "DBI:mysql:database=$mysql{'dbname'};host=$mysql{'host'};$mysql{'port'}";

    $dbh = DBI->connect($data_source, $mysql{'user'}, $mysql{'pass'}, {
            'RaiseError' => 1
            }) or die "could not connect to mysql database";
}

# close connection
sub sqlDisconnect {
    $dbh->disconnect();
}

# Runs sql query with multiple possible results
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

# Perl trim function to remove whitespace
# from the start and end of the string
sub trim {
    my $string = shift;

    $string =~ s/^\s+//;
    $string =~ s/\s+$//;

    return $string;
}

# Strip letters from input
sub stripLetters {
    my ($text) = @_;

    $text =~ s/a-zA-Z//gi;

    return $text;
}

# Strip colors form input
sub stripColor {
    my $string = shift;

    # mIRC colors
    $string =~ s/\x03(?:\d{1,2}(?:,\d{1,2})?)?//g;
    $string =~ s/\x0f//g;

    # RGB colors supported by some clients
    $string =~ s/\x04[0-9a-f]{0,6}//ig;

    return $string;
}

# Strip formating from input
sub stripFormatting {
    my $string = shift;
    $string =~ s/[\x0f\x02\x1f\x16\x1d\x11]//g;
    return $string;
}

# Strip bad chars
sub stripBadCharsPre {
    my $string = shift;

    $string !~ s/[^a-zA-Z0-9\_\.\(\)\&\-]//g;
    return $string;
}

# Strip bad chars
sub stripBadCharsFile {
    my $string = shift;

    $string !~ s/[^a-zA-Z0-9\_\.\(\)\&\-]//g;
    return $string;
}

# Strip bad chars
sub stripBadCharsUrl {
    my $string = shift;

    $string !~ s/[^a-zA-Z0-9\_\.\(\)\&\-\/:?&=#]//g;
    return $string;
}

# Strip bad chars
sub stripSqlInjection {
    my $string = shift;

    $string =~ s/['";]//g;
    return $string;
}

# Strip bad chars
sub stripBadCharsGenre {
    my $string = shift;

    $string !~ s/[^a-zA-Z0-9\_\&\-\s\/]//g;
    return $string;
}

# Function to strip url from nfo
sub stripUrlFromNfo {
    my (@nfo) = @_;
    my $find = "http://";

    for (@nfo) {
        if ($_ =~ /$find/) {
            my @words = split(" ", $_);
            for (@words) {
                if ($_ =~ /^$find.*$/) {
                    return $_;
                }
            }
        }
    }

    return 0;
}

# Function to strip genre from nfo
sub stripGenreFromNfo {
    my ($pre, @nfo) = @_;
    my $find = "GENRE|STYLE|TYPE";

    for (@nfo) {
        if ($_ =~ /.*(GENRE|STYLE).*/gi) {
            my $line = stripBadCharsGenre($_);
            $line =~ s/genre//gi;

            my @words = split(" ", $line);
            for (@words) {
                my $genre = trim($_);
                printDebug("Parsed genre: $genre");
                $genre = checkIfAllowedGenre($pre, $genre);
                if ($genre) {
                    return $genre;
                }
            }	

            if ($line =~ /\//) {
                @words = split(/\//, $line);
            for (@words) {
                my $genre = trim($_);
                printDebug("Parsed genre: $genre");
                $genre = checkIfAllowedGenre($pre, $genre);
                if ($genre) {
                    return $genre;
                }
            }
        }

        my $genre = $words[0]."_".$words[1];
        printDebug("Parsed genre: $genre");
        $genre = checkIfAllowedGenre($pre, $genre);
        if ($genre) {
            return $genre;
        }
        }
    }

    return 0;
}

# tries to fetch genres from TVRage.com
# http://services.tvrage.com/tools/quickinfo.php?show=Example%20Show
sub fetchDataFromNet {
    my ($pre, $server) = @_;
    my $release = $pre;
    my $fetchurl = "http://services.tvrage.com/tools/quickinfo.php?show=";
    my $imdbapi = "http://www.imdbapi.com/?t=";

    # if a tv show
    if ($pre =~ m/.*\.S[0-9][0-9]?.?E[0-9][0-9]?.?\./i) {
        $pre =~ s/\.S[0-9][0-9]?.?E[0-9][0-9]?.?\..*$//;

        if ($pre =~ /\./) {
            $pre =~ s/\./%20/g;
        }
        elsif ($pre =~ /_/) {
            $pre =~ s/_/%20/g;
        }

        my $info = get($fetchurl.$pre."&exact=1");
        my @data = split(/\n/, $info);

        my $url = $data[2];		
        $url =~ s/Show\sURL@//;

        if (length($url)>1) {
            printDebug("[tvrage]->$url");
            saveUrl("$release $url", $server, "tvrage", "tvrage");
        }

        my $gn;
        for (@data) {
            if ($_ =~ /^Genres@.*/) {
                $gn = $_;
                $gn =~ s/Genres@//;
                printDebug("[tvrage]->$gn");
                my $genre = checkIfAllowedGenre($release, $gn); 
                if ($genre) {
                    saveGenre("$release $genre", $server, "tvrage", "tvrage");
                    last;
                }

                my @genres;
                if ($gn =~ /\|/) {
                    @genres = split(/\|/, $gn);
                }
                elsif ($gn =~ /\//) {
                    @genres = split(/\//, $gn);
                }
                else {
                    return 0;
                }

                for (@genres) {
                    my $genre = trim($_);
                    printDebug("[tvrage]->$genre");
                    $genre = checkIfAllowedGenre($release, $genre); 
                    if ($genre) {
                        saveGenre("$release $genre", $server, "tvrage", "tvrage");
                        last;
                    }
                }
            }
        }
    }
    elsif ($pre =~ m/(_|\.)E[0-9][0-9]?.?\./i) {
        $pre =~ s/(_|\.)E[0-9][0-9]?.?\..*$//;

        if ($pre =~ /\./) {
            $pre =~ s/\./%20/g;
        }
        elsif ($pre =~ /_/) {
            $pre =~ s/_/%20/g;
        }

        my $info = get($fetchurl.$pre."&exact=1");
        my @data = split(/\n/, $info);

        my $url = $data[2];

        $url =~ s/Show\sURL@//;

        if (length($url)>1) {
            printDebug("[tvrage]->$url");
            saveUrl("$release $url", $server, "tvrage", "tvrage");
        }

        my $gn;
        for (@data) {
            if ($_ =~ /^Genres@.*/) {
                $gn = $_;
                $gn =~ s/Genres@//;
                printDebug("[tvrage]->$gn");
                my $genre = checkIfAllowedGenre($release, $gn); 
                if ($genre) {
                    saveGenre("$release $genre", $server, "tvrage", "tvrage");
                    last;
                }

                my @genres;
                if ($gn =~ /\|/) {
                    @genres = split(/\|/, $gn);
                }
                elsif ($gn =~ /\//) {
                    @genres = split(/\//, $gn);
                }
                else {
                    return 0;
                }

                for (@genres) {
                    my $genre = trim($_);
                    printDebug("[tvrage]->$genre");
                    $genre = checkIfAllowedGenre($release, $genre); 
                    if ($genre) {
                        saveGenre("$release $genre", $server, "tvrage", "tvrage");
                        last;
                    }
                }
            }
        }
    }
    elsif (($pre =~ m/.*\.[0-9][0-9][0-9][0-9]?.[0-9][0-9]?.[0-9][0-9]?.?\./i) 
          && ($pre =~ m/.*(XVID|X264|DVDR).*/)) {

        $pre =~ s/(_|\.)[0-9][0-9][0-9][0-9]?\.[0-9][0-9]?\.[0-9][0-9]?\..*$//;

        if ($pre =~ /\./) {
            $pre =~ s/\./%20/g;
        }
        elsif ($pre =~ /_/) {
            $pre =~ s/_/%20/g;
        }

        my $info = get($fetchurl.$pre."&exact=1");
        my @data = split(/\n/, $info);

        my $url = $data[2];
        $url =~ s/Show\sURL@//;

        if (length($url)>1) {
            printDebug("[tvrage]->$url");
            saveUrl("$release $url", $server, "tvrage", "tvrage");
        }

        my $gn;
        for (@data) {
            if ($_ =~ /^Genres@.*/) {
                $gn = $_;
                $gn =~ s/Genres@//;
                printDebug("[tvrage]->$gn");
                my $genre = checkIfAllowedGenre($release, $gn); 
                if ($genre) {
                    saveGenre("$release $genre", $server, "tvrage", "tvrage");
                    last;
                }

                my @genres;
                if ($gn =~ /\|/) {
                    @genres = split(/\|/, $gn);
                }
                elsif ($gn =~ /\//) {
                    @genres = split(/\//, $gn);
                }
                else {
                    return 0;
                }

                for (@genres) {
                    my $genre = trim($_);
                    printDebug("[tvrage]->$genre");
                    $genre = checkIfAllowedGenre($release, $genre); 
                    if ($genre) {
                        saveGenre("$release $genre", $server, "tvrage", "tvrage");
                        last;
                    }
                }
            }
        }
    }
    elsif (($pre =~ m/.*\.[0-9][0-9][0-9][0-9]?\..*/i) && 
          ($pre =~ m/.*(XVID|X264|DVDR).*/)) {

        $pre =~ s/\.[0-9][0-9][0-9][0-9]?\..*//;
        if ($pre =~ /\./) {
            $pre =~ s/\./\+/g;
        }

        $pre = trim($pre);
        printDebug("IMDB query: $pre");

        my $info = get($imdbapi.$pre."&r=JSON");
        my $info2 = $info;
        #$info = decode_json($info);

        my $json = new JSON;
        $info2 = $json->allow_nonref->utf8(0)->relaxed->decode($info2);
        printDebug($info2->{Genre});
        printDebug($info2->{ID});

        my $genre = $info2->{Genre};
        my $url = $info2->{ID};

        if (length($url)>1) {
            $url = "http://www.imdb.com/title/$url";
            printDebug("[imdb]->$url");
            saveUrl("$release $url", $server, "imdb", "imdb");
        }

        $genre =~ s/,//gi;
        my @genres = split(" ", $genre);
        for (@genres) {
            my $genre = trim($_);
            printDebug("[imdb]->$genre");
            $genre = checkIfAllowedGenre($release, $genre); 
            if ($genre) {
                saveGenre("$release $genre", $server, "imdb", "imdb");
                last;
            }
        }	
    }
    elsif (($pre =~ m/.*(\.)?(FiNNiSH|SWEDISH|DANISH|NORWEGIAN|GERMAN|FLEMISH)?\.(720p|1080p)?\.?(BluRay|BD5|BD9|BDRip)?\.(x264|XviD)?.*/i) 
            && ($pre !~ m/.*(-|\.)?(MDVDR|XXX)?(-|\.)?.*/g)) {

        $pre =~ s/(\.)?(FiNNiSH|SWEDiSH|DANiSH|NORWEGiAN|GERMAN|FLEMISH|PL|FRENCH)?\.(720p\.|1080p\.)?(BluRay|BD5|BD9|BDRip)?\.(x264|XviD)?.*//;

        if ($pre =~ /\./) {
            $pre =~ s/\./\+/g;
        }

        $pre = trim($pre);
        printDebug("IMDB query: $pre");

        my $info = get($imdbapi.$pre."&r=JSON");
        my $info2 = $info;

        my $json = new JSON;
        $info2 = $json->allow_nonref->utf8(0)->relaxed->decode($info2);
        printDebug($info2->{Genre});
        printDebug($info2->{ID});

        my $genre = $info2->{Genre};
        my $url = $info2->{ID};

        if (length($url)>1) {
            $url = "http://www.imdb.com/title/$url";
            printDebug("[imdb]->$url");
            saveUrl("$release $url", $server, "imdb", "imdb");
        }

        $genre =~ s/,//gi;
        my @genres = split(" ", $genre);
        for (@genres) {
            my $genre = trim($_);
            printDebug("[imdb]->$genre");
            $genre = checkIfAllowedGenre($release, $genre); 
            if ($genre) {
                saveGenre("$release $genre", $server, "imdb", "imdb");
                last;
            }
        }
    }

    return 0;
}

# Checks if input is a number
sub isNumeric {
    my $text = shift;

    if ($text =~ /^(\d+\.?\d*|\.\d+)$/) {
        return 1;
    }

    return 0;
}

# prints debugmessages
sub printDebug {
    my $message = shift;

    if ($output{'debug'}) {
        print " ".$message;
    }

    return 0;
}
