<?php

$row = file_get_contents('/usr/local/apache2/htdocs/www/spam-fetch/codes.txt');

$foo = $zoo = array();

foreach(explode('#',$row) as $tempw) {

	list($bibliographic,$terminologic,$alpha2,$english,$french) = explode('|',trim($tempw));
	
	if($english != '') {
	
		$eng = explode(';',$english);
		
		$bibliographic = strtoupper(trim($bibliographic));
		$terminologic = strtoupper(trim($terminologic));
		$alpha2 = strtoupper(trim($alpha2));
		$english = strtoupper(trim($english));
		
		if(count($eng) > 1) {
			
			foreach($eng as $tempeng) {
				
				$tempeng = strtoupper(trim($tempeng));
				
				$foo[] = array('bbg' => $bibliographic, 'name' => $tempeng);
				$zoo[] = array('2code' => $alpha2, 'name' => $tempeng);
			
			}
		
		} else {

			$foo[] = array('bbg' => $bibliographic, 'name' => $english);
			$zoo[] = array('2code' => $alpha2, 'name' => $english);
		
		}
	
	}

}

echo '<pre>';
print_r($foo);
print_r($zoo);
echo '</pre>';

?>