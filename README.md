# TWRP Device configuration for Motorola Moto X4 (payton)

Copyright 2018 - The OmniROM Project
Copyright 2022 - The TeamWin Recovery Project

For building TWRP for Motorola Moto X4 ONLY.

### Kernel Source
https://github.com/moto-SDM660/android_kernel_motorola_sdm660/tree/twrp-11

### Device specifications
=====================================

Basic   | Spec Sheet
-------:|:-------------------------
CPU     | Octa-core (8x2.21 GHz Cortex A53)
CHIPSET | Qualcomm SDM630 Snapdragon 630
GPU     | Adreno 508
Memory  | 3, 4, 6 GB
Shipped Android Version | 7.1.1 (Nougat)
Storage | 32, 64GB
Battery | 3000 mAh
Dimensions | 148.4 x 73.4 x 8 mm
Display | 1080 x 1920 pixels, 5.2" LTPS IPS LCD
Rear Camera  | Dual 12 MP
Front Camera | 8 MP

<p align="center">
<img height="600" src="https://i.imgur.com/pEEUbfS.png" title="Motorola Moto X4 (payton)"/>
</p>

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
  <project name="android_device_motorola_payton" path="device/motorola/payton" remote="TeamWin" revision="android-11"/>
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
lunch twrp_payton-eng
make adbd bootimage
```
