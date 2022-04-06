###########################################################
##
##  zipscript-c solaris port
##
##  f3k, 13/05/04
##
###########################################################


## install

- replace zipscript/src/Makefile.in with Makefile.in
- replace zipscript/src/cleanup.c with cleanup.c
- replace zipscript/src/datacleaner.c with datacleaner.c
- replace zipscript/src/zsfunctions.h with zsfunctions.h
- replace zipscript/include/macros.h with macros.h
- copy scandir.c to zipscript/src
- ./configure;make as usual.


## notes

- there are some warnings about qsort which can be ignored.
- make sure you have the latest gcc, autoconf etc installed.


## credits

- to mighty dark0n3 for some help with libc.
- to joerg-r. hill for the scandir port.
- to grondsch for letting me test it on his box :p

## EOF