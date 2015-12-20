<?php

function mksecret($len=5) {

	$salt = '';
	
	for ( $i = 0; $i < $len; $i++ ) {
	
		$num   = rand(33, 126);
		
		if ( $num == '92' ) {
			$num = 93;
		}
		
		$salt .= chr( $num );
		
	}
	
	return $salt;
	
}
	


function make_passhash_login_key($len=60) {

	$pass = mksecret( $len );
	
	return md5($pass);
	
}
	


function make_passhash($salt, $md5_once_password) {

	return md5( md5( $salt ) . $md5_once_password );
	
}

function generatePassword($length = 8) {
	$chars = '&&&abdefhiknrstyz???ABDEFGHKNQRSTYZ@@@123456789###';
	$numChars = strlen($chars);

	$string = '';
	for ($i = 0; $i < $length; $i++) {
		$string .= substr($chars, rand(1, $numChars) - 1, 1);
	}
	return $string;
}

?>
