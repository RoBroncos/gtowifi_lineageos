#!/system/bin/sh
# WozOS native interface preview. No partition writes.
set -eu
[ "$(getprop ro.product.device)" = gtowifi ] || exit 1
[ "$(getprop ro.build.version.sdk)" = 35 ] || exit 1
case "${1:-status}" in
status)
 cmd overlay list --user 0
 cmd uimode night
 settings get secure theme_customization_overlay_packages
 ;;
preview)
 # Preview only; record existing overlays before making changes.
 cmd overlay list --user 0
 cmd uimode night yes
 ;;
*) echo "Usage: sh wozos-native.sh status|preview"; exit 2 ;;
esac
