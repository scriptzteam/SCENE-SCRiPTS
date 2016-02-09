CC=gcc

# Default
CFLAGS = -w -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -DFS64
LFLAGS =
LIBS = -lcrypto

# Default (no large file support)
#CFLAGS = -w -O2 
#LFLAGS =
#LIBS = -lcrypto


APPN = mktorrent
OBJS = mktorrent.o

.c.o:
	$(CC) $(CFLAGS) -c $?

all: $(OBJS)
	$(CC) $(LFLAGS) -o $(APPN) $(OBJS) $(LIBS)

clean:
	rm *.o
