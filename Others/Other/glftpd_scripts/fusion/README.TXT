
   fsSTATS v1.0.030616 - by fusion (fs2oo2@yahoo.com)
  --------------------------------------------------------------

   a replacement for the glftpd stats binary.

   advantages? this shows the user's group, and it's very easy
   to customize for anyone that knows a little tcl coding :)

   also, this can be used to make up the many missing group
   stat commands in glftpd's stat binary (eg. group-dayup,..)

   fsUStats.tcl         - user stats (wkup, dayup, etc.)
   fsGStats.tcl         - group stats (gpwk, gpal, etc.)

   all configuration is done at the top of the .tcl files.
   pretty self explanatory.

   run fs(U/G)Stats.tcl without any arguments to see how it
   works.

   to use these scripts instead of the default glftpd 
   'site wkup/dayup/etc' commands, put this in your glftpd.conf:

   site_cmd WKUP      EXEC /bin/fsUStats.tcl -w[:space:]-u
   site_cmd WKDN      EXEC /bin/fsUStats.tcl -w[:space:]-l
   site_cmd MONTHUP   EXEC /bin/fsUStats.tcl -m[:space:]-u
   site_cmd MONTHDN   EXEC /bin/fsUStats.tcl -m[:space:]-l
   site_cmd DAYUP     EXEC /bin/fsUStats.tcl -d[:space:]-u
   site_cmd DAYDN     EXEC /bin/fsUStats.tcl -d[:space:]-l
   site_cmd ALUP      EXEC /bin/fsUStats.tcl -a[:space:]-u
   site_cmd ALDN      EXEC /bin/fsUStats.tcl -a[:space:]-l
   site_cmd GPWK      EXEC /bin/fsGStats.tcl -w[:space:]-u
   site_cmd GPWD      EXEC /bin/fsGStats.tcl -w[:space:]-l
   site_cmd GPMN      EXEC /bin/fsGStats.tcl -m[:space:]-u
   site_cmd GPMD      EXEC /bin/fsGStats.tcl -m[:space:]-l
   site_cmd GPDY      EXEC /bin/fsGStats.tcl -d[:space:]-u
   site_cmd GPDD      EXEC /bin/fsGStats.tcl -d[:space:]-l
   site_cmd GPAL      EXEC /bin/fsGStats.tcl -a[:space:]-u
   site_cmd GPAD      EXEC /bin/fsGStats.tcl -a[:space:]-l

   custom-wkup      !8 *
   custom-wkdn      !8 *
   custom-monthup   !8 *
   custom-monthdn   !8 *
   custom-dayup     !8 *
   custom-daydn     !8 *
   custom-alup      !8 *
   custom-aldn      !8 *
   custom-gpwk      !8 *
   custom-gpwd      !8 *
   custom-gpmn      !8 *
   custom-gpmd      !8 *
   custom-gpdy      !8 *
   custom-gpdd      !8 *
   custom-gpal      !8 *
   custom-gpad      !8 *

   .. and you probably want to edit your 'site help' output
   to include these lines:

   DAYUP: Today's Top Uploaders                                        
   DAYDN: Today's Top Downloaders    
   WKUP: Show Weektop Uploaders                                       
   WKDN: Show Weektop Downloaders                                     
   MONTHUP: Show MonthTop Uploaders                                      
   MONTHDN: Show MonthTop Downloaders        
   ALUP: Show Alltime Uploaders                                       
   ALDN: Show Alltime Downloaders                                     
   GPDY: Today's Top Uploading Group
   GPDD: Today's Top Downloading Group                        
   GPWK: Show Weektop Groups                                          
   GPWD: Show Weektop Group Downloaders      
   GPMN: Show Monthtop Groups
   GPMD: Show Monthtop Group Downloaders
   GPAL: Show Alltime Top Groups                                      
   GPAD: Show Alltime Top Group Downloaders   

   Of course, you can always rename to commands to whatever
   you like.

   If you find any bugs or have any problems, just drop me a
   line at fs2oo2@yahoo.com.

                                          - fusion (2003.06.16)

  --------------------------------------------------------------
