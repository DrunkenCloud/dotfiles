#!/bin/bash
# Toggle screen recording (SUPER+SHIFT+R): first press picks a region and starts,
# second press stops. Files go to ~/Videos/Recordings (video only, no sound).
DIR="$HOME/Videos/Recordings"
LAST="${XDG_RUNTIME_DIR:?}/recording.last"   # path of the recording in progress

if pgrep -x wf-recorder >/dev/null; then
    pkill -INT -x wf-recorder
    FILE=$(cat "$LAST" 2>/dev/null)
    # Click "Open" on the notification to play it ("Folder" opens the folder).
    ( action=$(notify-send -A open=Open -A folder=Folder --wait \
                   "Recording saved" "${FILE/#$HOME/\~}")
      case "$action" in
          open)   xdg-open "$FILE" ;;
          folder) xdg-open "$DIR" ;;
      esac ) >/dev/null 2>&1 &
else
    GEOM=$(slurp) || exit 0          # Esc in slurp = cancel, don't record
    mkdir -p "$DIR"
    FILE="$DIR/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"
    echo "$FILE" > "$LAST"
    wf-recorder -g "$GEOM" -f "$FILE" >/dev/null 2>&1 &
    notify-send -u low "Recording started" "SUPER+SHIFT+R again to stop"
fi
pkill -RTMIN+8 waybar 2>/dev/null   # classic shell: refresh the bar's recording indicator
