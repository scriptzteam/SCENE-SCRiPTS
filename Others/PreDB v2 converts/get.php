<pre>
<?php
require_once("./nfo2html.php");
mysql_connect("localhost", "root", "root") or die(mysql_error());
mysql_select_db("scenedb_old") or die(mysql_error());
$id = $_GET['release'] ;

$req = mysql_query("SELECT UNCOMPRESS(`rel_nfo`) AS rel_nfo, rel_filename, rel_name FROM nfo WHERE rel_name = '" . $id . "'") or die( mysql_error());  
$res = mysql_fetch_assoc($req);
//print_r($res);
if($res['rel_nfo'] != ""){
	$finaldata = ($res['rel_nfo']);
	echo nfo2html($res['rel_name'])."

";
	echo nfo2html($res['rel_filename'])."
	
";
	echo nfo2html($finaldata);
	
} else {

    die();
	
}

?>