<?php

@ini_set("upload_max_filesize",1000000);

mysql_connect('127.0.0.1', 'scenedbaxx', 'Q3wX8GdPV7eKNQpw');
mysql_select_db('scenestuff');

function sqlesc($x) {
    
   if (get_magic_quotes_gpc()) {
       $x = stripslashes($x);
   }

   if (is_numeric($x)) return "'".$x."'";

   return "'" . mysql_real_escape_string(unsafeChar($x)) . "'";
}

function unsafeChar($var)
{
    return str_replace(array("&gt;", "&lt;", "&quot;", "&amp;"), array(">", "<", "\"", "&"), $var);
}

// Returns the current time in GMT in MySQL compatible format.
function get_date_time($timestamp = 0)
{
  if ($timestamp)
    return date("Y-m-d H:i:s", $timestamp);
  else
    return gmdate("Y-m-d H:i:s");
}

function sendbot($msg) {

	if ($msg == "") {
		return;
	}

	$bot['ip'] = "localhost"; // the ip of the bot spamming the upload details
	$bot['port'] = "30035"; // your script listen port on the bot
	$bot['password'] = "xxx"; // password which you have set in the ftp script

	$fp = fsockopen($bot['ip'], $bot['port'], $errno, $errstr, 40);
	if($fp)
	{
		sleep(1);
		fputs($fp, $bot['password'] . " " . $msg . "\n");
		sleep(1);
		fclose($fp);
	}

}

function addmp3info($type, $rlsname, $genre, $year, $hertz, $tp, $bitrate, $bittype, $fromnet, $ann = true) {
	
	$w = mysql_query("SELECT COUNT(id) AS tid FROM mp3info WHERE rlsname = " . sqlesc($rlsname) . "") or die("Err1 ".mysql_error());
	$qw = mysql_fetch_assoc($w);
	
	if ($qw['tid'] == 0) {
			
			$fromdata = explode(":", trim($fromnet));
			$fromdata[1] = "#".$fromdata[1];
			
			mysql_query("INSERT INTO mp3info ( `rlsname` , `genre` , `year` , `hertz` , `type` , `bitrate` , `bittype` , `unixtime` , `addedon` , `fromnet` ) VALUES (".sqlesc($rlsname).",".sqlesc($genre).",".sqlesc($year).",".sqlesc($hertz).",".sqlesc($tp).",".sqlesc($bitrate).",".sqlesc($bittype).",".time().",".sqlesc(get_date_time()).",".sqlesc($fromnet).")") or die('Err2 '.mysql_error());
			
			$id = mysql_insert_id();
			
			mysql_query("INSERT INTO frominfodata ( `infoid` , `type` , `time` , `nick` , `chan` , `network` ) VALUES (".$id.",".sqlesc($type).",".time().",".sqlesc($fromdata[0]).",".sqlesc($fromdata[1]).",".sqlesc($fromdata[2]).")") or die('Err3 '.mysql_error());
			
			if ($ann == true) {
				
				$sbotdata = array($type, $rlsname, $genre, $year, $hertz, $tp, $bitrate, $bittype);
				
				sendbot(join(" ",$sbotdata));
				
				return "OK";
			
			} else {
			
				return "FAiL";
			
			}
		
	}

}

foreach(explode(':','rlsname:type:fromnet') as $v) {
    if (!isset($_POST[$v]))
        die('Missing Data');
}
	
	$rlsname = (isset($_POST['rlsname']) && $_POST['rlsname'] != '') ? trim($_POST['rlsname']) : die('empty rlsname');
	$action = (isset($_POST['type']) && $_POST['type'] != '') ? trim($_POST['type']) : die('empty type');
	$fromnet = (isset($_POST['fromnet']) && $_POST['fromnet'] != '') ? trim($_POST['fromnet']) : die('empty fromnet');
	
	$actiontypes = array('ADDMP3INFO','OLDMP3INFO');
	
	if (!in_array($action, $actiontypes))
	die("Invalid Action Logged!");
	
	$genre = (isset($_POST['genre']) && $_POST['genre'] != '') ? trim($_POST['genre']) : die('empty genre');
	$year = (isset($_POST['year']) && $_POST['year'] != '') ? trim($_POST['year']) : die('empty year');
	$hertz = (isset($_POST['hertz']) && $_POST['hertz'] != '') ? trim($_POST['hertz']) : die('empty hertz');
	$tp = (isset($_POST['tp']) && $_POST['tp'] != '') ? trim($_POST['tp']) : die('empty tp');
	$bitrate = (isset($_POST['bitrate']) && $_POST['bitrate'] != '') ? trim($_POST['bitrate']) : die('empty bitrate');
	$bittype = (isset($_POST['bittype']) && $_POST['bittype'] != '') ? trim($_POST['bittype']) : die('empty bittype');
	

	switch ($action)
	{
		case 'ADDMP3INFO':
		$status = addmp3info($action,$rlsname,$genre,$year,$hertz,$tp,$bitrate,$bittype,$fromnet,true);
		echo $status;
		die;
		break;
		
		default:
		die("Invalid Action Logged!");
		break;
		
	}

?>