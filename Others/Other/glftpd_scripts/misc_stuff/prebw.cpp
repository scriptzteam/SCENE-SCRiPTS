// The MIT License (MIT)
//
// PreBW v0.1 Copyright (c) 2014 Biohazard
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#include <iostream>
#include <sstream>
#include <iomanip>
#include <fstream>
#include <cstdio>
#include <vector>
#include <set>
#include <algorithm>
#include <memory>
#include <ctime>
#include <cstring>
#include <cstdlib>
#include <cerrno>
#include <unistd.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/time.h>
#include "glconf.h"
#include "config.hpp"

struct Traffic
{
    double size;
    int userCount;
    int groupCount;

    Traffic() : size(0), userCount(0), groupCount(0) { }
};

struct Bandwidth
{
    double speed;
    int userCount;

    Bandwidth() : speed(0), userCount(0) { }
};

bool isDebug()
{
    const char* s = getenv("PREBW_DEBUG");
    return s && !strcasecmp(s, "TRUE");
}

const std::size_t NUM_SNAPSHOTS = sizeof(SNAPSHOTS) / sizeof(SNAPSHOTS[0]);

bool isInDirectory(const char* dir, const char* subdir)
{
    std::size_t dirLen = std::strlen(dir);
    if (std::strncmp(subdir, dir, dirLen) != 0) {
        return false;
    }

    return *(subdir + dirLen) == '/' || *(subdir + dirLen) == '\0';
}

bool collectBandwidth(const std::string& dirname, Bandwidth* result)
{
    int shmid = shmget(IPC_KEY, 0, 0);
    if (shmid < 0) {
        if (errno == ENOENT) {
            return result != NULL;
        }
        std::cerr << "shmget: " << strerror(errno) << "\n";
        return false;
    }

    ONLINE* online = (ONLINE*) shmat(shmid, NULL, SHM_RDONLY);
    if (online == (ONLINE*) -1) {
        std::cerr << "shmat: " << strerror(errno) << "\n";
        return false;
    }

    struct shmid_ds	stat;
    if (shmctl(shmid, IPC_STAT, &stat) < 0) {
        std::cerr << "shmctl: " << strerror(errno) << "\n";
        shmdt(online);
        return false;
    }

    if (result != NULL) {
        result->speed = 0;
        result->userCount = 0;
    }

    struct timeval now;
    gettimeofday(&now, NULL);

    const std::size_t numOnline  = stat.shm_segsz / sizeof(ONLINE);
    int numDownloaders           = 0;

    for (std::size_t i = 0; i < numOnline; ++i) {
        if (online[i].procid == 0) {
            continue;
        }

        if (strncasecmp(online[i].status, "RETR ", 5) != 0) {
            continue;
        }

        if (online[i].bytes_xfer <= 100 * 1024) {
            continue;
        }

        if (!isInDirectory(dirname.c_str(), online[i].currentdir)) {
            continue;
        }

        if (result != NULL) {
            double duration = (now.tv_sec - online[i].tstart.tv_sec) +
                              ((now.tv_usec - online[i].tstart.tv_usec) / 1000000.0);
            result->speed += (duration == 0 ? online[i].bytes_xfer
                                            : online[i].bytes_xfer / duration) / 1024.0 / 1024.0;
            ++result->userCount;
        }

        ++numDownloaders;
    }

    shmdt(online);

    return result != NULL || numDownloaders > 0;
}

bool collectBandwidthSnapshot(const std::string& dirname,
                              std::time_t snapshotTime,
                              Bandwidth& result)
{
    result.speed = 0;
    result.userCount = 0;

    while (true) {
        Bandwidth bandwidth;
        if (!collectBandwidth(dirname, &bandwidth)) {
            return false;
        }

        result.speed     = std::max(result.speed,     bandwidth.speed);
        result.userCount = std::max(result.userCount, bandwidth.userCount);

        if (std::time(NULL) >= snapshotTime) {
            break;
        }

        usleep(REFRESH_RATE);
    }

    return true;
}

bool collectBandwidthSnapshots(const std::string& dirname,
                               std::time_t startTime,
                               std::vector<Bandwidth>& result)
{
    for (std::size_t i = 0; i < NUM_SNAPSHOTS; ++i) {
        Bandwidth bandwidth;
        if (!collectBandwidthSnapshot(dirname, startTime + SNAPSHOTS[i], bandwidth)) {
            return false;
        }
        result.push_back(bandwidth);
    }
    return true;
}

void waitNoTransfersOrCutOff(const std::string& dirname, std::time_t cutOffTime)
{
    int consecutive = 0;
    while (std::time(NULL) < cutOffTime) {
        if (!collectBandwidth(dirname, NULL)) {
            if (++consecutive == 3) {
                return;
            }
        }
        else {
            consecutive = 0;
        }
        sleep(1);
    }
}

bool collectTrafficStats(const std::string& dirname, Traffic& traffic)
{
    std::ifstream f(XFER_LOG);
    if (!f) {
        return false;
    }

    traffic.size       = 0;
    traffic.userCount  = 0;
    traffic.groupCount = 0;

    std::set<std::string> users;
    std::set<std::string> groups;
    std::string line;
    while (std::getline(f, line)) {
        std::istringstream is(line);
        long bytes;
        std::string user;
        std::string group;
        std::string path;
        std::string type;
        std::string skip;
        is >> skip >> skip >> skip >> skip >> skip >> skip >> skip;
        is >> bytes >> path >> skip >> skip >> type >> skip >> user >> group;

        if (is.good() && type == "o" && isInDirectory(dirname.c_str(), path.c_str())) {

            traffic.size += bytes / 1024.0 / 1024.0;
            if (users.insert(user).second) {
                ++traffic.userCount;
            }

            if (groups.insert(group).second) {
                ++traffic.groupCount;
            }
        }
    }

    return true;
}

std::string formatTimestamp()
{
    const std::time_t now = std::time(NULL);
    char timestamp[26];
    std::strftime(timestamp, sizeof(timestamp),
                  "%a %b %e %T %Y",
                  std::localtime(&now));
    return timestamp;
}

bool log(const std::string& dirname,
         const std::vector<Bandwidth>& bandwidths,
         const Traffic& traffic)
{
    std::ofstream f(GLFTPD_LOG, std::ios_base::app);
    if (!f) {
        return false;
    }

    f << formatTimestamp() << " PREBW: \"" << dirname << "\" ";

    for (std::size_t i = 0; i < NUM_SNAPSHOTS; ++i) {
        f << "\"" << bandwidths[i].userCount << "\" "
          << "\"" << std::fixed << std::setprecision(1) << bandwidths[i].speed << "\" ";
    }

    f << "\"" << traffic.userCount  << "\" "
      << "\"" << traffic.groupCount << "\" "
      << "\"" << std::fixed << std::setprecision(2) << traffic.size << "\"" << std::endl;

    return f.good();
}

int main(int argc, char** argv)
{
    if (!isDebug()) {
        std::cout.setstate(std::ios::failbit);
        std::cerr.setstate(std::ios::failbit);
    }

    if (argc != 2) {
        std::cerr << "usage: " << argv[0] << " <dirname>\n";
        return 1;
    }

    const std::string dirname   = argv[1];
    const std::time_t startTime = std::time(NULL);

    std::vector<Bandwidth> bandwidths;
    if (!collectBandwidthSnapshots(dirname, startTime, bandwidths)) {
        std::cerr << "bandwidth snapshot collection failed\n";
        return 1;
    }

    waitNoTransfersOrCutOff(dirname, startTime + CUT_OFF);

    Traffic traffic;
    if (!collectTrafficStats(dirname, traffic)) {
        std::cerr << "traffic collection failed\n";
        return 1;
    }

    if (!log(dirname, bandwidths, traffic)) {
        std::cerr << "error while writing to glftpd.log\n";
        return 1;
    }
}