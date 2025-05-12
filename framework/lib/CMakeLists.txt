cmake_minimum_required(VERSION 3.0)
project(InteropLib)

include_directories(include)

set (CMAKE_RUNTIME_OUTPUT_DIRECTORY bin/)
set(CMAKE_BUILD_TYPE Debug)
add_executable(test bin/client.c src/interop.c)
