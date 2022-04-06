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

const char* GLFTPD_LOG      = "/glftpd/ftp-data/logs/glftpd.log";
const char* XFER_LOG        = "/glftpd/ftp-data/logs/xferlog";
key_t       IPC_KEY         = 0xDEADBABE;
const int   SNAPSHOTS[]     = { 1, 5, 10, 15, 20, 25, 30 }; // seconds
const long  REFRESH_RATE    = 50000; // microseconds
const int   CUT_OFF         = 60; // seconds
