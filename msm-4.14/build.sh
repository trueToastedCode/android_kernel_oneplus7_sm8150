#!/bin/bash

# ./build.sh 2>&1 | tee ../msm-4.14.log

REVISION=Q1
FINAL_ZIP_PATH=../WireKernel-r$REVISION-4.14.117.zip
DEFCONFIG=2OP7-perf_defconfig

CLANG_PREBUILD_BIN=$(pwd)/../../toolchain/clang-10.0.6/bin/clang
LINUX_GCC_CROSS_COMPILE_PREBUILTS_BIN=$(pwd)/../../toolchain/xanaxdroid-aarch64-8.0/bin
DTC_EXT=$(pwd)/../../toolchain/dtc-1.4.6/dtc
ANY_KERNEL_SAMPLE_PATH=../AnyKernel3.zip

OUT_PATH=out
CLANG_TRIPLE=aarch64-linux-gnu-
CROSS_COMPILE=aarch64-linux-android-

THREADS=$(grep -c ^processor /proc/cpuinfo)
BUILD_CROSS_COMPILE=$LINUX_GCC_CROSS_COMPILE_PREBUILTS_BIN/$CROSS_COMPILE

################################################################################################

# prepare
if ! [ -f $ANY_KERNEL_SAMPLE_PATH ];then
    echo '"'$ANY_KERNEL_SAMPLE_PATH'"' does not exist!
    exit 1
fi
rm -rf $OUT_PATH && mkdir $OUT_PATH

# establish defconfig
make O=$OUT_PATH ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$CLANG_PREBUILD_BIN CLANG_TRIPLE=$CLANG_TRIPLE $DEFCONFIG

# compile
make O=$OUT_PATH ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$CLANG_PREBUILD_BIN CLANG_TRIPLE=$CLANG_TRIPLE DTC_EXT=$DTC_EXT -j$THREADS

# make flashable zip
current_path=$(pwd)
temp_dir=$(mktemp -d)

cp $ANY_KERNEL_SAMPLE_PATH $FINAL_ZIP_PATH

# add setup script to flashable
echo "# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers
## AnyKernel setup
# begin properties
properties() { '
kernel.string=kernel.string=WireKernel r$REVISION by trueToastedCode @ xda-developers
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=OnePlus7
device.name2=OnePlus7Pro
device.name3=OnePlus7T
device.name4=OnePlus7TPro
device.name5=guacamoleb
device.name6=guacamole
device.name7=hotdogb
device.name8=hotdog
supported.versions=11
'; } # end properties
# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;
## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;
# Detect device and system
if ! [ -e /system/etc/buildinfo/oem_build.prop ]; then
  ui_print \" \"; ui_print \"Custom rom detected. Abort installation since they are unsupported!\";
  exit 1
fi
## AnyKernel install
dump_boot;
write_boot;
## end install" > "$temp_dir/anykernel.sh"

cd $temp_dir
zip -r "$current_path/$FINAL_ZIP_PATH" anykernel.sh
cd $current_path

# add kernel to flashable
cd "$OUT_PATH/arch/arm64/boot"
zip -r "$current_path/$FINAL_ZIP_PATH" Image.gz

# add dtb to flashable
cp dts/qcom/sm8150-v2.dtb "$temp_dir/dtb"
cd $temp_dir
zip -r "$current_path/$FINAL_ZIP_PATH" dtb

# clean up
rm -rf $temp_dir
echo Flashable zip has been written to '"'$FINAL_ZIP_PATH'"'
echo done.
