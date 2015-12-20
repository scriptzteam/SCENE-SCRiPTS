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
	$where = "allpres.rel_name LIKE '%" . $searcha . "%'";
}

if ($where != "")
	$where = "WHERE $where";
	
	mysql_query("TRUNCATE TABLE temp_predb") or die(mysql_error());
	mysql_query("INSERT INTO temp_predb (rel_id, rel_name, rel_section, rel_time, rel_files, rel_size, rel_genre) SELECT rel_id, rel_name, rel_section, rel_time, rel_files, rel_size, rel_genre FROM allpres $where ORDER BY rel_time DESC LIMIT 100") or die('er');
	
	$count = mysql_affected_rows();
	
	$q = (isset($cleansearchstr)) ? htmlspecialchars($searchstr) : '';
	
	echo '<form method="get" action="" class="well form-search">
		<input class="input-medium search-query" type="text" placeholder="Search Query" name="search" value="'.$q.'">
		<button class="btn primary" type="submit">Search</button>
		</form>';
	
	
	if($count == '0') {
	
		echo "<section>No results found for {$q}</section>";
	
	} else {
	
		$query = "SELECT STRAIGHT_JOIN temp_predb.rel_name, temp_predb.rel_section, temp_predb.rel_time, temp_predb.rel_size, temp_predb.rel_files, " .
		"temp_predb.rel_genre, nfo.id AS nfoid, sfv.id AS sfvid, m3u.id AS m3uid, nukes.n_reason AS nreason , unnukes.un_reason AS unreason, " . 
		"delpre.d_reason AS dreason, delpre.readded AS undel " . 
		"FROM temp_predb " . 
		"LEFT JOIN nukes ON temp_predb.rel_id = nukes.rel_id " .
		"LEFT JOIN unnukes ON temp_predb.rel_id = unnukes.rel_id " .
		"LEFT JOIN delpre ON temp_predb.rel_id = delpre.rel_id " .
		"LEFT JOIN nfo ON temp_predb.rel_name = nfo.rel_name " .
		"LEFT JOIN sfv ON temp_predb.rel_name = sfv.rel_name " .
		"LEFT JOIN m3u ON temp_predb.rel_name = m3u.rel_name " .
		"ORDER BY temp_predb.rel_time DESC LIMIT 0, 100";
		
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
			
			$nuked = ($row['nreason'] != '') ? "<a href='#' title={$row['nreason']}><span class='label important'>NUKED</span></a>&nbsp;" : '';
			$unnuked = ($row['unreason'] != '') ? "<a href='#' title={$row['unreason']}><span class='label success'>UNNUKED</span></a>&nbsp;" : '';
			
			$delpre = ($row['dreason'] != '' && $row['undel'] == 'N') ? "<a href='#' title={$row['dreason']}><span class='label important'>DELETED</span></a>&nbsp;" : '';
			$undelpre = ($row['undel'] == 'Y') ? "<a href='#' title={$row['dreason']}><span class='label success'>UNDELETED</span></a>&nbsp;" : '';
			
			$nfo = ($row['nfoid'] != '') ? "<a href='get.php?type=nfo&id={$row['nfoid']}' title='Download NFO'><span class='label warning'>NFO</span></a>&nbsp;" : '';
			$sfv = ($row['sfvid'] != '') ? "<a href='get.php?type=sfv&id={$row['sfvid']}' title='Download SFV'><span class='label notice'>SFV</span></a>&nbsp;" : '';
			$m3u = ($row['m3uid'] != '') ? "<a href='get.php?type=m3u&id={$row['m3uid']}' title='Download M3U'><span class='label'>M3U</span></a>&nbsp;" : '';
			
			$genre = ($row['rel_genre'] == '') ? '' : "Genre:&nbsp".$row['rel_genre'];
			
			echo "<tr>";
			echo "<td>{$row['rel_section']}</td>";
			echo "<td><a href='#' title='Pred ".gettime($row['rel_time'])." ago' rel='tooltip'>".get_date_time($row['rel_time'])."</a></td>";
			echo "<td><a href='#' title='".$row['rel_name']."' rel='tooltip'>".CutName($row['rel_name'])."</a>&nbsp;".$nuked.$unnuked.$delpre.$undelpre."<br />".$nfo.$sfv.$m3u.$genre."</td>";
			echo "<td><b>{$row['rel_files']}</b>F in <b>{$row['rel_size']}</b>MB</td>";
			echo "</tr>";
			
		}
		
		echo "</tbody></table></section>";
	
	}
	
	mysql_query("TRUNCATE TABLE temp_predb") or die(mysql_error());


echo stdfoot();

?>
