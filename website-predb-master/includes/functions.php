<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'defines.php');
require_once(__DIR__.DIRECTORY_SEPARATOR.'config.php');
require_once(__DIR__.DIRECTORY_SEPARATOR.'Isy_user.php');

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

function stdhead($title = '') {
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
			<link rel="stylesheet" href="' . $CONFIG['static_server'] . 'static/default.css" type="text/css" />
			<script type="text/javascript" src="' . $CONFIG['static_server'] . 'static/jquery-1.7.1.min.js"></script>
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
          <a class="brand" href="index.php">'.$CONFIG['sitename'].'</a>
          <ul class="nav">
            <li class="active"><a href="index.php">Home</a></li>
			<li class="vertical-divider"></li>
            <li><a href="pres.php">Releases</a></li>

          </ul>
		  
		            <ul class="nav pull-right">
            <li class="dropdown">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown">'.Isy_user::$current['name'].'\'s Profile <b class="caret"></b></a>
              <ul class="dropdown-menu">';
			  
                $htmlout .= (Isy_user::$current['id'] == 1) ? '<li><a href="adduser.php">Add User</a></li><li class="divider"></li>' : '';
				
                $htmlout .= '<li><a href="logout.php">Logout</a></li>
              </ul>
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
        <p>&copy; '.$CONFIG['sitename'].' 2012</p>
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

function userlogin() {
    global $CONFIG;
	
    $CURUSER = $updateuser = array();

    if (!$CONFIG['site_online'] || !get_mycookie('uid') || !get_mycookie('pass'))
    return;

    $id = 0 + get_mycookie('uid');
	
    if (!$id || strlen( get_mycookie('pass') ) != 32)
    return;
	
	$res = mysql_query('SELECT * FROM `users` WHERE `id` = '.$id.' AND `enabled` = "yes"') or sqlerr(__FILE__,__LINE__);
	$row = mysql_fetch_assoc($res);
	
    if (!$row)
    return;
	
	Isy_user::prepare_curuser($row);
	
	$nowip = getip();
	
	if( $CONFIG['IPcookieCheck'] ) {
	
		$octet  = explode( ".", $nowip );
		$md5ip = md5($octet[0].$row['passhash'].$octet[1]);
		
		if( !get_mycookie('ipcheck') OR (get_mycookie('ipcheck') !== $md5ip) )
		return;
	
    }
  
  if (get_mycookie('pass') !== $row["passhash"])
    return;

	if ($row['lastseen'] < (time() - 300))
		$updateuser[] = '`lastseen` = '.time();

	if ($row['ip'] != $nowip)
		$updateuser[] = '`ip` = '.sqlesc($nowip);

	if (count($updateuser)) {
		
		mysql_query('UPDATE `users` SET '.implode(', ', $updateuser).' WHERE `id` = '.$row['id']) or sqlerr(__FILE__, __LINE__);
		
	}
	
	Isy_user::$current = $row;
	$GLOBALS['CURUSER'] =& Isy_user::$current;

}

function loginIPcookie( $hash, $name='ipcheck' ) {
  
  global $CONFIG;
  
  $octet  = explode( ".", getip() );
  $md5ip = md5($octet[0].$hash.$octet[1]);
  
  set_mycookie( $name, $md5ip, 365 );
}

function logincookie($id, $passhash, $updatedb = 1, $expires = 0x7fffffff)
{
    //setcookie("uid", $id, $expires, "/");
    //setcookie("pass", $passhash, $expires, "/");
    set_mycookie( "uid", $id, $expires );
    set_mycookie( "pass", $passhash, $expires );
    loginIPcookie( $passhash );
	
	$nowip = getip();
    
    if ($updatedb) {
		
		mysql_query('UPDATE `users` SET lastseen = '.TIME_NOW.', ip = '.sqlesc($nowip).' WHERE `id` = '.$id) or sqlerr(__FILE__, __LINE__);
	
	}
}

function set_mycookie( $name, $value="", $expires_in=0, $sticky=1 ) {
	global $CONFIG;
		
		if ( $sticky == 1 )
    {
      $expires = TIME_NOW + 60*60*24*365;
    }
		else if ( $expires_in )
		{
			$expires = TIME_NOW + ( $expires_in * 86400 );
		}
		else
		{
			$expires = 0;
		}
		
		$CONFIG['cookie_domain'] = $CONFIG['cookie_domain'] == "" ? ""  : $CONFIG['cookie_domain'];
    $CONFIG['cookie_path']   = $CONFIG['cookie_path']   == "" ? "/" : $CONFIG['cookie_path'];
      	
		if ( PHP_VERSION < 5.2 )
		{
      if ( $CONFIG['cookie_domain'] != '' )
      {
        @setcookie( $CONFIG['cookie_prefix'].$name, $value, $expires, $CONFIG['cookie_path'], $CONFIG['cookie_domain'] . '_HttpOnly' );
      }
      else
      {
        @setcookie( $CONFIG['cookie_prefix'].$name, $value, $expires, $CONFIG['cookie_path'] );
      }
    }
    else
    {
      @setcookie( $CONFIG['cookie_prefix'].$name, $value, $expires, $CONFIG['cookie_path'], $CONFIG['cookie_domain'], NULL, TRUE );
    }
			
}
function get_mycookie($name) {
    global $CONFIG;
      
    	if ( isset($_COOKIE[$CONFIG['cookie_prefix'].$name]) AND !empty($_COOKIE[$CONFIG['cookie_prefix'].$name]) )
    	{
			return urldecode($_COOKIE[$CONFIG['cookie_prefix'].$name]);
    	}
    	else
    	{
    		return FALSE;
    	}
}

function logoutcookie() {
    //setcookie("uid", "", 0x7fffffff, "/");
    //setcookie("pass", "", 0x7fffffff, "/");
    set_mycookie('uid', '-1');
    set_mycookie('pass', '-1');
}

function loggedinorreturn() {
    global $CONFIG;
    
	userlogin();
	
	if (!Isy_user::$current) {
        header("Location: {$CONFIG['baseurl']}/login.php");
        die();
    }
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
