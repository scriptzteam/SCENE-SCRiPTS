<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'includes'.DIRECTORY_SEPARATOR.'functions.php');

$hash = (isset($_GET['h'])) ? $_GET['h'] : "";

if (strlen($hash) != '32')
die('Invalid hash');

$rlsname = $mc->get($hash);

if ($rlsname == '')
die('Link Expired');

$result = mysql_query("SELECT * FROM `predb` WHERE `rlsname` = ".sqlesc($rlsname)) or die(mysql_error());
$row = mysql_fetch_assoc($result);

if($row != '') {

	$nfo = $m3u = $sfv = '';

	$NFOres = mysql_query("SELECT nfo_data FROM `nfodb` WHERE `nfo_rlsname` = ".sqlesc($rlsname)) or die(mysql_error());
	$NFOrow = mysql_fetch_assoc($NFOres);

	if($NFOrow != '') {

		$nfo = ($NFOrow['nfo_data'] != '') ? "<a class=\"btn\" href='get.php?t=1&h=".$hash."' rel='tooltip' title='Download NFO'><span class='label label-success'><i class=\"icon-download-alt\"></i> NFO</span></a>&nbsp;&nbsp;" : '';

	}

	$SFVres = mysql_query("SELECT sfv_data FROM `sfvdb` WHERE `sfv_rlsname` = ".sqlesc($rlsname)) or die(mysql_error());
	$SFVrow = mysql_fetch_assoc($SFVres);

	if($SFVrow != '') {
		
		$sfv = ($SFVrow['sfv_data'] != '') ? "<a class=\"btn\" href='get.php?t=2&h=".$hash."' rel='tooltip' title='Download SFV'><span class='label label-info'><i class=\"icon-download-alt\"></i> SFV</span></a>&nbsp;&nbsp;" : '';

	}

	$M3Ures = mysql_query("SELECT m3u_data FROM `m3udb` WHERE `m3u_rlsname` = ".sqlesc($rlsname)) or die(mysql_error());
	$M3Urow = mysql_fetch_assoc($M3Ures);

	if($M3Urow != '') {
		
		$m3u = ($M3Urow['m3u_data'] != '') ? "<a class=\"btn\" href='get.php?t=3&h=".$hash."' rel='tooltip' title='Download M3U'><span class='label label-warning'><i class=\"icon-download-alt\"></i> M3U</span></a>&nbsp;&nbsp;" : '';

	}

	echo stdhead('Info', $row['rlsname']);

	echo '<div class="row">';

		echo '<div class="span4">';

		echo '<div class="well">';

			echo 'Section: <span class="label">'.$row['section'].'</span><br><br>';
			echo 'Pre\'d: <strong>'.gettime($row['unixtime']).' ago</strong> ('.get_date_time($row['unixtime']).')<br><br>';
			echo ($row['size'] != 0 && $row['files'] != 0) ? 'Info: <b>'.$row['files'].'</b>F in <b>'.$row['size'].'</b>MB<br><br>' : '';
			echo ($row['genre'] != '') ? 'Genre: '.$row['genre'].'<br><br>' : '';
			echo ($row['nukereason'] != '' && $row['nukestatus'] == 'Nuked') ? "<a href='javascript:;' rel='tooltip' title=\"".$row['nukereason']."/".$row['nukenet']."\"><span class='label label-important'>NUKED</span></a>&nbsp;" : '';
			echo ($row['nukereason'] != '' && $row['nukestatus'] == 'ModNuked') ? "<a href='javascript:;' rel='tooltip' title=\"".$row['nukereason']."/".$row['nukenet']."\"><span class='label label-important'>MODNUKED</span></a>&nbsp;" : '';
			echo ($row['nukereason'] != '' && $row['nukestatus'] == 'UnNuked') ? "<a href='javascript:;' rel='tooltip' title=\"".$row['nukereason']."/".$row['nukenet']."\"><span class='label label-success'>UNNUKED</span></a>&nbsp;" : '';
			echo ($row['nukereason'] != '' && $row['nukestatus'] == 'Deleted') ? "<a href='javascript:;' rel='tooltip' title=\"".$row['nukereason']."/".$row['nukenet']."\"><span class='label label-important'>DELETED</span></a>&nbsp;" : '';
			echo ($row['nukereason'] != '' && $row['nukestatus'] == 'UnDeleted') ? "<a href='javascript:;' rel='tooltip' title=\"".$row['nukereason']."/".$row['nukenet']."\"><span class='label label-info'>UNDELETED</span></a>&nbsp;" : '';
			echo ($nfo != '' || $sfv != '' || $m3u != '') ? 'Files: '.$nfo.$sfv.$m3u : '';

		echo '</div>';

		echo '</div>';

		echo '<div class="span8">';

		echo '<div class="well">';

			if($nfo == '' && $sfv == '' && $m3u == '') {

				echo '<h3>No Files found for this release.</h3>';

			} else {

				echo '<div class="tabbable">

				  		<ul class="nav nav-tabs">';

				    		echo ($nfo != '') ? '<li class="active"><a href="#nfo" data-toggle="tab">NFO</a></li>' : '';
				    		echo ($sfv != '') ? '<li><a href="#sfv" data-toggle="tab">SFV</a></li>' : '';
				    		echo ($m3u != '') ? '<li><a href="#m3u" data-toggle="tab">M3U</a></li>' : '';

				  		echo '</ul>

				  		<div class="tab-content">';

				    		echo ($nfo != '') ? '<div class="tab-pane active" id="nfo"><pre>'.$NFOrow['nfo_data'].'</pre></div>' : '';
				    		echo ($sfv != '') ? '<div class="tab-pane" id="sfv"><pre>'.$SFVrow['sfv_data'].'</pre></div>' : '';
				    		echo ($m3u != '') ? '<div class="tab-pane" id="m3u"><pre>'.$M3Urow['m3u_data'].'</pre></div>' : '';

				  		echo '</div>
					</div>';

			}

		echo '</div>';

		echo '</div>';

	echo '</div>';

	echo stdfoot();

		
} else {

	die('Release Not Found');

}

?>