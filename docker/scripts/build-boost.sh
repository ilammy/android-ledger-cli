#!/bin/bash
#
# Build Boost for Android
#
# See https://github.com/moritz-wundke/Boost-for-Android/ and
# somewhere in https://www.boost.org/ for instructions.
#
# Environment variables:
#
#     ANDROID_API         - minimum target Android API (21)
#     ANDROID_NDK_VERSION - Android NDK version to use (20.0.5594570)
#     ANDROID_NDK         - path to Android NDK        ($ANDROID_HOME/ndk/$ANDROID_NDK_VERSION)
#     ANDROID_HOME        - path to Android SDK        ($HOME/android-sdk)
#     BOOST_VERSION       - Boost version to compile   (1.73.0)
#     BOOST_PATH          - where to install Boost     (/opt/boost)

set -eu

ANDROID_API=${ANDROID_API:-21}
ANDROID_HOME=${ANDROID_HOME:-$HOME/android-sdk}
ANDROID_NDK_VERSION=${ANDROID_NDK_VERSION:-20.0.5594570}
ANDROID_NDK=${ANDROID_NDK:-$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION}
BOOST_VERSION=${BOOST_VERSION:-1.73.0}
BOOST_PATH=${BOOST_PATH:-/opt/boost}

# Boost libraries to compile
# See ledger's CMakeLists.txt for the list
BOOST_LIBRARIES=date_time,filesystem,headers,system,iostreams,regex,test

# Note that only some combinations of Boost and NDK versions are supported.
# See Boost-for-Android/README.md for details.
#
# Furthermore, FindBoost scripts for CMake may require particular versions
# of CMake to fine particularly modern versions of Boost.
# See https://stackoverflow.com/questions/42123509/cmake-finds-boost-but-the-imported-targets-not-available-for-boost-version
# (We build and install appropriate CMake.)
#
# Yes, C++ dependency management is fucking amazing and I love it so much!

cd Boost-for-Android

./build-android.sh \
    --boost=$BOOST_VERSION \
    --target-version=$ANDROID_API \
    --with-libraries=$BOOST_LIBRARIES \
    "$ANDROID_NDK"

sudo mkdir "$BOOST_PATH"
sudo cp -r build/out/* "$BOOST_PATH"
