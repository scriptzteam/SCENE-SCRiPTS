/* -------------------------------------------------------------------------
 * lastxfer v2.1 - Scans xferlog, shows date of last UL/DL by specified user(s).
 * Copyright (C) 2000 jehsom@jehsom.com
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * -------------------------------------------------------------------------
 */

/* Put the location of your xferlog here */
#define LOG "/glftpd/ftp-data/logs/xferlog"

/* End of user configuration */

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <errno.h>
#include <string.h>
#include <time.h>

#define HUNKSIZE 1048576
#define PROGNAME "lastxfer: "

time_t dateconv( char *date ){
    time_t rc=0;
    int ctr, tmp;
    char monthstr[4];
    char daystr[3];
    char yearstr[5];
    struct tm tm;
   
    strncpy( monthstr, date, 4 );
    monthstr[3]='\0';
    date+=4;

    strncpy( daystr, date, 3 );
    daystr[2]='\0';
    date+=12;

    strncpy( yearstr, date, 5 );
    yearstr[4]='\0';

    tm.tm_sec=0;
    tm.tm_min=0;
    tm.tm_hour=0;
    tm.tm_mday=(int)strtol( daystr, NULL, 0 );
    if( strcmp( monthstr, "Jan" ) == 0 ) tm.tm_mon=0;
        else if( strcmp( monthstr, "Feb" ) == 0 ) tm.tm_mon=1;
        else if( strcmp( monthstr, "Mar" ) == 0 ) tm.tm_mon=2;
        else if( strcmp( monthstr, "Apr" ) == 0 ) tm.tm_mon=3;
        else if( strcmp( monthstr, "May" ) == 0 ) tm.tm_mon=4;
        else if( strcmp( monthstr, "Jun" ) == 0 ) tm.tm_mon=5;
        else if( strcmp( monthstr, "Jul" ) == 0 ) tm.tm_mon=6;
        else if( strcmp( monthstr, "Aug" ) == 0 ) tm.tm_mon=7;
        else if( strcmp( monthstr, "Sep" ) == 0 ) tm.tm_mon=8;
        else if( strcmp( monthstr, "Oct" ) == 0 ) tm.tm_mon=9;
        else if( strcmp( monthstr, "Nov" ) == 0 ) tm.tm_mon=10;
        else if( strcmp( monthstr, "Dec" ) == 0 ) tm.tm_mon=11;
    tm.tm_year=(int)strtol( yearstr, NULL, 0 )-1900;

    rc=mktime( &tm );
    return rc;
}


int main( int argc, char *argv[] ){
    FILE *fp;
    long start_offset, end_offset, curr;
    char *user, *group;
    char dir;

    if( argc < 2 ){
        fprintf( stderr, "Usage: %s user [user2 [...]]\n", argv[0] );
        return EXIT_FAILURE;
    }
    /* Open the logfile for reading */
    if( (fp=fopen(LOG, "r")) == NULL ){
        perror( PROGNAME LOG );
        return EXIT_FAILURE;
    }
    while ( *(++argv) != NULL ){
        int donewithuser=0;

        user=*argv;
        dir='\0';
        /* Go to the end of the file */
        if( fseek( fp, 0, SEEK_END ) == -1 ){
            perror( PROGNAME "fseek" );
            fclose(fp);
            return EXIT_FAILURE;
        }
        /* end_offset starts as the EOF offset */
        end_offset=ftell(fp);
        /* start_offset is the start of each read of size HUNKSIZE */
        start_offset=end_offset-HUNKSIZE;
        /* Keep reading a hunk at a time until we've read it all */
        while( start_offset > -HUNKSIZE ){
            char buf[HUNKSIZE];
            int i=0,j=0;

            /* Seek to start_offset or byte 0, whichever is larger */
            if( fseek( fp, (start_offset<0?0L:start_offset), SEEK_SET )) {
                perror( PROGNAME "fseek" );
                fclose(fp);
                return EXIT_FAILURE;
            }
            /* If we're only reading part of a block, adjust accordingly */
            if( start_offset < 0 ) {
                fread( buf-start_offset, 1, HUNKSIZE+start_offset, fp );
                i=-start_offset;
            } else {
                /* Else read an entire block normally */
                fread( buf, 1, HUNKSIZE, fp );
                /* Find the first newline; set i and start_offset. */
                while( buf[i] != '\n' ) {
                    i++; start_offset++;
                    if( i >= HUNKSIZE ){
                        fprintf( stderr, PROGNAME "Line too long. Increase HUNKSIZE\n");
                        fclose(fp);
                        return EXIT_FAILURE;
                    }
                }
                /* Advance i to the next char (first char of the first full line) */
                i++;
            }

            /* Start at the end of our buffer and search the fields backwards */
            curr=HUNKSIZE-1;
            while( curr > i ){
                /* Go to the 4th field from the end */
                for( j=0; j<3; j++ ){
                    buf[curr]='\0';
                    while( buf[curr] != ' ' ) curr--;
                }
                group=&buf[curr+1];
                buf[curr]='\0';
                while( buf[curr] != ' ' ) curr--;
                curr++;
                /* Compare this field to the user specified */
                if( strcmp(&buf[curr], user) == 0 ){
                    /* If dir == '\0', we have not found EITHER direction yet */
                    if( dir == '\0' ){
                        /* Direction character is 4 back */
                        dir=buf[curr-4];
                        while( buf[curr-1] != '\n' ) curr--;
                        curr+=4;
                        buf[curr+20]='\0';
                        printf( "%s@%s last %sloaded %d days ago.\n", user, group,
                            (dir=='i'?"up":"down"), (time(NULL)-dateconv(&buf[curr]))/86400 );
                    } else {
                        /* Else, this is the 2nd direction found. Adjust output */
                        if( buf[curr-4] != dir ){
                            while( buf[curr-1] != '\n' ) curr--;
                            curr+=4;
                            buf[curr+20]='\0';
                            printf( "    and %s@%s last %sloaded %d days ago.\n", user, group,
                                (dir=='o'?"up":"down"), (time(NULL)-dateconv(&buf[curr]))/86400 );
                            donewithuser=1; break;
                        } else {
                            while( buf[curr] != '\n' ) curr--;
                        }
                    }
                } else {
                    /* Back up to previous newline */
                    while( buf[curr] != '\n' ) curr--;
                }
            }
            if( donewithuser == 1 ) break;

            /* Get ready for next read */
            end_offset=start_offset;
            start_offset=end_offset-HUNKSIZE;
        }
        /* At this point, we haven't found entries for at least one direction */
        if( donewithuser == 0 )
            printf( "%sNo %sentries found for user %s.\n", (dir=='\0'?"":"    "),
            (dir=='i'?"download ":(dir=='o'?"upload ":"")), user);
    }
    fclose(fp);
    return EXIT_SUCCESS;
}

