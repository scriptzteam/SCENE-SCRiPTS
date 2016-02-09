<?
require_once "/home/webbrowsestuff/www/include/functions.php";

$ip = getip();

$allowip = array("1.2.3.4");

if (!in_array($ip, $allowip))
die();

if ($_GET['name'] == "")
die();

connect();

$searchfin = sqlesc(trim($_GET['name']));
$name = str_replace(" ", "%", $searchfin);
	
$query = "SELECT * FROM `videoinfo` WHERE `rlsname` LIKE '%" . $name . "%' LIMIT 1";
$result = mysql_query($query) or die(mysql_error());
	
$row = mysql_fetch_assoc($result);


if( $row != "" ) {
	
	$join = ",";
	$fintime = $row['rlsname'].$join.$row['videocodec'].$join.$row['frames'].$join.$row['resolution'].$join.$row['resnframe'].$join.$row['audiocodec'].$join.$row['bitrate'].$join.$row['hertz'].$join.$row['channel'];
	
	echo $fintime;
	
} else {

	die();
	
}

disconnect();


?>