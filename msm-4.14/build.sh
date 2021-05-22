#!/bin/bash

# ./build.sh 2>&1 | tee ../msm-4.14.log

DEFCONFIG=2OP7-perf_defconfig

CLANG_PREBUILD_BIN=$(pwd)/../../toolchain/clang-9.0.5/bin/clang
LINUX_GCC_CROSS_COMPILE_PREBUILTS_BIN=$(pwd)/../../toolchain/xanaxdroid-aarch64-8.0/bin
DTC_EXT=$(pwd)/../../toolchain/dtc-1.4.6/dtc
MKBOOTIMG_PATH=$(pwd)/../../toolchain/mkbootimg

ORIGINAL_BOOT_FILE=op7_global_11.0.0.2-boot.img
EXRACT_BOOT_PATH=op7_global_11.0.0.2-boot

OUT_PATH=out
PART_SIZE_EXPECT=100663296
DTB_FILE=qcom/sm8150-v2.dtb
CLANG_TRIPLE=aarch64-linux-gnu-
CROSS_COMPILE=aarch64-linux-android-

THREADS=$(grep -c ^processor /proc/cpuinfo)
BUILD_CROSS_COMPILE=$LINUX_GCC_CROSS_COMPILE_PREBUILTS_BIN/$CROSS_COMPILE

################################################################################################

# extract original boot image
if [ -d "$EXRACT_BOOT_PATH" ]; then
     rm -rf $EXRACT_BOOT_PATH
fi
mkdir $EXRACT_BOOT_PATH && $MKBOOTIMG_PATH/unpackbootimg -i $ORIGINAL_BOOT_FILE -o $EXRACT_BOOT_PATH

# remove old build
if [ -f "boot.img" ]; then
    rm "boot.img"
fi

# prepare out folder
rm -rf $OUT_PATH && mkdir $OUT_PATH

# establish defconfig
make O=$OUT_PATH ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE CC=$CLANG_PREBUILD_BIN CLANG_TRIPLE=$CLANG_TRIPLE $DEFCONFIG

# compile
make O=$OUT_PATH ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE CC=$CLANG_PREBUILD_BIN CLANG_TRIPLE=$CLANG_TRIPLE DTC_EXT=$DTC_EXT -j$THREADS

# prepare boot image parameter for new boot image
echo
echo 'Making new "boot.img"'

kernel=$OUT_PATH/arch/arm64/boot/Image.gz
ramdisk=$EXRACT_BOOT_PATH/$ORIGINAL_BOOT_FILE-ramdisk
cmdline=$(cat "$EXRACT_BOOT_PATH/$ORIGINAL_BOOT_FILE-cmdline")
base=$(cat "$EXRACT_BOOT_PATH/$ORIGINAL_BOOT_FILE-base")
pagesize=$(cat "$EXRACT_BOOT_PATH/$ORIGINAL_BOOT_FILE-pagesize")
kernel_offset=$(cat "$EXRACT_BOOT_PATH/$ORIGINAL_BOOT_FILE-kernel_offset")
ramdisk_offset=$(cat "$EXRACT_BOOT_PATH/$ORIGINAL_BOOT_FILE-ramdisk_offset")
second_offset=$(cat "$EXRACT_BOOT_PATH/$ORIGINAL_BOOT_FILE-second_offset")
tags_offset=$(cat "$EXRACT_BOOT_PATH/$ORIGINAL_BOOT_FILE-tags_offset")
dtb=$OUT_PATH/arch/arm64/boot/dts/$DTB_FILE
dtb_offset=$(cat "$EXRACT_BOOT_PATH/$ORIGINAL_BOOT_FILE-dtb_offset")
os_version=$(cat "$EXRACT_BOOT_PATH/$ORIGINAL_BOOT_FILE-os_version")
os_patch_level=$(cat "$EXRACT_BOOT_PATH/$ORIGINAL_BOOT_FILE-os_patch_level")
header_version=$(cat "$EXRACT_BOOT_PATH/$ORIGINAL_BOOT_FILE-header_version")

echo kernel=$kernel
echo ramdisk=$ramdisk
echo cmdline=$cmdline
echo base=$base
echo pagesize=$pagesize
echo kernel_offset=$kernel_offset
echo ramdisk_offset=$ramdisk_offset
echo second_offset=$second_offset
echo tags_offset=$tags_offset
echo dtb=$dtb
echo dtb_offset=$dtb_offset
echo os_version=$os_version
echo os_patch_level=$os_patch_level
echo header_version=$header_version

# make new boot image
$MKBOOTIMG_DIR/mkbootimg \
    --kernel "${kernel}" \
    --ramdisk "${ramdisk}" \
    --cmdline "${cmdline}" \
    --base "${base}" \
    --pagesize "${pagesize}" \
    --kernel_offset "${kernel_offset}" \
    --ramdisk_offset "${ramdisk_offset}" \
    --second_offset "${second_offset}" \
    --tags_offset "${tags_offset}" \
    --dtb "${dtb}" \
    --dtb_offset "${dtb_offset}" \
    --os_version "${os_version}" \
    --os_patch_level "${os_patch_level}" \
    --header_version "${header_version}" \
    -o "boot.img"
echo 'New boot image has been written to "boot.img"'
rm -rf $EXRACT_BOOT_PATH

# Check if original boot image has the expected size
if [ "$(stat --printf="%s" $ORIGINAL_BOOT_FILE)" != "$PART_SIZE_EXPECT" ]; then
    echo warning: $'"'$ORIGINAL_BOOT_FILE$'"' does not match expected size of $PART_SIZE_EXPECT
fi

# Check if new boot image is too big
if [[ $(stat --printf="%s" "boot.img") -gt $PART_SIZE_EXPECT ]]; then
    echo error: $'"boot.img"' size is larger then the partition size of $PART_SIZE_EXPECT
    exit 1
fi

echo done.
