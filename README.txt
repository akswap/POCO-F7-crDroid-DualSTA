POCO F7 / onyx - crDroid 12.12 exact build backup
ROM: crDroidAndroid-16.0-20260913-onyx-v12.12
Verified: 2026-09-29

Verified live combination:
- wlan0 primary: TP-Link_5G_be, 5640 MHz, 160 MHz, Wi-Fi 7/EHT
- wlan1 secondary: Airtel_2.4G, 2437 MHz, Wi-Fi 6/HE
- Reboot auto-connect: PASS
- Auto fallback: PASS. Unavailable profile #0 was skipped after 35 seconds and profile #1 connected without manual commands.
- Dual STA Profile Manager v1.4 shows the first boot choice as "Auto #0 (first choice)".

Required order after the same ROM build is flashed:
1. Flash images/init_boot_b_crDroid_DualSTA_WORKING.img to init_boot_b.
2. Install WiFi7-6GHz module.
3. Install DualSTA-HAL module.
4. Install POCO-F7-crDroid-DualSTA-Service-v1.5.1-AUTOCONNECT.zip.
5. Reboot.

The service ZIP contains private current Wi-Fi profiles. Keep it private.
Do not install the Infinity-X service-wifi.jar on crDroid.
Rollback image is included.

Patched driver backup:
- driver-patch/qca_cld3_wcn7750-crdroid-dualsta.ko
- driver-patch/qca_cld3_wcn7750-crdroid-dualsta.ko.xz (exact payload used by the working test8 init_boot build)
- driver-patch/qca_cld3_wcn7750_crDroid_stock.ko (original comparison/rollback driver)
- driver-patch/DRIVER-NOTES.txt
