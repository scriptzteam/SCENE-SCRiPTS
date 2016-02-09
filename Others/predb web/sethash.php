<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'includes'.DIRECTORY_SEPARATOR.'functions.php');

$ip = getip();

$allowip = array("127.0.0.1");

if (!in_array($ip, $allowip))
die('No Access');

$release = (isset($_GET['r'])) ? $_GET['r'] : "";

if ($release == '')
die('Release Name Cannot be empty');

$release = str_replace(" ", "%", $release);

$result = mysql_query("SELECT rlsname FROM `predb` WHERE `rlsname` LIKE ".sqlesc($release)." ORDER BY unixtime DESC LIMIT 1") or die(mysql_error());
$row = mysql_fetch_assoc($result);

if($row != '') {

	$rlsname = $row['rlsname'];

	$key = md5(md5($rlsname.time()).time().$rlsname);

	$mc->set($key, $rlsname, false, 300) or die ("Failed to save data at memcache server");

	echo $rlsname.' '.$key;

} else {

	die('No Release found.');

}

?>