# POCO F7 crDroid Dual STA

Verified STA+STA backup for **POCO F7 / onyx** running this exact ROM build:

- ROM: `crDroidAndroid-16.0-20260913-onyx-v12.12`
- Verified: `2026-09-29`
- Primary interface: `wlan0`
- Secondary STA interface: `wlan1`

## Verified behavior

- `wlan0`: TP-Link 5 GHz, 5640 MHz, 160 MHz, Wi-Fi 7/EHT
- `wlan1`: Airtel 2.4 GHz, 2437 MHz, Wi-Fi 6/HE
- Reboot auto-connect: passed
- Automatic profile fallback: passed
- If Auto profile `#0` is unavailable, service v1.5.1 tries the next enabled profile without a manual command.

## Installation order

1. Flash [`images/init_boot_b_crDroid_DualSTA_WORKING.img`](images/init_boot_b_crDroid_DualSTA_WORKING.img) to the matching `init_boot_b` slot.
2. Install [`POCO-F7-crDroid-WiFi7-6GHz-v0.4.2-WORKING.zip`](magisk-modules/POCO-F7-crDroid-WiFi7-6GHz-v0.4.2-WORKING.zip) in Magisk.
3. Install [`POCO-F7-crDroid-DualSTA-HAL-v1.0-WORKING.zip`](magisk-modules/POCO-F7-crDroid-DualSTA-HAL-v1.0-WORKING.zip) in Magisk.
4. Install [`POCO-F7-crDroid-DualSTA-Service-v1.5.1-AUTOCONNECT.zip`](magisk-modules/POCO-F7-crDroid-DualSTA-Service-v1.5.1-AUTOCONNECT.zip) in Magisk.
5. Reboot.
6. Install [`DualStaProfileManager-current.apk`](app/DualStaProfileManager-current.apk) if profile editing is required.

## Driver backup

The [`driver-patch`](driver-patch) directory contains:

- Original crDroid driver
- Patched uncompressed `qca_cld3_wcn7750.ko`
- Exact `.ko.xz` payload embedded in the verified test8 `init_boot`
- Early-load script and init `.rc`
- Verified test8 build script

See [`driver-patch/DRIVER-NOTES.txt`](driver-patch/DRIVER-NOTES.txt) for details.

## Rollback

The original rollback image is available at:

[`images/init_boot_b_crDroid_DualSTA_ROLLBACK.img`](images/init_boot_b_crDroid_DualSTA_ROLLBACK.img)

## Verification

File hashes are recorded in [`SHA256SUMS.txt`](SHA256SUMS.txt).

## Compatibility

These driver and boot files are for the exact crDroid build named above. Do not flash them on MIUI EU, Infinity-X, or a different crDroid kernel build without rebuilding and verifying kernel-module compatibility.

The service ZIP contains the tested profile configuration. The included Wi-Fi password was temporary at the time of publication.
