# SM-T290 low-memory experiment

Status: source changes only; not compiled or hardware validated.

Use the upstream README build instructions, but ensure the local manifest entry for device/samsung/gtowifi_mainline points to RoBroncos/gtowifi_lineageos at dev/lowram (keep other projects unchanged). Verify the checked-out device tree before building.

Build baseline with GTOWIFI_LOW_RAM unset, then experimental build with export GTOWIFI_LOW_RAM=true before breakfast. Use separate OUT_DIR values and the same source revisions and build variant. Check the generated system build properties for ro.config.low_ram=true in the experimental image and check for duplicate/conflicting assignments. Keep the upstream 1 GiB LZ4 zram setup, SELinux and suspend configuration unchanged.

Prefer the upstream microSD development layout and RAM boot on an already prepared, unlocked device. Back up data first; bootloader unlocking wipes data and preparing the SD card erases that card. Do not flash experimental images to internal storage.

For each build run bash tools/collect-lowram-baseline.sh from a host with adb. Collect after a five-minute idle period and after identical app-switching, browser and video workloads. Compare available memory, zram usage, memory pressure, LMKD kills, app reloads and responsiveness. Review diagnostics before sharing.

Release gates: successful build and boot, SELinux enforcing, working Wi-Fi/audio/cameras/touch, repeated suspend/resume, overnight battery measurement and no regression in app switching. Check notification delivery and UI features affected by low-RAM mode. Do not claim improvement until measured. If low-RAM mode regresses usability, rebuild with the flag unset.
