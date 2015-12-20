<?php

// MySQL settings
$c['mysql_address'] 	= 'localhost';
$c['mysql_port']	= '3306';
$c['mysql_username']	= 'username';
$c['mysql_password']	= '';
$c['mysql_db']		= 'releases';



$c['mysql_conn'] = mysql_conn($c['mysql_address'], $c['mysql_username'], 
                              $c['mysql_password'], $c['mysql_db']);

$sql = "SELECT nfo FROM nfos WHERE releaseid = '".mysql_escape($_GET['id']).
       "' AND timeout >= ".time()."";
$nfo = sql_single($sql);

if ($nfo == null) { 
    die();
}

print_nfo(base64_decode($nfo));


function mysql_conn($host, $user, $pass, $db) {
    $conn = mysql_connect ($host, $user, $pass);

    if (!$conn) { 
        die ('Unable to connect mysql server: ' . mysql_error()); 
    }

    if (!mysql_select_db($db, $conn)) { 
        die ('Unable to select database: ' . mysql_error()); 
    }

    return $conn;
}


function sql_single ($sql) {
    $results = mysql_query($sql);	

    $x = 0;
    while ($row=mysql_fetch_array($results)) {
        $tulos = $row[0];
        $x++;
    }

    if ($x == 0) {
        return NULL;
    } else {
        return $tulos;
    }	
}


function mysql_escape($text) {
    if(get_magic_quotes_gpc()) {
        $text = stripslashes($text);
    }	
    return mysql_real_escape_string($text);
}


function sql_run($sql) {
    if (!mysql_query($sql)) {
        print_debug("MySQL error: " . mysql_error());
        return 0;
    }

    return 1;
}


function print_nfo($nfo, $colour=0, $background="0") { 
    /* 
       0 = white 
       1 = green 
       2 = amber 
       3 = white on blue 
       4 = deep red 
       5 = black on white 
       6 = silver 
       7 = gold 
       8 = rainbow 
       9 = blue 
     */                 
    if (!is_array($nfo)) { 
        $nfo = explode("\n", $nfo); 
    } 

    if (version_compare('4.0.6', phpversion()) == 1) { 
        echo 'This version of PHP is not fully supported. You need 4.0.6 or ' .
             'above.'; 
        exit(); 
    } 

    if (extension_loaded('gd') == false && !dl('gd.so')) { 
        echo 'You are missing the GD extension for PHP, sorry but I cannot ' .
             'continue.'; 
        exit(); 
    } 

    if (isset($background) == false) { 
        $red = 0; 
        $green = 0; 
        $blue = 0; 
    } 
    else { 
        $hex_bgc = $background; 
        $hex_bgc = str_replace('#', '', $hex_bgc); 

        switch (strlen($hex_bgc)) { 
            case 6: 
                $red = hexdec(substr($hex_bgc, 0, 2)); 
                $green = hexdec(substr($hex_bgc, 2, 2)); 
                $blue = hexdec(substr($hex_bgc, 4, 2)); 
                break; 

            case 3: 
                $red = substr($hex_bgc, 0, 1); 
                $green = substr($hex_bgc, 1, 1); 
                $blue = substr($hex_bgc, 2, 1); 
                $red = hexdec($red . $red); 
                $green = hexdec($green . $green); 
                $blue = hexdec($blue . $blue); 
                break; 

            default: 
                $red = 0; 
                $green = 0; 
                $blue = 0; 
        } 
    } 


    $fontpath = dirname(__FILE__); 

    if (file_exists("$fontpath/nfogen.png")) { 
        $fontset = imagecreatefrompng("$fontpath/nfogen.png"); 
    } 
    else { 
        echo "Aborting, cannot find the required fontset nfogen.png in ". 
             "path: $fontpath"; 
        exit(); 
    } 

    $x = 0; 
    $y = 0; 
    $fontx = 5; 
    $fonty = 12; 
    $colour = $colour * $fonty; 

    //Calculate max width and height of image needed 
    $image_height = count($nfo) * 12; 
    $image_width = 0; 

    //Width needs a loop through the text 
    for ($c = 0; $c < count($nfo); $c++) { 
        $line = $nfo[$c]; 
        $temp_len = strlen($line); 
        if ($temp_len > $image_width) { 
            $image_width = $temp_len; 
        } 
    } 

    $image_width = $image_width * $fontx; 
    $image_width = $image_width + 10; 

    //Sanity Checks 
    if ($image_width > 1600) { 
        $image_width = 1600; 
    } 

    $im = imagecreatetruecolor($image_width, $image_height); 
    $bgc = imagecolorallocate($im, $red, $green, $blue); 
    imagefill($im, 0, 0, $bgc); 

    for ($c = 0; $c < count($nfo); $c++) { 
        $x = $fontx; 
        $line = $nfo[$c]; 

        for ($i = 0; $i < strlen($line); $i++) { 
            $current_char = substr($line, $i, 1); 
            if ($current_char !== "\r" && $current_char !== "\n") { 
                $offset = ord($current_char) * 5; 
                imagecopy($im, $fontset, $x, $y, $offset, $colour, $fontx, 
                          $fonty); 
                $x += $fontx; 
            } 
        } 
        $y += $fonty; 
    } 

    header("Content-type: image/png"); 
    imagepng($im);
    imagedestroy($im); 

}     
?>
