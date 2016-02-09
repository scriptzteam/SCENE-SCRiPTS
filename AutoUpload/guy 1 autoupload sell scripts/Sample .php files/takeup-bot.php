<?


require_once("include/benc.php");
require_once("include/bittorrent.php");
require "rconpasswords.php";

function bark($msg="") {
	echo $msg;
	die ();
}

$ip = getip();

if ($ip != "1.2.3.4")
bark("no up access");

//error_reporting(E_ALL ^ E_NOTICE);

hit_start();

ini_set("upload_max_filesize",$max_torrent_size);



function ircannounce($msg) {
	
	if ($msg == "") {
		return;
	}
	
	$bot['ip'] = "localhost"; // the ip of the bot spamming the upload details
	$bot['port'] = "12345"; // your script listen port on the bot
	$bot['password'] = "xxxx"; // password which you have set in the ftp script

	$fp = fsockopen($bot['ip'], $bot['port'], $errno, $errstr, 40);
	if($fp)
	{
		fputs($fp, $bot['password'] . " " . $msg . "\n");
		sleep(2);
		fclose($fp);
	}

}

function get_pretimex($ts)
{
 $since=$ts;
 $pots = array('second','minute','hour','day','week','month','year','decade');
 $lngh = array(1,60,3600,86400,604800,2630880,31570560,315705600);
 for($i=count($lngh)-1;$i>=0;$i--)
 {
 if($since>=$lngh[$i])
 {
 $gets[] .= ($n=intval($since/$lngh[$i])). ' '. $pots[$i] . ($n>1?'s':'');
 $since%=$lngh[$i];
 }
 }
 return implode(', ',$gets);
}


dbconn();

hit_count();

//loggedinorreturn();

$res = mysql_query("SELECT * FROM users WHERE id = 6929 AND enabled='yes' AND status = 'confirmed'");// or die(mysql_error());
$row = mysql_fetch_assoc($res);

    if (!$row)
        bark("invalid user");

$GLOBALS["CURUSER"] = $row;

if ($CURUSER["uploadpos"] == 'no')
die();

foreach(explode(":","type") as $v) {
	if (!isset($_POST[$v]))
		bark("missing form data");
}

if (!isset($_FILES["file"]))
	bark("missing form data");

$f = $_FILES["file"];
$fname = unesc($f["name"]);
if (empty($fname))
	bark("Empty filename!");
	

$freeleech = "0";

	if (!empty($_POST['poster']))
      $poster = unesc($_POST['poster']);

    $nfo = sqlesc('');
    /////////////////////// NFO FILE ////////////////////////	
    if(isset($_FILES['nfo']) && !empty($_FILES['nfo']['name'])) {
    $nfofile = $_FILES['nfo'];
    if ($nfofile['name'] == '')
      bark("No NFO!");

    if ($nfofile['size'] == 0)
      bark("0-byte NFO");

    if ($nfofile['size'] > 65535)
      bark("NFO is too big! Max 65,535 bytes.");

    $nfofilename = $nfofile['tmp_name'];

    if (@!is_uploaded_file($nfofilename))
      bark("NFO upload failed");

    $nfo = sqlesc(str_replace("\x0d\x0d\x0a", "\x0d\x0a", @file_get_contents($nfofilename)));
    }
    /////////////////////// NFO FILE END /////////////////////
	
	if ($nfofile['name'] == '')
	bark("You must upload NFO!");
	
	$descr = (isset($_POST['descr'])) ? unesc($_POST["descr"]) : "";
	
	if ($descr !="") {
	
		include 'include/strip.php';
		$descr = preg_replace("/[^\\x20-\\x7e\\x0a\\x0d]/", " ", $descr);
		strip($descr);
	
	}
  
$vip = "no";

$scene = "yes";

$catid = (0 + $_POST["type"]);
if (!is_valid_id($catid))
	bark("You must select a category to put the torrent in!");

if (!validfilename($fname))
	bark("Invalid filename!");
if (!preg_match('/^(.+)\.torrent$/si', $fname, $matches))
	bark("Invalid filename (not a .torrent).");
$shortfname = $torrent = $matches[1];

if (!empty($_POST["name"]))
	$torrent = unesc($_POST["name"]);

$tmpname = $f["tmp_name"];
if (!is_uploaded_file($tmpname))
	bark("eek");
if (!filesize($tmpname))
	bark("Empty file!");

$dict = bdec_file($tmpname, $max_torrent_size);
if (!isset($dict))
	bark("What the hell did you upload? This is not a bencoded file!");

function dict_check($d, $s) {
	if ($d["type"] != "dictionary")
		bark("not a dictionary");
	$a = explode(":", $s);
	$dd = $d["value"];
	$ret = array();
	foreach ($a as $k) {
		unset($t);
		if (preg_match('/^(.*)\((.*)\)$/', $k, $m)) {
			$k = $m[1];
			$t = $m[2];
		}
		if (!isset($dd[$k]))
			bark("dictionary is missing key(s)");
		if (isset($t)) {
			if ($dd[$k]["type"] != $t)
				bark("invalid entry in dictionary");
			$ret[] = $dd[$k]["value"];
		}
		else
			$ret[] = $dd[$k];
	}
	return $ret;
}

function dict_get($d, $k, $t) {
	if ($d["type"] != "dictionary")
		bark("not a dictionary");
	$dd = $d["value"];
	if (!isset($dd[$k]))
		return;
	$v = $dd[$k];
	if ($v["type"] != $t)
		bark("invalid dictionary entry type");
	return $v["value"];
}

list($ann, $info) = dict_check($dict, "announce(string):info");
list($dname, $plen, $pieces) = dict_check($info, "name(string):piece length(integer):pieces(string)");

//if (!in_array($ann, $announce_urls, 1))
	//bark("invalid announce url! must be <b>" . $announce_urls[0] . "</b>");

if (strlen($pieces) % 20 != 0)
	bark("invalid pieces");

$filelist = array();
$totallen = dict_get($info, "length", "integer");
if (isset($totallen)) {
	$filelist[] = array($dname, $totallen);
	$type = "single";
}
else {
	$flist = dict_get($info, "files", "list");
	if (!isset($flist))
		bark("missing both length and files");
	if (!count($flist))
		bark("no files");
	$totallen = 0;
	foreach ($flist as $fn) {
		list($ll, $ff) = dict_check($fn, "length(integer):path(list)");
		$totallen += $ll;
		$ffa = array();
		foreach ($ff as $ffe) {
			if ($ffe["type"] != "string")
				bark("filename error");
			$ffa[] = $ffe["value"];
		}
		if (!count($ffa))
			bark("filename error");
		$ffe = implode("/", $ffa);
		$filelist[] = array($ffe, $ll);
	}
	$type = "multi";
}

/*
$info['value']['source']['type'] = "string";
$info['value']['source']['value'] = $SITENAME;
$info['value']['source']['strlen'] = strlen($info['value']['source']['value']);
$info['value']['private']['type'] = "integer";
$info['value']['private']['value'] = 1;
$dict['value']['info'] = $info;
$dict = benc($dict);
$dict = bdec($dict);
list($ann, $info) = dict_check($dict, "announce(string):info");
*/
#Start Private Tracker Patch

$dict['value']['announce']=bdec(benc_str( $announce_urls[0]));  // change announce url to local
$dict['value']['info']['value']['private']=bdec('i1e');  // add private tracker flag
unset($dict['value']['announce-list']); // remove multi-tracker capability
unset($dict['value']['nodes']); // remove cached peers (Bitcomet & Azareus)
unset($dict['value']['info']['value']['crc32']); // remove crc32
unset($dict['value']['info']['value']['ed2k']); // remove ed2k
unset($dict['value']['info']['value']['md5sum']); // remove md5sum
unset($dict['value']['info']['value']['sha1']); // remove sha1
unset($dict['value']['info']['value']['tiger']); // remove tiger
unset($dict['value']['azureus_properties']); // remove azureus properties
$dict=bdec(benc($dict)); // double up on the becoding solves the occassional misgenerated infohash
$dict['value']['comment']=bdec(benc_str( "Torrent created for SceneBits")); // change torrent comment
list($ann, $info) = dict_check($dict, "announce(string):info");

#End of Private Tracker Patch

$infohash = pack("H*", sha1($info["string"]));


// Replace punctuation characters with spaces

$pretime = 0+@file_get_contents("http://xxxxx/abcd.php?name=".trim($torrent));

$poster = (isset($_POST['poster'])) ? unesc($_POST['poster']) : "";

//$torrent = str_replace("_", " ", $torrent);

$anonymous = 'yes';

$ret = mysql_query("INSERT INTO torrents (search_text, filename, owner, visible, scene, freeleech, url, anonymous, vip, info_hash, poster, name, size, numfiles, type, descr, ori_descr, category, save_as, added, last_action, nfo, pretime) VALUES (" .
		implode(",", array_map("sqlesc", array(searchfield("$shortfname $dname $torrent"), $fname, $CURUSER["id"], "no", $scene, $freeleech, $url, $anonymous, $vip, $infohash, $poster, $torrent, $totallen, count($filelist), $type, $descr, $descr, 0 + $_POST["type"], $dname))) .
		", '" . get_date_time() . "', '" . get_date_time() . "', $nfo, '" . $pretime . "')");

if (!$ret) {
	if (mysql_errno() == 1062)
		bark("torrent already uploaded!");
	bark("mysql puked: ".mysql_error());
}
$id = mysql_insert_id();

@mysql_query("DELETE FROM files WHERE torrent = $id");
foreach ($filelist as $file) {
	@mysql_query("INSERT INTO files (torrent, filename, size) VALUES ($id, ".sqlesc($file[0]).",".$file[1].")");
}

move_uploaded_file($tmpname, "$torrent_dir/$id.torrent");

//IRC ANNOUNCE by sCRiPTzTEAM  02-August-2009
$upvar = $pretime != '0' ? " :: \0033Uploaded\003: ".get_pretimex($pretime)." after pre." : "";
$res = mysql_query("SELECT name FROM categories WHERE id=$catid") or sqlerr(__FILE__, __LINE__);
$arr = mysql_fetch_assoc($res);
$cat = $arr["name"];
$ircmsg = "\002\0032NEW\003\002 in \0033$cat\003 => $torrent :: \0036Size\003: ".mksize($totallen)."$upvar :: \00314http://www.scenebits.info/details.php?id=$id\003";
ircannounce($ircmsg);
//IRC Announce End

//===add karma 
mysql_query("UPDATE users SET seedbonus = seedbonus+15.0 WHERE id = $CURUSER[id]") or sqlerr(__FILE__, __LINE__);
//===end

write_log("Torrent $id ($torrent) was uploded by Anonymous!");

/** shoutbox announce new torrent **/ //--- edited by triple h
$free2 = (isset($freeleech) && $freeleech == 'yes'? '[color=green][FREE][/color]' : '');
$catname = mysql_result(mysql_query('SELECT name FROM categories where id= '.$catid),0);

switch($catid)
{
    default: $message = ' [b]'.$free2.' [color=red]New '.$catname.' torrent [/color][/b]  [url=details.php?id='.$id.'] '.$torrent.'[/url]  '; break;
    case '9': $message = ' [b]'.$free2.' [color=darkred]New Adult torrent [/color][/b]  [url=details.php?id='.$id.'] Link[/url]'; break;
    case '35': $message = ' [b]'.$free2.' [color=darkred]New Adult torrent [/color][/b]  [url=details.php?id='.$id.'] Link[/url]'; break;
}
   
autoshout($message);
/** end **/

/* RSS 0.91 feeds */

if (($fd1 = @fopen("rss.xml", "w")) && ($fd2 = fopen("rssdd.xml", "w")))
{
    $cats = "";
    $res = mysql_query("SELECT id, name FROM categories");
    while ($arr = mysql_fetch_assoc($res))
        $cats[$arr["id"]] = $arr["name"];
    $s = "<?xml version=\"1.0\" encoding=\"iso-8859-1\" ?>\n<rss version=\"0.91\">\n<channel>\n" .
        "<title>SceneBits</title>\n<description>0-week torrents</description>\n<link>$DEFAULTBASEURL/</link>\n";
    @fwrite($fd1, $s);
    @fwrite($fd2, $s);
    $r = mysql_query("SELECT id,name,descr,filename,category FROM torrents ORDER BY added DESC LIMIT 15") or sqlerr(__FILE__, __LINE__);
    while ($a = mysql_fetch_assoc($r))
    {
        $cat = $cats[$a["category"]];
        $s = "<item>\n<title>" . htmlspecialchars($a["name"] . " ($cat)") . "</title>\n" .
            "<description>" . htmlspecialchars($a["descr"]) . "</description>\n";
        @fwrite($fd1, $s);
        @fwrite($fd2, $s);
        @fwrite($fd1, "<link>$DEFAULTBASEURL/details.php?id=$a[id]&hit=1</link>\n</item>\n");
        $filename = htmlspecialchars($a["filename"]);
        @fwrite($fd2, "<link>$DEFAULTBASEURL/download.php/$a[id]/$filename</link>\n</item>\n");
    }
    $s = "</channel>\n</rss>\n";
    @fwrite($fd1, $s);
    @fwrite($fd2, $s);
    @fclose($fd1);
    @fclose($fd2);
}


$fp = fopen("$torrent_dir/$id.torrent", "w");
if ($fp)
{
 @fwrite($fp, benc($dict), strlen(benc($dict)));
 fclose($fp);
}
	
	bark("OK {$id}");

	hit_end();

?>