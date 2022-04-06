#define GLCONF	"/etc/glftpd.conf"	/* Default config path        */

struct dirlog {
        ushort status;                  /* 0 = NEWDIR, 1 = NUKE, 2 = UNNUKE, 3 = DELETED */
        time_t uptime;                  /* Creation time since epoch (man 2 time) */
        ushort uploader;                /* The userid of the creator */
        ushort group;                   /* The groupid of the primary group of the creator */
        ushort files;                   /* The number of files inside the dir */
        unsigned long long bytes;       /* The number of bytes in the dir */
        char dirname[255];              /* The name of the dir (fullpath) */
        struct dirlog *nxt;             /* Unused, kept for compatibility reasons */
        struct dirlog *prv;             /* Unused, kept for compatibility reasons */
};

struct lastonlog {
        char uname[24];         /* username */
        char gname[24];         /* users primary group */
        char tagline[64];       /* users tagline */
        time_t logon;           /* users logon time */
        time_t logoff;          /* users logoff time */
        unsigned long upload;   /* bytes uploaded */
        unsigned long download; /* bytes downloaded */
        char stats[6];          /* what did the user do ? */
};

struct nukelog {
        ushort status;          /* 0 = NUKED, 1 = UNNUKED */
        time_t nuketime;        /* The nuke time since epoch (man 2 time) */
        char nuker[12];         /* The name of the nuker */
        char unnuker[12];       /* The name of the unnuker */
        char nukee[12];         /* The name of the nukee */
        ushort mult;            /* The nuke multiplier */
        float bytes;            /* The number of bytes nuked */
        char reason[60];        /* The nuke reason */
        char dirname[255];      /* The dirname (fullpath) */
        struct nukelog *nxt;    /* Unused, kept for compatibility reasons */
        struct nukelog *prv;    /* Unused, kept for compatibility reasons */
};

struct oneliner {
        char uname[24];         /* The user that added the oneliner */
        char gname[24];         /* The primary group of the user who added the oneliner */
        char tagline[64];       /* The tagline of the user who added the oneliner */
        time_t timestamp;       /* The time the message was added (epoch) */
        char message[100];      /* The message (oneliner) */
};

struct dupefile {
       char filename[256];
       time_t timeup;
       char uploader[25];
};

struct ONLINE {
  char   tagline[64];             /* The users tagline */
  char   username[24];            /* The username of the user */
  char   status[256];             /* The status of the user, idle, RETR, etc */
  short int ssl_flag;             /* 0 = no ssl, 1 = ssl on control, 2 = ssl on control and data */
  char   host[256];               /* The host the user is comming from (with ident) */
  char   currentdir[256];         /* The users current dir (fullpath) */
  long   groupid;                 /* The groupid of the users primary group */
  time_t login_time;              /* The login time since the epoch (man 2 time) */
  struct timeval tstart;          /* replacement for last_update. */
  struct timeval txfer;           /* The time of the last succesfull transfer. */
  unsigned long long bytes_xfer;  /* bytes transferred so far. */
  pid_t  procid;                  /* The processor id of the process */
};

