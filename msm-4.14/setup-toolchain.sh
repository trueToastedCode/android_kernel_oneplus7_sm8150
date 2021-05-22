#!/bin/bash

CLANG_GIT=https://gitlab.com/HDTC/gclang.git
CLANG_BRANCH=9.0.5-r353983e
CLANG_DIR=clang-9.0.5

GCC_GIT=https://bitbucket.org/xanaxdroid/aarch64-8.0.git
GCC_BRANCH=linaro
GCC_DIR=xanaxdroid-aarch64-8.0

DTC_GIT=https://git.kernel.org/pub/scm/utils/dtc/dtc.git
DTC_BRANCH=v1.4.6
DTC_DIR=dtc-1.4.6

MKBOOTIMG_GIT=https://github.com/osm0sis/mkbootimg.git
MKBOOTIMG_DIR=mkbootimg

########################################################

# prepare toolchain folder
if ! [ -d "../../toolchain" ]; then
    mkdir "../../toolchain"
else
    echo -n '"../../toolchain" exists, delete and continue (y/n)? '
    read inp
    if [ "$inp" != "y" ] && [ "$inp" != "Y" ]; then
        exit 1
    fi
    rm -rf "../../toolchain"
    mkdir "../../toolchain"
fi
cd "../../toolchain"

# clang
git clone --depth 1 -b $CLANG_BRANCH $CLANG_GIT $CLANG_DIR

# gcc
git clone --depth 1 -b $GCC_BRANCH $GCC_GIT $GCC_DIR

# dtc
git clone --depth 1 -b $DTC_BRANCH $DTC_GIT $DTC_DIR
cd $DTC_DIR
sed -i '/YYLTYPE yylloc;/d' dtc-lexer.l
make
cd ..

# mkbootimg
git clone $MKBOOTIMG_GIT $MKBOOTIMG_DIR
cd $MKBOOTIMG_DIR
make
cd ..

echo done.
