/*
 *
 * cruxis was here
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <time.h>

int main(int argc, char *argv[]) {
	  struct stat filestats;

	    if((argc != 2) || (stat(argv[1], &filestats) == -1)) {
		        printf("Sat Jan  1 00:00:00 2003\n");
			    exit(EXIT_FAILURE);
			      }

	      printf("%s", ctime(&filestats.st_mtime));
	        exit(EXIT_SUCCESS);
}

