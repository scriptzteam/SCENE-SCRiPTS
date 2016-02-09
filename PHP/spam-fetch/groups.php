<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'func.php');
dbconn();

function trimcolors($string) {
	

	//preg_replace('/[^a-zA-Z0-9]*/', '', $string);
	
	// trim colors
	$new = preg_replace("/[^\x9\xA\xD\x20-\x7F]/", "", $string);
	
	$new2 = preg_replace('/[^a-zA-Z0-9_-]/', '', $new);
	
	if(trim($new2) == '') {
	
		return trim($new);
	
	} else {
		
		return $new2;
		
	}
	
}

$grps = $grpsD = array();

$res = mysql_query("SELECT grp FROM prerlsdb GROUP BY grp") or die( mysql_error());  

while ($row = mysql_fetch_assoc($res)) {
	
	// trim colors
	//$g = preg_replace("/[^\x9\xA\xD\x20-\x7F]/", "", $row['grp']);
	
	//$new2 = preg_replace('/[^a-zA-Z0-9_-]/', '', trim($row['grp']));
	$new = str_replace('_', '', trim($row['grp']));
	$new1 = str_replace('-', '', trim($new));
	$new2 = preg_replace("/#\W#/", "", trim($new1));
	
	if(trim($new2) == '') {
	
		$grps[] = "(".trim($row['grp']).")";
		
	} else {
		
		$grpsD[] = $new2;
		
	}
}

print_r($grpsD);

//mysql_query("INSERT IGNORE INTO grps (name) VALUES ".join(",",$grps)) or die( mysql_error());

?>