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
#     ANDROID_NDK_VERSION - Android NDK version to use (20.0.5594570)
#     ANDROID_NDK         - path to Android NDK        ($ANDROID_HOME/ndk/$ANDROID_NDK_VERSION)
#     ANDROID_HOME        - path to Android SDK        ($HOME/android-sdk)
#     GMP_PATH            - where to install GMP       (/opt/gmp)

set -eu

ANDROID_API=${ANDROID_API:-21}
ANDROID_HOME=${ANDROID_HOME:-$HOME/android-sdk}
ANDROID_NDK_VERSION=${ANDROID_NDK_VERSION:-20.0.5594570}
ANDROID_NDK=${ANDROID_NDK:-$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION}

#   ABI         target triplet              compiler toolchain
ANDROID_TARGETS="
    arm64-v8a   aarch64-linux-android       aarch64-linux-android
    armeabi-v7a armv7a-linux-androideabi    arm-linux-androideabi
    x86         i686-linux-android          i686-linux-android
    x86_64      x86_64-linux-android        x86_64-linux-android
"

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
for abi in $(echo "$ANDROID_TARGETS" | awk '{print $1}'); do
    target=$(echo "$ANDROID_TARGETS"    | awk -v abi=$abi '$1 == abi {print $2}')
    toolchain=$(echo "$ANDROID_TARGETS" | awk -v abi=$abi '$1 == abi {print $3}')
    compiler=$target$API
    echo "Building GMP for $target..."
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
        --prefix=$GMP_PATH/$abi
    make -j$(nproc)
    sudo make install
    cd ..
done
