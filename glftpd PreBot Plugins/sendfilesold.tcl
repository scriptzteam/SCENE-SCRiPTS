#!/usr/bin/tclsh

if {[llength $argv] != 4} {puts "Invalid arguments passed to script!" ; exit 2}

package require TclCurl

set addfileurl "http://example.com/prefilesadd.php"
set dir(glroot) "/jail/glftpd"

set type [lindex $argv 0]
set rlsname [lindex $argv 1]
set filepath [lindex $argv 2]
set filename [lindex $argv 3]

if { $rlsname == "" || $filepath == "" || $filename == "" } {
	exit 0;
}

proc checkpath {path} {
   if {![file readable $path]} {
      echo "Bitch at the sysop, because he has\nabsolutely no idea how to setup this script!" ; exit 0
   }
}

set file $dir(glroot)$filepath$filename

checkpath $file

proc filesend { type rlsname fullpath filename } {
global addfileurl
	
	set fromnet "xxx:unknown:xxx"
	
	curl::transfer -url $addfileurl -timeout 3 -bodyvar hashdata -verbose 1 -post 1 -httppost [list name "rlsname"  contents $rlsname] -httppost [list name "type"  contents $type] -httppost [list name "filename"  contents $filename] -httppost [list name "fromnet" contents $fromnet] -httppost [list name "data" file $fullpath] -followlocation 1 -maxredirs 1 -useragent "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2b5) Gecko/20091204 Firefox/3.6b5 GTB7.0" -httpheader "Expect: "

	exit 0

}

filesend $type $rlsname $file $filename


exit 0
