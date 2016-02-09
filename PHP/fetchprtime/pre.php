<?php

require_once "/usr/local/apache2/htdocs/www/include/functions.php";
//ob_start("ob_gzhandler");
error_reporting(E_ALL);

//-------------------------------------------------

	connect();


if(isset($_GET["search"])) {
$searchstr = unesc($_GET["search"]);
$cleansearchstr = searchfield($searchstr);
if (empty($cleansearchstr))
	unset($cleansearchstr);
}

$addparam = "";
$wherea = array();
$wherecatina = array();

$category = isset($_GET["cat"]) ? $_GET["cat"] : false;
$blah = (isset($_GET["blah"])) ? (int)$_GET["blah"] : false;
$grp = isset($_GET["grp"]) ? $_GET["grp"] : false;


$rescat = mysql_query("SELECT section, COUNT(id) as numrls FROM prerls GROUP BY section ORDER BY section") or die(mysql_error());
while ($rowcat = mysql_fetch_array($rescat))
    $ret[] = $rowcat;
	$cats = $ret;

$resgrp = mysql_query("SELECT `group` FROM prerls GROUP BY `group` ORDER BY `group`") or die(mysql_error());
while ($rowgrp = mysql_fetch_array($resgrp))
    $retg[] = $rowgrp;
	$grps = $retg;


	if ($category)
	{
	  //if (!in_array($category,$cats))
		//stderr("Error", "Invalid Section.");
	  $wherecatina[] = sqlesc($category);
	  $addparam .= "cat=$category&amp;";
	}
	else
	{
	  $all = True;
	  foreach ($cats as $cat)
	  {
	    $all &= isset($_GET["c{$cat['section']}"]);
	    if (isset($_GET["c{$cat['section']}"]))
	    {
	      $wherecatina[] = sqlesc($cat['section']);
	      $addparam .= "c{$cat['section']}=1&amp;";
	    }
	  }
	}

if (count($wherecatina) > 1)
	$wherecatin = implode("','",$wherecatina);
elseif (count($wherecatina) == 1)
	$wherea[] = "section = '$wherecatina[0]'";

if ($blah > 0) {
  if ($blah == 0) {
    $wherea[] = "";
  } elseif ($blah == 1) {
    $wherea[] = "nukestatus = 'Nuked'";
	$addparam .= "blah=1&amp;";
  } elseif ($blah == 2) {
    $wherea[] = "nukestatus = 'UnNuked'";
	$addparam .= "blah=2&amp;";
  } elseif ($blah == 3) {
    $wherea[] = "nukestatus = 'UnDeleted'";
	$addparam .= "blah=3&amp;";
  }
}

if (isset($wherecatin))
	$wherea[] = "section IN('" . $wherecatin . "')";

if (isset($grp) && $grp != "") {
	$wherea[] = "grp = '" . sqlesc($grp) . "'";
	$addparam .= "grp=$grp&amp;";
}
if (isset($cleansearchstr)) {
	$addparam .= "search=" . urlencode($searchstr) . "&amp;";
	$searchfin = sqlesc(trim($cleansearchstr));
	$searcha = str_replace(" ", "%", $searchfin);
	
	//$wherea[] = "rlsname LIKE '%" . sqlwildcardesc($searcha) . "%'";
	$wherea[] = "rlsname LIKE '%" . $searcha . "%'";
}

$where = implode(" AND ", $wherea);

if ($where != "")
	$where = "WHERE $where";
	
	$res = mysql_query("SELECT COUNT(*) FROM prerls $where");
	$row = mysql_fetch_array($res,MYSQL_NUM);
	$count = $row[0];

//echo $addparam;
//print("<br>");
//echo $where;
if ($count)
{	
	//list($pagertop, $pagerbottom, $limit) = pager(100, $count, "pre.php?" . $addparam);
	$pager = pager(100, $count, "pre.php?" . $addparam);
	
	$query = "SELECT * FROM prerls $where ORDER BY id DESC {$pager['limit']}";
	//$query = "SELECT * FROM prerls $where ORDER BY id DESC $limit";
	
	//$query = "SELECT releases.id, releases.rlsname, releases.section, releases.unixtime, releases.addedon, releases.files, releases.size, releases.genre, releases.grp, releases.nukestatus, releases.nukereason, releases.nukenet, nfodb.rlsname " .
	//"FROM releases LEFT JOIN nfodb ON releases.rlsname = nfodb.rlsname ORDER BY releases.id DESC $limit";
	// LEFT JOIN nfodb ON releases.rlsname = nfodb.rlsname
	// Perform Query
	$respretable = mysql_query($query) or die(mysql_error());
}
else
	unset($respretable);
	
	stdhead();
	
?>

<br><br>
<form method="get" action="pre.php">
<table class=bottom align=center>
<tr>

<?

$i = 0;
foreach ($cats as $cat)
{
	$catsperrow = 7;
	print(($i && $i % $catsperrow == 0) ? "</tr><tr>" : "");
	print("<td class=bottom style=\"padding-bottom: 2px;padding-left: 7px\"><input name=c$cat[section] type=\"checkbox\" " . (in_array($cat['section'],$wherecatina) ? "checked " : "") . "value=1><a class=catlink href=pre.php?cat=$cat[section]>" . htmlspecialchars($cat['section']) . "</a> (" . $cat['numrls'] . ")</td>\n");
	$i++;
}

?>
	</tr>
	</table>



<p><p>
<table width=750 class=main align=center border=0 cellspacing=0 cellpadding=0><tr><td class=embedded>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Search:
<?
if (isset($cleansearchstr)) {
?>
<input type="text" name="search" size="40" value="<?= htmlspecialchars($searchstr) ?>" />
<? } else { ?>
<input type="text" name="search" size="40" value="" />
<? } ?>
in 
<select name=blah>
<option value="0">(all types)</option>
<option value="1"<? print($blah == 1 ? " selected" : ""); ?>>Nuked</option>
<option value="2"<? print($blah == 2 ? " selected" : ""); ?>>UnNuked</option>
<option value="3"<? print($blah == 3 ? " selected" : ""); ?>>UnDeleted</option>
</select>
<select name="cat">
<option value="">(all sections)</option>
<?

$catdropdown = "";
foreach ($cats as $cat) {
$catdropdown .= "<option value=\"" . $cat["section"] . "\"";
if ($cat["section"] == $_GET["cat"])
$catdropdown .= " selected=\"selected\"";
$catdropdown .= ">" . htmlspecialchars($cat["section"]) . "</option>\n";

}

?>
<?= $catdropdown ?>
</select>
<select name="grp">
<option value="">(all groups)</option>
<?

$grpdropdown = "";
foreach ($grps as $grp) {
$grpdropdown .= "<option value=\"" . $grp["grp"] . "\"";
if ($grp["grp"] == $_GET["grp"])
$grpdropdown .= " selected=\"selected\"";
$grpdropdown .= ">" . htmlspecialchars($grp["grp"]) . "</option>\n";

}

?>
<?= $grpdropdown ?>
</select>
<input type="submit" value="Search!" />
</form>
</td></tr></table>

<?

if (isset($cleansearchstr))
print("<center><h2>Search results for \"" . htmlentities($searchstr, ENT_QUOTES) . "\"</h2><c\enter>\n");

	
if ($count) {
	//print($pagertop);
	print($pager['pagertop']);
	pretable($respretable);
	print($pager['pagerbottom']);
	//print($pagerbottom);
}
else {
	print("<center>");
	if (isset($cleansearchstr)) {
		print("<h2>Nothing found!</h2>\n");
		print("<p>Try again with a refined search string.</p>\n");
	}
	else {
		print("<h2>Nothing here!</h2>\n");
		print("<p>Sorry pal :(</p>\n");
	}
	print("</center>");
}

disconnect();

stdfoot();
?>