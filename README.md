Copyright 2022 - The TeamWin Recovery Project

TWRP Device Tree for Motorola One (Deen)
===========================================

The Motorola Motorola One (codenamed _"deen"_) is a mid-range smartphone from Motorola mobility.
It was announced on August 2018.

Basic   | Spec Sheet
-------:|:-------------------------
CPU     | Octa-core 2.0 GHz Cortex-A53
Chipset | Qualcomm MSM8953-PRO Snapdragon 625
GPU     | Adreno 506
Memory  | 4 GB RAM
Shipped Android Version | 8.1.0
Storage | 64 GB
MicroSD | Up to 256 GB
Battery | Li-Ion 3000mAh battery
Display | 720 x 1520 pixels, 5.9 inches (~287 ppi pixel density)
Camera  | 13 MP, 2160 pixels, panorama,depth sensor, PDAF ,flash LED

![Motorola One](https://cdn2.gsmarena.com/vv/pics/motorola/motorola-one-02.jpg "Motorola One")
### Kernel Source

https://github.com/jro1979oliver/kernel_motorola_deen/tree/android-11

## Compile

First repo init the twrp-11 tree (and necessary qcom dependencies):

```
mkdir ~/android/twrp-11
cd ~/android/twrp-11
repo init -u git://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11
mkdir -p .repo/local_manifests
curl https://raw.githubusercontent.com/TeamWin/buildtree_manifests/master/min-aosp-11/qcom.xml > .repo/local_manifests/qcom.xml
```

Then add to a local manifest (if you don't have .repo/local_manifest then make that directory and make a blank file and name it something like twrp.xml):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project name="osm0sis/twrp_abtemplate" path="bootable/recovery/installer" remote="github" revision="master"/>
  <project name="android_device_motorola_deen" path="device/motorola/deen" remote="jro1979oliver" revision="android-11"/>
</manifest>
```

Now you can sync your source:

```
repo sync
```

To automatically make the TWRP installer zip, you need to import this commit in the build/make path: https://gerrit.twrp.me/c/android_build/+/4964

Finally execute these:

```
. build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL=C
lunch twrp_deen-eng
make adbd bootimage
```
