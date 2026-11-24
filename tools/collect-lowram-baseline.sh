#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail
command -v adb >/dev/null
adb wait-for-device
model="$(adb shell getprop ro.product.model | tr -d '\r')"
if [[ "$model" != SM-T290 ]]; then
    echo "Expected SM-T290, got $model" >&2
    exit 1
fi
out="${1:-gtowifi-baseline-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out"
capture() {
    local name="$1"; shift
    adb shell "$@" > "$out/$name.txt" 2>&1 || echo "Capture failed: $name" >&2
}
capture build getprop ro.build.fingerprint
capture lowram getprop ro.config.low_ram
capture meminfo cat /proc/meminfo
capture swaps cat /proc/swaps
capture zram cat /sys/block/zram0/mm_stat
capture pressure cat /proc/pressure/memory
capture vmstat cat /proc/vmstat
capture processes dumpsys meminfo
capture thermal dumpsys thermalservice
capture lmkd logcat -d -s lmkd
capture selinux getenforce
echo "Diagnostics saved locally in $out. Review before sharing."
