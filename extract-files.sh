#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

function blob_fixup() {
    case "${1}" in
        odm/lib64/libAlgoProcess.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "android.hardware.graphics.common-V1-ndk_platform.so" "android.hardware.graphics.common-V5-ndk.so" "${2}"
            ;;
        odm/lib64/libCOppLceTonemapAPI.so|odm/lib64/libaps_frame_registration.so|odm/lib64/libYTCommon.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libstdc++.so" "libstdc++_vendor.so" "${2}"
            ;;
        vendor/overlayfs/in/lib64/hw/com.qti.chi.override.so)
            [ "$2" = "" ] && return 0
            grep -q libcamera_metadata_shim.so "${2}" || "${PATCHELF}" --add-needed libcamera_metadata_shim.so "${2}"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

function blob_fixup_dry() {
    blob_fixup "$1" ""
}

# If we're being sourced by the common script that we called,
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

export DEVICE=oscar
export DEVICE_COMMON=sm6375-common
export VENDOR=realme
export VENDOR_COMMON=${VENDOR}

"./../../${VENDOR_COMMON}/${DEVICE_COMMON}/extract-files.sh" "$@"
