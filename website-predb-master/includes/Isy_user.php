<?php

class Isy_user {

	public static $current = NULL;

	public static function prepare_curuser(&$user) {
		if (empty($user))
			die;

		$user['id'] 			= 0 + $user['id'];
		$user['name'] 			= $user['name'];
		$user['ip'] 			= $user['ip'];
		$user['added'] 			= 0 + $user['added'];
		$user['lastseen'] 		= 0 + $user['lastseen'];
		$user['enabled'] 		= $user['enabled'];
	}
	
}

?>
