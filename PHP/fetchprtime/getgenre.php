<?php

mysql_connect('127.0.0.1', 'scenedbaxx', 'Q3wX8GdPV7eKNQpw');
mysql_select_db('scenestuff');

//$pretime = 0 + @file_get_contents("http://example.com/getgenre.php?name=".trim($torrent));

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

$allowip = array("127.0.0.1","1.2.3.4");

if (!in_array($ip, $allowip))
die();

$like = (isset($_GET['like'])) ? (int)$_GET['like'] : "0";
$n = isset($_GET['name']) ? $_GET['name'] : "";


$liked = (($like == "1") ? "LIKE" : "=");

$n = str_replace(" ", "%", $n);
$name = sqlesc($n);


$query = "SELECT `genre` FROM `prerlsdb` WHERE `rlsname` $liked '$name' ORDER BY `unixtime` DESC LIMIT 1";
$result = mysql_query($query) or die(mysql_error());
	
$row = mysql_fetch_assoc($result);


if( $row['genre'] != '' ) {
	
	foreach(explode('_' , $row['genre']) as $gn) {
	
		if($gn != '') {
		
			$gnArr[] = $gn;
		
		}
	
	}
	
	echo implode(', ' , $gnArr);
	
} elseif( $row['genre'] == "" ) {

	$queryx = "SELECT `genre` FROM `prerls` WHERE `rlsname` $liked '$name' ORDER BY `rlstime` DESC LIMIT 1";
	$resultx = mysql_query($queryx) or die(mysql_error());
	
	$rowx = mysql_fetch_assoc($resultx);
	
	if( $rowx['genre'] != '' ) {
		
		foreach(explode('_' , $rowx['genre']) as $gn) {
	
			if($gn != '') {
			
				$gnArr[] = $gn;
			
			}
	
		}
	
		echo implode(', ' , $gnArr);
		
	}

}

?>