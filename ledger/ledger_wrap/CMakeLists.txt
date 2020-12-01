cmake_minimum_required(VERSION 3.10.2)

project(LedgerWrap)

# Docker image sets all these paths appropriately. Check it.
if(NOT DEFINED ENV{BOOST_PATH})
    message(ERROR "BOOST_PATH environment variable not set")
endif()
if(NOT DEFINED ENV{GMP_PATH})
    message(ERROR "GMP_PATH environment variable not set")
endif()
if(NOT DEFINED ENV{MPFR_PATH})
    message(ERROR "MPFR_PATH environment variable not set")
endif()

# Sometimes CMake creates more problems than it solves.
# In particular, FindBoost.cmake script has somewhat poor support
# of Boost installations in weird places used for cross-compilation.
# So we do part of its job and provide some hard hints about locations
# of "Boost CMake" scripts which will figure out the rest.
set(BOOST_ROOT $ENV{BOOST_PATH}/${ANDROID_ABI}
    CACHE PATH "Boost installation directory"
    FORCE)
set(Boost_USE_STATIC_LIBS ON
    CACHE BOOL "Use Boost static libraries"
    FORCE)
set(Boost_COMPILER "-clang"
    CACHE STRING "Boost compiler suffix"
    FORCE)
set(Boost_DIR ${BOOST_ROOT}/lib/cmake/Boost-1.73.0
    CACHE FILEPATH "Boost CMake directory (Boost)"
    FORCE)

# Android toolchain inserts NDK here and this messes up search paths
# if the variable has been empty. Ensure we look into the host system
# too, we need that to locate our non-NDK library builds.
set(CMAKE_FIND_ROOT_PATH "/" ${CMAKE_FIND_ROOT_PATH}
    CACHE FILEPATH "CMake find_something() search roots"
    FORCE)

# Add paths of dependencies to search prefixes so that they can be found.
set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH}
    $ENV{GMP_PATH}/${ANDROID_ABI}
    $ENV{MPFR_PATH}/${ANDROID_ABI}
    CACHE FILEPATH "CMake search prefixes"
    FORCE)

# Tell Ledger build system to always build the library.
set(BUILD_LIBRARY ON CACHE BOOL "Build libledger.a" FORCE)

# Include Ledger build system.
add_subdirectory(ledger)

# Include wrapper code.
add_subdirectory(src)
