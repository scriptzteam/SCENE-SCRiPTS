<?php

mysql_connect('127.0.0.1', 'scenedbaxx', 'Q3wX8GdPV7eKNQpw');
mysql_select_db('scenestuff');

// Patched function to detect REAL IP address if it's valid
function getip() {
   if (isset($_SERVER)) {
     if (isset($_SERVER['HTTP_X_FORWARDED_FOR']) && validip($_SERVER['HTTP_X_FORWARDED_FOR'])) {
       $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
     } elseif (isset($_SERVER['HTTP_CLIENT_IP']) && validip($_SERVER['HTTP_CLIENT_IP'])) {
       $ip = $_SERVER['HTTP_CLIENT_IP'];
     } else {
       $ip = $_SERVER['REMOTE_ADDR'];
     }
   } else {
     if (getenv('HTTP_X_FORWARDED_FOR') && validip(getenv('HTTP_X_FORWARDED_FOR'))) {
       $ip = getenv('HTTP_X_FORWARDED_FOR');
     } elseif (getenv('HTTP_CLIENT_IP') && validip(getenv('HTTP_CLIENT_IP'))) {
       $ip = getenv('HTTP_CLIENT_IP');
     } else {
       $ip = getenv('REMOTE_ADDR');
     }
   }

   return $ip;
}

function sqlesc($x) {
    
   if (get_magic_quotes_gpc()) {
       $x = stripslashes($x);
   }

   if (is_numeric($x)) return "'".$x."'";

   return "" . mysql_real_escape_string(unsafeChar($x)) . "";
}

function unsafeChar($var)
{
    return str_replace(array("&gt;", "&lt;", "&quot;", "&amp;"), array(">", "<", "\"", "&"), $var);
}

$ip = getip();

$allowip = array("1.2.3.4");

if (!in_array($ip, $allowip))
die();

if ($_GET['name'] == "")
die();

$like = (isset($_GET['like'])) ? (int)$_GET['like'] : "0";
$n = isset($_GET['name']) ? $_GET['name'] : "";

echo $like.$n;
$liked = (($like == "1") ? "LIKE" : "=");

$n = str_replace(" ", "%", $n);
$name = sqlesc($n);
	
$query = "SELECT * FROM `mp3info` WHERE `rlsname` $liked '$name' LIMIT 1";
$result = mysql_query($query) or die(mysql_error());
	
$row = mysql_fetch_assoc($result);


if( $row != "" ) {
	
	$join = ",";
	$fintime = $row['rlsname'].$join.$row['genre'].$join.$row['year'].$join.$row['hertz'].$join.$row['type'].$join.$row['bitrate'].$join.$row['bittype'].$join.$row['unixtime'];
	
	echo $fintime;
	
} else {

	die();
	
}


?>