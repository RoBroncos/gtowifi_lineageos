#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail
adb wait-for-device
model="$(adb shell getprop ro.product.model | tr -d '\r')"
[[ "$model" == SM-T290 ]] || { echo "Expected SM-T290, got $model" >&2; exit 1; }
out="${1:-gtowifi-projection-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out"
capture() {
    local name="$1"; shift
    adb shell "$@" > "$out/$name.txt" 2>&1 || echo "Capture failed: $name" >&2
}
capture features pm list features
capture codecs dumpsys media.codec
capture codec_services dumpsys media.resource_manager
capture usb dumpsys usb
capture display wm size
capture density wm density
capture wifi cmd wifi status
capture audio dumpsys audio
capture thermal dumpsys thermalservice
capture battery dumpsys battery
capture memory cat /proc/meminfo
capture pressure cat /proc/pressure/memory
capture abi getprop ro.product.cpu.abilist
capture selinux getenforce
echo "Saved local diagnostics in $out. Review for personal data before sharing."
echo "Codec service output alone does not prove hardware AVC decoding; verify during projection."
