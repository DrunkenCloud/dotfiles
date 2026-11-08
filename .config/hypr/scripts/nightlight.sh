#!/bin/bash
# SUPER+R: toggle night light (warmer screen colors, easier on the eyes at night).
TEMP=4000   # Kelvin: lower = warmer/more orange (6500 = normal daylight)

if pgrep -x hyprsunset >/dev/null; then
    pkill -x hyprsunset
    notify-send -u low "Night light off"
else
    setsid hyprsunset -t "$TEMP" >/dev/null 2>&1 &
    notify-send -u low "Night light on" "${TEMP} K"
fi
