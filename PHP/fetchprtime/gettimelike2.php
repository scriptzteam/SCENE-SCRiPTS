<?
require_once "/home/webbrowsestuff/www/include/functions.php";

connect();

$name = $_GET['name'];
$query = "SELECT unixtime 
FROM `prerlsdb` 
WHERE `rlsname` LIKE '$name' 
ORDER BY `unixtime` DESC 
LIMIT 1";



// Perform Query
$result = mysql_query($query) or die(mysql_error());

while ($row = mysql_fetch_assoc($result)) {
    echo abs(strtotime($row['unixtime']) - time());
}

?>