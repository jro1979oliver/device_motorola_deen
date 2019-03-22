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
        # Use libprotobuf-cpp-lite-v29.so for libwvhidl.so
        vendor/lib64/libwvhidl.so)
            patchelf --replace-needed "libprotobuf-cpp-lite.so" "libprotobuf-cpp-lite-v29.so" "${2}"
            ;;
        # Missing symbols for ril
	vendor/lib64/libril-qc-hal-qmi.so)
	    patchelf --add-needed libcutils_shim.so "${2}"
	    ;;
        # Use libprotobuf-cpp-lite-v29.so for libril-qc-hal-qmi.so
        vendor/lib64/libril-qc-hal-qmi.so)
            patchelf --replace-needed "libprotobuf-cpp-full.so" "libprotobuf-cpp-full-v29.so" "${2}"
            ;;
        # memset shim
	vendor/bin/charge_only_mode)
	    patchelf --add-needed libmemset_shim.so "${2}"
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
