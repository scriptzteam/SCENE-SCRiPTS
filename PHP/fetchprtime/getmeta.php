<?
require_once "/home/webbrowsestuff/www/include/functions.php";
// $pretags = get_meta_tags('http://example.com/getmeta.php?name='.trim($torrent));
// $pretime = 0 + $pretags['timeinfo'];

$ip = getip();

$allowip = array("127.0.0.1","1.2.3.4");

if (!in_array($ip, $allowip))
die();


connect();

$name = sqlesc($_GET['name']);
	
$query = "SELECT rlstime FROM `prerls` WHERE `rlsname` = '$name' LIMIT 1";
$result = mysql_query($query) or die(mysql_error());
	
$row = mysql_fetch_assoc($result);

	
$tinfo = abs($row['rlstime'] - time());

$htmlout = "<html>
<head>
<meta name='timeinfo' content='{$tinfo}'>
<title>xxx PR3 DB</title>
</head>
<body></body>
</html>";

print $htmlout;


disconnect();
	

?>