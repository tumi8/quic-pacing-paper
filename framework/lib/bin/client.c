#include "interop.h"

#include <stdio.h>

int main(int argc, char **argv) {
    int n_processed = interop_init(argc, argv);
    if(n_processed < 0) {
        return -1;
    }
    argc -= n_processed;
    argv += n_processed;


    printf("Init done\n");
    int err = begin();
    if(err < 0) {
        return -1;
    }
    printf("Running\n");
    err = end();
    if(err < 0) {
        return -1;
    }
    printf("Done\n");
    return 0;
}
