<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'func.php');
//require_once "func.php";

if (!isset($_GET['l'])) {
	die();
}

$getw = (isset($_GET['l'])?safe($_GET['l']):'');

if (isset($_GET['l']) && $getw == "") {
	die();
}

$val = $mc->get($getw);

$id = $val['ID'] ;
$type = $val['TYPE'];

if (!is_valid_id($id))
die();

if ($type == "")
die();

dbconn();

$whichdb = array('ADDNFO' => 'nfosdb','OLDNFO' => 'nfosdb','ADDSFV' => 'sfvsdb','OLDSFV' => 'sfvsdb','ADDM3U' => 'm3usdb','OLDM3U' => 'm3usdb','ADDDIZ' => 'dizdb','OLDDIZ' => 'dizdb','ADDJPG' => 'jpgdb','OLDJPG' => 'jpgdb');

$req = mysql_query("SELECT data, filename, size FROM " . $whichdb[$type] . " WHERE id = " . $id . "") or die( mysql_error());  
$res = mysql_fetch_assoc($req);

if($res['data'] != ""){
	
	$wtfile = array('ADDNFO' => 'nfo','OLDNFO' => 'nfo','ADDSFV' => 'sfv','OLDSFV' => 'sfv','ADDM3U' => 'm3u','OLDM3U' => 'm3u','ADDDIZ' => 'diz','OLDDIZ' => 'diz','ADDJPG' => 'jpg','OLDJPG' => 'jpg');
	
	$finaldata = gzuncompress($res['data']);
	
    header('Content-Disposition: attachment; filename='.$res['filename'].'');
	header('Content-Type: application/'.$wtfile[$type]);
	header('Content-Length: '.$res['size']); 
	
	print($finaldata);
	
} else {

    die();
	
}

?>