#pragma once

/**
 * @brief Parses the command line arguments and initializes the interop library.
 * 
 * @param argc 
 * @param argv 
 * @return The number of arguments that were processed. If an error occured a negative value is returned. 
 */
int interop_init(int argc, char **argv);

/**
 * @brief This function creates a socket and waits until data becomes available.
 * This function is expected to be called once
 * 
 * @return 0 on success, any other value indicates an error.
 */
int begin();

/**
 * @brief This function waits until data becomes available and closes the socket.
 * If the -f option was given, the start end end time will be written to the file.
 * This function is expected to be called once
 * 
 * @return 0 on success, any other value indicates an error.
 */
int end();

/**
 * @brief This function overwrites the start time recorded with begin(). This is 
 * usefull if multiple connections are started but only one is used to measure goodput.
 * 
 */
int overwrite_start_time();

