#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Copy upstream local manifests, redirecting only the SM-T290 device tree."""
import argparse
from pathlib import Path
import xml.etree.ElementTree as ET

p = argparse.ArgumentParser(description=__doc__)
p.add_argument("source", type=Path, help="fork checkout's local_manifests directory")
p.add_argument("destination", type=Path, help="Android checkout .repo/local_manifests")
args = p.parse_args()
trees = [(f.name, ET.parse(f)) for f in sorted(args.source.glob("*.xml"))]
target = "device/samsung/gtowifi_mainline"
matches = [(tree, project) for _, tree in trees for project in tree.getroot().findall("project")
           if project.get("path") == target]
if len(matches) != 1:
    p.error(f"Expected exactly one device project, found {len(matches)}")
tree, project = matches[0]
root = tree.getroot()
remote = "gtowifi-custom-github"
if any(r.get("name") == remote for _, t in trees for r in t.getroot().findall("remote")):
    p.error("Custom remote already exists")
root.insert(0, ET.Element("remote", {"name": remote, "fetch": "https://github.com/"}))
project.set("name", "RoBroncos/gtowifi_lineageos")
project.set("remote", remote)
project.set("revision", "refs/heads/dev/lowram")
project.attrib.pop("upstream", None)
project.attrib.pop("dest-branch", None)
args.destination.mkdir(parents=True, exist_ok=True)
for name, t in trees:
    path = args.destination / name
    if path.exists():
        p.error(f"Refusing to overwrite {path}; back up existing manifests first")
for name, t in trees:
    ET.indent(t, space="  ")
    t.write(args.destination / name, encoding="utf-8", xml_declaration=True)
print("Custom manifests prepared. Other project revisions preserved.")
