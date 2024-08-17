#A very simple root cmake, we want to build a simple executable linking one zig library
cmake_minimum_required(VERSION 3.22.1)
project("cmake-zig")

#add zig sub folder which should build our myziglib target
add_subdirectory(zig)

#building a simple executable linking our target
add_executable(myexe main.c)
target_link_libraries(myexe
    PRIVATE myziglib)
