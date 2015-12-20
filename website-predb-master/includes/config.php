<?php
/* Compare php version for date/time stuff etc! */
	if (version_compare(PHP_VERSION, "5.1.0RC1", ">="))
		date_default_timezone_set('Europe/London');


// DB setup
$CONFIG['mysql_host'] = "127.0.0.1";
$CONFIG['mysql_user'] = "root";
$CONFIG['mysql_pass'] = "xxx";
$CONFIG['mysql_db']   = "xxx";

$CONFIG['sitename'] = "";

$CONFIG['sitecaption'] = 'Public Online Scene Pre Database';

$CONFIG['static_server'] = "http://*/";

// Cookie setup
$CONFIG['cookie_prefix']  = '';
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
