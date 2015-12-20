<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'includes'.DIRECTORY_SEPARATOR.'functions.php');
require_once(INCL_DIR.'password_functions.php');
loggedinorreturn();

if (Isy_user::$current['id'] != 1) { die('No Access'); }
	
	if ($_SERVER["REQUEST_METHOD"] == "POST") {
		
		require_once(INCL_DIR.'password_functions.php');
		
		$username = trim($_POST['username']);
		$password = $_POST['password'];
		$secret = mksecret();
		$wantpasshash = make_passhash( $secret, md5($password) );
		//$editsecret = make_passhash_login_key();

		mysql_query('INSERT INTO `users` (name, added, lastseen, passhash, secret) VALUES ('.sqlesc($username).', '.time().', '.time().', '.sqlesc($wantpasshash).', '.sqlesc($secret).')') or sqlerr(__FILE__,__LINE__);
		
		
		echo stdhead();
		
		echo 'User '.$username.' successfully added to database.';
	
		echo stdfoot();
	
	} else {
		
		echo stdhead();
		
		echo '<div id="login">
		<form action="" method="POST" class="search-form">
			
			<h2>Add New User</h2>
			  
				<fieldset class="control-group">
				  
					<input class="span2" type="text" name="username" placeholder="Username" autofocus>&nbsp;
					<input class="span2" type="password" name="password" placeholder="Password" required>
					<div>Random generated Password: <strong>'.generatePassword().'</strong></div>
				  </fieldset>
				  
				  <hr />
				  
				  <fieldset>
				<button class="btn primary" type="submit"><i class="ok"></i>&nbsp;Add User</button>
				&nbsp;
				<button type="reset" class="btn"><i class="remove"></i>&nbsp;Cancel</button>
				</fieldset>
			  </form>

		</div>';
	
		echo stdfoot();
		
	}
	
?>
