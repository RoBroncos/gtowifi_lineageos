# Android 15 customization layer
This directory targets official LineageOS 22.2 for SM-T290 (gtowifi). The parent Git branch still contains the unrelated Android 16 device tree: do not build or flash it for this project. This is not a fork of the official Android 15 source or a modified signed ROM.

Install the untouched official ROM using https://wiki.lineageos.org/devices/gtowifi/install/ and https://download.lineageos.org/devices/gtowifi/builds . Follow firmware requirements and back up data; unlocking wipes userdata.

On Windows, Linux or macOS install Python 3 and Android platform-tools, enable USB debugging and authorize your computer. From this directory:
```
adb devices
python customize.py status --serial YOUR_SERIAL
python customize.py apply --serial YOUR_SERIAL
python customize.py restore --serial YOUR_SERIAL
```
Edit profile.json to choose animation scales. The tool refuses unsupported settings, verifies model, Android version and LineageOS version, saves original settings before changing them, and refuses to overwrite an existing backup. Keep backup files private. The script is not yet physically tested. If apply fails midway, restore using the saved backup.

No system app deletion, root, boot image changes or kernel tweaks. Official updates remain available; check whether settings survive updates. Future profiles can add user-approved launcher, appearance and application choices. Framework modifications require a separate build or carefully tested root module.
