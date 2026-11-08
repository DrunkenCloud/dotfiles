#!/bin/bash
# Battery saver, started by Hyprland at login:
#   on battery -> screen 60 Hz + "power-saver" CPU profile
#   on AC      -> screen 120 Hz + "balanced"
# Event-driven (udev power_supply events), so it sleeps until you plug/unplug.
# POWER_MODE_AC=<file> overrides the AC status file (for testing).

AC="${POWER_MODE_AC:-/sys/class/power_supply/AC/online}"
LOCK="${XDG_RUNTIME_DIR:?}/power-mode.lock"

exec 9>"$LOCK"
flock -n 9 || exit 0          # only one instance

last=""
apply() {
    local on hz prof
    on=$(< "$AC") || return
    [ "$on" = "$last" ] && return
    last=$on
    if [ "$on" = 1 ]; then hz=120; prof=balanced; else hz=60; prof=power-saver; fi
    hyprctl eval "hl.monitor({ output = \"eDP-1\", mode = \"1920x1080@$hz\", position = \"auto\", scale = 1 })" >/dev/null
    powerprofilesctl set "$prof"
}

apply
[ -n "$POWER_MODE_ONESHOT" ] && exit 0
udevadm monitor --udev --subsystem-match=power_supply | while read -r _; do
    sleep 1                   # let the AC status settle
    apply
done
