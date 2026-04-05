cmake_minimum_required(VERSION 3.21)

project(simplecble VERSION 0.1.0 LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# The SimpleBLE repo is a monorepo, so we point to the simpleble subfolder
# We use EXCLUDE_FROM_ALL so SimpleBLE's own install rules don't clash with Flutter's build bundle.
add_subdirectory(simpleble/simpleble EXCLUDE_FROM_ALL)

add_library(simplecble SHARED 
    simplecble.cpp
    simplecble.h
)

target_link_libraries(simplecble PRIVATE simpleble::simpleble)

if (WIN32)
    set_target_properties(simplecble PROPERTIES
        COMPILE_PDB_NAME simplecble
    )
    # Flutter on Windows outputs everything to CMAKE_INSTALL_PREFIX (the app bundle)
    install(TARGETS simplecble RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND NOT ANDROID)
    # Flutter on Linux puts shared libraries in the lib/ folder of the bundle
    install(TARGETS simplecble LIBRARY DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" COMPONENT Runtime)
endif()
