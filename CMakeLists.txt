#A very simple root cmake, we want to build a simple executable linking one zig library
cmake_minimum_required(VERSION 3.22.1)
project("cmake-zig")

#add zig sub folder which should build our myziglib target
add_subdirectory(zig)

#building a simple c executable linking our target
add_executable(my_c_exe main.c)
target_link_libraries(my_c_exe
    PRIVATE myziglib)

#building a simple cpp executable linking our target
add_executable(my_cpp_exe main.cpp)
target_link_libraries(my_cpp_exe
    PRIVATE myziglib)
