#!/system/bin/sh
set -eu
cd /data/local/tmp/crdroid_initboot_candidate
MB=/data/local/tmp/magiskboot_aks
rm -f kernel ramdisk.cpio second dtb extra candidate.img
$MB unpack base.img
$MB cpio ramdisk.cpio 'add 0644 overlay.d/sbin/qca_cld3_wcn7750-crdroid-dualsta.ko.xz qca_cld3_wcn7750-crdroid-dualsta.ko.xz'
$MB cpio ramdisk.cpio 'ls -r overlay.d/sbin'
$MB repack base.img candidate.img
sha256sum base.img candidate.img
ls -l candidate.img