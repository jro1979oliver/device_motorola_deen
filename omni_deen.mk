#
# Copyright (C) 2015 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from our custom product configuration
$(call inherit-product, vendor/omni/config/common.mk)

# Inherit from deen device
$(call inherit-product, device/motorola/deen/device.mk)

# Platform
TARGET_BOARD_PLATFORM := msm8953

PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware.keystore=$(TARGET_BOARD_PLATFORM) \
    ro.hardware.bootctrl=$(TARGET_BOARD_PLATFORM) \
    ro.vendor.build.security_patch=2099-12-31 \

# Device identifier. This must come after all inclusions
PRODUCT_DEVICE := deen
PRODUCT_NAME := omni_deen
PRODUCT_BRAND := motorola
PRODUCT_MODEL := motorola one
PRODUCT_MANUFACTURER := motorola
