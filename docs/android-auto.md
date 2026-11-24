# Android Auto receiver experiment

This branch provides diagnostics and an installation helper, not an Android Auto protocol implementation. Use a legally obtained compatible receiver such as Headunit Reloaded; compatibility with Android 16 and this device is unverified. Do not redistribute proprietary APKs. A receiver may require licensing or Google services; test before relying on a Google-free ROM.

## Setup
1. Follow docs/lowram-testing.md and establish a working baseline.
2. Run bash tools/check-projection.sh with ADB connected.
3. Install a trusted receiver through its supported distribution channel, or run bash tools/install-projection-receiver.sh /path/to/receiver.apk if the publisher provides a standalone APK. Verify publisher identity and signing certificate.
4. Configure phone and receiver while parked. Try wireless projection first using the receiver's documented connection method; 5 GHz Wi-Fi is reported working upstream. Test USB separately with an OTG adapter and data cable. USB host and simultaneous charging are not established.
5. Start at 800x480 or the closest supported low-resolution projection mode, 30 fps if selectable. Compare baseline and low-RAM builds.

## Validation
- Confirm actual H.264 decoder selection during playback; GPU rendering does not establish hardware video decoding.
- Check touch mapping, audio focus, navigation prompts, phone call routing and reconnect behavior.
- Run at least 30 minutes of projection while monitoring thermal state, frame drops, memory pressure and battery.
- Test screen-off, charger removal, reconnection and overnight drain. Do not keep the tablet awake indefinitely.
- Do not disable SELinux, thermal protection, lock screen or Android Auto driving restrictions.
- Use a secure mount outside airbag deployment zones and sightlines. Avoid leaving the tablet in a hot parked car.

## Known constraints
The upstream README reports software camera video encoding, working GPU rendering, Wi-Fi reconnect around 20 seconds after resume, and untested Android USB OTG. Bluetooth headset call audio is not supported by the current kernel routing. Hardware AVC decode is unverified. Route calls through the phone or vehicle where supported. A wired USB host connection may prevent charging through the single micro-USB port; wireless projection with a suitable fused automotive USB supply is the preferred first experiment.

## Future development
After baseline tests, investigate hardware video decoding and receiver-specific reconnect issues. Add opt-in dock behavior only after verifying ignition power behavior, thermal safety and suspend. Keep the ordinary tablet mode available. No flashable image or verified projection support exists yet.
