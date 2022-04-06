/* -------------------------------------------------------------------------
 * chksfv - Used by jehsom's zipscript to read sfv/crc information
 *          see usage information for instructions.
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


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <dirent.h>
#include <ctype.h>
#include <sys/types.h>

#ifndef PATH_MAX
#define PATH_MAX 4095
#endif

static char *getcrc( char *in ){
	char *out;

	if(!in) return NULL;

	out=in + strlen(in);
	while( *out != ' ' && out > in) out--;
	out++;
	if( strlen(out) < 8 ) return NULL;
	*(out+8)='\0';
	return out;
}

int main( int argc, char *argv[] ){
	FILE *fp;
	DIR *dp;
	char *cp;
	char *name=NULL;
	struct dirent *entry;
	char *linebuf;
	int len;
	char *infname, *incrc;
	char *sfvcrc;
	int rc=1;
	char message[500];
	int count=0;

	if( argc == 1 ){
		fprintf( stderr, 
			"Usage:\n"
			" %s <filename> <32bit_crc>\n"
			"    Verifies that the supplied CRC is correct by the sfv.\n"
			"    Return code 0: CRCs match. RC 2: CRCs differ. RC 3: error.\n"
			" %s <filename>\n"
			"    Shows the CRC value for the specified file in the sfv.\n"
			"    Returns 0 on success, and 1 on any error.\n"
			" %s -c\n"
			"    Shows a count of all the files in the sfv.\n"
			" %s -l\n"
			"    Lists all the files in the sfv, one per line.\n\n"
            "If $sfv contains the name of a valid file, that file is used\n"
            "  as the sfv. Otherwise, the first sfv found is used.\n"
				, argv[0], argv[0], argv[0], argv[0] );
		return rc;
	}

	infname=argv[1];
	incrc=argv[2];

	/* Open the dir */
	if( (dp=opendir(".")) == NULL ){
		fprintf( stderr, "Could not open current directory for reading.\n" );
		return rc;
	}
	
	/* Find the sfv */
	if( (name=getenv( "sfv" )) == NULL || access(name, F_OK|R_OK) == -1 ){
		while( (entry=readdir(dp)) ){
			len=strlen(entry->d_name);
			cp=entry->d_name;
			if( tolower(cp[len-1]) == 'v' &&
				tolower(cp[len-2]) == 'f' &&
				tolower(cp[len-3]) == 's' &&
				cp[len-4] == '.' ){
				name=cp;
				break;
			}
		}
	}
	if(!name){
		fprintf( stderr, "Could not find an sfv file in the current directory.\n" );
		return rc;
	}

	/* Open the sfv for reading */
	if( (fp=fopen(name, "r")) == NULL ){
		fprintf( stderr, "Could not open file %s.\n", name );
		return rc;
	}

	/* Make space to read a line */
	if( (linebuf=malloc(PATH_MAX)) == NULL ){
		fprintf( stderr, "Could not malloc.\n" );
		return rc;
	}
	
	/* Make a copy of our pointer */
	cp=linebuf;
	message[0]='\0';
	
	/* Read line by line and look for matching record */
	while( (cp=fgets(cp, PATH_MAX, fp)) ){
		if( *cp == ';' || strlen(cp) < 8 ) continue;
		count++;
		if( strcmp( infname, "-l" ) == 0 ) {
			if( *cp == '\0' ) continue;
			if( strrchr( cp, ' ' ) ) *(strrchr( cp, ' ' ))='\0';
			printf( "%s\n", cp );
			rc=0;
			continue;
		} else {
			if( cp[strlen(infname)] != ' ' ||
				strncasecmp(infname, cp, strlen(infname)) ) continue;
			if( argv[2] == NULL ){
				if( incrc=getcrc(cp) ){
					printf( "%s\n", incrc );
					rc=0;
				}else{
					sprintf( "Invalid SFV entry for file %s.\n", infname );
				}
			} else if( strcasecmp( incrc, sfvcrc=getcrc(cp) ) == 0 ){
				strcpy( message, "File CRCs match.\n" );
				rc=0;
			} else {
				strcpy( message, "CRCs differ.\n" );
				rc=2;
			}
		}
	}

	if( strcmp( infname, "-c" ) == 0 ){
		printf( "%d\n", count );
		rc=0;
		strcpy( message, "" );
	}

	if( rc == 1 && !message[0]){
		strcpy( message, "Could not find a matching record for specified file.\n" );
	}
	fclose(fp);
	fprintf( stderr, message );
	return rc;
}
