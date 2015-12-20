<?php

$id = $_GET['id'];
$host="http://yourhos.st";
print_header($id);

function print_header($id) {
    echo "<?xml version=\"1.1\" encoding=\"UTF-8\" ?>
        <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" 
        \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">
        <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"fi\">

        <head>
            <title>T0P S3CR3T</title>
            <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
            <meta name=\"robots\" content=\"noarchive\" />
            <link rel='stylesheet' type='text/css' href='style.css' />
        </head>
        <body>
            <div class=\"content\">
                <img src=\"$host/nfo/nfo.php?id=$id\" alt=\"nfo\" />
            </div>
        </body>
        </html>
        ";
}

?>
