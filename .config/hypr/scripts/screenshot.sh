#!/bin/bash
# Screenshots: saved to ~/Pictures/Screenshots, copied to the clipboard, and notified.
#   screenshot.sh          select a region   (SUPER+SHIFT+S)
#   screenshot.sh full     whole screen      (Print)
#   screenshot.sh window   focused window    (SHIFT+Print)

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

case "$1" in
    full)   GEOM="" ;;
    window) GEOM=$(hyprctl activewindow -j | python3 -c \
              'import json,sys; w=json.load(sys.stdin); print("%d,%d %dx%d" % (*w["at"], *w["size"])) if w else sys.exit(1)') \
              || { notify-send "Screenshot" "No focused window"; exit 1; } ;;
    *)      GEOM=$(slurp) || exit 0 ;;   # Esc in slurp = cancel, take nothing
esac

if [ -n "$GEOM" ]; then grim -g "$GEOM" "$FILE"; else grim "$FILE"; fi \
    || { notify-send -u critical "Screenshot failed"; exit 1; }
wl-copy < "$FILE"
notify-send -i "$FILE" "Screenshot copied" "Saved to ${FILE/#$HOME/\~}"
