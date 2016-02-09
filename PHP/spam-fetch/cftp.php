<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'func.php');

function filetypenumber($format) {
	
	$fnumber = 0;
	$format = trim($format);
	
	if($format == '') { return $fnumber; }
	
	if(preg_match('/^(r[a|0-9][r|0-9]|0[0-9]{1,2})$/i', $format)) {
		
		$fnumber = 1;
		
	} elseif($format == 'zip') {
		
		$fnumber = 2;
		
	} elseif($format == 'nfo') {
		
		$fnumber = 3;
		
	} elseif($format == 'diz') {
		
		$fnumber = 4;
		
	} elseif($format == 'sfv') {
		
		$fnumber = 5;
		
	} elseif($format == 'cue') {
		
		$fnumber = 6;
		
	} elseif($format == 'mkv') {
		
		$fnumber = 7;
		
	} elseif($format == 'm3u') {
		
		$fnumber = 8;
		
	} elseif($format == 'flac') {
		
		$fnumber = 9;
		
	} elseif($format == 'mpg') {
		
		$fnumber = 10;
		
	} elseif($format == 'mp2') {
		
		$fnumber = 11;
		
	} elseif($format == 'mp3') {
		
		$fnumber = 12;
		
	} elseif($format == 'mp4') {
		
		$fnumber = 13;
		
	} elseif($format == 'vob') {
		
		$fnumber = 14;
		
	} elseif($format == 'avi') {
		
		$fnumber = 15;
		
	} elseif($format == 'png') {
		
		$fnumber = 16;
		
	} elseif($format == 'jpg' || $format == 'jpeg') {
		
		$fnumber = 17;
		
	}/* elseif(preg_match('/^(r[a|0-9][r|0-9]|0[0-9]{1,2}|zip|mp[g|2|3|4]|vob|avi|png|jp[e]?g|nfo|diz|sfv|cue|mkv|m3u|flac)$/i', $format)) {
		
		$fnumber = 1;
		
	}*/
	
	return $fnumber;

}
	$section = 'MP3/0319';
	$rls = 'Joan_Franka-You_And_Me-WEB-2012-gnvr';
	
	$subdirexp = explode('/', $rls);
	
	$rlsname = trim($subdirexp[0]);
	
	$subdir = (isset($subdirexp[1]) && trim($subdirexp[1]) != '') ? trim($subdirexp[1]).'/' : '';
	
    $username = 'xxx'; 
    $password = 'xxx'; 
	$sitename = 'xxx'; 
    $url = 'ftpd.example.com:34591/'.$section.'/'.$rlsname.'/'.$subdir; 
    $ftp_server = "ftp://" . $username . ":" . $password . "@" . $url; 
    
    //echo "Starting CURL.\n"; 
    $ch = curl_init(); 
    //echo "Set CURL URL.\n"; 
    
    //curl FTP 
    curl_setopt($ch, CURLOPT_URL, $ftp_server); 
    
    //For Debugging 
    //curl_setopt($ch, CURLOPT_VERBOSE, TRUE);    
    
    //SSL Settings 
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE); 
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE); 
    curl_setopt($ch, CURLOPT_FTP_SSL, CURLFTPSSL_TRY); 
    
    //List FTP files and directories 
    //curl_setopt($ch, CURLOPT_FTPLISTONLY, TRUE); 
    
    //Output to curl_exec 
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 

    //echo "Executing CURL.\n"; 
    $output = curl_exec($ch); 
    curl_close($ch); 
    //echo "Closing CURL.\n"; 
    //echo $output . "\n"; 
	
	//if (trim($files) == '') { return; }
	
	$files = explode("\n", trim($output));

	if (count($files)) {
		
		$final = array();
		
		foreach ($files AS $filedata) {
		
			$fdata = explode(" ", trim($filedata));
			
			$ffin = array();
			
			foreach ($fdata AS $fdatatrimed) {
				
				if(trim($fdatatrimed) != '')
				$ffin[] = trim($fdatatrimed);
				
			}
			
			$ffd = join(" ", $ffin);

			//-rw-r--r-- 1 xxx iND 50000000 Mar 19 09:16 heartland.ca.s05e17.720p.hdtv.x264-2hd.r05
			//-rw-r--r--   1 xxx      iND          1431 Mar 19 09:16 heartland.ca.s05e17.720p.hdtv.x264-2hd.sfv

			preg_match('/^-.*- [0-9] (.*?) (.*?) ([0-9]+) .* [0-9]{2} [0-9]{2}:[0-9]{2} (.*?)\.(r[a|0-9][r|0-9]|0[0-9]{1,2}|zip|mp[g|2|3|4]|vob|avi|png|jp[e]?g|nfo|diz|sfv|cue|mkv|m3u|flac)$/i', $ffd, $matches);
			
			if(isset($matches[1]) && isset($matches[2]) && isset($matches[3]) && isset($matches[4]) && isset($matches[5]) && trim($matches[1]) != '' && trim($matches[2]) != '' && trim($matches[3]) != '' && trim($matches[4]) != '' && trim($matches[5]) != '')
			$final[] = "(".sqlesc(trim($rlsname)).",".((trim($subdir) != '') ? sqlesc(trim($subdir))."," : '').sqlesc(trim($sitename)).",".time().",".sqlesc(trim($matches[3])).",".sqlesc(trim($matches[4].'.'.$matches[5])).",".sqlesc(filetypenumber($matches[5])).",".sqlesc(trim($matches[1])).",".sqlesc(trim($matches[2])).")";
		
		}
		
		//sort($files, SORT_REGULAR);
   
		print(join(' ', $final)); 
	
	}
  
?>