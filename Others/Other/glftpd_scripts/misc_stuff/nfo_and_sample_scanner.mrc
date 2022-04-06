; This is the NFO and Sample scanner
; This is still experimental
; Version 0,1

alias tvcheck {
  set %ssite ENT-TV
  set %spath /TV/
  dll rushmirc.dll SetMircCmd /rlsstrip
  dll rushmirc.dll RushScript RushApp.FTP.RAW(' $+ %ssite %+ ','stat -l %spath $+ ',RS_LOGIN);
  /timer 1 7 unset %spath
  /timer 1 9 set %spath /TV-DVDRip/
  /timer 1 10 set %spath1 /TV-DVDRip/
  /timer 1 12 dll rushmirc.dll SetMircCmd /rlsstrip
  /timer 1 15 dll rushmirc.dll RushScript RushApp.FTP.RAW(' $+ %ssite %+ ','stat -l %spath1 $+ ',RS_LOGIN);
  /timer 1 19 set %bling ON 
  /timer 1 20 unset %spath
  /timer 1 22 set %spath2 /x264/
  /timer 1 23 set %spath /x264/
  /timer 1 24 dll rushmirc.dll SetMircCmd /rlsstrip
  /timer 1 25 dll rushmirc.dll RushScript RushApp.FTP.RAW(' $+ %ssite %+ ','stat -l %spath2 $+ ',RS_LOGIN);
  window -emz @Scanner
  aline @Scanner [ $time ] @ 9Now gathering releases
  /timer 1 40 /startscn
}

alias rlsstrip {
  if ($regex($2,^[d]) == 1) {
    if (@Nuked- isin $10) { halt } 
    if (_old isin $10) { halt }
    write C:\echofiles\samplecheck.txt %spath $+ $10 $10
  }
  if ($2 == 213) && ($3 == End) && ($4 == of) && ($5 == Status) && (%bling == ON) {
    write C:\echofiles\samplecheck.txt END
    set %bling OFF
  }
}

alias startscn {
  var %readout = $read(C:\echofiles\samplecheck.txt,1)
  if (END === %readout) { aline @Scanner [ $time ] @ All is 9DONE | write -dl1 C:\echofiles\samplecheck.txt | halt }
  set %rlpath $gettok($strip(%readout),1,32)
  set %rlnm $gettok($strip(%readout),2,32)
  dll rushmirc.dll SetMircCmd /sandntjeck
  dll rushmirc.dll RushScript RushApp.FTP.RAW(' $+ %ssite %+ ','stat -l %rlpath $+ ',RS_LOGIN);
  write -dl1 C:\echofiles\samplecheck.txt 
  set %nfo 2
  set %sample 2
  aline @Scanner [ $time ] @ %rlnm 9Is beeing testet
  /timer 1 6 /result
}

alias sandntjeck {
  if (.nfo isin $10) { set %nfo 1 }
  if ($regex($2,^[d]) == 1) {
    if (sample = $10) { set %sample 1 }
  }
  else { halt }
}

alias result {
  if (dirfix isin %relname) {
    if (1 === %nfo) { aline @Scanner [ $time ] @ %rlnm is OK }
  }
  if (nfofix isin %relname) {
    if (1 === %nfo) { aline @Scanner [ $time ] @ %rlnm is OK }
  }
  elseif (samplefix isin %relname) {
    if (1 === %nfo) { aline @Scanner [ $time ] @ %rlnm is OK }
  }
  elseif (2 === %nfo) && (2 === %sample) { aline @Scanner [ $time ] @ %rlnm 4is missing Sample and NFO }
  elseif (2 === %nfo) && (1 === %sample) { aline @Scanner [ $time ] @ %rlnm 4is missing NFO }
  elseif (1 === %nfo) && (2 === %sample) { aline @Scanner [ $time ] @ %rlnm 4is missing Sample }
  elseif (1 === %nfo) && (1 === %sample) { aline @Scanner [ $time ] @ %rlnm 9is OK }
  unset %rlpath
  unset %rlnm
  unset %nfo
  unset %sample
  /timer 1 10 /startscn
}