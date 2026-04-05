cmake_minimum_required(VERSION 3.10)

project(simplecble VERSION 0.1.0 LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Assuming SimpleBLE is installed or available as a submodule
# find_package(simpleble REQUIRED)

add_library(simplecble SHARED 
    simplecble.cpp
    simplecble.h
)

# target_link_libraries(simplecble PRIVATE simpleble::simpleble)

if (WIN32)
    set_target_properties(simplecble PROPERTIES
        COMPILE_PDB_NAME simplecble
    )
endif()

# Installation logic for Flutter Native Assets would go here if using the new system
# Otherwise, binaries are manually placed in macos/Frameworks, android/app/src/main/jniLibs, etc.
