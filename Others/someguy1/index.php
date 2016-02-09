<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'includes'.DIRECTORY_SEPARATOR.'functions.php');
loggedinorreturn();

echo stdhead('Index');
	
if(isset($_GET["search"])) {

	$searchstr = unesc($_GET["search"]);
	$cleansearchstr = searchfield($searchstr);
	
	if (empty($cleansearchstr))
		unset($cleansearchstr);
		
}

$where = $addparam = '';

if (isset($cleansearchstr)) {
	$addparam .= "search=" . urlencode($searchstr) . "&amp;";
	$searchfin = trim($cleansearchstr);
	$searcha = str_replace(" ", "%", $searchfin);
	
	//$wherea[] = "rlsname LIKE '%" . sqlwildcardesc($searcha) . "%'";
	$where = "releases.rlsname LIKE '%" . $searcha . "%'";
}

if ($where != "")
	$where = "WHERE $where";
	
	mysql_query("TRUNCATE TABLE temp_releases") or die(mysql_error());
	mysql_query("INSERT INTO temp_releases (id, rlsname, grp, section, time, files, size, genre) SELECT id, rlsname, grp, section, time, files, size, genre FROM releases $where ORDER BY time DESC LIMIT 100") or die('er');
	
	$count = mysql_affected_rows();
	
	$q = (isset($cleansearchstr)) ? htmlspecialchars($searchstr) : '';
	
	echo '<form method="get" action="" class="well form-search">
		<input class="input-medium search-query" type="text" placeholder="Search Query" name="search" value="'.$q.'">
		<button class="btn primary" type="submit">Search</button>
		</form>';
	
	
	if($count == '0') {
	
		echo "<section>No results found for {$q}</section>";
	
	} else {
	
		$query = "SELECT STRAIGHT_JOIN tr.rlsname, tr.grp, tr.section, tr.time, tr.files, tr.size, tr.genre, " .
		"nfo.id AS nfoid, sfv.id AS sfvid, m3u.id AS m3uid, jpg.id AS jpgid, cover.id AS coverid, mp3info.rel_info AS mp3info, ".
		"videoinfo.rel_info AS videoinfo, url.rel_url AS url, nukelog.reason , nukelog.network, nukelog.status, spam.id AS spamid " . 
		"FROM temp_releases AS tr " . 
		"LEFT JOIN nukelog ON tr.rlsname = nukelog.rlsname " .
		"LEFT JOIN spam ON tr.rlsname = spam.rlsname " .
		"LEFT JOIN nfo ON tr.rlsname = nfo.rel_name " .
		"LEFT JOIN sfv ON tr.rlsname = sfv.rel_name " .
		"LEFT JOIN m3u ON tr.rlsname = m3u.rel_name " .
		"LEFT JOIN jpg ON tr.rlsname = jpg.rel_name " .
		"LEFT JOIN cover ON tr.rlsname = cover.rel_name " .
		"LEFT JOIN mp3info ON tr.rlsname = mp3info.rel_name " .
		"LEFT JOIN videoinfo ON tr.rlsname = videoinfo.rel_name " .
		"LEFT JOIN url ON tr.rlsname = url.rel_name " .
		"ORDER BY tr.time DESC LIMIT 0, 100";
		
		$res = mysql_query($query) or die(mysql_error());
		
		$svar = ($q != '') ? ($count == 100) ? "<p>Displaying {$count} Search Results found for {$q}. Limited to 100 results re-define your search.</p>" : "<p>Displaying {$count} Search Results found for {$q}.</p>" : '';
		
		echo "<section>{$svar}
		<table class='zebra-striped'>
			<thead>
			  <tr>
				<th>Section</th>
				<th>Added</th>
				<th>Release Name</th>
				<th>Info</th>
			  </tr>
			</thead>
			<tbody>";

		while ($row = mysql_fetch_assoc($res)) {
			
			$nuked = ($row['reason'] != '' && $row['status'] == '1') ? "<a href='#' title={$row['reason']}><span class='label important'>NUKED</span></a>&nbsp;" : '';
			$modnuked = ($row['reason'] != '' && $row['status'] == '2') ? "<a href='#' title={$row['reason']}><span class='label important'>MODNUKED</span></a>&nbsp;" : '';
			$unnuked = ($row['reason'] != '' && $row['status'] == '3') ? "<a href='#' title={$row['reason']}><span class='label success'>UNNUKED</span></a>&nbsp;" : '';
			
			$delpre = $undelpre = '';
			//$delpre = ($row['dreason'] != '' && $row['undel'] == 'N') ? "<a href='#' title={$row['dreason']}><span class='label important'>DELETED</span></a>&nbsp;" : '';
			//$undelpre = ($row['undel'] == 'Y') ? "<a href='#' title={$row['dreason']}><span class='label success'>UNDELETED</span></a>&nbsp;" : '';
			
			$nfo = ($row['nfoid'] != '') ? "<a href='get.php?type=nfo&id={$row['nfoid']}' rel='tooltip' title='View NFO'><span class='label warning'>NFO</span></a>&nbsp;" : '';
			$sfv = ($row['sfvid'] != '') ? "<a href='get.php?type=sfv&id={$row['sfvid']}' rel='tooltip' title='View SFV'><span class='label notice'>SFV</span></a>&nbsp;" : '';
			$m3u = ($row['m3uid'] != '') ? "<a href='get.php?type=m3u&id={$row['m3uid']}' rel='tooltip' title='View M3U'><span class='label'>M3U</span></a>&nbsp;" : '';
			$jpg = ($row['jpgid'] != '') ? "<a href='image.php?type=jpg&id={$row['jpgid']}' rel='tooltip' title='View JPG'><span class='label'>JPG</span></a>&nbsp;" : '';
			$cover = ($row['coverid'] != '') ? "<a href='image.php?type=cover&id={$row['coverid']}' rel='tooltip' title='View Cover'><span class='label'>COVER</span></a>&nbsp;" : '';
			$mp3info = ($row['mp3info'] != '') ? "<a href='#' rel='tooltip' title='{$row['mp3info']}'><span class='label'>MP3</span></a>&nbsp;" : '';
			$videoinfo = ($row['videoinfo'] != '') ? "<a href='#' rel='tooltip' title='{$row['videoinfo']}'><span class='label'>ViDEO</span></a>&nbsp;" : '';
			$url = ($row['url'] != '') ? "<a href='http://anonym.to/{$row['url']}' target='_blank' rel='tooltip' title='{$row['url']}'><span class='label'>URL</span></a>&nbsp;" : '';
			
			$genre = ($row['genre'] == '') ? '' : "Genre:&nbsp".$row['genre'];
			
			echo "<tr>";
			echo "<td>{$row['section']}</td>";
			echo "<td><a href='#' title='Pred ".gettime($row['time'])." ago' rel='tooltip'>".get_date_time($row['time'])."</a></td>";
			echo "<td><a href='#' title='".$row['rlsname']."' rel='tooltip'>".CutName($row['rlsname'])."</a>&nbsp;".$nuked.$modnuked.$unnuked.$delpre.$undelpre."<br />".$nfo.$sfv.$m3u.$jpg.$cover.$mp3info.$videoinfo.$url.$genre."</td>";
			echo "<td><b>{$row['files']}</b>F in <b>{$row['size']}</b>MB</td>";
			echo "</tr>";
			
		}
		
		echo "</tbody></table></section>";
	
	}
	
	mysql_query("TRUNCATE TABLE temp_releases") or die(mysql_error());


echo stdfoot();

?>