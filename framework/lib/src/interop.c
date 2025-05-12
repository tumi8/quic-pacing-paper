#include "interop.h"

#include <signal.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <sys/time.h>
#include <string.h>

#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

static void print_help() {
    printf("Help for interop library:\n");
    printf("\t-s <client>,<server>\t\tThis path is used to create a socket. If a socket path is provide the program will hold on begin() and end()\n");
    printf("\t-f <file>\t\tThe file to write the start and end time to\n");
}

static FILE *file = NULL;
static bool hold = false;
static uint64_t start_time = 0;
static int socket_fd = 0;
static struct sockaddr_un addr_client = {0};
static struct sockaddr_un addr_server = {0};

int parse_socket(char *optarg) {
    const char delim[2] = ",";

    char *client = strtok(optarg, delim);
    char *server = strtok(NULL, delim);
    if(!server){
        return -1;
    }  
    strncpy(addr_client.sun_path, client, sizeof(addr_client.sun_path));
    strncpy(addr_server.sun_path, server, sizeof(addr_server.sun_path));

    char *other = strtok(NULL, delim);
    return other != NULL; 
}

int interop_init(int argc, char **argv) {
    //getopt
    int opt;

    while ((opt = getopt(argc, argv, ":s:f:")) != -1) {
        switch (opt) {
            case 's':

                hold = true;
                int err = parse_socket(optarg);
                if(err) {
                    return -1;
                }
                break;
            case 'f':
                file = fopen(optarg, "w");
                if(!file) {
                    perror("fopen: ");
                    return -1;
                }
                break;
            case ':':
                if(optopt != 's') {
                    return -1;
                }
                break;
            default:
                print_help();
                return -1;
                break;
        }
    }

    if(!hold) {
        return 0;
    }

    //Create socket for communication if hold is set
    if(!addr_client.sun_path[0] || !addr_server.sun_path[0]) {
        fprintf(stderr, "No client and/or server socket path was given.\n");
        return -1;
    }

    return 0;
}

static int read_any() {
    char buf[1];
    int err = recv(socket_fd, buf, 1, 0);
    if(err < 0) {
        perror("read: ");
        return -1;
    }
    return err;
}

static int notify_wait() {
    //Send to let server know the client is ready
    char send = 1;
    int err = write(socket_fd, &send, 1);
    if(err < 0) {
        perror("write: ");
        return -1;
    }

    //Wait till the server executes all scripts and notifies the client
    err = read_any();
    if(err < 0) {
        return err;
    }

    return 0;
}

int overwrite_start_time() {
    //Get starting time
    struct timeval now;
    gettimeofday(&now, NULL);
    start_time = now.tv_sec * 1000000000 + now.tv_usec * 1000;

    return 0;
}

int begin() {
    if(hold) {
        //Create socket & conenct/bind
        socket_fd = socket(AF_UNIX, SOCK_DGRAM, 0);
        if(socket_fd < 1) {
            perror("socket: ");
            return -1;
        }
        addr_client.sun_family = AF_UNIX;
        addr_server.sun_family = AF_UNIX;
        unlink(addr_client.sun_path);
        int err = bind(socket_fd, (struct sockaddr*)&addr_client, sizeof(addr_client));
        if(err) {
            perror("bind: ");
            return -1;
        }
        err = connect(socket_fd, (struct sockaddr*)&addr_server, sizeof(addr_server));
        if(err) {
            perror("connect: ");
            return -1;
        }

        err = notify_wait();
        if(err) {
            return err;
        }
        
    }


    //Get starting time
    struct timeval now;
    gettimeofday(&now, NULL);
    start_time = now.tv_sec * 1000000000 + now.tv_usec * 1000;

    return 0;
}

int end() {
    //Get end time
    struct timeval now;
    gettimeofday(&now, NULL);
    uint64_t end_time = now.tv_sec * 1000000000 + now.tv_usec * 1000;

    if(hold) {
        int err = notify_wait();
        if(err) {
            return err;
        }
    }

    //Write time to file
    if(file) {
        int err = fprintf(file, "{\"start\": %lu, \"end\": %lu}\n", start_time, end_time);
        if(err < 0) {
            perror("fprintf: ");
            return -1;
        }
    }

    return 0;
}
