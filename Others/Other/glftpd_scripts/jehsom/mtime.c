/* mtime.c, by Jehsom.
 * Shows the modification time of a file in epoch time.
 * This software is property of the public domain.
 */
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <time.h>
#include <strings.h>

#define TIMELEN 300

int main( int argc, char *argv[] ){
	char mtime[TIMELEN];
	struct stat filestats;

	if( argc < 2 ){
		fprintf( stderr, "Usage: %s file [file2 [file3 [...]]]\n", argv[0] );
		return 1;
	}

	while( argv[1] != NULL ) {
        if( stat(argv[1], &filestats) == -1 ) {
		    fprintf( stderr, "Could not open %s.\n", argv[1] );
        }
	    printf( "%d %s\n", filestats.st_mtime, argv[1] );
        argv++;
	}
	return 0;
}	
