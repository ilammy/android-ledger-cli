#!/bin/bash
#
# Building Ledger amalgamation library for Android
#
# Environment variables:
#
#     ANDROID_API         - minimum target Android API (21)
#     ANDROID_NDK_VERSION - Android NDK version to use (20.0.5594570)
#     ANDROID_NDK         - path to Android NDK        ($ANDROID_HOME/ndk/$ANDROID_NDK_VERSION)
#     ANDROID_HOME        - path to Android SDK        ($HOME/android-sdk)
#     ANDROID_CMAKE_PATH  - path to Android CMake      ($ANDROID_HOME/cmake/3.10.2.4988404/bin)
#     BOOST_PATH          - path to Boost installation (/opt/boost)
#     GMP_PATH            - path to GMP installation   (/opt/gmp)
#     MPFR_PATH           - path to MPFR installation  (/opt/mpfr)

set -eu

ANDROID_API=${ANDROID_API:-21}
ANDROID_HOME=${ANDROID_HOME:-$HOME/android-sdk}
ANDROID_NDK_VERSION=${ANDROID_NDK_VERSION:-20.0.5594570}
ANDROID_NDK=${ANDROID_NDK:-$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION}
ANDROID_CMAKE_PATH=${ANDROID_CMAKE_PATH:-$ANDROID_HOME/cmake/3.10.2.4988404/bin}

ANDROID_TARGETS="arm64-v8a armeabi-v7a x86 x86_64"

mkdir -p build
mkdir -p lib

for target in $ANDROID_TARGETS; do
    echo "Building for $target..."
    echo

    echo "Configuring..."
    mkdir -p "build/$target"
    cd "build/$target"
    $ANDROID_CMAKE_PATH/cmake -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
        -DANDROID_ABI=$target \
        -DANDROID_PLATFORM=android-$ANDROID_API \
        ../..
    echo

    echo "Building..."
    $ANDROID_CMAKE_PATH/ninja libledger_amalgam.a
    cd ../..
    mkdir -p "lib/$target"
    ln -f "build/$target/libledger_amalgam.a" "lib/$target"
    echo

    echo "Done with $target"
    echo
done
