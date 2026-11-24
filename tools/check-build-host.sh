#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail
[[ "$(uname -s)" == Linux && "$(uname -m)" == x86_64 ]] || { echo "Linux x86_64 required" >&2; exit 1; }
for tool in git repo python3 java make; do
    command -v "$tool" >/dev/null || { echo "Missing $tool" >&2; exit 1; }
done
git lfs version
available=$(df -Pk . | awk 'NR==2 {print $4}')
ram=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
swap=$(awk '/SwapTotal:/ {print $2}' /proc/meminfo)
echo "CPU threads: $(nproc); RAM: $((ram/1048576)) GiB; swap: $((swap/1048576)) GiB; free disk: $((available/1048576)) GiB"
(( available >= 400*1048576 )) || { echo "Reserve at least 400 GiB for a fresh checkout and build" >&2; exit 1; }
(( ram+swap >= 32*1048576 )) || { echo "At least 32 GiB combined RAM and swap recommended" >&2; exit 1; }
case "$(stat -f -c %T .)" in
    9p|drvfs|fuseblk) echo "Use a native Linux filesystem, not a Windows-mounted drive" >&2; exit 1 ;;
esac
echo "Basic host preflight passed; upstream dependencies still required."
