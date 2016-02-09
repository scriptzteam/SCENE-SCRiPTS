<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'includes'.DIRECTORY_SEPARATOR.'functions.php');

if (!isset($_GET['t'])) {
	die();
}

$type = (isset($_GET['t']) ? safe($_GET['t']) : '');

if (isset($_GET['t']) && $type == '') {
	die();
}

if ($type == '')
die('type empty');

$hash = (isset($_GET['h'])) ? $_GET['h'] : "";

if (strlen($hash) != '32')
die('Invalid hash');

$rlsname = $mc->get($hash);

if ($rlsname == '')
die('Link Expired');

$types = array(1, 2, 3);

if (!in_array($type, $types))
die('invalid type');

$whichdb = array(1 => 'nfodb', 2 => 'sfvdb', 3 => 'm3udb');
$typ = array(1 => 'nfo', 2 => 'sfv', 3 => 'm3u');

$t = $whichdb[$type];
$tt = $typ[$type];

$req = mysql_query("SELECT ".$tt."_data, ".$tt."_filename, ".$tt."_rlsname, ".$tt."_size FROM " .$t. " WHERE ".$tt."_rlsname = '" . $rlsname . "'") or die( mysql_error());  
$res = mysql_fetch_assoc($req);

if($res[$tt."_data"] != '') {
	
    header('Content-Disposition: attachment; filename='.$res[$tt.'_filename'].'');
	header('Content-Type: application/'.$tt);
	header('Content-Length: '.$res[$tt.'_size']); 
	
	echo $res[$tt.'_data'];
	exit();
	
} else {

    die('empty '.$type);
	
}

?>