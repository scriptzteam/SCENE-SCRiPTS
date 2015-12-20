<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'includes'.DIRECTORY_SEPARATOR.'functions.php');

logoutcookie();

header("Location: {$CONFIG['baseurl']}/index.php");

?>
