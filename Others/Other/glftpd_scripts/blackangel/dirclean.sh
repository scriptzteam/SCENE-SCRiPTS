#!/bin/bash
/glftpd/bin/olddirclean2
mv /glftpd/ftp-data/logs/dirlog2 /glftpd/ftp-data/logs/dirlog
chmod 777 /glftpd/ftp-data/logs/dirlog
