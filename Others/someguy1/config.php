<?php
/* Compare php version for date/time stuff etc! */
	if (version_compare(PHP_VERSION, "5.1.0RC1", ">="))
		date_default_timezone_set('Europe/London');


// DB setup
$CONFIG['mysql_host'] = "localhost";
$CONFIG['mysql_user'] = "root";
$CONFIG['mysql_pass'] = "T?35y#07q2";
$CONFIG['mysql_db']   = "predb";

$CONFIG['sitename'] = "xxx";

$CONFIG['sitecaption'] = 'xxx';

$CONFIG['static_server'] = "http://example.com/";

// Cookie setup
$CONFIG['cookie_prefix']  = 'xxx';
$CONFIG['cookie_path']    = '';
$CONFIG['cookie_domain']  = '';
$CONFIG['IPcookieCheck'] = 1;
$CONFIG['site_online'] = 1;


if ($_SERVER["HTTP_HOST"] == "")
  $_SERVER["HTTP_HOST"] = $_SERVER["SERVER_NAME"];
  
$CONFIG['baseurl'] = "http://" . $_SERVER["HTTP_HOST"]."";

$CONFIG['sql_error_log'] = ROOT_DIR.'logs'.DIRECTORY_SEPARATOR.'sql_err_'.date('M_D_Y').'.log';
$CONFIG['images_dir'] = $CONFIG['static_server'] . "images/";


?>