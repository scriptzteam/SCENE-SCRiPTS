<?
require_once "/home/webbrowsestuff/www/include/functions.php";
//$pretime = 0 + @file_get_contents("http://example.com/gettime.php?name=".trim($torrent));
//http://example.com/gettime.php?name=Panopticon-The_Return_EP-(AIR005)-2009-WEB

$ip = getip();

$allowip = array("127.0.0.1","1.2.3.4");

if (!in_array($ip, $allowip))
die();


connect();

$like = (isset($_GET['like'])) ? (int)$_GET['like'] : "0";
$n = isset($_GET['name']) ? $_GET['name'] : "";


$liked = (($like == "1") ? "LIKE" : "=");

$n = str_replace(" ", "%", $n);
$name = sqlesc($n);


$query = "SELECT `unixtime` FROM `prerlsdb` WHERE `rlsname` $liked '$name' ORDER BY `unixtime` DESC LIMIT 1";
$result = mysql_query($query) or die(mysql_error());
	
$row = mysql_fetch_assoc($result);


if( $row['unixtime'] != "" ) {
	
	$fintime = abs($row['unixtime'] - time());
	
	echo $fintime;
	
} elseif( $fintime == "" ) {

	$queryx = "SELECT `rlstime` FROM `prerls` WHERE `rlsname` $liked '$name' ORDER BY `rlstime` DESC LIMIT 1";
	$resultx = mysql_query($queryx) or die(mysql_error());
	
	$rowx = mysql_fetch_assoc($resultx);
	
	if( $rowx['rlstime'] != "" ) {
	
		$fintimex = abs($row['rlstime'] - time());
		
		echo $fintimex;
		
	}

}

disconnect();


?>