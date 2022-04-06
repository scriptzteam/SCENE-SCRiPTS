#!/bin/sh
for i in \
  libboost-thread-dev libboost-regex-dev libboost-iostreams-dev libboost-system-dev \
  libboost-filesystem-dev libboost-date-time-dev libboost-program-options-dev libboost-signals-dev \
  libssl-dev \
  mongodb
  mongodb-dev
do
    apt-get install $i -y
done
