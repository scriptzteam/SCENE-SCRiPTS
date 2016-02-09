<?php

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

//gets the data from a URL
function get_url_data($url)
{
	$ch = curl_init();
	$timeout = 3;
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
	curl_setopt($ch, CURLOPT_BINARYTRANSFER, 1);
	curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
	curl_setopt($ch, CURLOPT_TIMEOUT, $timeout);
	
	$res['data'] = curl_exec($ch);
	$res['size'] = curl_getinfo($ch, CURLINFO_CONTENT_LENGTH_DOWNLOAD);
	$res['error'] = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	
	curl_close($ch);
	
	return $res;
}

function addspam($type, $rlsname, $url, $filename, $fromnet, $ann = true) {
	global $mc;
	
	$whichdb = array('ADDNFO' => 'nfosdb','OLDNFO' => 'nfosdb','ADDSFV' => 'sfvsdb','OLDSFV' => 'sfvsdb','ADDM3U' => 'm3usdb','OLDM3U' => 'm3usdb');
	
	$w = mysql_query("SELECT COUNT(id) AS tid FROM " . $whichdb[$type] . " WHERE rlsname = " . sqlesc($rlsname) . "") or exit("Err1 ".mysql_error());
	$qw = mysql_fetch_assoc($w);
	
	if ($qw['tid'] == 0) {
		
		$a = get_url_data(trim($url));
		
		$size = ($a['size'] == 0 ? strlen($a['data']) : $a['size']);
		
		if ($size == 0 || $size < 25 || $a['error'] == 404 || $a['data'] == "") {
		
			return 'URL FAIL';
			
		} else {
			
			$crc = strtoupper(dechex(crc32($a['data'])));
			$newdata = gzcompress($a['data'], 9);
			$grp = explode ( "-", $rlsname );
			$grp = $grp [count ( $grp ) - 1];
			$fromdata = explode(":", trim($fromnet));
			$fromdata[1] = "#".$fromdata[1];
			
			mysql_query("INSERT INTO " . $whichdb[$type] . " ( `rlsname` , `grp` , `time` , `data` , `filename` , `size` ) VALUES (".sqlesc($rlsname).",".sqlesc($grp).",".time().",".sqlesc($newdata).",".sqlesc($filename).",".sqlesc($size).")") or exit('Err2 '.mysql_error());
			
			$id = mysql_insert_id();
			
			mysql_query("INSERT INTO fromspamdata ( `spamid` , `type` , `time` , `nick` , `chan` , `network` ) VALUES (".$id.",".sqlesc($type).",".time().",".sqlesc($fromdata[0]).",".sqlesc($fromdata[1]).",".sqlesc($fromdata[2]).")") or exit('Err3 '.mysql_error());
			
			if ($ann == true) {
			
				$mcdata = array('ID' => $id, 'TYPE' => $type);
				
				$hash1 = md5($id . $type . $rlsname . $url);
				$hash2 = md5(md5($filename.time()).time().$rlsname);
				$key = md5(md5($hash1.$hash2).md5($hash2.$hash1));
				
				$mc->set($key, $mcdata, false, 300) or die ("Failed to save data at memcache server");
				
				return $key." ".$crc." ".$size;
			
			} else {
			
				return;
			
			}
			
		}
		
	}

}

if (isset($_GET['data']) && $_GET['data'] != "") {
	
	$v = explode(",", trim($_GET['data']));
	
	$actiontypes = array('ADDPRE','INFO','GENRE','ADDNFO','ADDSFV','ADDM3U','ADDJPG','ADDCOVER','ADDPOSTER','ADDBACKDROP','ADDURL','ADDIMDB','ADDTVRAGE','ADDVIDEOINFO','ADDMP3INFO','ADDOLD','OLDNUKE','OLDUNNUKE','OLDDELPRE','OLDUNDELPRE','OLDNFO','OLDSFV','OLDM3U','OLDJPG','OLDCOVER','OLDPOSTER','OLDBACKDROP','OLDURL','OLDIMDB','OLDTVRAGE','OLDVIDEOINFO','OLDMP3INFO');
	
	if (!in_array($v[0], $actiontypes))
	die("Invalid Action Logged!");
	
	$action = $v[0];
	
	switch ($action)
	{
		case 'ADDNFO':
		$status = addspam($action,$v[1],$v[2],$v[3],$v[4]);
		echo $status;
		die;
		break;

		case 'ADDSFV':
		$status = addspam($action,$v[1],$v[2],$v[3],$v[4]);
		echo $status;
		die;
		break;
		
		case 'ADDM3U':
		$status = addspam($action,$v[1],$v[2],$v[3],$v[4]);
		echo $status;
		die;
		break;
		
		case 'OLDNFO':
		addspam($action,$v[1],$v[2],$v[3],$v[4],false);
		die;
		break;
		
		case 'OLDSFV':
		addspam($action,$v[1],$v[2],$v[3],$v[4],false);
		die;
		break;
		
		case 'OLDM3U':
		addspam($action,$v[1],$v[2],$v[3],$v[4],false);
		die;
		break;
		
		default:
		die("Invalid Action Logged!");
		break;
		
	}
	
	
} else {

    die('your actions have been logged!');
	
}

?>