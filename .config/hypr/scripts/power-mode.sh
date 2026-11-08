#!/bin/bash
# Battery saver, started by Hyprland at login.
#   On AC:      "balanced" profile.
#   On battery: "power-saver" profile, BUT if you start real work
#               (more than ~2 cores busy for ~20 s) it switches to "balanced",
#               and goes back to "power-saver" after ~1 min of calm.
# Plug/unplug is picked up instantly via udev; load is sampled every INTERVAL s.
#
# Testing overrides: POWER_MODE_AC=<file>  INTERVAL=  UP_AFTER=  DOWN_AFTER=

AC="${POWER_MODE_AC:-/sys/class/power_supply/AC/online}"
INTERVAL=${INTERVAL:-10}
HIGH_TENTHS=20        # >= 2.0 cores busy counts as "working"
LOW_TENTHS=8          # <= 0.8 cores busy counts as "calm"
UP_AFTER=${UP_AFTER:-2}       # working samples in a row before boosting (~20 s)
DOWN_AFTER=${DOWN_AFTER:-6}   # calm samples in a row before saving again (~60 s)
NCPU=$(nproc)

exec 9>"${XDG_RUNTIME_DIR:?}/power-mode.lock"
flock -n 9 || exit 0          # only one instance

log() { [ -n "$POWER_MODE_DEBUG" ] && echo "$(date +%T) $*" >&2; }

prev_total=0 prev_idle=0
# Sets BUSY = cores busy since the last call, in tenths (25 = 2.5 cores).
# (Not echo + $(...): a subshell would throw away prev_total/prev_idle.)
BUSY=0
busy_tenths() {
    local _ u n s i w x y z total idle dt di
    read -r _ u n s i w x y z _ < /proc/stat
    idle=$((i + w)); total=$((u + n + s + i + w + x + y + z))
    dt=$((total - prev_total)); di=$((idle - prev_idle))
    prev_total=$total; prev_idle=$idle
    if (( dt > 0 )); then BUSY=$(( (dt - di) * NCPU * 10 / dt )); else BUSY=0; fi
}

# (The refresh rate is deliberately NOT changed: switching 120<->60 Hz makes the
#  panel re-sync, which shows as a black flash on plug/unplug.)
profile=""
set_profile() {
    [ "$1" = "$profile" ] && return
    powerprofilesctl set "$1"; profile=$1; log "profile -> $1"
}

hot=0 calm=0
tick() {
    local on b
    on=$(< "$AC") || return
    busy_tenths; b=$BUSY
    if [ "$on" = 1 ]; then
        set_profile balanced; hot=0; calm=0; return
    fi
    if   (( b >= HIGH_TENTHS )); then hot=$((hot + 1)); calm=0
    elif (( b <= LOW_TENTHS ));  then calm=$((calm + 1)); hot=0
    fi
    log "battery, busy=$((b / 10)).$((b % 10)) cores, hot=$hot calm=$calm"
    if (( hot >= UP_AFTER )); then set_profile balanced
    elif (( calm >= DOWN_AFTER )) || [ -z "$profile" ]; then set_profile power-saver
    fi
}

busy_tenths                   # prime the CPU counters
tick
# read -t returns on a udev event (plug/unplug) or after INTERVAL seconds, whichever first.
udevadm monitor --udev --subsystem-match=power_supply | while :; do
    read -t "$INTERVAL" -r _
    tick
done
