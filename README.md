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
mkdir android && cd android && git clone https://github.com/trueToastedCode/android_kernel_oneplus7_sm8150.git kernel
```
#### Setup toolchain
```
cd kernel/msm-4.14 && bash setup-toolchain.sh
```
## Compilation
```
./build.sh 2>&1 | tee ../msm-4.14.log
```
So ```msm-4.14.log``` is a dir level above the kernel and contains the log
#### Notes
- ```OP7-perf_defconfig``` comes from a real OP7 wihich ran on OOS 11.0.02 Global. 
- ```2OP7-perf_defconfig``` the module singing is deactivated, ```CONFIG_BUILD_ARM64_DT_OVERLAY=y``` and compressed gzip creation is activated
- For creating boot images, the script uses ```op7_global_11.0.0.2-boot.img``` as the source for the ramdisk and params. The kernel and ramdisk come from the output of the compilation

## Sources
- https://github.com/OnePlusOSS/android_vendor_oneplus_opensource_kernel
- https://github.com/OnePlusOSS/android_vendor_qcom_opensource_audio_kernel_sm8150
- https://github.com/OnePlusOSS/android_kernel_oneplus_sm8150
