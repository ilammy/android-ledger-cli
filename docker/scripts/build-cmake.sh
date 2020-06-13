#!/bin/bash
#
# Building CMake
#
# Recent versions of Boost require recent versions of CMake which we are
# not going to find in Debian 9 host or Android SDK toolset.
#
# Thankfully, we need to build it only for the host architecture.

set -eu

CMAKE_VERSION=3.17.3
CMAKE_SHA_256=0bd60d512275dc9f6ef2a2865426a184642ceb3761794e6b65bff233b91d8c40
CMAKE_TARBALL=cmake.tar.gz

echo "Downloading CMake $CMAKE_VERSION..."
wget -O $CMAKE_TARBALL \
    https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz

CHECKSUM=$(shasum --algorithm 256 $CMAKE_TARBALL | awk '{print $1}')
if [[ $CHECKSUM != $CMAKE_SHA_256 ]]; then
    exec >2
    echo "CMake tarball checksum mismatch!"
    exit 1
fi

echo "Extracting CMake..."
tar xf $CMAKE_TARBALL
cd cmake-$CMAKE_VERSION

echo "Bootstapping CMake..."
./bootstrap --prefix=/usr/local --parallel=$(nproc)

echo "Building CMake..."
make -j$(nproc)
sudo make install
