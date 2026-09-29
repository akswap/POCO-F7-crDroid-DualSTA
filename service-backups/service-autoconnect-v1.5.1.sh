#!/system/bin/sh

MODDIR=$(dirname "$0")
JAR="$MODDIR/dualsta-helper-config.jar"
CONFIG="$MODDIR/profiles.conf"
LOG=/data/local/tmp/dualsta-autoconnect.log
HELPER_LOG=/data/local/tmp/dualsta-helper.log
PIDFILE=/data/local/tmp/dualsta-helper.pid
PROFILE_WAIT_SECONDS=35
HOTSPOT_POLL_SECONDS=1
HOTSPOT_CLEAR_SECONDS=6

log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG"
}

secondary_connected() {
    [ -e /sys/class/net/wlan1 ] || return 1
    /system/bin/ip -o -4 addr show dev wlan1 2>/dev/null | grep -q ' inet '
}

primary_ready() {
    [ -e /sys/class/net/wlan0 ] || return 1
    /system/bin/ip -o -4 addr show dev wlan0 2>/dev/null | grep -q ' inet '
}

primary_ssid() {
    dumpsys wifi 2>/dev/null \
        | grep 'current SSID(s):' \
        | tail -n 1 \
        | sed -n 's/.*iface=wlan0,ssid="\([^"]*\)".*/\1/p'
}

enabled_profile_ssid() {
    wanted="$1"
    awk -F '\t' -v wanted="$wanted" '
        !/^#/ && NF == 7 && $2 == "1" {
            if (seen == wanted) { print $3; exit }
            seen++
        }
    ' "$CONFIG" 2>/dev/null
}

hotspot_active() {
    [ -e /sys/class/net/wlan2 ] || [ -e /sys/class/net/ap0 ]
}

stop_helper() {
    [ -f "$PIDFILE" ] || return 0
    pid="$(cat "$PIDFILE" 2>/dev/null)"
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null
        sleep 1
    fi
    rm -f "$PIDFILE"
}

enabled_count() {
    awk -F '	' '!/^#/ && NF == 7 && $2 == "1" {n++} END {print n+0}' "$CONFIG" 2>/dev/null
}

start_profile() {
    index="$1"
    [ -f "$JAR" ] || return 1
    [ -f "$CONFIG" ] || return 1
    CLASSPATH="$JAR" app_process /system/bin DualStaRequest "$CONFIG" "$index" >> "$HELPER_LOG" 2>&1 &
    echo "$!" > "$PIDFILE"
    log_msg "secondary profile index=$index requested pid=$!"
}

wait_hotspot_end() {
    stop_helper
    log_msg "hotspot detected; secondary STA suspended"
    clear_seconds=0
    while [ "$clear_seconds" -lt "$HOTSPOT_CLEAR_SECONDS" ]; do
        if hotspot_active; then
            clear_seconds=0
        else
            clear_seconds=$((clear_seconds + HOTSPOT_POLL_SECONDS))
        fi
        sleep "$HOTSPOT_POLL_SECONDS"
    done
    log_msg "hotspot ended; secondary STA resume scheduled"
}

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done
sleep 10
chmod 600 "$CONFIG" 2>/dev/null
log_msg "HAL-managed configurable secondary-only hotspot-aware watchdog started"

# Do not race Android while it is still restoring the primary Wi-Fi after boot.
primary_waited=0
while ! primary_ready && [ "$primary_waited" -lt 90 ]; do
    sleep 2
    primary_waited=$((primary_waited + 2))
done
log_msg "primary readiness wait completed after ${primary_waited}s"

while true; do
    if hotspot_active; then
        wait_hotspot_end
        continue
    fi

    if secondary_connected; then
        sleep 1
        continue
    fi

    count="$(enabled_count)"
    if [ "$count" -lt 1 ]; then
        stop_helper
        sleep 10
        continue
    fi

    index=0
    hotspot_seen=0
    connected=0

    while [ "$index" -lt "$count" ]; do
        if hotspot_active; then
            hotspot_seen=1
            break
        fi

        candidate_ssid="$(enabled_profile_ssid "$index")"
        active_primary_ssid="$(primary_ssid)"
        if [ -n "$candidate_ssid" ] && [ "$candidate_ssid" = "$active_primary_ssid" ]; then
            log_msg "profile index=$index skipped because it is already primary"
            index=$((index + 1))
            continue
        fi

        stop_helper
        start_profile "$index"
        waited=0

        while [ "$waited" -lt "$PROFILE_WAIT_SECONDS" ]; do
            sleep 1
            if hotspot_active; then
                stop_helper
                hotspot_seen=1
                break
            fi
            if secondary_connected; then
                connected=1
                break
            fi
            waited=$((waited + 1))
        done

        [ "$hotspot_seen" = "1" ] && break
        [ "$connected" = "1" ] && break
        index=$((index + 1))
    done

    [ "$hotspot_seen" = "1" ] && continue
    [ "$connected" = "1" ] && continue
    sleep 2
done
