<?php
//if($_SERVER["QUERY_STRING"]) {
  
require_once(__DIR__.DIRECTORY_SEPARATOR.'includes'.DIRECTORY_SEPARATOR.'functions.php');


//  loggedinorreturn();
    //include("nfo2png.php");
  if (!isset($_GET['type'])) {
    die("erreur type");
  }

$type = (isset($_GET['type'])?safe($_GET['type']):'');


if (isset($_GET['type']) && $type == "") {
	die("");
}

if (!isset($_GET['id'])) {
	die("");
}

$id = (isset($_GET['id'])?safe($_GET['id']):'');

if (isset($_GET['id']) && $id == "") {
	die("");
}
	/*function tty($title){
		$content = $title;
		preg_match('/tt[0-9]{7}/',$content,$matches);
		return $matches[0];
	}*/

$id=decrypt2($id);
//echo $id;
//print($id);
if (!is_valid_id($id))
die('not valid id');

if ($type == '' || $id == '')
die('');

$types = array('nfo','sfv','m3u','jpg', 'diz', 'msg');

if (!in_array($type, $types))
die('err1');

$whichdb = array('nfo' => 'nfo','sfv' => 'sfv','m3u' => 'm3u','jpg' => 'jpg','diz' => 'diz','msg' => 'ftp_message');

$t = $whichdb[$type];
$tt = 'rel_'.$t;
/*
$req = mysql_query("SELECT UNCOMPRESS(`" .$tt. "`) AS " .$tt. ", rel_filename, rel_name FROM " .$t. " WHERE id = '" . $id . "'") or die( mysql_error("err2"));  
$res = mysql_fetch_assoc($req);
*/

//print("test");
//define("ID",tty($res[$tt]));
//define("rlz",($res["rel_name"]));

//require_once('./getImdb.php');

if(isset($_GET['type']) && $_GET['type'] != "jpg")
{
require_once("./nfo2html.php");
$req = mysql_query("SELECT UNCOMPRESS(`" .$tt. "`) AS " .$tt. ", rel_filename, rel_name FROM " .$t. " WHERE id = '" . $id . "'") or die( mysql_error("err2"));  
$res = mysql_fetch_assoc($req);
$nfodata = nfo2html($res[$tt]);
if(isset($_GET["api"]) && $_GET["api"] == "1")
{
echo "<pre>".($nfodata)."</pre>";
}
else
{
echo stdhead();
//$nfo_in_txt = $res[$tt];
//$reg_exUrl = "/(http|https|ftp|ftps)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/";
//if(preg_match($reg_exUrl, $nfo_in_txt, $url)) {
//echo $url[0];
	//   }
echo     '<div class="alert alert-success"><b>'.$res["rel_name"].'</b> - '.$res["rel_filename"].'</div>';
//echo "<pre>".($nfodata)."</pre>";
echo '<pre><img src="y.php?type='.$_GET['type'].'&id='.$_GET['id'].'"/></pre>';
echo stdfoot();
}
die();
}
if(isset($_GET['type']) && $_GET['type'] == "jpg")
{
header('Content-Type: image/jpeg');
$req = mysql_query("SELECT UNCOMPRESS(`" .$tt. "`) AS " .$tt. ", rel_filename, rel_name FROM " .$t. " WHERE id = '" . $id . "'") or die( mysql_error("err2")); 
$res = mysql_fetch_assoc($req);
$nfodata = ($res[$tt]);
echo $nfodata;
}
   //include("nfo2png.php");
    //$f = file($res);
   // $f = implode("",$res[$tt]);
    //buildNFO($res[$tt], "~ predb.no-ip.info ~", "F0E0D0");
  //}
?>
