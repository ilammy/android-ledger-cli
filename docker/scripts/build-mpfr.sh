#!/bin/bash
#
# Building MPFR library for Android
#
# See https://www.mpfr.org/mpfr-current/ for MPFR build instructions.
#
# See https://developer.android.com/ndk/guides/other_build_systems
# for instructions on doing Autotools-based builds for Android.
#
# MPFR requires GMP library to be installed. It is expected in the
# /opt directory, in per-target subdirectory.
#
# Environment variables:
#
#     ANDROID_API         - minimum target Android API (21)
#     ANDROID_NDK_VERSION - Android NDK version to use (20.0.5594570)
#     ANDROID_NDK         - path to Android NDK        ($ANDROID_HOME/ndk/$ANDROID_NDK_VERSION)
#     ANDROID_HOME        - path to Android SDK        ($HOME/android-sdk)
#     GMP_PATH            - path to GMP installation   (/opt/gmp)
#     MPFR_PATH           - where to install MPFR      (/opt/mpfr)

set -eu

ANDROID_API=${ANDROID_API:-21}
ANDROID_HOME=${ANDROID_HOME:-$HOME/android-sdk}
ANDROID_NDK_VERSION=${ANDROID_NDK_VERSION:-20.0.5594570}
ANDROID_NDK=${ANDROID_NDK:-$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION}

GMP_PATH=${GMP_PATH:-/opt/gmp}

#   ABI         target triplet              compiler toolchain
ANDROID_TARGETS="
    arm64-v8a   aarch64-linux-android       aarch64-linux-android
    armeabi-v7a armv7a-linux-androideabi    arm-linux-androideabi
    x86         i686-linux-android          i686-linux-android
    x86_64      x86_64-linux-android        x86_64-linux-android
"

MPFR_VERSION=4.0.2
MPFR_SHA_256=1d3be708604eae0e42d578ba93b390c2a145f17743a744d8f3f8c2ad5855a38a
MPFR_TARBALL=mpfr.tar.xz

echo "Downloading MPFR $MPFR_VERSION..."
wget -O $MPFR_TARBALL \
    https://www.mpfr.org/mpfr-current/mpfr-$MPFR_VERSION.tar.xz

CHECKSUM=$(shasum --algorithm 256 $MPFR_TARBALL | awk '{print $1}')
if [[ $CHECKSUM != $MPFR_SHA_256 ]]; then
    exec >2
    echo "MPFR tarball checksum mismatch!"
    exit 1
fi

echo "Extracting MPFR..."
tar xf $MPFR_TARBALL
cd mpfr-$MPFR_VERSION

export API=$ANDROID_API
export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64

mkdir build
cd build
for abi in $(echo "$ANDROID_TARGETS" | awk '{print $1}'); do
    target=$(echo "$ANDROID_TARGETS"    | awk -v abi=$abi '$1 == abi {print $2}')
    toolchain=$(echo "$ANDROID_TARGETS" | awk -v abi=$abi '$1 == abi {print $3}')
    compiler=$target$API
    echo "Building MPFR for $target..."
    mkdir $target
    cd $target
    export TARGET=$target
    export AR=$TOOLCHAIN/bin/$toolchain-ar
    export AS=$TOOLCHAIN/bin/$toolchain-as
    export CC=$TOOLCHAIN/bin/$compiler-clang
    export CXX=$TOOLCHAIN/bin/$compiler-clang++
    export LD=$TOOLCHAIN/bin/$toolchain-ld
    export RANLIB=$TOOLCHAIN/bin/$toolchain-ranlib
    export STRIP=$TOOLCHAIN/bin/$toolchain-strip
    ../../configure \
        --disable-shared \
        --host=$target \
        --with-gmp=$GMP_PATH/$abi \
        --prefix=$MPFR_PATH/$abi
    make -j$(nproc)
    sudo make install
    cd ..
done
