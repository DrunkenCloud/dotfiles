#!/bin/bash
# SUPER+SHIFT+W: pick something from clipboard history (text and images) and copy it again.
# History is recorded by `cliphist store` (started in hyprland.lua).
sel=$(cliphist list | rofi -dmenu -i -p "Clipboard" -display-columns 2) || exit 0
printf '%s' "$sel" | cliphist decode | wl-copy
