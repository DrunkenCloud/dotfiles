#!/bin/bash
# Toggle screen recording: first press picks a region and starts, second press stops.
if pgrep -x wf-recorder >/dev/null; then
    pkill -INT -x wf-recorder
    notify-send "Recording saved" "~/Videos" 2>/dev/null
else
    GEOM=$(slurp) || exit 0          # Esc in slurp = cancel, don't record
    mkdir -p ~/Videos
    wf-recorder -g "$GEOM" -f ~/Videos/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4 &
    notify-send -u low "Recording started" "SUPER+SHIFT+R again to stop"
fi
sleep 0.3; pkill -RTMIN+8 waybar     # refresh the bar's recording indicator now
