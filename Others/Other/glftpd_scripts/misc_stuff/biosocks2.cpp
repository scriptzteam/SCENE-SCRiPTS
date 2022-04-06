#include <cassert>
#include <cerrno>
#include <tr1/memory>
#include <cstdio>
#include <pthread.h>
#include <string>
#include <fnmatch.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <cstring>
#include <unistd.h>
#include <netdb.h>

// pass -f switch to biosocks2 to run in foreground when debugging

const int listenPort = 12345;
const char* listenIP = "0.0.0.0";
const bool authRequired = true;
const char* authUsername = "login";
const char* authPassword = "password";

const char* allowedIPs[] =
{
  "127.0.0.1",
  "*",
  ""
};

const unsigned numAllowedIPs = sizeof(allowedIPs) / sizeof(char*);

const char SocksV5 = 0x05;
const char MethodNone = 0x00, MethodUsername = 0x02, MethodInvalid = char(0xFF);
const char ResultSuccess = 0x00, ResultFail = 0x01;
const char AddressIPv4 = 0x01, AddressDomain = 0x03, AddressIPv6 = 0x04;
const char CommandConnect = 0x01, CommandBind = 0x02;

class Condition;

class Mutex
{
  pthread_mutex_t mutex;

  Mutex(const Mutex&);
  Mutex& operator=(const Mutex&);

public:
  Mutex() { pthread_mutex_init(&mutex, 0); }
  ~Mutex() { pthread_mutex_destroy(&mutex); }

  void Lock() { pthread_mutex_lock(&mutex); }
  void Unlock() { pthread_mutex_unlock(&mutex); }

  friend class Condition;
};

class ScopeLock
{
  Mutex& mutex;

  ScopeLock(const ScopeLock&);
  ScopeLock& operator=(const ScopeLock&);

public:
  ScopeLock(Mutex& mutex) : mutex(mutex) { mutex.Lock(); }
  ~ScopeLock() { mutex.Unlock(); }
};

class Condition
{
  pthread_cond_t cond;

  Condition(const Condition&);
  Condition& operator=(const Condition&);

public:
  Condition() { pthread_cond_init(&cond, 0); }
  ~Condition() { pthread_cond_destroy(&cond); }

  void Wait(Mutex& mutex)
  {
    pthread_cond_wait(&cond, &mutex.mutex);
  }

  void Signal() { pthread_cond_signal(&cond); }
};

bool Readn(int s, char *buffer, ssize_t n)
{
  ssize_t len = 0;
  while (len < n)
  {
    ssize_t ret = read(s, buffer + len, n - len);
    if (ret < 0)
    {
      if (errno == EINTR) continue;
      return false;
    }
    if (!ret)
    {
      errno = ECONNRESET;
      return false;
    }
    len += ret;
  }

  return true;
}

bool Writen(int s, char *buffer, ssize_t n)
{
  ssize_t len = 0;
  while (len < n)
  {
    ssize_t ret = write(s, buffer + len, n - len);
    if (ret < 0)
    {
      if (errno == EINTR) continue;
      return false;
    }
    if (!ret)
    {
      errno = ECONNRESET;
      return -1;
    }
    len += ret;
  }

  return true;
}

bool IPAllowed(const char* ip)
{
  for (unsigned i = 0; i < numAllowedIPs; ++i)
  {
    if (!fnmatch(allowedIPs[i], ip, 0)) return true;
  }

  return false;
}

class Server;

class Client
{
  Server& server;
  struct sockaddr_storage srcStor;
  struct sockaddr_storage dstStor;
  struct sockaddr* srcAddr;
  struct sockaddr* dstAddr;
  int srcSock;
  int dstSock;
  char ip[INET6_ADDRSTRLEN];
  char buffer[BUFSIZ];

  Client(const Client&);
  Client& operator=(const Client&);

  bool Accept();
  bool Auth();
  bool Readn(size_t len);
  bool Writen(size_t len);
  bool Command();
  bool Relay(int readSock, int writeSock);
  void Relay();
  bool Connect();
  bool Resolve(const char* domain);

public:
  Client(Server& server) :
    server(server),
    srcAddr(reinterpret_cast<struct sockaddr*>(&srcStor)),
    dstAddr(reinterpret_cast<struct sockaddr*>(&dstStor)),
    srcSock(-1),
    dstSock(-1)
  { }

  ~Client()
  {
    if (srcSock != -1) close(srcSock);
    if (dstSock != -1) close(dstSock);
  }

  void Handle();
};

class Server
{
  int sock;
  struct sockaddr_storage stor;
  struct sockaddr* addr;
  Mutex acceptMutex;
  Mutex poolMutex;
  Condition poolCond;
  unsigned poolClientsNeeded;

  Server(const Server&);
  Server& operator=(const Server&);

public:
  Server() :
    sock(-1),
    addr(reinterpret_cast<struct sockaddr*>(&stor)),
    poolClientsNeeded(5)
  {
    memset(&stor, 0, sizeof(stor));
  }

  ~Server()
  {
    if (sock != -1) close(sock);
  }

  bool Listen(const char* ip, int port);
  int Accept(struct sockaddr& addr, socklen_t len);
  void LaunchClient();
  void Handle();
};

// CLIENT IMPLEMENTATION

bool Client::Accept()
{
  srcSock = server.Accept(*srcAddr, sizeof(struct sockaddr_storage));
  if (srcSock < 0)
  {
    perror("accept");
    return false;
  }

  socklen_t len = sizeof(srcStor);
  if (getpeername(srcSock, srcAddr, &len) < 0)
  {
    perror("getpeername");
    close(srcSock);
    srcSock = -1;
    return false;
  }

  if (srcAddr->sa_family == AF_INET)
  {
    if (!inet_ntop(AF_INET, &reinterpret_cast<struct
            sockaddr_in*>(srcAddr)->sin_addr, ip, sizeof(ip)))
    {
      perror("inet_ntop");
      return false;
    }
  }
  else
  {
    if (!inet_ntop(AF_INET6, &reinterpret_cast<struct
            sockaddr_in6*>(srcAddr)->sin6_addr, ip, sizeof(ip)))
    {
      perror("inet_ntop");
      return false;
    }
  }

  return true;
}

bool Client::Readn(size_t len)
{
  memset(buffer, 0, sizeof(buffer));
  if (!::Readn(srcSock, buffer, len))
  {
    if (errno != ECONNRESET) perror("readn");
    return false;
  }

  return true;
}

bool Client::Writen(size_t len)
{
  if (!::Writen(srcSock, buffer, len))
  {
    if (errno != ECONNRESET) perror("writen");
    return false;
  }

  return true;
}

bool Client::Auth()
{
  if (!Readn(2)) return false;
  if (buffer[0] != SocksV5)
  {
    fprintf(stderr, "invalid socks version\n");
    return false;
  }

  size_t methods = static_cast<int>(buffer[1]);
  if (methods <= 0)
  {
    fprintf(stderr, "invalid number of auth methods\n");
    return false;
  }

  if (!Readn(methods)) return false;

  char method = MethodInvalid;
  for (size_t i = 0; i < methods; ++i)
  {
    if (buffer[i] == MethodNone && !authRequired && method != MethodUsername)
      method = buffer[i];
    else
    if (buffer[i] == MethodUsername)
      method = buffer[i];
  }

  buffer[0] = SocksV5;
  buffer[1] = method;
  if (!Writen(2)) return false;

  if (method == MethodInvalid)
  {
    fprintf(stderr, "unable to negotiate a suitable authetication method\n");
    return false;
  }

  if (method == MethodNone) return true;

  if (!Readn(2)) return false;
  size_t usernameLen = static_cast<size_t>(buffer[1]);
  char username[256 + 1];

  if (usernameLen > sizeof(username))
  {
    fprintf(stderr, "username longer than 256 characters\n");
    return false;
  }

  if (!Readn(usernameLen)) return false;
  memcpy(username, buffer, usernameLen);
  username[usernameLen] = '\0';

  if (!Readn(1)) return false;
  size_t passwordLen = static_cast<size_t>(buffer[0]);
  char password[256 + 1];

  if (!Readn(passwordLen)) return false;
  memcpy(password, buffer, passwordLen);
  password[passwordLen] = '\0';

  buffer[0] = 0x01;

  if (strcmp(authUsername, username) ||
      strcmp(authPassword, password))
  {
    buffer[1] = ResultFail;

    if (!Writen(2)) return false;
    fprintf(stderr, "username / password authentication failed\n");
    return false;
  }

  buffer[1] = ResultSuccess;
  if (!Writen(2)) return false;

  return true;
}

bool Client::Connect()
{
  char result = ResultSuccess;
  dstSock = socket(dstAddr->sa_family, SOCK_STREAM, 0);
  if (dstSock < 0)
  {
    perror("socket");
    result = ResultFail;
  }
  else
  if (connect(dstSock, dstAddr, sizeof(dstStor)) < 0)
  {
    perror("connect");
    result = ResultFail;
  }

  size_t len = 0;
  buffer[len++] = SocksV5;
  buffer[len++] = result;
  buffer[len++] = 0x00;

  if (dstAddr->sa_family == AF_INET6)
  {
    buffer[len++] = AddressIPv6;
    struct sockaddr_in6* dstAddr6 = reinterpret_cast<struct sockaddr_in6*>(dstAddr);
    memcpy(buffer + len, &dstAddr6->sin6_addr, sizeof(struct in6_addr));
    len += sizeof(struct in6_addr);
    memcpy(buffer + len, &dstAddr6->sin6_port, sizeof(dstAddr6->sin6_port));
    len += sizeof(dstAddr6->sin6_port);
  }
  else
  {
    buffer[len++] = AddressIPv4;
    struct sockaddr_in* dstAddr4 = reinterpret_cast<struct sockaddr_in*>(dstAddr);
    memcpy(buffer + len, &dstAddr4->sin_addr, sizeof(struct in_addr));
    len += sizeof(struct in_addr);
    memcpy(buffer + len, &dstAddr4->sin_port, sizeof(dstAddr4->sin_port));
    len += sizeof(dstAddr4->sin_port);
  }

  if (result == ResultFail) memset(dstAddr, 0, sizeof(dstStor));
  if (!Writen(len)) return false;
  return result == ResultSuccess;
}

bool Client::Resolve(const char* domain)
{
  struct addrinfo hints;
  memset(&hints, 0, sizeof(hints));
  hints.ai_family = PF_UNSPEC;
  hints.ai_flags = AI_PASSIVE;
  hints.ai_socktype = SOCK_STREAM;

  struct addrinfo* res = 0;
  if (getaddrinfo(domain, 0, &hints, &res)) return false;

  struct addrinfo* cur = res;
  while (cur)
  {
    if (cur->ai_family == AF_INET)
    {
      memcpy(dstAddr, cur->ai_addr, sizeof(struct sockaddr_in));
      break;
    }
    else
    if (cur->ai_family == AF_INET6)
    {
      memcpy(dstAddr, cur->ai_addr, sizeof(struct sockaddr_in6));
      break;
    }
  }

  freeaddrinfo(res);
  return cur != 0;
}

bool Client::Command()
{
  if (!Readn(4)) return false;
  if (buffer[1] != CommandConnect)
  {
    fprintf(stderr, "only connect command supported by this socks5 server");
    return false;
  }

  switch (buffer[3])
  {
    case AddressIPv4    :
    {
      if (!Readn(sizeof(struct in_addr))) return false;
      struct sockaddr_in* dstAddr4 = reinterpret_cast<struct sockaddr_in*>(dstAddr);
      memcpy(&dstAddr4->sin_addr, buffer, sizeof(struct in_addr));
      dstAddr4->sin_family = AF_INET;
      break;
    }
    case AddressIPv6    :
    {
      if (!Readn(sizeof(struct in6_addr))) return false;
      struct sockaddr_in6* dstAddr6 = reinterpret_cast<struct sockaddr_in6*>(dstAddr);
      memcpy(&dstAddr6->sin6_addr, buffer, sizeof(struct in6_addr));
      dstAddr6->sin6_family = AF_INET6;
      break;
    }
    case AddressDomain  :
    {
      if (!Readn(1)) return false;
      size_t len = static_cast<size_t>(buffer[0]);
      if (!Readn(len)) return false;
      buffer[len] = '\0';
      if (!Resolve(buffer))
      {
        fprintf(stderr, "resolve failed\n");
        return false;
      }
      break;
    }
    default             :
    {
      fprintf(stderr, "invalid address family\n");
      return false;
    }
  }

  if (!Readn(2)) return false;

  if (dstAddr->sa_family == AF_INET)
  {
    memcpy(&reinterpret_cast<struct sockaddr_in*>(dstAddr)->sin_port,
          buffer, sizeof(uint16_t));
  }
  else
  {
    memcpy(&reinterpret_cast<struct sockaddr_in6*>(dstAddr)->sin6_port,
          buffer, sizeof(uint16_t));
  }

  return Connect();
}

bool Client::Relay(int readSock, int writeSock)
{
  ssize_t len = read(readSock, buffer, sizeof(buffer));
  if (len <= 0) return false;

  if (!::Writen(writeSock, buffer, len)) return false;

  return true;
}

void Client::Relay()
{
  fd_set set;
  int max = (srcSock > dstSock ? srcSock : dstSock) + 1;

  while (true)
  {
    FD_ZERO(&set);
    FD_SET(srcSock, &set);
    FD_SET(dstSock, &set);

    int n = select(max, &set, 0, 0, 0);
    if (n <= 0) break;

    if (FD_ISSET(srcSock, &set) && !Relay(srcSock, dstSock)) break;
    if (FD_ISSET(dstSock, &set) && !Relay(dstSock, srcSock)) break;
  }
}

void Client::Handle()
{
  if (!Accept()) return;
  if (!IPAllowed(ip))
  {
    fprintf(stderr, "connections not allowed from ip: %s\n", ip);
    return;
  }

  if (!Auth()) return;
  if (!Command()) return;
  Relay();
}


void* ThreadMain(void* arg)
{
  std::auto_ptr<Client> client(static_cast<Client*>(arg));
  client->Handle();
  return NULL;
}

// SERVER IMPLEMENTATION


bool Server::Listen(const char* ip, int port)
{
  socklen_t len;
  if (inet_pton(AF_INET, ip, &reinterpret_cast<struct sockaddr_in*>(addr)->sin_addr) == 1)
  {
    struct sockaddr_in* addr4 = reinterpret_cast<struct sockaddr_in*>(addr);
    addr4->sin_port = htons(port);
    addr4->sin_family = AF_INET;
    len = sizeof(struct sockaddr_in);
  }
  else
  if (inet_pton(AF_INET6, ip, &reinterpret_cast<struct sockaddr_in6*>(addr)->sin6_addr) == 1)
  {
    struct sockaddr_in6* addr6 = reinterpret_cast<struct sockaddr_in6*>(addr);
    addr6->sin6_port = htons(port);
    addr6->sin6_family = AF_INET6;
    len = sizeof(struct sockaddr_in6);
  }
  else
  {
    printf("invalid listen ip address\n");
    return false;
  }

  sock = socket(addr->sa_family, SOCK_STREAM, 0);
  if (sock < 0)
  {
    perror("socket");
    return false;
  }

  int optVal = 1;
  setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &optVal, sizeof(optVal));

  if (bind(sock, addr, len) < 0)
  {
    perror("bind");
    close(sock);
    sock = -1;
    return false;
  }

  if (listen(sock, 100) < 0)
  {
    perror("listen");
    close(sock);
    sock = -1;
    return false;
  }

  return true;
}

int Server::Accept(struct sockaddr& addr, socklen_t len)
{
  acceptMutex.Lock();
  int cliSock = accept(sock, &addr, &len);
  int errno_ = errno;
  acceptMutex.Unlock();

  poolMutex.Lock();
  ++poolClientsNeeded;
  poolCond.Signal();
  poolMutex.Unlock();

  errno = errno_;
  return cliSock;
}

void Server::LaunchClient()
{
  pthread_t threadID;
  pthread_attr_t attr;
  pthread_attr_init(&attr);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
  pthread_create(&threadID, &attr, ThreadMain, new Client(*this));
}

void Server::Handle()
{
  ScopeLock lock(poolMutex);
  while (true)
  {
    do
    {
      LaunchClient();
    }
    while (--poolClientsNeeded);
    poolCond.Wait(poolMutex);
  }
}

void DisableOutput()
{
  FILE* f1 = freopen("/dev/null", "w", stdout); (void) f1;
  FILE *f2 = freopen("/dev/null", "w", stderr); (void) f2;
}

int main(int argc, char** argv)
{
  bool foreground = false;
  if (argc >= 2 && !strcmp(argv[1], "-f")) foreground = true;

  Server server;
  if (!server.Listen(listenIP, listenPort)) return 1;

  printf("biosocks v2 listening on %s %i ..\n", listenIP, listenPort);
  if (foreground || !fork())
  {
    if (!foreground) DisableOutput();
    server.Handle();
  }

  return 0;
}