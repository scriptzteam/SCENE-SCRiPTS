# AutoUP v9.66 Script made my Islander 
# Release date 18th March 2011
# D0 N0T SHAR3 & N0T F0R PUBLiC US3
# F0R T3STiNG PURP0SES 0NLY

Requires tcl8.4 , tclcurl , mktorrent and mysqltcl

Install all the necessary packages , mysql mysqltcl , tcl8.4 , buildessentails , curl , etc...

upload mktorrent directory and ftptable.sql to root directory

make sure you are loggedin as root use then cd to mktorrent folder then do "make" to compile mktorrent

then copy the mktorrent.o and mktorrent files to /usr/local/bin  and chmod both files to 755

Then login to mysql via putty and create a new database 
then run the below cmd where XX is your mysql root password

mysql -u root -pXX ftpdb < /root/ftptable.sql

now in a seperate user install eggdrop and edit the eggdrop.conf file load the rls-track.tcl to bot-1

and create a new .conf file and load createtorrent.tcl to bot-2

and create a new .conf file again and load autoup.tcl to bot-3

and make sure u make necessary changes in ALL the .tcl files and also category id's in autoup.tcl file

and make sure your glftpd or drftpd bot is in channel announcing new and complete releases..

and finally make changes in takeup-bot.php and downloadbot.php file seedbox ip address 
and autoupload bot user id in mysql query 
and upload this modified takeup-bot.php and downloadbot.php file to your site directory.

# E0F