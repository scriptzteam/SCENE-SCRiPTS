proc prebot:pubcmd:getbetween {qnick uhost hand chan arg} {
	global db sqlhand put nick site
  set tstart [clock clicks -milliseconds]
  set max $site(prebot,addold,max)
  if { ! [channel get $chan addold]} { return 0 }
  if { $arg == "" } {
    $put(slow) "PRIVMSG $chan :Syntax: !${nick}play \[--between <release1> <release2>\] \[\[--s <nr>\] <pattern>\]"
    return 0
  } elseif {[lindex $arg 0] == "--between"} {
    set sfound [lsearch -exact $arg "--s"]
    if {$sfound != -1} {
      set first [lindex $arg [expr $sfound+1]]
      set max [expr $site(prebot,addold,max)+$first]
      set arg [lrange $arg $sfound [expr $sfound+1]]
    } {
      set first 0
    }
    set rel1 [lindex $arg 1]
    set rel2 [lindex $arg 2]
    if { $rel1 == "" || $rel2 == "" } { putlog "first or last release is missing" ; return 0 }
    set timestart [lindex [::mysql::sel $sqlhand "select rel_time from pres where rel_name='$rel1' order by rel_time asc limit 0,1" -list] 0]
    set timeend [lindex [::mysql::sel $sqlhand "select rel_time from pres where rel_name='$rel2' order by rel_time desc limit 0,1" -list] 0]
    if {$timestart == 0 || $timestart == ""} {putlog "Error: no starttime"; return 0}
    if {$timeend == 0 || $timeend == ""} {putlog "Error: no endtime"; return 0}
    if {$timestart > $timeend} {putlog "Error: starttime is after endtime"; return 0}
    set numstring "SELECT count(*) FROM `$db(pre)` WHERE rel_time>=$timestart AND rel_time <= $timeend"
    set querystring "SELECT rel_id,rel_name,rel_section,nuked,rel_time,rel_files,rel_size,rel_genre FROM `$db(pre)` WHERE rel_time>=$timestart AND rel_time <= $timeend ORDER BY rel_time ASC limit $first,$max"
  } elseif { $arg != "" } {
    if {[lindex $arg 0] == "--s"} {
      set first [lindex $arg 1]
      set numstring "SELECT count(*) FROM `$db(pre)` WHERE rel_name like '[string map {"*" "%"} [join [lrange $arg 2 e] %]]'"
      set querystring "SELECT rel_id,rel_name,rel_section,nuked,rel_time,rel_files,rel_size,rel_genre FROM `$db(pre)` WHERE rel_name like '[string map {"*" "%"} [join [lrange $arg 2 e] %]]' order by rel_time ASC limit $first,$max"
    } else {
      set first 0
      set numstring "SELECT count(*) FROM `$db(pre)` WHERE rel_name like '[string map {"*" "%"} [join $arg %]]'"
      set querystring "SELECT rel_id,rel_name,rel_section,nuked,rel_time,rel_files,rel_size,rel_genre FROM `$db(pre)` WHERE rel_name like '[string map {"*" "%"} [join $arg %]]' order by rel_time ASC limit 0,$max"
    }
  } else {
    putlog "Something went wrong in !${nick}play --between ... ..."
    return 0
  }
  
  set num [lindex [::mysql::sel $sqlhand $numstring -list] 0]
  set storing1 [::mysql::sel $sqlhand $querystring -list]
  if {[llength $storing1] == 0} {	return 0  }
  set cnt 0
  $put(slow) "PRIVMSG $chan :Found $num results. Listing result $first to [expr $first+$max]."
  foreach row $storing1 {
    foreach {rel_id release section nuked reltime files size genre} $row {
      if {$genre == ""} {set genre "-"}
      if { [expr $nuked%2] == 1 } {
        set nreason [lindex [lindex [::mysql::sel $sqlhand "SELECT n_id,rel_id,n_reason,n_time,unnuked FROM `$db(nuke)` WHERE rel_id = '$rel_id' AND unnuked='N' ORDER BY n_id DESC limit 0,1" -list] 0] 2]
      } else { set nreason "-" }
      $put(slow) "PRIVMSG $chan :!addold $release $section $reltime $files $size $genre $nreason"
      incr cnt
      if {[expr $cnt%20]==0} {after 1000}
    }
  }
  if {$num > [expr $first+$max]} {
    set countedres [expr $first+$max]
  } else {
    set countedres [expr $num-$first]
  }
  $put(slow) "PRIVMSG $chan :finnished listing $first to $countedres out of $num results"
  putlog "--------- prebot:pubcmd:getbetween [expr [clock clicks -milliseconds] - $tstart] ms. ----------"
  return 0
}

proc isAddNFO {nick uhost handle channel arg} {
    if {[channel get $channel nfocmds]} {
      regsub -all -- {\003[0-9]{0,2}(,[0-9]{0,2})?|\017|\037|\002|\026|\007} $arg {} arg; set rls [lindex [split $arg] 0]
      if {[string match {*/*} $rls]} {return 0}
      if {![cache:find "addnfo" $rls]} { set fn [lindex $arg 2]
        if {[isEND $fn]==1} { variable conn; variable table
          if {![::mysql::sel $conn "SELECT COUNT(*) FROM `$table(nfo)` WHERE rls ='[mysqlescape $rls]'" -flatlist]} {
            if {[regexp -nocase {^000?[\_\-]} $fn]} {return 0}
            set url [lindex $arg 1]; set f1 "$table(tmp)$fn"
            if {[string match -nocase "https*" $url]} { ::http::register https 443 ::tls::socket }
            set token [::http::geturl $url -timeout 5000]; set f [open $f1 w]; fconfigure $f -translation binary; puts -nonewline $f [::http::data $token]; close $f; ::http::cleanup $token; set size [file size "$f1"]
	    if {$size > 10} {
              set f2 "$table(tmp)${fn}.gz"; compressfile -level 9 $f1 $f2; set fid [open "$f2" r]; fconfigure $fid -translation binary; set fsize [file size "$f2"]; set data [read $fid $fsize]; close $fid; set date [clock seconds]
              ::mysql::exec $conn "INSERT INTO `$table(nfo)` (`id`,`rls`,`nfo`,`fn`,`hits`) VALUES (NULL,'[mysqlescape $rls]','[mysqlescape $data]','$fn','0')"  
              ::mysql::exec $conn "INSERT INTO `$table(log)` (`id`,`cmd`,`rls`,`date`,`added`,`chan`,`network`) VALUES (NULL,'2','[mysqlescape $rls]','$date','[mysqlescape $nick]','[mysqlescape $channel]','[mysqlescape $::network]')"
              cache:add "addnfo" $rls
              file delete -force $f2
            }
            file delete -force $f1
          }
        }
      }
    }
  }