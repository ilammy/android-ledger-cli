cmake_minimum_required(VERSION 3.17.3)

project(Ledger)

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

# Add these paths to search prefixes so that these libraries can be found.
set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH}
    $ENV{GMP_PATH}/${ANDROID_ABI}
    $ENV{MPFR_PATH}/${ANDROID_ABI}
    CACHE FILEPATH "CMake search prefixes"
    FORCE)

# Tell Ledger build system to always build the library.
set(BUILD_LIBRARY ON CACHE BOOL "Build libledger.a" FORCE)

# Include Ledger build system.
add_subdirectory(ledger)

# Include JNI library.
add_subdirectory(jni)

# Android build system refuses to package non-libraries into APKs
# and Google refuses to care about that. The common workaround is
# to rename binaries so that they look like libraries.
set_target_properties(ledger
  PROPERTIES
    OUTPUT_NAME lib...ledger...so
)
