#!/bin/bash

# ./build-headers.sh 2>&1 | tee ../msm-4.14_headers.log

DEFCONFIG=2OP7-perf_defconfig

CLANG_PREBUILD_BIN=$(pwd)/../../toolchain/clang-9.0.6/bin/clang
LINUX_GCC_CROSS_COMPILE_PREBUILTS_BIN=$(pwd)/../../toolchain/xanaxdroid-aarch64-8.0/bin
DTC_EXT=$(pwd)/../../toolchain/dtc-1.4.6/dtc

OUT_PATH=../kernel-headers
CLANG_TRIPLE=aarch64-linux-gnu-
CROSS_COMPILE=aarch64-linux-android-

BUILD_CROSS_COMPILE=$LINUX_GCC_CROSS_COMPILE_PREBUILTS_BIN/$CROSS_COMPILE

################################################################################################

# prepare out folder
rm -rf $OUT_PATH && mkdir $OUT_PATH

# establish defconfig
make O=$OUT_PATH ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$CLANG_PREBUILD_BIN CLANG_TRIPLE=$CLANG_TRIPLE $DEFCONFIG

# Prepare modules
make O=$OUT_PATH ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$CLANG_PREBUILD_BIN CLANG_TRIPLE=$CLANG_TRIPLE modules_prepare

# Make modules
make O=$OUT_PATH ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$CLANG_PREBUILD_BIN CLANG_TRIPLE=$CLANG_TRIPLE INSTALL_MOD_PATH=$OUT_PATH modules

# Install modules
make O=$OUT_PATH ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$CLANG_PREBUILD_BIN CLANG_TRIPLE=$CLANG_TRIPLE INSTALL_MOD_PATH=$OUT_PATH modules_install

# Install kernel headers
make O=$OUT_PATH ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$CLANG_PREBUILD_BIN CLANG_TRIPLE=$CLANG_TRIPLE INSTALL_HDR_PATH=$OUT_PATH headers_install
