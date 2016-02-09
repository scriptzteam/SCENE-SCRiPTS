<?
require_once "/home/webbrowsestuff/www/include/functions.php";
//$pretime = 0 + @file_get_contents("http://example.com/gettime.php?name=".trim($torrent));
//http://example.com/gettime.php?name=Panopticon-The_Return_EP-(AIR005)-2009-WEB

$ip = getip();

if($ip == '127.0.0.1' || $ip == '1.2.3.4')
{
	
	connect();

	$name = mysql_real_escape_string($_GET['name']);
	$query = "SELECT rlstime FROM `prerls` WHERE `rlsname` = '$name' LIMIT 1";

	// Perform Query
	$result = mysql_query($query) or die(mysql_error());
	while ($row = mysql_fetch_assoc($result)) {
		echo abs($row['rlstime'] - time());
	}
	disconnect();
	
	
} else {

die();

}

?>