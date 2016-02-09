#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <dirent.h>
#include <openssl/sha.h>

#define ver "0.9.9"

/*
Info about bencoding and torrent file specifiction
has been taken from:
http://wiki.theory.org/BitTorrentSpecification
*/

#define strncpyz(d,s,l) *(strncpy(d,s,l)+l)=0
#define lwrcase(a) ((a>64 && a<91) ? a+32:a)
#define uprcase(a) ((a>97 && a<123) ? a-32:a)
#define BadPtr(ptr) (!ptr || !*ptr)

#ifdef O_BINARY
#define MO_RDONLY O_RDONLY|O_BINARY
#else
#define MO_RDONLY O_RDONLY
#endif

#define F_PUB 1
#define F_ND 2
#define AL_MAX 31
#define EX_MAX 31

struct file_s
{
char *fn;
char *path;
char *tp;
off_t size;
int depth;
void *link;
};

struct dir_s
{
char *name;
char *path;
void *link;
};

static char str[1024];

static char *name;
static char *announce;
static char *announce_list[AL_MAX+1];
static char *ignore_list[EX_MAX+1];
static long long totalsize;
static struct file_s *files,*files2;
static int bs;
static int flags;

#define benc_raw(f,s) fprintf(f,"%s",s)
#define benc_str(f,s) fprintf(f,"%u:%s",strlen(s),s)
#define benc_int(f,i) fprintf(f,"i%de",i)
#define benc_int64(f,i) fprintf(f,"i%llde",i)

static void *myalloc(int sz)
{
void *mem;

if((mem=malloc(sz)))
  return mem;
printf("mktorrent: Unable to allocate more memory\n");
exit(2);
}

static void free_files(void)
{
struct file_s *ptr,*l;

ptr=files;
while(ptr)
  {
  l=ptr->link;
  free(ptr->fn);
  free(ptr->path);
  free(ptr);
  ptr=l;
  }
}

static void free_dirs(struct dir_s *dirs)
{
struct dir_s *ptr,*l;

ptr=dirs;
while(ptr)
  {
  l=ptr->link;
  free(ptr->name);
  free(ptr->path);
  free(ptr);
  ptr=l;
  }
}

static char *cmpstr(char *a,char *b)
{
char *c,*d,*t;

t=b;
while(1)
  {
  c=a;
  d=t;
  #ifdef __CYGWIN__
  while(*c && lwrcase(*c)==lwrcase(*d))
  #else
  while(*c && *c==*d)
  #endif
    {
    c++;
    d++;
    }
  if(!*c)
    return d;
  t++;
  if(!*t)
    return 0;
  }
}

static char iswm(char *s,char *w)
{
char st[128];
char *a,*p;

if(!s || !w || !*s || !*w)
  return 0;

a=s;
while(1)
  {
  while(*w=='?')
    {
    w++;
    a++;
    if(!*a)
      {
      if(!*w)
        return 1;
      return 0;
      }
    }
  while(*w=='*')
    {
    w++;
    if(!*w)
      return 1;
    p=st;
    while(*w && *w!='*' && *w!='?')
      *p++=*w++;
    *p=0;
    while(1)
      {
      a=cmpstr(st,a);
      if(!a)
        return 0;
      if(*w)
        break;
      if(!*a)
        return 1;
      }
    }
  #ifdef __CYGWIN__
  while(*w && *w!='*' && *w!='?' && lwrcase(*a)==lwrcase(*w))
  #else
  while(*w && *w!='*' && *w!='?' && *a==*w)
  #endif
    {
    a++;
    w++;
    }
  if(!*w)
    {
    if(!*a)
      return 1;
    return 0;
    }
  if(*w!='*' && *w!='?')
    return 0;
  }
return 0;
}

static int cnt_bits(int a)
{
int c=0;

while(a)
  {
  a=a&(a-1);
  c++;
  }
return c;
}

static int calc_bs(void)
{
long long pieces;
int bs=65536;

while(bs<4194304)
  {
  pieces=totalsize/bs;
  if(pieces<16384)
    return bs;
  bs=bs<<1;
  }
return bs;
}

static void build_sf(struct file_s *file,char *out_fn)
{
long long pieces=0;
long long cnt=0;
long cps=0,ops=0;
time_t ctm,otm;
FILE *fo;
char *buf,*sha;
int f,r;
int i;

if(!(fo=fopen(out_fn,"wb")))
  {
  printf("mktorrent: Unable to open file for writing: %s\n",out_fn);
  exit(1);
  }

if(!bs)
  bs=calc_bs();

// MAIN torrent dictionary
benc_raw(fo,"d");
benc_str(fo,"announce");
benc_str(fo,announce);
if(announce_list[0])
  {
  char *s,*p;

  benc_str(fo,"announce-list");
  benc_raw(fo,"l");
  for(i=0;announce_list[i];i++)
    {
    benc_raw(fo,"l");
    s=announce_list[i];
    while(s && *s)
      {
      while(*s && *s==32)
        s++;
      if(!*s)
        break;
      if((p=strchr(s,32)))
        *p=0;
      benc_str(fo,s);
      s=(p) ? p+1:0;
      }
    benc_raw(fo,"e");
    }
  benc_raw(fo,"e");
  }
benc_str(fo,"creation date");
benc_int(fo,time(0));

benc_str(fo,"info");
benc_raw(fo,"d");
//{ info dictionary
benc_str(fo,"length");
#ifdef FS64
benc_int64(fo,file->size);
#else
benc_int(fo,file->size);
#endif
benc_str(fo,"name");
benc_str(fo,name);
benc_str(fo,"piece length");
benc_int(fo,bs);
if(!(buf=malloc(bs)) || !(sha=malloc(SHA_DIGEST_LENGTH)))
  {
  fclose(fo);
  close(f);
  free_files();
  printf("mktorrent: Unable to allocate more memory\n");
  exit(1);
  }
pieces=totalsize/bs;
if(totalsize%bs)
  pieces++;
benc_str(fo,"pieces");
fprintf(fo,"%lld:",pieces*SHA_DIGEST_LENGTH);

printf("Creating torrent file...\n",out_fn);
if((f=open(file->fn,MO_RDONLY))==-1)
  {
  fclose(fo);
  free(buf);
  free(sha);
  free_files();
  printf("mktorrent: Unable to open file: %s\n",file->fn);
  exit(1);
  }
otm=time(0);
fprintf(stdout,"done: %3d%%",cps);
fflush(stdout);
while((r=read(f,buf,bs))>0)
  {
  SHA1(buf,r,sha);
  fwrite(sha,1,SHA_DIGEST_LENGTH,fo);
  cnt++;
  cps=cnt*100/pieces;
  ctm=time(0);
  if(ctm!=otm && cps!=ops)
    {
    fprintf(stdout,"\rdone: %3d%%",cps);
    fflush(stdout);
    ops=cps;
    otm=ctm;
    }
  }
close(f);
fprintf(stdout,"\rdone: %3d%%\n",cps);
fflush(stdout);
if(r<0)
  {
  fclose(fo);
  free(buf);
  free(sha);
  free_files();
  printf("mktorrent: Error reading from file: %s\n",file->fn);
  exit(1);
  }
if(!(flags&F_PUB))
  {
  benc_str(fo,"private");
  benc_int(fo,1);
  }
//} info dictionary
benc_raw(fo,"ee");
fclose(fo);
free(buf);
free(sha);
free_files();
}

static void build_mf(struct file_s *filelist,char *out_fn)
{
long long pieces=0;
long long cnt=0;
long cps=0,ops=0;
time_t ctm,otm;
FILE *fo;
struct file_s *ptr;
char *buf,*sha;
int f,r,r2;
int i;

if(!(fo=fopen(out_fn,"wb")))
  {
  printf("mktorrent: Unable to open file for writing: %s\n",out_fn);
  exit(1);
  }

if(!bs)
  bs=calc_bs();

// MAIN torrent dictionary
benc_raw(fo,"d");
benc_str(fo,"announce");
benc_str(fo,announce);
if(announce_list[0])
  {
  char *s,*p;

  benc_str(fo,"announce-list");
  benc_raw(fo,"l");
  for(i=0;announce_list[i];i++)
    {
    benc_raw(fo,"l");
    s=announce_list[i];
    while(s && *s)
      {
      while(*s && *s==32)
        s++;
      if(!*s)
        break;
      if((p=strchr(s,32)))
        *p=0;
      benc_str(fo,s);
      s=(p) ? p+1:0;
      }
    benc_raw(fo,"e");
    }
  benc_raw(fo,"e");
  }
benc_str(fo,"creation date");
benc_int(fo,time(0));

benc_str(fo,"info");
benc_raw(fo,"d");
//{ info dictionary
benc_str(fo,"files");
benc_raw(fo,"l");
for(ptr=filelist;ptr;ptr=ptr->link)
  {
  benc_raw(fo,"d");
  benc_str(fo,"length");
  #ifdef FS64
  benc_int64(fo,ptr->size);
  #else
  benc_int(fo,ptr->size);
  #endif
  benc_str(fo,"path");
  benc_raw(fo,ptr->path);
  benc_raw(fo,"e");
  }
benc_raw(fo,"e");

benc_str(fo,"name");
benc_str(fo,name);
benc_str(fo,"piece length");
benc_int(fo,bs);

if(!(buf=malloc(bs)) || !(sha=malloc(SHA_DIGEST_LENGTH)))
  {
  fclose(fo);
  close(f);
  free_files();
  printf("mktorrent: Unable to allocate more memory\n");
  exit(1);
  }
pieces=totalsize/bs;
if(totalsize%bs)
  pieces++;
benc_str(fo,"pieces");
fprintf(fo,"%lld:",pieces*SHA_DIGEST_LENGTH);

printf("Creating torrent file...\n",out_fn);
otm=time(0);
fprintf(stdout,"done: %3d%%",cps);
fflush(stdout);
f=0;
ptr=filelist;
while(ptr)
  {
  if(!f && (f=open(ptr->fn,MO_RDONLY))==-1)
    {
    fclose(fo);
    free(buf);
    free(sha);
    free_files();
    printf("\nmktorrent: Unable to open file: %s\n",ptr->fn);
    exit(1);
    }
  while((r=read(f,buf,bs))==bs)
    {
    SHA1(buf,r,sha);
    fwrite(sha,1,SHA_DIGEST_LENGTH,fo);
    cnt++;
    cps=cnt*100/pieces;
    ctm=time(0);
    if(ctm!=otm && cps!=ops)
      {
      fprintf(stdout,"\rdone: %3d%%",cps);
      fflush(stdout);
      ops=cps;
      otm=ctm;
      }
    }
  close(f);
  f=0;

  if(r<0)
    {
    fclose(fo);
    free(buf);
    free(sha);
    free_files();
    printf("\nmktorrent: Error reading from file: %s\n",ptr->fn);
    exit(1);
    }

  while(r>0 && r<bs && ptr->link)
    {
    ptr=ptr->link;
    if((f=open(ptr->fn,MO_RDONLY))==-1)
      {
      fclose(fo);
      free(buf);
      free(sha);
      free_files();
      printf("\nmktorrent: Unable to open file: %s\n",ptr->fn);
      exit(1);
      }
    if((r2=read(f,buf+r,bs-r))<0)
      {
      fclose(fo);
      free(buf);
      free(sha);
      free_files();
      printf("\nmktorrent: Error reading from file: %s\n",ptr->fn);
      exit(1);
      }
    r+=r2;
    }
  if(r>0)
    {
    SHA1(buf,r,sha);
    fwrite(sha,1,SHA_DIGEST_LENGTH,fo);
    cnt++;
    cps=cnt*100/pieces;
    ctm=time(0);
    if(ctm!=otm && cps!=ops)
      {
      fprintf(stdout,"\rdone: %3d%%",cps);
      fflush(stdout);
      ops=cps;
      otm=ctm;
      }
    }
  if(!f)
    ptr=ptr->link;
  }
fprintf(stdout,"\rdone: %3d%%\n",cps);
fflush(stdout);
if(!(flags&F_PUB))
  {
  benc_str(fo,"private");
  benc_int(fo,1);
  }
//} info dictionary
benc_raw(fo,"ee");
fclose(fo);
free(buf);
free(sha);
free_files();
}

static char mycmpi(char *s1,char *s2)
{
char c1,c2,r;

while(*s1 && *s2)
  {
  c1=lwrcase(*s1);
  c2=lwrcase(*s2);
  if((r=c1-c2))
    return r;
  s1++,s2++;
  }
}

static int mydcmpi(char *s1,char *s2)
{
char c1,c2;
int d=0;

while(*s1 && *s2)
  {
  c1=lwrcase(*s1);
  c2=lwrcase(*s2);
  if(c1!=c2)
    return d;
  if(c1=='/')
    d++;
  s1++,s2++;
  }
}

static void add_file(char *fn,char *tp,struct stat *st)
{
static char path[1024];
struct file_s *tmp,*cp,*lp;
char *pf,*cpt,*lpt,*p;
int l,depth;

tmp=myalloc(sizeof(struct file_s));
tmp->fn=myalloc(strlen(fn)+1);
strcpy(tmp->fn,fn);
if((pf=strrchr(fn,'/')))
  pf++;
else
  pf=fn;
l=strlen(tp);
tmp->tp=myalloc(l+strlen(pf)+1);
strcpy(tmp->tp,tp);
strcpy(tmp->tp+l,pf);

p=path;
*p++='l';
depth=0;
lpt=tp;
while((cpt=strchr(lpt,'/')))
  {
  l=cpt-lpt;
  if((p-path)+l+8>1020)
    {
    printf("mktorrent: Path len exceeded\n");
    exit(1);
    }
  p+=sprintf(p,"%u:",l);
  strncpy(p,lpt,l);
  p+=l;
  lpt=cpt+1;
  depth++;
  }
l=strlen(pf);
if((p-path)+l+8>1020)
  {
  printf("mktorrent: Path len exceeded\n");
  exit(1);
  }
p+=sprintf(p,"%u:%s",l,pf);
*p++='e';
*p=0;
tmp->path=myalloc(strlen(path)+1);
strcpy(tmp->path,path);
tmp->depth=depth;
tmp->size=st->st_size;
totalsize+=st->st_size;

lp=0;
for(cp=files2;cp;lp=cp,cp=cp->link)
  {
  if(depth<=cp->depth)
    break;
  }
if(!lp)
  {
  tmp->link=files2;
  files2=tmp;
  return;
  }
if(!cp)
  {
  lp->link=tmp;
  tmp->link=0;
  return;
  }
tmp->link=cp;
lp->link=tmp;
}

static void sort_files(void)
{
struct file_s *tmp,*link,*cp,*lp;
int dc,dt;

for(tmp=files2;tmp;tmp=link)
  {
  link=tmp->link;
  dc=0;
  lp=0;
  for(cp=files;cp;lp=cp,cp=cp->link)
    {
    if((dt=mydcmpi(tmp->tp,cp->tp))<dc)
      break;
    dc=dt;
    if(tmp->depth==cp->depth && mycmpi(tmp->fn,cp->fn)<0)
      break;
    }
  if(!lp)
    {
    tmp->link=files;
    files=tmp;
    continue;
    }
  if(!cp)
    {
    lp->link=tmp;
    tmp->link=0;
    continue;
    }
  tmp->link=cp;
  lp->link=tmp;
  }
}

static void process_dir(char *ap,char *tp)
{
static char fn[1024];
struct stat st;
struct dir_s *dirs,*ptr;
struct dirent *d;
char *tpath;
DIR *dir;
int i;

if(!(dir=opendir(ap)))
  {
  printf("mktorrent; Unable to read dir: %s\n",ap);
  exit(1);
  }

dirs=0;
while((d=readdir(dir)))
  {
  if(!strcmp(d->d_name,".") || !strcmp(d->d_name,".."))
    continue;
  if(strlen(ap)+strlen(d->d_name)>1020)
    {
    printf("mktorrent: Path len exceeded\n");
    exit(1);
    }
  // Loop over the ignores in the list
  for(i=0;ignore_list[i];i++)
    {
    if(iswm(d->d_name,ignore_list[i]))
      break;
    }
  if(ignore_list[i])
    continue;
  sprintf(fn,"%s/%s",ap,d->d_name);
  if(stat(fn,&st))
    {
    printf("mktorrent: Cannot stat file: %s\n",fn);
    exit(1);
    }

  if(S_ISREG(st.st_mode))
    {
    add_file(fn,tp,&st);
    continue;
    }
  if(S_ISDIR(st.st_mode))
    {
    struct dir_s *curr;

    curr=dirs;
    dirs=myalloc(sizeof(struct dir_s));
    dirs->name=myalloc(strlen(d->d_name)+1);
    strcpy(dirs->name,d->d_name);
    dirs->path=myalloc(strlen(fn)+1);
    strcpy(dirs->path,fn);
    dirs->link=curr;
    continue;
    }
  }
closedir(dir);

for(ptr=dirs;ptr;ptr=ptr->link)
  {
  tpath=myalloc(strlen(tp)+strlen(ptr->name)+4);
  sprintf(tpath,"%s%s/",tp,ptr->name);
  process_dir(ptr->path,tpath);
  free(tpath);
  }
free_dirs(dirs);
}

static void prepare_sf(char *ap,struct stat *st)
{
char *p;

if((p=strrchr(ap,'/')))
  p++;
else
  p=ap;
name=p;
files=myalloc(sizeof(struct file_s));
memset(files,0,sizeof(struct file_s));
files->fn=myalloc(strlen(ap)+1);
strcpy(files->fn,ap);
files->size=st->st_size;
totalsize+=st->st_size;
}

static void prepare_mf(char *ap)
{
struct stat st;

if(stat(ap,&st))
  {
  printf("mktorrent: Cannot stat file: %s\n",ap);
  exit(1);
  }
if(S_ISDIR(st.st_mode))
  {
  if(!(flags&F_ND))
    {
    char *tpath,*p;

    if((p=strrchr(ap,'/')))
      p++;
    else
      p=ap;
    tpath=myalloc(strlen(p)+4);
    sprintf(tpath,"%s/",p);
    process_dir(ap,tpath);
    free(tpath);
    return;
    }
  process_dir(ap,"");
  return;
  }
if(S_ISREG(st.st_mode))
  {
  add_file(ap,"",&st);
  return;
  }
}

void help(void)
{
printf("Usage: mktorrent -a <url> [options] -o <torrent> <file/dir> ...\n");
printf("Options:\n");
printf("  -bs <size>      - piece size in KB\n");
printf("  -a <url>        - announce URL\n");
printf("  -n <name>       - dir for storing multiple files\n");
printf("  -nd             - do not include source dirs into torrent\n");
printf("  -o <torrent>    - output file (.torrent)\n");
printf("  -pub            - torrent is public (can use peer exchange)\n");
printf("  -ig <pattern>   - ignore files/dirs that match specified pattern\n");
printf("      You can specify -ig many times.\n");
printf("  -mt 'url1 url2 ...'\n");
printf("      MultiTracker tier group. You can specify -mt many times\n");
printf("  -v  mktorrent Version Info\n");
}

int main(int argc,char *argv[])
{
struct stat st;
char *out_fn;
char *p;
int i,ac,ic;

if(argc<2)
  {
  help();
  return 0;
  }

flags=0;
files=0;
files2=0;
totalsize=0;
bs=0;
announce=0;
name=0;
out_fn=0;

announce_list[0]=0;
ac=0;

ignore_list[0]=0;
ic=0;

for(i=1;i<argc;i++)
  {
  if(BadPtr(argv[i]))
    {
    printf("mktorrent: Panic: Null argument\n");
    exit(2);
    }
  if(!strcmp(argv[i],"--"))
    {
    i++;
    break;
    }
  if(*argv[i]!='-')
    break;

  if(!strcmp(argv[i],"-v") || !strcmp(argv[i],"--version"))
    {
    printf("mktorrent %s by Borg custom modified by Islander.\n",ver);
    return 0;
    }
  if(!strcmp(argv[i],"--help"))
    {
    help();
    return 0;
    }

  if(!strcmp(argv[i],"-bs"))
    {
    i++;
    if(argc<i || BadPtr(argv[i]) || !(bs=atoi(argv[i])))
      {
      printf("mktorrent: Not enough arguments\n");
      return 1;
      }
    continue;
    }
  if(!strcmp(argv[i],"-a"))
    {
    i++;
    if(argc<i || BadPtr(argv[i]))
      {
      printf("mktorrent: Not enough arguments\n");
      return 1;
      }
    announce=argv[i];
    continue;
    }
  if(!strcmp(argv[i],"-mt"))
    {
    i++;
    if(argc<i || BadPtr(argv[i]))
      {
      printf("mktorrent: Not enough arguments\n");
      return 1;
      }
    if(ac>=AL_MAX)
      {
      printf("mktorrent: Max announce urls exceeded\n");
      return 1;
      }
    announce_list[ac++]=argv[i];
    announce_list[ac]=0;
    continue;
    }
  if(!strcmp(argv[i],"-ig"))
    {
    i++;
    if(argc<i || BadPtr(argv[i]))
      {
      printf("mktorrent: Not enough arguments\n");
      return 1;
      }
    if(ic>=EX_MAX)
      {
      printf("mktorrent: Max ignored extensions exceeded\n");
      return 1;
      }
    ignore_list[ic++]=argv[i];
    ignore_list[ic]=0;
    continue;
    }
  if(!strcmp(argv[i],"-n"))
    {
    i++;
    if(argc<i || BadPtr(argv[i]))
      {
      printf("mktorrent: Not enough arguments\n");
      return 1;
      }
    name=argv[i];
    continue;
    }
  if(!strcmp(argv[i],"-o"))
    {
    i++;
    if(argc<i || BadPtr(argv[i]))
      {
      printf("mktorrent: Not enough arguments\n");
      return 1;
      }
    out_fn=argv[i];
    continue;
    }
  if(!strcmp(argv[i],"-nd"))
    {
    flags|=F_ND;
    continue;
    }
  if(!strcmp(argv[i],"-pub"))
    {
    flags|=F_PUB;
    continue;
    }
  printf("mktorrent: Unknown option\n");
  return 1;
  }

if(!announce || !out_fn || argc<i+1 || BadPtr(argv[i]))
  {
  printf("mktorrent: Not enough parameters\n");
  return 1;
  }
if(bs)
  {
  if(bs<32 || bs>4096 || cnt_bits(bs)!=1)
    {
    printf("mktorrent: Wrong piece size specified\n");
    return 1;
    }
  bs=bs<<10;
  }

if(i+1==argc)
  {
  if(BadPtr(argv[i]))
    {
    printf("mktorrent: Panic: Null argument\n");
    exit(2);
    }
  p=argv[i]+strlen(argv[i])-1;
  if(*p=='/')
    *p=0;
  if(stat(argv[i],&st))
    {
    printf("mktorrent: Cannot stat file: %s\n",argv[i]);
    return 1;
    }
  if(S_ISDIR(st.st_mode))
    {
    if((p=strrchr(argv[i],'/')))
      p++;
    else
      p=argv[i];
    if(!name)
      name=p;
    process_dir(argv[i],"");
    sort_files();
    if(!files)
      {
      printf("mktorrent: No files to add\n");
      return 1;
      }
    build_mf(files,out_fn);
    return 0;
    }
  if(S_ISREG(st.st_mode))
    {
    prepare_sf(argv[i],&st);
    build_sf(files,out_fn);
    return 0;
    }
  printf("mktorrent: Unknown file: %s\n",argv[i]);
  return 1;
  }

if(!name)
  {
  printf("mktorrent: You need to specify dir name\n");
  return 1;
  }

while(i<argc)
  {
  if(BadPtr(argv[i]))
    {
    printf("mktorrent: Panic: Null argument\n");
    exit(2);
    }
  p=argv[i]+strlen(argv[i])-1;
  if(*p=='/')
    *p=0;
  prepare_mf(argv[i++]);
  }
sort_files();
if(!files)
  {
  printf("mktorrent: No files to add\n");
  return 1;
  }
build_mf(files,out_fn);
return 0;
}
