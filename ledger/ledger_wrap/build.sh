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

build_debug=
build_release=
while [[ $# -ne 0 ]]; do
    case "$1" in
        --debug)
            build_debug=yes
            [[ -z "$build_release" ]] && build_release=no
            ;;
        --no-debug)
            build_debug=no
            [[ -z "$build_release" ]] && build_release=yes
            ;;
        --release)
            build_release=yes
            [[ -z "$build_debug" ]] && build_debug=no
            ;;
        --no-release)
            build_release=no
            [[ -z "$build_debug" ]] && build_debug=yes
            ;;
        *)
            echo 2>&1 "unknown option: $1"
            exit 1
            ;;
    esac
    shift
done
[[ -z "$build_debug" ]]   && build_debug=yes
[[ -z "$build_release" ]] && build_release=yes

CMAKE_MODES=
[[ "$build_debug"   = "yes" ]] && CMAKE_MODES="${CMAKE_MODES} Debug"
[[ "$build_release" = "yes" ]] && CMAKE_MODES="${CMAKE_MODES} Release"

mkdir -p build
mkdir -p lib

for target in $ANDROID_TARGETS; do
    for cmake_mode in $CMAKE_MODES; do
        mode=$(echo "$cmake_mode" | tr '[:upper:]' '[:lower:]')
        echo "Building for $target ($mode)..."
        echo

        echo "Configuring..."
        mkdir -p "build/$mode/$target"
        cd "build/$mode/$target"
        $ANDROID_CMAKE_PATH/cmake -GNinja \
            -DCMAKE_BUILD_TYPE=$cmake_mode \
            -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
            -DANDROID_ABI=$target \
            -DANDROID_PLATFORM=android-$ANDROID_API \
            ../../..
        echo

        echo "Building..."
        $ANDROID_CMAKE_PATH/ninja libledger_amalgam.a
        cd ../../..
        mkdir -p "lib/$mode/$target"
        ln -f "build/$mode/$target/libledger_amalgam.a" "lib/$mode/$target"
        echo

        echo "Done with $target ($mode)"
        echo
    done
done

if [[ -z "$CMAKE_MODES" ]]; then
    echo "Nothing to build"
else
    for target in $ANDROID_TARGETS; do
        echo -n "Complete: "
        mode=
        for cmake_mode in $CMAKE_MODES; do
            [[ ! -z "$mode" ]] && echo -n ", "
            mode=$(echo "$cmake_mode" | tr '[:upper:]' '[:lower:]')
            echo -n "$mode"
        done
        echo -n ": $target"
        echo
    done
fi
echo
