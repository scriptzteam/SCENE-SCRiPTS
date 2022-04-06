#include <sys/param.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <syslog.h>
#include <sys/file.h>
#include <fcntl.h>
#include <dirent.h>
#include <stdio.h>
#include <time.h>
#include "glconf.h"

char * read_conf_datapath ( char *rootpath, char *confpath ) {
  FILE *fp;
  char datapath[255];
  char temp[255];
  if((fp = fopen(confpath, "r")) == NULL)
    return 0;

  while (fscanf(fp, "%s", temp) == 1) {
    if (strcmp(temp, "rootpath") == 0) {
      fscanf(fp, "%s", rootpath);
    }
    if (strcmp(temp, "datapath") == 0) {
      fscanf(fp, "%s", datapath);
      strcat(rootpath, datapath);
      return rootpath;
    }
  }
fclose(fp);
return 0;
}

/* GreyLine's Code.. I'm to layze to code my own */

void hms_format(time_t dirtime, char *dhmbuf ) /*added the second param */
{

 	time_t timenow = time(NULL);
	time_t difftime;
	int days = 0;
	int hours = 0;
	int minutes = 0;
	int seconds = 0;

	difftime = timenow - dirtime;

	while(difftime >= (time_t)86400)
	{
		difftime -= (time_t)86400;
		days++;
	}
	while (difftime >= (time_t)3600)
	{
		difftime -= (time_t)3600;
		hours++;
	}
	while(difftime >= (time_t)60)
	{
		difftime -= (time_t)60;
		minutes++;
	}
	seconds = (int)difftime;
	if (days != 0)
		sprintf(dhmbuf, "%2dd %2dh", days, hours);
	else if (hours != 0)
		sprintf(dhmbuf, "%2dh %2dm", hours, minutes);
	else
		sprintf(dhmbuf, "%2dm %2ds", minutes, seconds);
}

int main ( int argc, char *argv[]) {
   FILE *fp;
   char config_file[255] = GLCONF;
   char datapath[255], dirlogfile[255];
   struct dirlog buffer;

   read_conf_datapath(datapath, config_file);
   
   sprintf(dirlogfile, "/ftp-data/logs/dirlog", datapath);
   printf("PATH: %s\n", dirlogfile);

   if((fp = fopen(dirlogfile, "r")) == NULL) {
    printf("Unable to open dirlog");
    return 0;
   }

   while(!feof(fp)) {
     if (fread(&buffer, sizeof(struct dirlog), 1, fp) < 1)
       break;
     printf("STATUS: %d\tDIRNAME: %s\n", buffer.status, buffer.dirname);
   }

fclose(fp);
return 0;
}

