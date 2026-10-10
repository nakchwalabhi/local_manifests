#!/bin/bash
# =============================================================================
# fogos (Motorola moto g34 5G / SM6375 "blair") - kernel-platform build wrapper.
#
# Adapted from Samsung-QTI-Blair/android_kernel_platform_build_config:build.sh
# (the working gta9pwifi blair 6.1 reference). Only the device-specific values
# are changed for fogos:
#     MODEL         gta9pwifi -> fogos
#     MSM_ARCH      P86803AA1 -> blair   (matches build.config.msm.blair)
#     KERNEL_TARGET P86803AA1 -> blair
# Everything else (the prepare_vendor.sh / build_with_bazel.py flow) is Qualcomm's
# generic kernel-platform build and is unchanged.
#
# Place this file at the tree root (next to kernel_platform/) and run:
#     ./fogos-build.sh
# =============================================================================
set -e

START_TIME=$(date +%s)
echo "Build started at $(date)"

# ----------------------------------------------------------------------------
# Device / chipset
# ----------------------------------------------------------------------------
MODEL=fogos
TARGET_BOARD_PLATFORM=blair
TARGET_BUILD_VARIANT=user
# kernel target == the name of build.config.msm.<target> in the msm-kernel tree
KERNEL_TARGET=blair

# resolve tree root from this script's own location (so it runs from anywhere)
ANDROID_BUILD_TOP="$(cd "$(dirname "$0")" && pwd)"
export ANDROID_BUILD_TOP

export MSM_ARCH="${KERNEL_TARGET}"
export TARGET_BOARD_PLATFORM
export TARGET_BUILD_VARIANT
# TARGET_PRODUCT here is the kernel variant (gki), not an Android lunch target
export TARGET_PRODUCT=gki

# ----------------------------------------------------------------------------
# Output dirs
# ----------------------------------------------------------------------------
export ANDROID_PRODUCT_OUT="${ANDROID_BUILD_TOP}/out/target/product/${MODEL}"
export OUT_DIR="${ANDROID_BUILD_TOP}/out/msm-kernel-${KERNEL_TARGET}-${TARGET_PRODUCT}"
mkdir -p "${ANDROID_PRODUCT_OUT}" "${OUT_DIR}"

echo "Build environment:"
echo "  MODEL:               ${MODEL}"
echo "  KERNEL_TARGET:       ${KERNEL_TARGET}"
echo "  MSM_ARCH:            ${MSM_ARCH}"
echo "  TARGET_PRODUCT:      ${TARGET_PRODUCT}"
echo "  ANDROID_BUILD_TOP:   ${ANDROID_BUILD_TOP}"
echo "  OUT_DIR:             ${OUT_DIR}"

# ----------------------------------------------------------------------------
# External (DLKM) modules - built from kernel_platform/vendor
# (the android_kernel_motorola_sm6375-modules repo mounted at kernel_platform/vendor)
# ----------------------------------------------------------------------------
DLKM_OBJ="${ANDROID_PRODUCT_OUT}/obj/DLKM_OBJ/kernel_platform/vendor/qcom/opensource"

export KBUILD_EXTRA_SYMBOLS="\
${DLKM_OBJ}/mmrm-driver/Module.symvers \
${DLKM_OBJ}/mm-drivers/hw_fence/Module.symvers \
${DLKM_OBJ}/mm-drivers/sync_fence/Module.symvers \
${DLKM_OBJ}/mm-drivers/msm_ext_display/Module.symvers \
${DLKM_OBJ}/securemsm-kernel/Module.symvers"

export KBUILD_EXT_MODULES="\
../vendor/qcom/opensource/mm-drivers/msm_ext_display \
../vendor/qcom/opensource/mm-drivers/sync_fence \
../vendor/qcom/opensource/mm-drivers/hw_fence \
../vendor/qcom/opensource/mmrm-driver \
../vendor/qcom/opensource/securemsm-kernel \
../vendor/qcom/opensource/display-drivers/msm \
../vendor/qcom/opensource/audio-kernel \
../vendor/qcom/opensource/camera-kernel"

export MODNAME=audio_dlkm
export RECOMPILE_KERNEL=1

echo ""
echo "Invoking prepare_vendor.sh ${KERNEL_TARGET} ${TARGET_PRODUCT} ..."
echo ""
"${ANDROID_BUILD_TOP}/kernel_platform/build/android/prepare_vendor.sh" \
    "${KERNEL_TARGET}" "${TARGET_PRODUCT}"

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
echo ""
echo "Build finished at $(date)"
echo "Duration: $(( ELAPSED / 3600 ))h $(( (ELAPSED / 60) % 60 ))m $(( ELAPSED % 60 ))s"
echo "Output:   ${ANDROID_PRODUCT_OUT}"
