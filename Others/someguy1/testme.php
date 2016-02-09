<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'includes'.DIRECTORY_SEPARATOR.'functions.php');

setcookie('xxx_uid', 'xxx');

echo $_COOKIE['xxx_uid'];
echo $HTTP_COOKIE_VARS["xxx_uid"];

// Another way to debug/test is to view all cookies
print_r($_COOKIE);

?>