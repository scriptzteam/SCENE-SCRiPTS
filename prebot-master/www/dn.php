<?php

// MySQL settings
$c['mysql_address']     = 'localhost';
$c['mysql_port']	= '3306';
$c['mysql_username']	= 'username';
$c['mysql_password']	= 'password';
$c['mysql_db']		= 'db_name';


$c['mysql_conn'] = mysql_conn($c['mysql_address'], $c['mysql_username'], 
                              $c['mysql_password'], $c['mysql_db']);


$sql = "SELECT nfo, nfoname FROM nfos WHERE releaseid = '".
       mysql_escape($_GET['id'])."' AND timeout >= ".time()."";
$result = sql_single($sql);

if ($result == null) { 
    die();
}

load_headers($result[1]);
print base64_decode($result[0]);

die();


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


function sql_single($sql) {
    $results = mysql_query($sql);	

    $x = 0;
    while ($row = mysql_fetch_array($results)) {
        $result = array($row[0], $row[1]);
        $x++;
    }

    if ($x == 0) {
        return NULL;
    } else {
        return $result;
    }	
}


function mysql_escape($text) {
    if(get_magic_quotes_gpc()) {
        $text = stripslashes($text);
    }	
    return mysql_real_escape_string($text);
}


function load_headers($name) {
    $expires = 60;

    header("Pragma: public");
    header("Cache-Control: maxage=".$expires.", must-revalidate");
    header('Expires: ' . gmdate('D, d M Y H:i:s', time()+$expires) . ' GMT');
    header("Content-Type: application/force-download");
    header("Content-Type: application/octet-stream");
    header("Content-Type: application/download");

    $a[0] = array('Ä','ä','Ö','ö','Å','å');
    $a[1] = array('A','a','O','o','A','a');
    $name = str_replace($a[0], $a[1], $name);
    header("Content-Disposition: attachment; filename=".$name.";");
    header("Content-Transfer-Encoding: binary");
}

?>
