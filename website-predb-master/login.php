<?php
require_once(__DIR__.DIRECTORY_SEPARATOR.'includes'.DIRECTORY_SEPARATOR.'functions.php');
userlogin();

    if (Isy_user::$current) {
        header("Location: {$CONFIG['baseurl']}/index.php");
        die();
    }
	
	if ($_SERVER["REQUEST_METHOD"] == "POST") {
		
		require_once(INCL_DIR.'password_functions.php');
		
		$username = trim($_POST['username']);
		$password = $_POST['password'];

		$res = mysql_query("SELECT id, passhash, secret, enabled FROM users WHERE name = " . sqlesc($username)) or sqlerr(__FILE__,__LINE__);
		$row = mysql_fetch_assoc($res);

		if (!$row)
		die('Username Invalid');

		if ($row['passhash'] != make_passhash( $row['secret'], md5($password) ) )
		die('Password Incorrect');

		if ($row['enabled'] == 'no')
		die('Disabled User');

		logincookie($row['id'], $row['passhash']);

		header("Location: {$CONFIG['baseurl']}/index.php");
	
	}

$HTMLOUT = '';

$HTMLOUT .= '<!DOCTYPE html PUBLIC \'-//W3C//DTD XHTML 1.0 Transitional//EN\'
		\'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\'>
		
		<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
			
			<title>'.$CONFIG['sitename'].' :: Login</title>
			<link rel="SHORTCUT ICON" href="favicon.ico">
			<link rel="stylesheet" href="' . $CONFIG['static_server'] . 'static/bootstrap.min.css" type="text/css" />
			<link rel="stylesheet" href="' . $CONFIG['static_server'] . 'static/default.css" type="text/css" />
		</head>
		    <body>
			<div class="container"><div class="row">

    
	
    

        <div class="span8 offset4">
            <div class="clearfix">
                <h1 id="flat-logo">'.$CONFIG['sitename'].'</h1>
            </div>
            
            
<div id="login">
<form action="" method="POST" class="search-form">
    
    
    <h2>Sign in</h2>
	  
        <fieldset class="control-group">
          
            <input class="span2" type="text" name="username" placeholder="Username" autofocus>&nbsp;
            <input class="span2" type="password" name="password" placeholder="Password" required>
          
		  </fieldset>
		  
		  <hr />
		  
		  <fieldset>
		<button class="btn primary" type="submit"><i class="ok"></i>&nbsp;Sign in</button>
		&nbsp;
		<button type="reset" class="btn"><i class="remove"></i>&nbsp;Cancel</button>
        </fieldset>
      </form>

   

</div>

	
	<footer>
        <p>&copy; '.$CONFIG['sitename'].' 2012</p>
      </footer>

    </div></div></body></html>
	';
	
	echo $HTMLOUT;


?>
