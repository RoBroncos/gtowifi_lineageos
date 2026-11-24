#!/usr/bin/env python3
import argparse, subprocess, json
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument("--serial", required=True)
p.add_argument("--output",type=Path,default=Path("device-inventory.json"))
a=p.parse_args()
def read(*args):
    r=subprocess.run(["adb","-s",a.serial,"shell",*args],capture_output=True,text=True,timeout=60)
    return {"output":r.stdout.strip(),"error":r.stderr.strip(),"code":r.returncode}
if read("getprop","ro.product.model")["output"]!="SM-T290" or read("getprop","ro.build.version.sdk")["output"]!="35":
    p.error("Expected SM-T290 Android 15")
commands={"lineage":["getprop","ro.lineage.version"],"build":["getprop","ro.build.display.id"],"memory":["cat","/proc/meminfo"],"swap":["cat","/proc/swaps"],"packages":["pm","list","packages"],"display":["wm","size"],"density":["wm","density"],"lowram":["getprop","ro.config.low_ram"],"storage":["df","-h","/data"],"launcher":["cmd","package","resolve-activity","--brief","-a","android.intent.action.MAIN","-c","android.intent.category.HOME"]}
with a.output.open("x") as f:
    json.dump({k:read(*v) for k,v in commands.items()},f,indent=2)
print("Inventory saved. Review installed package names before sharing.")
