<?php

require_once "/usr/local/apache2/htdocs/www/include/config.php";

define('TIME_NOW', time());

function connect() 
{
	global $mysql_host, $mysql_user, $mysql_pass, $mysql_db;
	
	$con = mysql_connect($mysql_host, $mysql_user, $mysql_pass);
	if (!$con)
	{
		die('Database connection failed: ' . mysql_error());
	}
	
	$db = mysql_select_db($mysql_db);
	if(!$db){
		die('Database selection failed: ' . mysql_error());
	}
	
}


function disconnect() { 

	mysql_close(); 
	//if(isset($connection)){
	//mysql_close($connection);
	//}
	
}

function unesc($x) {
    if (get_magic_quotes_gpc())
        return stripslashes($x);
    return $x;
}

function searchfield($s) {
    return preg_replace(array('/[^a-z0-9]/si', '/^\s*/s', '/\s*$/s', '/\s+/s'), array(" ", "", "", " "), $s);
}

function pager($rpp, $count, $href, $opts = array()) {
    
    if($rpp > $count)
          return array('pagertop' => '&nbsp;', 'pagerbottom' => '&nbsp;', 'limit' => '');

    $pages = ceil($count / $rpp);

    if (!isset($opts["lastpagedefault"]))
        $pagedefault = 0;
    else {
        $pagedefault = floor(($count - 1) / $rpp);
        if ($pagedefault < 0)
            $pagedefault = 0;
    }

    if (isset($_GET["page"])) {
        $page = 0 + $_GET["page"];
        if ($page < 0)
            $page = $pagedefault;
    }
    else
        $page = $pagedefault;

    $pager = "";

    $mp = $pages - 1;
    $as = "<b>&lt;&lt;&nbsp;Prev</b>";
    if ($page >= 1) {
        $pager .= "<a href=\"{$href}page=" . ($page - 1) . "\">";
        $pager .= $as;
        $pager .= "</a>";
    }
    else
        $pager .= $as;
    $pager .= "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
    $as = "<b>Next&nbsp;&gt;&gt;</b>";
    if ($page < $mp && $mp >= 0) {
        $pager .= "<a href=\"{$href}page=" . ($page + 1) . "\">";
        $pager .= $as;
        $pager .= "</a>";
    }
    else
        $pager .= $as;

    if ($count) {
        $pagerarr = array();
        $dotted = 0;
        $dotspace = 3;
        $dotend = $pages - $dotspace;
        $curdotend = $page - $dotspace;
        $curdotstart = $page + $dotspace;
        for ($i = 0; $i < $pages; $i++) {
            if (($i >= $dotspace && $i <= $curdotend) || ($i >= $curdotstart && $i < $dotend)) {
                if (!$dotted)
                    $pagerarr[] = "...";
                $dotted = 1;
                continue;
            }
            $dotted = 0;
            $start = $i * $rpp + 1;
            $end = $start + $rpp - 1;
            if ($end > $count)
                $end = $count;
            $text = "$start&nbsp;-&nbsp;$end";
            if ($i != $page)
                $pagerarr[] = "<a href=\"{$href}page=$i\"><b>$text</b></a>";
            else
                $pagerarr[] = "<b>$text</b>";
        }
        $pagerstr = join(" | ", $pagerarr);
        $pagertop = "<p align=\"center\">$pager<br />$pagerstr</p>\n";
        $pagerbottom = "<p align=\"center\">$pagerstr<br />$pager</p>\n";
    }
    else {
        $pagertop = "<p align=\"center\">$pager</p>\n";
        $pagerbottom = $pagertop;
    }

    $start = $page * $rpp;

    return array('pagertop' => $pagertop, 'pagerbottom' => $pagerbottom, 'limit' => "LIMIT $start,$rpp");
}

function stdmsg($heading, $text)
{
  print("<table class=main width=750 border=0 cellpadding=0 cellspacing=0><tr><td class=embedded>\n");
  if ($heading)
    print("<h2>$heading</h2>\n");
  print("<table width=100% border=1 cellspacing=0 cellpadding=10><tr><td class=text>\n");
  print($text . "</td></tr></table></td></tr></table>\n");
}

function stderr($heading, $text)
{
  stdhead();
  stdmsg($heading, $text);
  stdfoot();
  die;
}

function stdhead($title = "", $msgalert = true) {
    global $CURUSER, $TBDEV;

  if (!$TBDEV['site_online'])
    die("Site is down for maintenance, please check back again later... thanks<br>");

    //header("Content-Type: text/html; charset=iso-8859-1");
    //header("Pragma: No-cache");
    if ($title == "")
        $title = $TBDEV['site_name'] .(isset($_GET['tbv'])?" (".TBVERSION.")":'');
    else
        $title = $TBDEV['site_name'].(isset($_GET['tbv'])?" (".TBVERSION.")":''). " :: " . htmlspecialchars($title);
		
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<link rel="stylesheet" type="text/css" href="../styles5.css">
<title>xxx PRE Database</title>
</head>
<body>
<?

}

function tracetable($restracetable) {
		?>
	<table width=75% border="1" align="center" cellspacing="0" cellpadding="5">
<tr>
<td class="colhead" align="center">Type</td>
<td class="colhead" align="center">Release</td>
<td class="colhead" align="center">Added On</td>
<td class="colhead" align="center">Genre</td>
	
	<?
	print("</tr>\n");
	while ($row = mysql_fetch_assoc($restracetable)) {
	print("<tr>\n");
			
			//$nukereason = "" . $row['nukereason'] . " (" . $row['nukenet'] . ")";
			//$nukedimage = ($row['nukestatus']=="nuked" ? "&nbsp;<img src='../nuked.png' title='$nukereason' alt='$nukereason' />" : "");
			//$sticky = ($row['nukestatus']=="nuked" ? "class=\"wtf\"" : "");
			//$sticky2 = ($row[sticky]=="yes" ? "&nbsp;<font color=#f47d13 size=0>[Sticky]</font>" : "");
			$sticky = "";
			
			$isinnfo = sql_query("SELECT id FROM nfodb WHERE rlsname = '$row[rlsname]'") or die(mysql_error());
			$isnfo = mysql_num_rows($isinnfo);
			
			$nfoindb = "";
			if ($isnfo == "1") {
			$nfoindb = "[NFO] ";
			}
			
			$isinsfv = sql_query("SELECT id FROM sfvdb WHERE rlsname = '$row[rlsname]'") or die(mysql_error());
			$issfv = mysql_num_rows($isinsfv);
			
			$sfvindb = "";
			if ($issfv == "1") {
			$sfvindb = "[SFV] ";
			}
			
			$isinm3u = sql_query("SELECT id FROM m3udb WHERE rlsname = '$row[rlsname]'") or die(mysql_error());
			$ism3u = mysql_num_rows($isinm3u);
			
			$m3uindb = "";
			if ($ism3u == "1") {
			$m3uindb = "[M3U]";
			}
			
			$id = $row['id'];
			
			print("<td align=\"center\" $sticky>" . $row["site"] . "</td>\n");
			
			$pred = gettime($row["unixtime"]);
			
			print("<td align=\"left\" $sticky><b><a href=\"details.php?id=$id\">" . $row['rlsname'] . "</a></b><br>");
			print("Pre'd $pred <b>(</b> " . $row['addedon'] . " <b>)</b>");
			//print("$info$brfix$genre");
			//print("$nfoindb$sfvindb$m3uindb");
			print("</td>\n");
			print("<td align=\"center\" $sticky>$nfoindb$sfvindb$m3uindb</td>\n");
			print("<td align=\"center\" $sticky>" . $row["site"] . "</td>\n");
			print("</tr>\n");
	
	}
	print("</table>\n");
}

function pretable($respretable) {
		?>
	<table width=75% border="1" align="center" cellspacing="0" cellpadding="5">
<tr>
<td class="colhead" align="center">Type</td>
<td class="colhead" align="center">Release</td>
<td class="colhead" align="center">Added On</td>
<td class="colhead" align="center">Genre</td>
	
	<?
	print("</tr>\n");
	while ($row = mysql_fetch_assoc($respretable)) {
	print("<tr>\n");
			
			$nukereason = "" . $row['nukereason'] . " (" . $row['nukenet'] . ")";
			$nukedimage = ($row['nukestatus']=="nuked" ? "&nbsp;<img src='../nuked.png' title='$nukereason' alt='$nukereason' />" : "");
			$sticky = ($row['nukestatus']=="nuked" ? "class=\"wtf\"" : "");
			//$sticky2 = ($row[sticky]=="yes" ? "&nbsp;<font color=#f47d13 size=0>[Sticky]</font>" : "");
			
			$isinnfo = sql_query("SELECT id FROM nfodb WHERE rlsname = '$row[rlsname]'") or die(mysql_error());
			$isnfo = mysql_num_rows($isinnfo);
			
			$nfoindb = "";
			if ($isnfo == "1") {
			$nfoindb = "[NFO] ";
			}
			
			$isinsfv = sql_query("SELECT id FROM sfvdb WHERE rlsname = '$row[rlsname]'") or die(mysql_error());
			$issfv = mysql_num_rows($isinsfv);
			
			$sfvindb = "";
			if ($issfv == "1") {
			$sfvindb = "[SFV] ";
			}
			
			$isinm3u = sql_query("SELECT id FROM m3udb WHERE rlsname = '$row[rlsname]'") or die(mysql_error());
			$ism3u = mysql_num_rows($isinm3u);
			
			$m3uindb = "";
			if ($ism3u == "1") {
			$m3uindb = "[M3U]";
			}
			
			$id = $row['id'];
			$info = "";
			if ($row['size'] != "0" && $row['files'] != "0") { 
			$info = "<br><b>".$row['size'] . "</b> MB | <b>" . $row['files'] . "</b> FiLES ";
			}
			
			$brfix = "";
			if ($info == "") { $brfix = "<br>"; }
			
			$genre = "";
			if ($row['genre'] != "") { 
			$genre = "<b>[Genre: " . $row['genre'] . "]</b> ";
			}
			
			print("<td align=\"center\" $sticky>" . $row["section"] . "</td>\n");
			
			$pred = gettime($row["rlstime"]);
			
			print("<td align=\"left\" $sticky><b><a href=\"details.php?id=$id\">" . $row['rlsname'] . "</a></b> $nukedimage<br>");
			print("Pre'd $pred <b>(</b> " . $row['pretime'] . " <b>)</b>");
			print("$info$brfix$genre");
			//print("$nfoindb$sfvindb$m3uindb");
			print("</td>\n");
			print("<td align=\"center\" $sticky>$nfoindb$sfvindb$m3uindb</td>\n");
			print("<td align=\"center\" $sticky>" . $row["genre"] . "</td>\n");
			print("</tr>\n");
	
	}
	print("</table>\n");
}

function stdfoot() {
  global $query_stat;
  
  print "<p align='center'>
<a href='http://example.com'><img src='nuked.png' border='0' alt='Powered By xxx &copy; 2009' title='Powered By xxx &copy; 2009' /></a></p>";

  print "</body></html>\n";
  
  		$totalqueries = 0;
		if ((DEBUG_MODE && $query_stat) || isset($_GET["yuna"])) 
		{
			foreach ($query_stat as $key => $value) 
			{
				$totaltime += $value["ms"];
				$totalqueries++; 
				$detailedqueriesdata .= "[".($key+1)."] => <b>".($value["ms"] > 10 ? "<font color=\"red\" title=\"I suggest you should optimize this query.\">".$value["ms"]."</font>" : "<font color=\"green\" title=\"This query doesn't need's optimization.\">".$value["ms"]."</font>" )."</b> [$value[query]]<br />\n";
			}
		}
		
		print("<table width=700 align=center><tr><td align=center>");
		print("<font color=white>Tracker has used $totalqueries queries with $totaltime ms..</font>");
		print("</td></tr></table>");
		print("<table width=1200 align=center><tr><td align=left>".$detailedqueriesdata."</td></tr></table>");
  
}

function is_valid_id($id)
{
  return is_numeric($id) && ($id > 0) && (floor($id) == $id);
}

function gmtime()
{
    return strtotime(get_date_time());
}

function get_date_time($timestamp = 0)
{
  if ($timestamp)
    return date("Y-m-d H:i:s", $timestamp);
  else
    return gmdate("Y-m-d H:i:s");
}

function sqlesc($x) {
    
   if (get_magic_quotes_gpc()) {
       $x = stripslashes($x);
   }

   if (is_numeric($x)) return "'".$x."'";

   return "" . mysql_real_escape_string(unsafeChar($x)) . "";
}

function sqlwildcardesc($x) {
    return str_replace(array("%","_"), array("\\%","\\_"), mysql_real_escape_string($x));
}

function safe($var)
{
    return str_replace(array('&', '>', '<', '"', '\''), array('&amp;', '&gt;', '&lt;', '&quot;', '&#039;'), str_replace(array('&gt;', '&lt;', '&quot;', '&#039;', '&amp;'), array('>', '<', '"', '\'', '&'), $var));
}

function unsafeChar($var)
{
    return str_replace(array("&gt;", "&lt;", "&quot;", "&amp;"), array(">", "<", "\"", "&"), $var);
}

function safechar($var)
{
    return htmlspecialchars(unsafeChar($var));
}

function gettime($st)
{
	$curtime = TIME_NOW;
	$st = $curtime - $st;
	
	$secs = $st;
	$mins = floor($st / 60);
	$hours = floor($mins / 60);
	$days = floor($hours / 24);
	$week = floor($days / 7);
	$month = floor($week / 4);
	
	$week_elapsed = floor(($st - ($month * 4 * 7 * 24 * 60 * 60)) / (7 * 24 * 60 * 60));
	$days_elapsed = floor(($st - ($week * 7 * 24 * 60 * 60)) / (24 * 60 * 60));
	$hours_elapsed = floor(($st - ($days * 24 * 60 * 60)) / (60 * 60));
	$mins_elapsed = floor(($st - ($hours * 60 * 60)) / 60);
	$secs_elapsed = floor($st - $mins * 60);
	
	$pretime = "";
	
	if($secs_elapsed > 0)
	  $pretime = "$secs_elapsed secs ago " .$pretime;
	if($mins_elapsed > 0)
	  $pretime = "$mins_elapsed mins, " .$pretime;
	if($hours_elapsed > 0)
	  $pretime = "$hours_elapsed hours, " .$pretime;
	if($days_elapsed > 0)
	  $pretime = "$days_elapsed days, " .$pretime;
	if($week_elapsed > 0)
	  $pretime = "$week_elapsed weeks, " .$pretime;
	if($month > 0)
	  $pretime = "$month months, " .$pretime;
	
	return "$pretime";
}

// Patched function to detect REAL IP address if it's valid
function getip() {
   if (isset($_SERVER)) {
     if (isset($_SERVER['HTTP_X_FORWARDED_FOR']) && validip($_SERVER['HTTP_X_FORWARDED_FOR'])) {
       $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
     } elseif (isset($_SERVER['HTTP_CLIENT_IP']) && validip($_SERVER['HTTP_CLIENT_IP'])) {
       $ip = $_SERVER['HTTP_CLIENT_IP'];
     } else {
       $ip = $_SERVER['REMOTE_ADDR'];
     }
   } else {
     if (getenv('HTTP_X_FORWARDED_FOR') && validip(getenv('HTTP_X_FORWARDED_FOR'))) {
       $ip = getenv('HTTP_X_FORWARDED_FOR');
     } elseif (getenv('HTTP_CLIENT_IP') && validip(getenv('HTTP_CLIENT_IP'))) {
       $ip = getenv('HTTP_CLIENT_IP');
     } else {
       $ip = getenv('REMOTE_ADDR');
     }
   }

   return $ip;
}

function mksize($bytes)
{
	if ($bytes < 1000 * 1024)
		return number_format($bytes / 1024, 2) . " kB";
	elseif ($bytes < 1000 * 1048576)
		return number_format($bytes / 1048576, 2) . " MB";
	elseif ($bytes < 1000 * 1073741824)
		return number_format($bytes / 1073741824, 2) . " GB";
	else
		return number_format($bytes / 1099511627776, 2) . " TB";
}

function code($ibm_437, $swedishmagic = false) {
$table437 = array("\200", "\201", "\202", "\203", "\204", "\205", "\206", "\207",
"\210", "\211", "\212", "\213", "\214", "\215", "\216", "\217", "\220",
"\221", "\222", "\223", "\224", "\225", "\226", "\227", "\230", "\231",
"\232", "\233", "\234", "\235", "\236", "\237", "\240", "\241", "\242",
"\243", "\244", "\245", "\246", "\247", "\250", "\251", "\252", "\253",
"\254", "\255", "\256", "\257", "\260", "\261", "\262", "\263", "\264",
"\265", "\266", "\267", "\270", "\271", "\272", "\273", "\274", "\275",
"\276", "\277", "\300", "\301", "\302", "\303", "\304", "\305", "\306",
"\307", "\310", "\311", "\312", "\313", "\314", "\315", "\316", "\317",
"\320", "\321", "\322", "\323", "\324", "\325", "\326", "\327", "\330",
"\331", "\332", "\333", "\334", "\335", "\336", "\337", "\340", "\341",
"\342", "\343", "\344", "\345", "\346", "\347", "\350", "\351", "\352",
"\353", "\354", "\355", "\356", "\357", "\360", "\361", "\362", "\363",
"\364", "\365", "\366", "\367", "\370", "\371", "\372", "\373", "\374",
"\375", "\376", "\377");

$tablehtml = array("&#x00c7;", "&#x00fc;", "&#x00e9;", "&#x00e2;", "&#x00e4;",
"&#x00e0;", "&#x00e5;", "&#x00e7;", "&#x00ea;", "&#x00eb;", "&#x00e8;",
"&#x00ef;", "&#x00ee;", "&#x00ec;", "&#x00c4;", "&#x00c5;", "&#x00c9;",
"&#x00e6;", "&#x00c6;", "&#x00f4;", "&#x00f6;", "&#x00f2;", "&#x00fb;",
"&#x00f9;", "&#x00ff;", "&#x00d6;", "&#x00dc;", "&#x00a2;", "&#x00a3;",
"&#x00a5;", "&#x20a7;", "&#x0192;", "&#x00e1;", "&#x00ed;", "&#x00f3;",
"&#x00fa;", "&#x00f1;", "&#x00d1;", "&#x00aa;", "&#x00ba;", "&#x00bf;",
"&#x2310;", "&#x00ac;", "&#x00bd;", "&#x00bc;", "&#x00a1;", "&#x00ab;",
"&#x00bb;", "&#x2591;", "&#x2592;", "&#x2593;", "&#x2502;", "&#x2524;",
"&#x2561;", "&#x2562;", "&#x2556;", "&#x2555;", "&#x2563;", "&#x2551;",
"&#x2557;", "&#x255d;", "&#x255c;", "&#x255b;", "&#x2510;", "&#x2514;",
"&#x2534;", "&#x252c;", "&#x251c;", "&#x2500;", "&#x253c;", "&#x255e;",
"&#x255f;", "&#x255a;", "&#x2554;", "&#x2569;", "&#x2566;", "&#x2560;",
"&#x2550;", "&#x256c;", "&#x2567;", "&#x2568;", "&#x2564;", "&#x2565;",
"&#x2559;", "&#x2558;", "&#x2552;", "&#x2553;", "&#x256b;", "&#x256a;",
"&#x2518;", "&#x250c;", "&#x2588;", "&#x2584;", "&#x258c;", "&#x2590;",
"&#x2580;", "&#x03b1;", "&#x00df;", "&#x0393;", "&#x03c0;", "&#x03a3;",
"&#x03c3;", "&#x03bc;", "&#x03c4;", "&#x03a6;", "&#x0398;", "&#x03a9;",
"&#x03b4;", "&#x221e;", "&#x03c6;", "&#x03b5;", "&#x2229;", "&#x2261;",
"&#x00b1;", "&#x2265;", "&#x2264;", "&#x2320;", "&#x2321;", "&#x00f7;",
"&#x2248;", "&#x00b0;", "&#x2219;", "&#x00b7;", "&#x221a;", "&#x207f;",
"&#x00b2;", "&#x25a0;", "&#x00a0;");
$s = htmlspecialchars($ibm_437);


// 0-9, 11-12, 14-31, 127 (decimalt)
$control =
array("\000", "\001", "\002", "\003", "\004", "\005", "\006", "\007",
"\010", "\011", /*"\012",*/ "\013", "\014", /*"\015",*/ "\016", "\017",
"\020", "\021", "\022", "\023", "\024", "\025", "\026", "\027",
"\030", "\031", "\032", "\033", "\034", "\035", "\036", "\037",
"\177");

/* Code control characters to control pictures.
http://www.unicode.org/charts/PDF/U2400.pdf
(This is somewhat the Right Thing, but looks crappy with Courier New.)
$controlpict = array("&#x2423;","&#x2404;");
$s = str_replace($control,$controlpict,$s); */

// replace control chars with space - feel free to fix the regexp :)
/*echo "[a\\x00-\\x1F]";
//$s = ereg_replace("[ \\x00-\\x1F]", " ", $s);
$s = ereg_replace("[ \000-\037]", " ", $s); */
$s = str_replace($control," ",$s);




if ($swedishmagic){
$s = str_replace("\345","\206",$s); // Code windows "å" to dos.
$s = str_replace("\344","\204",$s); // Code windows "ä" to dos.
$s = str_replace("\366","\224",$s); // Code windows "ö" to dos.
// $s = str_replace("\304","\216",$s); // Code windows "Ä" to dos.
//$s = "[ -~]\\xC4[a-za-z]";

// couldn't get ^ and $ to work, even through I read the man-pages,
// i'm probably too tired and too unfamiliar with posix regexps right now.
$s = ereg_replace("([ -~])\305([ -~])", "\\1\217\\2", $s); // Å
$s = ereg_replace("([ -~])\304([ -~])", "\\1\216\\2", $s); // Ä
$s = ereg_replace("([ -~])\326([ -~])", "\\1\231\\2", $s); // Ö

$s = str_replace("\311", "\220", $s); // É
$s = str_replace("\351", "\202", $s); // é
}

$s = str_replace($table437, $tablehtml, $s);
return $s;
}

function format_urls($s)
{
	return preg_replace(
    	"/(\A|[^=\]'\"a-zA-Z0-9])((http|ftp|https|ftps|irc):\/\/[^()<>\s]+)/i",
	    "\\1<a href=\"\\2\">\\2</a>", $s);
}

function sql_query($query) {
	global $queries, $query_stat;
	$queries++;
	$mtime = microtime(); // Get Current Time
	$mtime = explode (" ", $mtime); // Split Miliseconds and Microseconds
	$mtime = $mtime[1] + $mtime[0];  // Create a single value for start time
	$query_start_time = $mtime; // Start time
	$result = mysql_query($query);
	$mtime = microtime();
	$mtime = explode (" ", $mtime);
	$mtime = $mtime[1] + $mtime[0];
	$query_end_time = $mtime; // End time
	$query_time = ($query_end_time - $query_start_time);
	$query_time = substr($query_time, 0, 8);
	$query_stat[] = array("ms" => $query_time, "query" => $query);
	return $result;
}

?>