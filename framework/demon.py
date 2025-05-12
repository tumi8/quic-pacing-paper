#!/bin/python3

import socket
import argparse
import os

def execute(scripts: list[str]):
    for script in scripts:
        print("Executing script: " + script)
        os.system(script)

def bind(server_path: str) -> socket.socket:
    server = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
    if(os.path.exists(server_path)):
        os.unlink(server_path)
    server.bind(server_path)
    return server

def control(server: socket.socket, client_path: str, pre_path: list[str], post_path: list[str]):
    #Wait till server is ready
    server.recv(1)
    server.connect(client_path)

    #Execute scripts
    print("Executing pre scripts")
    execute(pre_path)

    #Send signal to server
    server.send(b"1")

    #Wait till server done with the execution
    server.recv(1)

    #Execute scripts
    print("Executing post scripts")
    execute(post_path)

    #Send signal to server
    server.send(b"1")

def main():
    def parse():
        parser = argparse.ArgumentParser()
        parser.add_argument(
            "-c", "--client",
            help="Path to the unix socket of the client",
            required=True
        )
        parser.add_argument(
            "-s", "--server",
            help="Path to the unix socket of the server",
            required=True
        )
        parser.add_argument(
            "-p", "--pre",
            default=[],
            nargs="*",
            metavar="SCRIPT",
            help="Path to a pre script to execute",
        )
        parser.add_argument(
            "-P", "--post",
            default=[],
            nargs="*",
            metavar="SCRIPT",
            help="Path to a post script to execute",
        )

        args = parser.parse_args()
        return args

    args = parse()

    server = bind(args.server)
    control(server, args.client, args.pre, args.post)

if __name__ == '__main__':
    main()
