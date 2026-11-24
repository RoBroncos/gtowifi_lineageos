#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Run from the root of an already synced LineageOS 23.2 checkout.
set -eo pipefail
case "${1:-}" in
    baseline) unset GTOWIFI_LOW_RAM; profile=baseline ;;
    lowram) export GTOWIFI_LOW_RAM=true; profile=lowram ;;
    *) echo "Usage: bash $0 baseline|lowram" >&2; exit 2 ;;
esac
device=device/samsung/gtowifi_mainline
[[ -f build/envsetup.sh && -f "$device/lineage_gtowifi_mainline.mk" ]] || {
    echo "Run from the synced Android source root" >&2; exit 1;
}
grep -q GTOWIFI_LOW_RAM "$device/lineage_gtowifi_mainline.mk" || {
    echo "Custom device tree missing; check local manifests" >&2; exit 1;
}
export GTOWIFI_MAINLINE_SYSTEM_ON_SDCARD=true
export OUT_DIR="$PWD/out-gtowifi-$profile"
mkdir -p "$OUT_DIR"
repo manifest -r -o "$OUT_DIR/source-manifest.xml"
# Platform patches must already have been applied using upstream instructions.
source build/envsetup.sh
breakfast gtowifi_mainline userdebug
mka bootimage systemimage vendorimage vendor_dlkmimage
product_out="$(get_build_var PRODUCT_OUT)"
python3 "$device/tools/check-boot-layout.py" "$product_out/boot.img"
for image in boot.img system.img vendor.img vendor_dlkm.img; do
    test -s "$product_out/$image"
done
(cd "$product_out" && sha256sum boot.img system.img vendor.img vendor_dlkm.img > SHA256SUMS)
echo "Development images: $product_out"
echo "Not hardware validated. Do not flash internal storage."
