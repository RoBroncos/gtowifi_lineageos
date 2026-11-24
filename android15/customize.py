#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
import argparse, json, subprocess
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument("action", choices=["apply", "restore", "status"])
p.add_argument("--serial", required=True)
p.add_argument("--backup", type=Path, default=Path("gtowifi-settings-backup.json"))
p.add_argument("--profile", type=Path, default=Path(__file__).with_name("profile.json"))
a = p.parse_args()
def adb(*args):
    return subprocess.check_output(["adb","-s",a.serial,*args], text=True).strip()
def shell(*args):
    return adb("shell",*args)
if shell("getprop","ro.product.model") != "SM-T290" or shell("getprop","ro.product.device") != "gtowifi" or shell("getprop","ro.build.version.sdk") != "35" or not shell("getprop","ro.lineage.version").startswith("22.2"):
    p.error("Expected SM-T290 gtowifi running LineageOS 22.2 / Android 15")
allowed = {("global", "window_animation_scale"), ("global", "transition_animation_scale"), ("global", "animator_duration_scale")}
if a.action == "status":
    for ns,key in sorted(allowed):
        print(ns,key,shell("settings","get",ns,key))
elif a.action == "apply":
    profile=json.loads(a.profile.read_text())
    entries=[]
    for key,value in profile.items():
        ns="global"
        if (ns,key) not in allowed or str(value) not in {"0","0.5","1","1.0","2","2.0"}:
            p.error("Unsupported setting or value: "+key)
        entries.append({"namespace":ns,"key":key,"old":shell("settings","get",ns,key),"new":str(value)})
    with a.backup.open("x") as f:
        json.dump({"serial":a.serial,"entries":entries},f,indent=2)
    for e in entries:
        shell("settings","put",e["namespace"],e["key"],e["new"])
        if shell("settings","get",e["namespace"],e["key"]) != e["new"]:
            raise RuntimeError("Setting verification failed; run restore")
    print("Applied; original values saved in",a.backup)
else:
    backup=json.loads(a.backup.read_text())
    if backup["serial"] != a.serial:
        p.error("Backup belongs to another device")
    for e in backup["entries"]:
        ns,key,old=e["namespace"],e["key"],e["old"]
        if (ns,key) not in allowed or (old!="null" and (not isinstance(old,str) or not old.replace(".","",1).isdigit())):
            p.error("Unexpected backup entry")
    for e in backup["entries"]:
        ns,key,old=e["namespace"],e["key"],e["old"]
        if old=="null":
            shell("settings","delete",ns,key)
        else:
            shell("settings","put",ns,key,old)
    print("Original settings restored. Backup retained.")
