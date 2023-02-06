#!/bin/sh

# Get script directory
if [ -L $0 ] ; then
    SCRIPT_DIR=$(dirname $(readlink -f $0)) ;
else
    SCRIPT_DIR=$(dirname $0) ;
fi ;

# Set dirs
BUILD_DIR=${SCRIPT_DIR}/../build
BIN_DIR=${BUILD_DIR}/bin

# Build llvm
if [ ! -d "${BUILD_DIR}" ]; then
  mkdir ${BUILD_DIR}
fi
cd ${BUILD_DIR}
cmake -G "Ninja" ../llvm/ -DLLVM_USE_LINKER=gold -DCMAKE_BUILD_TYPE=Release
ninja -j3
cd ../test_llvm_pass
echo ----------------------------------------------------

# Create ir from test file
clang -S -c -Xclang -O0 -emit-llvm test.c -o test.ll

# Run pass on ir
./${BIN_DIR}/opt -disable-output -passes=read-module test.ll