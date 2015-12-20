<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'includes'.DIRECTORY_SEPARATOR.'functions.php');
loggedinorreturn();

if (!isset($_GET['type'])) {
	die();
}

$type = (isset($_GET['type'])?safe($_GET['type']):'');

if (isset($_GET['type']) && $type == "") {
	die();
}

if (!isset($_GET['id'])) {
	die();
}

$id = (isset($_GET['id'])?safe($_GET['id']):'');

if (isset($_GET['id']) && $id == "") {
	die();
}

if (!is_valid_id($id))
die('not valid id');

if ($type == '' || $id == '')
die('type or id empty');

$types = array('nfo','sfv','m3u');

if (!in_array($type, $types))
die('invalid type');

$whichdb = array('nfo' => 'nfo','sfv' => 'sfv','m3u' => 'm3u');

$t = $whichdb[$type];
$tt = 'rel_'.$t;

$req = mysql_query("SELECT UNCOMPRESS(`" .$tt. "`) AS " .$tt. ", rel_filename, rel_name FROM " .$t. " WHERE id = '" . $id . "'") or die( mysql_error());  
$res = mysql_fetch_assoc($req);

if($res[$tt] != "") {
	
    //header('Content-Disposition: attachment; filename='.$res['rel_filename'].'');
	//header('Content-Type: application/'.$t);
	//header('Content-Length: '.$res['size']); 
	
	echo stdhead();
	
	echo "<section><h2>{$type} for {$res['rel_name']}</h2><pre>{$res[$tt]}</pre></section>";
	
	echo stdfoot();
	
} else {

    die('empty '.$tt);
	
}

?>
