# PREBOT FOR IRSSI
This is here for historical purposes. I'm surprised if anyone finds any
usage for this.

## ABOUT

I was browsing an old hard drive and happened to find these old scripts 
for irssi that implement prebot functionality. If you don't know what
I am talking about then you have no need whatsoever for these. I haven't 
ran these in years and have no clue whatsoever if they can be used at all
these days. The code is messy and violates all princibles of good software
design. Also it's most likely vulnerable to all sorts of SQL injection 
so consider yourself warned. I will provide scripts as is and will offer 
no support setting them up. All I can remember that scripts used to work 
well enough back in the good days.

The scripts consist of to "irssi scripts" one for saving information
from IRC and another one for doing queries from the database. There
are also simple php scripts for displaying files on web server.
Those scripts are located in www directory.

## DIRECTORIES

### src/
Irssi scripts implementing prebot functionality. Also file describing 
database schema is here.

### www/
Scripts used to create images out of files and display them over http.

## DATABASE SCHEMA

Expected database schema can be found in db_schema.txt file. A word of i
caution as the size of the database will grow rather large once you have 
enough files stored in it.

## INSTALLATION

Please read about section again. Repeat if necessary.

## LICENCE

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
Version 2, December 2004

Copyright (C) 2006 Janne Haapsaari <haaja@iki.fi>

Everyone is permitted to copy and distribute verbatim or modified
copies of this license document, and changing it is allowed as long
as the name is changed.

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

You just DO WHAT THE FUCK YOU WANT TO.
