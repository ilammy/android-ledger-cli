#!/bin/bash
#
# Building GMP library for Android
#
# See https://gmplib.org/ for GMP build instructions.
#
# See https://developer.android.com/ndk/guides/other_build_systems
# for instructions on doing Autotools-based builds for Android.
#
# Environment variables:
#
#     ANDROID_API         - minimum target Android API (21)
#     ANDROID_TARGETS     - Android CPU targets        ({aarch64,armv7a,i686,x86_64}-linux-android)
#     ANDROID_NDK_VERSION - Android NDK version to use (20.0.5594570)
#     ANDROID_NDK         - path to Android NDK        ($ANDROID_HOME/ndk/$ANDROID_NDK_VERSION)
#     ANDROID_HOME        - path to Android SDK        ($HOME/android-sdk)

set -eu

ANDROID_API=${ANDROID_API:-21}
ANDROID_TARGETS=${ANDROID_TARGETS:-aarch64-linux-android armv7a-linux-androideabi i686-linux-android x86_64-linux-android}
ANDROID_HOME=${ANDROID_HOME:-$HOME/android-sdk}
ANDROID_NDK_VERSION=${ANDROID_NDK_VERSION:-20.0.5594570}
ANDROID_NDK=${ANDROID_NDK:-$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION}

GMP_VERSION=6.2.0
GMP_SHA_256=258e6cd51b3fbdfc185c716d55f82c08aff57df0c6fbd143cf6ed561267a1526
GMP_TARBALL=gmp.tar.xz

echo "Downloading GMP $GMP_VERSION..."
wget -O $GMP_TARBALL \
    https://gmplib.org/download/gmp/gmp-$GMP_VERSION.tar.xz

CHECKSUM=$(shasum --algorithm 256 $GMP_TARBALL | awk '{print $1}')
if [[ $CHECKSUM != $GMP_SHA_256 ]]; then
    exec >2
    echo "GMP tarball checksum mismatch!"
    exit 1
fi

echo "Extracting GMP..."
tar xf $GMP_TARBALL
cd gmp-$GMP_VERSION

export API=$ANDROID_API
export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64

mkdir build
cd build
for target in $ANDROID_TARGETS; do
    echo "Building GMP for $target..."
    mkdir $target
    cd $target
    export TARGET=$target
    compiler=$TARGET$API
    toolchain=$TARGET
    # ARM is a bit special because historically it had common tools
    # but multiple compilers. Anyway, handle this special case...
    if [[ "$toolchain" = armv7a-linux-androideabi ]]; then
        toolchain=arm-linux-androideabi
    fi
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
        --prefix=/opt/gmp_$GMP_VERSION/$target
    make -j$(nproc)
    sudo make install
    cd ..
done
