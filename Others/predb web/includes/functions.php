<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'defines.php');
require_once(__DIR__.DIRECTORY_SEPARATOR.'config.php');

$load = sys_getloadavg();
if ($load[0] > 16)
	die('Load is too high, DO NOT continuously refresh, or you will just make the problem last longer');

if (!isset($_NO_CACHEHEADERS))
	header('Cache-Control: no-store, no-transform, private, must-revalidate, max-age=0');
else
	header('Cache-Control: private');

function connect() {
  global $CONFIG;
	
	$con = mysql_connect($CONFIG['mysql_host'], $CONFIG['mysql_user'], $CONFIG['mysql_pass']);
	if (!$con)
	{
		die('Database connection failed: ' . mysql_error());
	}
	
	$db = mysql_select_db($CONFIG['mysql_db']);
	if(!$db){
		die('Database selection failed: ' . mysql_error());
	}
	
}

function disconnect() {

	mysql_close(); 
	
}

connect();

$mc = new Memcache;
$mc->connect($CONFIG['memcache_ip'], $CONFIG['memcache_port']) or die ("Could not connect Memcache");

function stdhead($title = '', $rlsname = '') {
 global $CONFIG;

	$title = ($title == '') ? $CONFIG['sitename'] : $CONFIG['sitename'] . " :: " . htmlspecialchars($title);
	
    $htmlout = '<!DOCTYPE html PUBLIC
          "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<html>
			<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
			<title>'.$title.'</title>
			<link rel="SHORTCUT ICON" href="favicon.ico">
			<link rel="stylesheet" href="' . $CONFIG['static_server'] . 'static/bootstrap.min.css" type="text/css" />
			<link rel="stylesheet" href="' . $CONFIG['static_server'] . 'static/bootstrap-responsive.min.css" type="text/css" />
			<link rel="stylesheet" href="' . $CONFIG['static_server'] . 'static/default.css" type="text/css" />
			<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
			<script type="text/javascript" src="' . $CONFIG['static_server'] . 'static/bootstrap.min.js"></script>
			<script>
            $(function () {
			    $("button,a[rel=tooltip]").tooltip();

				$("button,a[rel=popover]").popover();
		  
            })
          </script>
		</head>
		    <body>
			
			    <div class="navbar navbar-fixed">
      <div class="navbar-inner">
        <div class="container">
          <a class="brand" href="javascript:;">'.$CONFIG['sitename'].'</a>
		  
		    <ul class="nav pull-right">
		    <li><a href="javascript:;">'.$rlsname.'</a></li>
            </li>
          </ul>
		  
        </div>
      </div>
    </div>
		 
			
			<div class="container">';
	


    return $htmlout;
    
} // stdhead

function stdfoot() {
	global $CONFIG;
	
    return '<footer>
        <p>&copy; '.$CONFIG['sitename'].' '.date('Y').'</p>
      </footer>

    </div></body></html>';
	
}

function CutName($txt, $len=60) {
	return (strlen($txt)>$len ? substr($txt,0,$len-1).'...' : $txt);
}

function searchfield($s) {
    return preg_replace(array('/[^a-z0-9]/si', '/^\s*/s', '/\s*$/s', '/\s+/s'), array(" ", "", "", " "), $s);
}

function unesc($x) {
    if (get_magic_quotes_gpc())
        return stripslashes($x);
    return $x;
}

function validemail($email) {
    return preg_match('/^[\w.-]+@([\w.-]+\.)+[a-z]{2,6}$/is', $email);
}

function is_valid_id($id)
{
  return is_numeric($id) && ($id > 0) && (floor($id) == $id);
}

function gmtime()
{
    return strtotime(get_date_time());
}

function get_date_time($timestamp = 0)
{
  if ($timestamp)
    return date("Y-m-d H:i:s", $timestamp);
  else
    return gmdate("Y-m-d H:i:s");
}

function sqlesc($x) {
    
   if (get_magic_quotes_gpc()) {
       $x = stripslashes($x);
   }

   if (is_numeric($x)) return "'".$x."'";

   return "'" . mysql_real_escape_string(unsafeChar($x)) . "'";
   
}

function sqlwildcardesc($x) {
    return str_replace(array("%","_"), array("\\%","\\_"), mysql_real_escape_string($x));
}

function safe($var)
{
    return str_replace(array('&', '>', '<', '"', '\''), array('&amp;', '&gt;', '&lt;', '&quot;', '&#039;'), str_replace(array('&gt;', '&lt;', '&quot;', '&#039;', '&amp;'), array('>', '<', '"', '\'', '&'), $var));
}

function unsafeChar($var)
{
    return str_replace(array("&gt;", "&lt;", "&quot;", "&amp;"), array(">", "<", "\"", "&"), $var);
}

function safechar($var)
{
    return htmlspecialchars(unsafeChar($var));
}

function gettime($st) {

 	$curtime = TIME_NOW;
	$since = $curtime - $st;
	
	$gets = array();
	$pots = array('second','minute','hour','day','week','month','year','decade');
	$lngh = array(1,60,3600,86400,604800,2630880,31570560,315705600);
	
	for($i=count($lngh)-1;$i>=0;$i--) {
	
		if($since>=$lngh[$i]) {
		
			$gets[] .= ($n=intval($since/$lngh[$i])). ' '. $pots[$i] . ($n>1?'s':'');
			$since%=$lngh[$i];
			
		}
	}
	
	return implode(', ',$gets);
	
}

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


function httperr($code = 404) {
    header("HTTP/1.0 404 Not found");
    print("<h1>Not Found</h1>\n");
    print("<p>Sorry pal :(</p>\n");
    exit();
}

function commify($string, $decimals=-1, $dec_point='.', $thousands_sep=',')
{
    if ($decimals == -1)
    {
        if (preg_match('/(.*)\.(\d+.*)/', $string, $matches))
            return number_format($matches[1], 0, $dec_point, $thousands_sep) . $dec_point . $matches[2];
        else
            return number_format($string);
    }
    else
        return number_format($string, $decimals, $dec_point, $thousands_sep);
}

// Basic MySQL error handler
function sqlerr($file = '', $line = '') {
    global $CONFIG;
    
		$the_error    = mysql_error();
		$the_error_no = mysql_errno();

    	if ( SQL_DEBUG == 0 )
    	{
			exit();
    	}
     	else if ( $CONFIG['sql_error_log'] AND SQL_DEBUG == 1 )
		{
			$_error_string  = "\n===================================================";
			$_error_string .= "\n Date: ". date( 'r' );
			$_error_string .= "\n Error Number: " . $the_error_no;
			$_error_string .= "\n Error: " . $the_error;
			$_error_string .= "\n IP Address: " . $_SERVER['REMOTE_ADDR'];
			$_error_string .= "\n in file ".$file." on line ".$line;
			$_error_string .= "\n URL:".$_SERVER['REQUEST_URI'];
			$_error_string .= "\n Username: ".Isy_user::$current['name']."[".Isy_user::$current['id']."]";
			
			if ( $FH = @fopen( $CONFIG['sql_error_log'], 'a' ) )
			{
				@fwrite( $FH, $_error_string );
				@fclose( $FH );
			}
			
			print "<html><head><title>MySQL Error</title>
					<style>P,BODY{ font-family:arial,sans-serif; font-size:11px; }</style></head><body>
		    		   <blockquote><h1>MySQL Error</h1><b>There appears to be an error with the database.</b><br />
		    		   You can try to refresh the page by clicking <a href=\"javascript:window.location=window.location;\">here</a>
				  </body></html>";
		}
		else
		{
    		$the_error = "\nSQL error: ".$the_error."\n";
	    	$the_error .= "SQL error code: ".$the_error_no."\n";
	    	$the_error .= "Date: ".date("l dS \of F Y h:i:s A");
    	
	    	$out = "<html>\n<head>\n<title>MySQL Error</title>\n
	    		   <style>P,BODY{ font-family:arial,sans-serif; font-size:11px; }</style>\n</head>\n<body>\n
	    		   <blockquote>\n<h1>MySQL Error</h1><b>There appears to be an error with the database.</b><br />
	    		   You can try to refresh the page by clicking <a href=\"javascript:window.location=window.location;\">here</a>.
	    		   <br /><br /><b>Error Returned</b><br />
	    		   <form name='mysql'><textarea rows=\"15\" cols=\"60\">".htmlentities($the_error, ENT_QUOTES)."</textarea></form><br>We apologise for any inconvenience</blockquote></body></html>";
    		   
    
	       	print $out;
		}
		
        exit();
}

?>