CREATE TABLE `ftprls` (
`id` INT( 11 ) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`rlsname` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
`category` VARCHAR( 25 ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
`grp` VARCHAR( 50 ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
`unixtime` INT( 11 ) NOT NULL DEFAULT '0',
`nfofilename` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL ,
`subs` ENUM( 'yes', 'no' , 'done' ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'no' ,
`sample` ENUM( 'yes', 'no' ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'no' ,
`complete` ENUM( 'yes', 'no' ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'no',
INDEX ( `category` ) ,
INDEX ( `grp` ) ,
INDEX ( `subs` ) ,
INDEX ( `sample` ) ,
INDEX ( `complete` ) ,
UNIQUE ( `rlsname` )
) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_unicode_ci;


 CREATE TABLE `ftpsubs` (
`id` INT( 11 ) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`rlsname` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
`subdir` VARCHAR( 100 ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
`unixtime` INT( 11 ) UNSIGNED NOT NULL DEFAULT '0',
`preid` INT( 11 ) UNSIGNED NOT NULL DEFAULT '0',
`complete` ENUM( 'yes', 'no' ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL DEFAULT 'no',
INDEX ( `rlsname` ) ,
INDEX ( `subdir` ) ,
INDEX ( `complete` )
) ENGINE = MYISAM CHARACTER SET utf8 COLLATE utf8_unicode_ci;
