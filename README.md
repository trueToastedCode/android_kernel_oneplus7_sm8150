## Info
- Version: Android 10 (Q)
- Sync: Oxygen 10.3.5 - 10.3.8
- Kernel: msm-4.14.117
## Steps to do
#### Install dependencies
(Not shure if all are required)
```
sudo apt-get install dkms linux-headers-$(uname -r) git python2 ccache automake flex lzop bison gperf build-essential zip curl zlib1g-dev zlib1g-dev:i386 g++-multilib libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng maven libssl-dev pwgen libswitch-perl policycoreutils minicom libxml-sax-base-perl libxml-simple-perl bc libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev xsltproc unzip v4l2loopback-dkms libfdt-dev
```
```
sudo ln -s /usr/bin/python2 /usr/bin/python
```
#### Setup enviroment structure and kernel
```
mkdir android && cd android && git clone --depth 1 -b 117Q/msm-4.14 https://github.com/trueToastedCode/android_kernel_oneplus7_sm8150.git kernel
```
#### Setup toolchain
```
cd kernel/msm-4.14 && bash setup-toolchain.sh
```
## Compilation
#### Full build with flashable zip
```
./build.sh 2>&1 | tee ../msm-4.14.log
```
#### Only kernel headers
```
./build-headers.sh 2>&1 | tee ../msm-4.14_headers.log
```
So ```msm-4.14*_headers.log``` is a dir level above the kernel and contains the log
#### Notes
- ```OP7-perf_defconfig``` comes from 10.3.5 global kernel (and is the same as the 10.3.8 global kernel config)
- ```2OP7-perf_defconfig``` the module singing is deactivated, ```CONFIG_BUILD_ARM64_DT_OVERLAY=y``` and compressed gzip creation is activated

## Sources
- https://github.com/OnePlusOSS/android_vendor_oneplus_opensource_kernel
- https://github.com/OnePlusOSS/android_vendor_qcom_opensource_audio_kernel_sm8150
- https://github.com/OnePlusOSS/android_kernel_oneplus_sm8150
