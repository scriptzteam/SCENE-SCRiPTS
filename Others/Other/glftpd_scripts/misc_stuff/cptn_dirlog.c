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

struct dirlog {
        ushort status;     // 0 = NEWDIR, 1 = NUKE, 2 = UNNUKE, 3 = DELETED
        time_t uptime;
        ushort uploader;    /* Libc6 systems use ushort in place of uid_t/gid_t */
        ushort group;
        ushort files;
        long bytes;
        char dirname[255];
        struct dirlog *nxt;
        struct dirlog *prv;
};

int main ( int argc, char *argv[]) {
   FILE *fp, *fp2;
   struct dirlog buffer;

   if((fp = fopen(argv[1], "r")) == NULL) {
    printf("Unable to open dirlog");
    return 0;
   }

   while(!feof(fp)) {
     if (fread(&buffer, sizeof(struct dirlog), 1, fp) < 1)
       break;
     printf("%d %d %d username %s\n", buffer.uptime, buffer.files, buffer.bytes, buffer.dirname);
   }

fclose(fp);
return 0;
}