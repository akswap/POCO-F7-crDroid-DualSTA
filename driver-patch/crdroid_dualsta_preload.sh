#!/vendor/bin/sh
XZ="$1"
BBGZ="$2"
TMPKO=/dev/.qca_cld3_wcn7750-crdroid-dualsta.ko
TMPBB=/dev/busybox
echo "DUALSTA-CRDROID: early preload started" > /dev/kmsg
DEPS="cfg80211 cnss_prealloc qcom_iommu_util sched-walt qcom_va_minidump cnss_nl cnss_utils icnss2 rproc_qcom_common qmi_helpers"
for dep in $DEPS
do
    for dir in /system_dlkm/lib/modules /vendor_dlkm/lib/modules /vendor/lib/modules
    do
        [ -e "$dir/modules.dep" ] || continue
        /vendor/bin/modprobe -b -s -d "$dir" -a "$dep" >/dev/null 2>&1 && break
    done
done
rm -f "$TMPKO" "$TMPBB"
if /vendor/bin/gunzip -c "$BBGZ" > "$TMPBB"; then
    chmod 0755 "$TMPBB"
else
    echo "DUALSTA-CRDROID: busybox unpack FAILED" > /dev/kmsg
    exit 0
fi
if "$TMPBB" xzcat "$XZ" > "$TMPKO"; then
    chmod 0644 "$TMPKO"
    if /vendor/bin/insmod "$TMPKO"; then
        echo "DUALSTA-CRDROID: patched qca loaded OK" > /dev/kmsg
    else
        echo "DUALSTA-CRDROID: patched qca FAILED - stock fallback" > /dev/kmsg
    fi
else
    echo "DUALSTA-CRDROID: driver unpack FAILED - stock fallback" > /dev/kmsg
fi
rm -f "$TMPKO" "$TMPBB"
exit 0