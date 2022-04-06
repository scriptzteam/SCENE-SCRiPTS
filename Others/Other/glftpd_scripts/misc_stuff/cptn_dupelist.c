// Dupelist.C - list text output of dupefile
// 02-24-99
// evilution @ EFnet

#include <strings.h>
#include <stdio.h>
#include <sys/time.h>
#include <errno.h>
#include <sys/file.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>

struct dupefile {
  char filename[255];
  time_t timeup;
  char uploader[25];
};

int main (int argc, char *argv[]) {
    FILE *fp;
    struct dupefile buffer;
    if((fp = fopen(argv[1], "r")) == NULL)
    return 0;

  while (!feof(fp)) {
    if (fread(&buffer, sizeof(struct dupefile), 1, fp) < 1)
      break;
    printf("%s;%d;%s\n", buffer.filename,buffer.timeup,buffer.uploader);
  }
fclose(fp);
return 0;
}