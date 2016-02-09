<?php
/*
+------------------------------------------------------------------------------------------------------------
|   Auto Nuke/UnNuke for TBDev by sCRiPTzTEAM
|	Version: r26-tbdev_git
|
|	ALTER TABLE `torrents` ADD `nukestatus` TINYINT( 1 ) UNSIGNED NOT NULL DEFAULT '0';
|	ALTER TABLE `torrents` ADD INDEX ( `nukestatus` );
|	ALTER TABLE `torrents` ADD `nukereason` VARCHAR( 255 ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL;
|
+------------------------------------------------------------------------------------------------------------
*/
require_once 'include/bittorrent.php';
dbconn();

	$ip = getip();

	$allowip = array("1.2.3.4");

	if (!in_array($ip, $allowip))
	die();
    
	$parms = array_merge($_GET, $_POST);

	$action = isset($parms['action']) ? $parms['action'] : '';
    
    switch($action)
    {
      case 'nuke':
        nuke_this();
        break;
        
      case 'modnuke':
        modnuke_this();
        break;
        
      case 'unnuke':
        unnuke_this();
        break;

      default:
        check_this();
        break;
    }

function check_this() {

	return;

}

function nuke_this() {
global $parms;
	
	$name = isset($parms['name']) ? trim($parms['name']) : '';
	$reason = isset($parms['reason']) ? trim($parms['reason']) : '';

	if($name == '' || $reason == '') { return; }

	$res = mysql_query("SELECT id FROM torrents WHERE nukestatus != '1' AND name = ".sqlesc($name)) or sqlerr();
	$row = mysql_fetch_assoc($res);

	if (!$row) { return; }

	mysql_query("UPDATE torrents SET nukestatus = '1' AND nukereason = " . sqlesc($reason) . " WHERE name = " . sqlesc($name)) or sqlerr();

	return;

}

function modnuke_this() {
global $parms;
	
	$name = isset($parms['name']) ? trim($parms['name']) : '';
	$reason = isset($parms['reason']) ? trim($parms['reason']) : '';

	if($name == '' || $reason == '') { return; }

	$res = mysql_query("SELECT id FROM torrents WHERE name = ".sqlesc($name)) or sqlerr();
	$row = mysql_fetch_assoc($res);

	if (!$row) { return; }

	mysql_query("UPDATE torrents SET nukestatus = '1' AND nukereason = " . sqlesc($reason) . " WHERE name = " . sqlesc($name)) or sqlerr();

	return;

}

function unnuke_this() {
global $parms;
	
	$name = isset($parms['name']) ? trim($parms['name']) : '';
	$reason = isset($parms['reason']) ? trim($parms['reason']) : '';

	if($name == '' || $reason == '') { return; }

	$res = mysql_query("SELECT id FROM torrents WHERE nukestatus != '2' AND name = ".sqlesc($name)) or sqlerr();
	$row = mysql_fetch_assoc($res);

	if (!$row) { return; }

	mysql_query("UPDATE torrents SET nukestatus = '2' AND nukereason = " . sqlesc($reason) . " WHERE name = " . sqlesc($name)) or sqlerr();

	return;

}

?>