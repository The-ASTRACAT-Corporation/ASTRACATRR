# CMakeLists.txt for ASTRACAT Recursive Resolver

cmake_minimum_required(VERSION 3.10)
project(astracat-resolver C)

# Set C standard and compiler flags
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wpedantic")

# Find dependencies
find_package(PkgConfig REQUIRED)
pkg_check_modules(KRES libkres)
pkg_check_modules(LUA lua-5.3)

# Add options for build configuration
option(ENABLE_LUA "Enable Lua scripting support" ON)

# Configure include directories
include_directories(include)
include_directories(${KRES_INCLUDE_DIRS})

# Add source files
set(SOURCES
    src/main.c
    src/resolver.c
    src/cache.c
    src/hooks.c
    src/utils.c
)

# Add executable target
add_executable(astracat-resolver ${SOURCES})

# Link libraries
target_link_libraries(astracat-resolver ${KRES_LIBRARIES})

# Configure Lua support
if(ENABLE_LUA)
    target_compile_definitions(astracat-resolver PRIVATE -DENABLE_LUA)
    target_link_libraries(astracat-resolver ${LUA_LIBRARIES})
endif()

# Enable testing
enable_testing()

# Add test executable
add_executable(astracat-test tests/integration.sh)

# Add test targets
add_test(NAME integration-test COMMAND astracat-test)
add_test(NAME dnsperf-test COMMAND /bin/bash ${CMAKE_SOURCE_DIR}/tests/dnsperf.sh)


# Install target
install(TARGETS astracat-resolver DESTINATION bin)
