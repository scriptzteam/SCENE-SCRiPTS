<?php
error_reporting(E_ALL);

const REQUIRED_PHP = '5.3.0';

if (!version_compare(PHP_VERSION, REQUIRED_PHP, '>='))
	die('PHP '.REQUIRED_PHP.' or higher is required.');

define('SQL_DEBUG', 2);
define('TIME_NOW', time());
	
/** define dirs **/
define('INCL_DIR', __DIR__.DIRECTORY_SEPARATOR);
define('CLASS_DIR', INCL_DIR.'classes'.DIRECTORY_SEPARATOR);
define('ROOT_DIR', realpath(INCL_DIR.'..'.DIRECTORY_SEPARATOR).DIRECTORY_SEPARATOR);
define('ADMIN_DIR', ROOT_DIR.'admin'.DIRECTORY_SEPARATOR);
define('STATIC_DIR', ROOT_DIR.'static'.DIRECTORY_SEPARATOR);

// Base Dir
define('ROOT_PATH', realpath(INCL_DIR.'..'.DIRECTORY_SEPARATOR).DIRECTORY_SEPARATOR);

// Base Paths
define('BASE_PATH', realpath(ROOT_PATH.DIRECTORY_SEPARATOR).DIRECTORY_SEPARATOR);

// Tracker Paths
define('TROOT_PATH', BASE_PATH.DIRECTORY_SEPARATOR);
define('TINCL_PATH', TROOT_PATH.'includes'.DIRECTORY_SEPARATOR);

?>
