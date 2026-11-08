#!/bin/bash
# SUPER+SHIFT+S: select a region, save it, copy it to the clipboard, and notify.

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

GEOM=$(slurp) || exit 0            # Esc in slurp = cancel, take nothing
grim -g "$GEOM" "$FILE" || { notify-send -u critical "Screenshot failed"; exit 1; }
wl-copy < "$FILE"
notify-send -i "$FILE" "Screenshot copied" "Saved to ${FILE/#$HOME/\~}"
