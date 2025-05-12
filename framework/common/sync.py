#!/usr/bin/python3

import socket
import sys
import time

PORT = 11111
TIMEOUT = 40


hosts = {"dagda": "172.16.12.1", "nida": "172.16.9.1"}
args = sys.argv
if len(args) < 2:
    print("ERROR: hostname arg required")
    exit(1)
hostname = args[1]
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.settimeout(TIMEOUT)
s.bind((hosts[hostname], PORT))
if len(args) == 2:
    s.listen(16)
    c, addr = s.accept()
    c.close()
    s.close()
elif len(args) == 3:
    server = args[2]
    for i in range(TIMEOUT):
        try:
            s.connect((hosts[server], PORT))
            break
        except (ConnectionRefusedError, ConnectionAbortedError):
            time.sleep(1)
    s.close()
