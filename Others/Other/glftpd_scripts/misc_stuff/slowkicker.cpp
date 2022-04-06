// The MIT License (MIT)
//
// SlowKicker v0.3 Copyright (c) 2014 Biohazard
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

#include <cstdio>
#include <cctype>
#include <cstdlib>
#include <iostream>
#include <cstring>
#include <cerrno>
#include <ctime>
#include <csignal>
#include <cstdarg>
#include <string>
#include <sstream>
#include <deque>
#include <sys/time.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <sys/file.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fnmatch.h>
#include "glconf.h"

struct Directory
{
    const char* mask;
    double minSpeed;
    std::time_t minDuration;
    int maxKicks;
};

const char*       GLFTPD_ROOT   = "/glftpd";
const char*       LOG_FILE      = "/glftpd/ftp-data/logs/slowkicker.log";
const char*       LOCK_FILE     = "/glftpd/tmp/slowkicker.lock";
const key_t       IPC_KEY       = 0xDEADBABE;
bool              ONCE_ONLY     = true;
Directory         DIRECTORIES[] = {
    { "/site/iso/*",        125,    /* kB/s */    10,    /* seconds */  3 },
    { "/site/mp3/*",        125,    /* kB/s */    10,    /* seconds */  3 },
    { "/site/0day/*",       125,    /* kB/s */    10,    /* seconds */  3 }
};

struct KickInfo
{
    int32_t procid;
    std::string username;
    std::string groupname;
    std::string path;
    std::string sourceAddress;
    double speed;
};

struct History
{
    std::string username;
    std::string path;
    int numKicks;
};

std::deque<History> history;
const std::size_t maxHistory = 1000;

bool lookupSocketInode(int32_t procid, u_int32_t& inode)
{
    static const int socketMax = 20;

    bool validInode = false;
    for (int i = 2; i < socketMax; ++i) {
        std::ostringstream procPath;
        procPath << "/proc/" << procid << "/fd/" << i;

        char buf[1024];
        ssize_t len = readlink(procPath.str().c_str(), buf, sizeof(buf) - 1);
        if (len < 0) {
            continue;
        }

        buf[len] = '\0';
        if (sscanf(buf, "socket:[%u]", &inode) == 1) {
            validInode = true;
        }
    }

    return validInode;
}

std::string lookupSourceAddress(int32_t procid)
{
    u_int32_t inode;
    if (!lookupSocketInode(procid, inode)) {
        return "UNKNOWN";
    }

    FILE* f = std::fopen("/proc/net/tcp", "r");
    if (f == NULL) {
        return "UNKNOWN";
    }

    char buf[1024];
    std::string sourceAddress = "UNKNOWN";
    while (std::fgets(buf, sizeof(buf), f)) {
        u_int32_t currentInode;
        u_int32_t remoteAddr;
        int n = std::sscanf(buf, "%*d: %*8x:%*4x %8x:%*4x %*2x %*8x:%*8x %*2x: %*8x%*8x %*d %*d %u",
                            &remoteAddr, &currentInode);
        if (n == EOF) {
            break;
        }

        if (n != 2 || currentInode != inode) {
            continue;
        }

        char remoteIP[INET_ADDRSTRLEN];
        if (inet_ntop(AF_INET, &remoteAddr, remoteIP, sizeof(remoteIP))) {
            sourceAddress = remoteIP;
        }

        break;
    }

    std::fclose(f);
    return sourceAddress;
}

History* getHistory(const std::string& username, const std::string& path)
{
    for (std::size_t i = 0; i < history.size(); ++i) {
        if (history[i].username == username && history[i].path == path) {
            return &history[i];
        }
    }

    return NULL;
}

int getNumKicks(const std::string& username, const std::string& path)
{
    History* entry = getHistory(username, path);
    if (entry == NULL) {
        return 0;
    }

    return entry->numKicks;
}

void incrNumKicks(const std::string& username, const std::string& path)
{
    History* entry = getHistory(username, path);
    if (entry == NULL) {
        History entry = { username, path, 1 };
        history.push_front(entry);
        if (history.size() >= maxHistory) {
            history.pop_back();
        }
        return;
    }

    ++entry->numKicks;
}

const Directory* getDirectory(const std::string& path)
{
    static const std::size_t numDirectories = sizeof(DIRECTORIES) / sizeof(Directory);

    for (std::size_t i = 0; i < numDirectories; ++i) {
        if (!fnmatch(DIRECTORIES[i].mask, path.c_str(), 0)) {
            return &DIRECTORIES[i];
        }
    }

    return NULL;
}

std::string formatTimestamp()
{
    const std::time_t now = std::time(NULL);
    char timestamp[26];
    std::strftime(timestamp, sizeof(timestamp), "%a %b %e %T %Y", std::localtime(&now));
    return timestamp;
}

std::string lookupGroup(int32_t gid)
{
    std::string group = "NoGroup";
    std::string path = std::string(GLFTPD_ROOT) + "/etc/group";
    FILE* f = std::fopen(path.c_str(), "r");
    if (f != NULL) {
        char buf[1024];
        while (std::fgets(buf, sizeof(buf), f)) {
            char* p = std::strtok(buf, ":");
            if (p == NULL) {
                continue;
            }

            std::string currentGroup = p;
            p = std::strtok(NULL, ":");
            if (p == NULL) {
                continue;
            }

            p = std::strtok(NULL, ":");
            if (p == NULL) {
                continue;
            }

            char* pEnd;
            int32_t currentGid = std::strtol(p, &pEnd, 10);
            if (*pEnd != '\0' || currentGid != gid) {
                continue;
            }

            group = currentGroup;
            break;
        }
        std::fclose(f);
    }
    return group;
}

enum GlftpdLogTag
{
    GLTSlow,
    GLTZeroByte,
    GLTStalled
};

void gllog(GlftpdLogTag tag, const KickInfo& info)
{
    std::string logPath = GLFTPD_ROOT + std::string("/ftp-data/logs/glftpd.log");
    FILE* f = std::fopen(logPath.c_str(), "a");
    if (f == NULL) {
        return;
    }

    switch (tag) {
        case GLTSlow :
            std::fprintf(f, "%s SLOW: \"%s\" \"%s\" \"%s\" \"%s\" \"%.0f\"\n",
                         formatTimestamp().c_str(),
                         info.path.c_str(),
                         info.username.c_str(),
                         info.groupname.c_str(),
                         info.sourceAddress.c_str(),
                         info.speed);
            break;

        case GLTZeroByte :
            std::fprintf(f, "%s ZEROBYTE: \"%s\" \"%s\" \"%s\" \"%s\"\n",
                         formatTimestamp().c_str(),
                         info.path.c_str(),
                         info.username.c_str(),
                         info.groupname.c_str(),
                         info.sourceAddress.c_str());
            break;

        case GLTStalled :
            std::fprintf(f, "%s STALLED: \"%s\" \"%s\" \"%s\" \"%s\"\n",
                         formatTimestamp().c_str(),
                         info.path.c_str(),
                         info.username.c_str(),
                         info.groupname.c_str(),
                         info.sourceAddress.c_str());
            break;
    }

    std::fclose(f);
}

void log(const char* format,...)
{
    FILE* f = std::fopen(LOG_FILE, "a");
    if (f == NULL) {
        return;
    }

    std::fprintf(f, "%s ", formatTimestamp().c_str());

    va_list args;
    va_start(args, format);
    vfprintf(f, format, args);
    va_end(args);

    std::fprintf(f, "\n");
    std::fclose(f);
}

std::string buildPath(const ONLINE& online)
{
    std::string realPath(GLFTPD_ROOT);
    realPath += online.currentdir;

    struct stat st;
    if (stat(realPath.c_str(), &st) < 0) {
        if (errno != ENOENT) {
            log("Unable to stat path: %s: %s", online.currentdir, strerror(errno));
        }
        return "";
    }

    std::string path(online.currentdir);
    if (S_ISDIR(st.st_mode)) {
        const char* filename = online.status + 5;
        if (filename == '\0') {
            log("Malformed status: %s", online.status);
            return "";
        }
        path += '/';
        path += filename;
        while (!std::isprint(path[path.size() - 1])) {
            path.resize(path.size() - 1);
        }
    }

    return path;
}

void undupe(const std::string& username, const std::string& path)
{
    const char* filename = strrchr(path.c_str(), '/');
    if (filename == NULL) {
        log("Undupe failed, malformed path: %s: %s", username.c_str(), path.c_str());
        return;
    }
    ++filename;

    std::ostringstream command;
    command << GLFTPD_ROOT << "/bin/undupe"
            << " -u " << username
            << " -f '" << filename << "'"
            << " >/dev/null 2>/dev/null";

    if (system(command.str().c_str()) < 0) {
        log("Undupe failed: %s: %s: %s", username.c_str(), path.c_str(), strerror(errno));
    }
}

bool needsKicking(const ONLINE& online, KickInfo& info)
{
    if (online.procid == 0 ||
        strncasecmp(online.status, "STOR ", 5) != 0 ||
        kill(online.procid, 0) < 0) {

        return false;
    }

    info.username = online.username;
    info.path = buildPath(online);
    if (info.path.empty()) {
        return false;
    }

    const Directory* directory = getDirectory(info.path);
    if (directory == NULL) {
        return false;
    }

    struct timeval now;
    gettimeofday(&now, NULL);

    double duration = (now.tv_sec - online.tstart.tv_sec) +
                      ((now.tv_usec - online.tstart.tv_usec) / 1000000.0);
    info.speed = (duration == 0 ? online.bytes_xfer
                                : online.bytes_xfer / duration) / 1024.0;
    if (duration < directory->minDuration || info.speed >= directory->minSpeed) {
        return false;
    }

    if (getNumKicks(info.username, info.path) >= directory->maxKicks) {
        return false;
    }

    const std::string realPath = GLFTPD_ROOT + info.path;
    if (access(realPath.c_str(), X_OK) != 0) {
        return false;
    }

    info.groupname = lookupGroup(online.groupid);
    info.procid = online.procid;
    info.sourceAddress = lookupSourceAddress(online.procid);

    return true;
}

bool kick(const KickInfo& info)
{
    if (kill(info.procid, SIGTERM) < 0) {
        if (errno != ESRCH) {
            log("Unable to kill process: %ld: %s", (long) info.procid, strerror(errno));
        }
        return false;
    }

    const std::string realPath = GLFTPD_ROOT + info.path;

    struct stat st;
    if (stat(realPath.c_str(), &st) < 0) {
        if (errno != ENOENT) {
            log("Unable to stat path: %s: %s", realPath.c_str(), strerror(errno));
            return false;
        }
    }

    if (unlink(realPath.c_str()) < 0) {
        log("Unable to delete file: %s: %s", realPath.c_str(), strerror(errno));
        return false;
    }

    undupe(info.username, info.path);

    const char *reason;
    GlftpdLogTag tag;
    if (st.st_size == 0) {
        reason = "zero byte";
        tag = GLTZeroByte;
    }
    else if (info.speed == 0) {
        reason = "stalling upload";
        tag = GLTStalled;
    }
    else {
        reason = "slow uploading";
        tag = GLTSlow;
    }

    log("Kicked user for %s: %s: %s: %.0fkB/s: %s",
        reason, info.username.c_str(), info.sourceAddress.c_str(),
        info.speed, info.path.c_str());
    gllog(tag, info);

    return true;
}

void detach_online(ONLINE* online)
{
    shmdt(online);
}

ONLINE* open_online(std::size_t& num)
{
    int shmid = shmget(IPC_KEY, 0, 0);
    if (shmid < 0) {
        if (errno == ENOENT) {
            return NULL;
        }
        log("Unable to open online users: shmget: %s", strerror(errno));
        return NULL;
    }

    ONLINE* online = (ONLINE*) shmat(shmid, NULL, SHM_RDONLY);
    if (online == (ONLINE*) -1) {
        log("Unable to open online users: shmat: %s", strerror(errno));
        return NULL;
    }

    struct shmid_ds	stat;
    if (shmctl(shmid, IPC_STAT, &stat) < 0) {
        log("Unable to open online users: shmctl: %s", strerror(errno));
        detach_online(online);
        return NULL;
    }

    num = stat.shm_segsz / sizeof(ONLINE);
    return online;
}

void check()
{
    std::size_t numOnline;
    ONLINE* online = open_online(numOnline);
    if (online == NULL) {
        return;
    }

    for (std::size_t i = 0; i < numOnline; ++i) {
        KickInfo info;
        if (!needsKicking(online[i], info)) {
            continue;
        }

        if (kick(info)) {
            incrNumKicks(info.username, info.path);
        }
    }

    detach_online(online);
}

bool acquireLock()
{
    int fd = open(LOCK_FILE, O_CREAT | O_WRONLY, 0600);
    if (fd < 0) {
        std::cerr << "Unable to create/open lock file: " << strerror(errno) << std::endl;
        return false;
    }

    if (flock(fd, LOCK_EX | LOCK_NB) < 0) {
        if (errno == EWOULDBLOCK) {
            std::cerr << "Slowkicker is already running." << std::endl;
            return false;
        }

        std::cerr << "Unable to acquire exclusive lock: " << strerror(errno) << std::endl;
        return false;
    }

    return true;
}

int main()
{
    if (!acquireLock()) {
        return 1;
    }

    if (!fork()) {
        while (true) {
            check();
            sleep(1);
        }
    }
}