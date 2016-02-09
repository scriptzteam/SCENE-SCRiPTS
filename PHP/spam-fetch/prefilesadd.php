<?php

@ini_set("upload_max_filesize",1000000);

mysql_connect('127.0.0.1', 'scenedbaxx', 'Q3wX8GdPV7eKNQpw');
mysql_select_db('scenestuff');

$mc = new Memcache;
$mc->connect('localhost', 19420) or die ("Could not connect");

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

function crc32_file($fileName)
{
    $crc = hash_file("crc32b", $fileName);
    $crc = sprintf("%08X", 0x100000000 + hexdec($crc));
    return substr($crc, 6, 2) . substr($crc, 4, 2) . substr($crc, 2, 2) . substr($crc, 0, 2);
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

function addspam($type, $rlsname, $data, $filename, $fromnet, $crc, $ann = true) {
	global $mc;
	
	$whichdb = array('ADDNFO' => 'nfosdb','OLDNFO' => 'nfosdb','ADDSFV' => 'sfvsdb','OLDSFV' => 'sfvsdb','ADDM3U' => 'm3usdb','OLDM3U' => 'm3usdb','ADDDIZ' => 'dizdb','OLDDIZ' => 'dizdb');
	
	$w = mysql_query("SELECT COUNT(id) AS tid, id, size FROM " . $whichdb[$type] . " WHERE rlsname = " . sqlesc($rlsname) . "") or exit("Err1 ".mysql_error());
	$qw = mysql_fetch_assoc($w);
	
	if ($qw['tid'] == 0) {
			
			$newdata = gzcompress($data, 9);
			$grp = explode ( "-", $rlsname );
			$grp = $grp [count ( $grp ) - 1];
			$fromdata = explode(":", trim($fromnet));
			$fromdata[1] = "#".$fromdata[1];
			$size = strlen($data);
			
			mysql_query("INSERT INTO " . $whichdb[$type] . " ( `rlsname` , `grp` , `time` , `data` , `filename` , `size` ) VALUES (".sqlesc($rlsname).",".sqlesc($grp).",".time().",".sqlesc($newdata).",".sqlesc($filename).",".sqlesc($size).")") or exit('Err2 '.mysql_error());
			
			$id = mysql_insert_id();
			
			mysql_query("INSERT INTO fromspamdata ( `spamid` , `type` , `time` , `nick` , `chan` , `network` ) VALUES (".$id.",".sqlesc($type).",".time().",".sqlesc($fromdata[0]).",".sqlesc($fromdata[1]).",".sqlesc($fromdata[2]).")") or exit('Err3 '.mysql_error());
			
			if ($ann == true) {
			
				$mcdata = array('ID' => $id, 'TYPE' => $type);
				
				$hash1 = md5($id . $type . $rlsname);
				$hash2 = md5(md5($filename.time()).time().$rlsname);
				$key = md5(md5($hash1.$hash2).md5($hash2.$hash1));
				
				$mc->set($key, $mcdata, false, 300) or die ("Failed to save data at memcache server");
				
				$sbotdata = array($type, $rlsname, $key, $filename, $crc, $size);
				
				sendbot(join(" ",$sbotdata));
				
				return "OK";
			
			} else {
			
				return "FAiL";
			
			}
		
	}/* else {
		
		$id = $qw['id'];
		$mcdata = array('ID' => $id, 'TYPE' => $type);
		
		$hash1 = md5($id . $type . $rlsname);
		$hash2 = md5(md5($filename.time()).time().$rlsname);
		$key = md5(md5($hash1.$hash2).md5($hash2.$hash1));
		
		$mc->set($key, $mcdata, false, 300) or die ("Failed to save data at memcache server");
		
		$sbotdata = array($type, $rlsname, $key, $filename, $crc, $qw['size']);
		
		sendbot(join(" ",$sbotdata));
		
		return "OK";
		
	}*/

}

foreach(explode(':','rlsname:type:filename:fromnet') as $v) {
    if (!isset($_POST[$v]))
        die('Missing Data');
}

if (!isset($_FILES['data']))
	die('Missing file');
	
    $dataf = '';
    /////////////////////// FILE ////////////////////////	
    if(isset($_FILES['data']) && !empty($_FILES['data']['name'])) {
	
		$filedata = $_FILES['data'];
		
		if ($filedata['name'] == '')
		  die('Missing Name');

		if ($filedata['size'] == 0)
		  die('no data size');

		if ($filedata['size'] > 65535)
		  die('Missing size too big');

		$fname = $filedata['tmp_name'];

		if (@!is_uploaded_file($fname))
		  die('upload failed');
		
		$handle = fopen($fname, "rb");
		$dataf = fread($handle, filesize($fname));
		fclose($handle);
		
		//$dataf = @file_get_contents($fname);
		
		$crc = strtoupper(dechex(crc32($dataf)));
    }
    /////////////////////// FILE END /////////////////////
	
	$rlsname = (isset($_POST['rlsname']) && $_POST['rlsname'] != '') ? trim($_POST['rlsname']) : die('empty rlsname');
	$action = (isset($_POST['type']) && $_POST['type'] != '') ? trim($_POST['type']) : die('empty type');
	$filename = (isset($_POST['filename']) && $_POST['filename'] != '') ? trim($_POST['filename']) : die('empty filename');
	$fromnet = (isset($_POST['fromnet']) && $_POST['fromnet'] != '') ? trim($_POST['fromnet']) : die('empty fromnet');
	
	$actiontypes = array('ADDPRE','INFO','GENRE','ADDNFO','ADDSFV','ADDM3U','ADDJPG','ADDDIZ','ADDCOVER','ADDPOSTER','ADDBACKDROP','ADDURL','ADDIMDB','ADDTVRAGE','ADDVIDEOINFO','ADDMP3INFO','ADDOLD','OLDNUKE','OLDUNNUKE','OLDDELPRE','OLDUNDELPRE','OLDNFO','OLDSFV','OLDM3U','OLDJPG','OLDCOVER','OLDPOSTER','OLDBACKDROP','OLDURL','OLDIMDB','OLDTVRAGE','OLDVIDEOINFO','OLDMP3INFO','OLDDIZ');
	
	if (!in_array($action, $actiontypes))
	die("Invalid Action Logged!");
	
	switch ($action)
	{
		case 'ADDNFO':
		$status = addspam($action,$rlsname,$dataf,$filename,$fromnet,$crc,true);
		echo $status;
		die;
		break;

		case 'ADDSFV':
		$status = addspam($action,$rlsname,$dataf,$filename,$fromnet,$crc,true);
		echo $status;
		die;
		break;
		
		case 'ADDM3U':
		$status = addspam($action,$rlsname,$dataf,$filename,$fromnet,$crc,true);
		echo $status;
		die;
		break;
		
		case 'ADDDIZ':
		$status = addspam($action,$rlsname,$dataf,$filename,$fromnet,$crc,true);
		echo $status;
		die;
		break;
		
		default:
		die("Invalid Action Logged!");
		break;
		
	}

?>