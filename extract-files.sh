#!/bin/bash
#
# Copyright (C) 2021-2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=deen
VENDOR=motorola

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        # Camera shim
        system_ext/lib64/lib-imscamera.so | system_ext/lib64/lib-imsvideocodec.so | system_ext/lib/lib-imscamera.so | system_ext/lib/lib-imsvideocodec.so | vendor/lib/libmot_gpu_mapper.so)
            for LIBGUI_SHIM in $(grep -L "libgui_shim.so" "${2}"); do
                "${PATCHELF}" --add-needed "libgui_shim.so" "${LIBGUI_SHIM}"
            done
            ;;
        vendor/lib/libmot_gpu_mapper.so)
            for LIBGUI_SHIM in $(grep -L "libgui_shim_vendor.so" "${2}"); do
                "${PATCHELF}" --add-needed "libgui_shim_vendor.so" "${LIBGUI_SHIM}"
            done
            ;;
        # Fix camera recording
        vendor/lib/libmmcamera2_pproc_modules.so)
            sed -i "s/ro.product.manufacturer/ro.product.nopefacturer/" "${2}"
            ;;
        # Wrap libgui_vendor into libwui
        vendor/lib/libmot_gpu_mapper.so)
            sed -i "s/libgui/libwui/" "${2}"
            ;;
        vendor/lib/libmmcamera_vstab_module.so)
            sed -i "s/libgui/libwui/" "${2}"
            ;;
        # Fix xml version
        product/etc/permissions/vendor.qti.hardware.data.connection-V1.0-java.xml | product/etc/permissions/vendor.qti.hardware.data.connection-V1.1-java.xml)
            sed -i 's/xml version="2.0"/xml version="1.0"/' "${2}"
            ;;
        # Missing symbols for ril
        vendor/lib64/libril-qc-hal-qmi.so)
            for  LIBCUTILS_SHIM in $(grep -L "libcutils_shim.so" "${2}"); do
                "${PATCHELF}" --add-needed "libcutils_shim.so" "$LIBCUTILS_SHIM"
            done
	    ;;
        # qsap shim
        vendor/lib64/libmdmcutback.so)
            for  LIBQSAP_SHIM in $(grep -L "libqsap_shim.so" "${2}"); do
                "${PATCHELF}" --add-needed "libqsap_shim.so" "$LIBQSAP_SHIM"
            done
            ;;
        # memset shim
        vendor/bin/charge_only_mode)
            for  LIBMEMSET_SHIM in $(grep -L "libmemset_shim.so" "${2}"); do
                "${PATCHELF}" --add-needed "libmemset_shim.so" "$LIBMEMSET_SHIM"
            done
	    ;;
        # Missing symbols
        vendor/lib/mediadrm/libwvhidl.so | vendor/mediadrm/lib64/libwvhidl.so)
           "${PATCHELF}" --replace-needed "libprotobuf-cpp-lite.so" "libprotobuf-cpp-lite-v29.so" "${2}"
           ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"

# Remove libhwbinder - libhidltransport depedencies
for i in $(grep -rn 'libhidltransport.so\|libhwbinder.so' ../../../vendor/motorola/"${DEVICE}"/proprietary | awk '{print $3}'); do
	patchelf --remove-needed "libhwbinder.so" "$i"
	patchelf --remove-needed "libhidltransport.so" "$i"
done
