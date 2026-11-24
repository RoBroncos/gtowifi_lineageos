#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Install a legally obtained receiver APK as an ordinary Android app.
set -euo pipefail
if [[ $# != 1 || ! -f "$1" || "$1" != *.apk ]]; then
    echo "Usage: bash $0 /path/to/receiver.apk" >&2
    exit 2
fi
command -v adb >/dev/null
command -v apksigner >/dev/null
apksigner verify --print-certs "$1"
adb wait-for-device
model="$(adb shell getprop ro.product.model | tr -d '\r')"
[[ "$model" == SM-T290 ]] || { echo "Expected SM-T290, got $model" >&2; exit 1; }
echo "Verify the signing certificate against the trusted publisher before continuing."
read -r -p "Install this APK on the SM-T290? [y/N] " answer
[[ "$answer" == y || "$answer" == Y ]] || exit 0
adb install -r "$1"
echo "Open the receiver on the tablet and configure projection while parked."
