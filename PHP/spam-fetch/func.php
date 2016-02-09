<?php
//error_reporting(E_ALL);

//---------------------------------------------
// DB setup
$TBDEV['mysql_host'] = "127.0.0.1";
$TBDEV['mysql_user'] = "scenedbaxx";
$TBDEV['mysql_pass'] = "Q3wX8GdPV7eKNQpw";
$TBDEV['mysql_db']   = "scenestuff";
//---------------------------------------------

$mc = new Memcache;
$mc->connect('127.0.0.1', 19420) or die ("Could not connect");


function dbconn()
{
    global $TBDEV;

    if (!@mysql_connect($TBDEV['mysql_host'], $TBDEV['mysql_user'], $TBDEV['mysql_pass']))
    {
	  err('Please call back later');
    }
    mysql_select_db($TBDEV['mysql_db']) or err('Please call back later');
}

function sqlesc($x) {
   if (is_numeric($x)) return $x;
	else
   return "'" . mysql_real_escape_string($x) . "'";
}

function unsafeChar($var)
{
    return str_replace(array("&gt;", "&lt;", "&quot;", "&amp;"), array(">", "<", "\"", "&"), $var);
}

function safechar($var)
{
    return htmlspecialchars(unsafeChar($var));
}

function safe($var)
{
    return str_replace(array('&', '>', '<', '"', '\''), array('&amp;', '&gt;', '&lt;', '&quot;', '&#039;'), str_replace(array('&gt;', '&lt;', '&quot;', '&#039;', '&amp;'), array('>', '<', '"', '\'', '&'), $var));
}

function is_valid_id($id)
{
  return is_numeric($id) && ($id > 0) && (floor($id) == $id);
}

?>