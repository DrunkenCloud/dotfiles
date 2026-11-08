#!/bin/bash
# SUPER + /: searchable list of every keybinding, built live from Hyprland
# (descriptions come from bind(...) in hyprland.lua, so it never goes stale).

hyprctl binds -j | python3 -c '
import json, sys, html
MODS = [(64, "SUPER"), (4, "CTRL"), (8, "ALT"), (1, "SHIFT")]
NAMES = {"slash": "/", "space": "Space", "Escape": "Esc", "Tab": "Tab", "Print": "PrtSc",
         "mouse:272": "Left click", "mouse:273": "Right click",
         "mouse_down": "Scroll down", "mouse_up": "Scroll up",
         "left": "←", "right": "→", "up": "↑", "down": "↓"}
seen = set()
for b in json.load(sys.stdin):
    desc = b.get("description") or ""
    if not desc:
        continue
    k = b["key"]
    if k.startswith("XF86"):
        keys = "Media key"
    else:
        mods = [n for bit, n in MODS if b["modmask"] & bit]
        keys = " + ".join(mods + [NAMES.get(k, k.upper() if len(k) == 1 else k)])
    if (keys, desc.split(" (")[0]) in seen:   # e.g. ALT+Tab is two binds, show once
        continue
    seen.add((keys, desc.split(" (")[0]))
    # keys in a monospace font so the description column lines up
    padded = html.escape(keys.ljust(20))
    print(f"<span font_family=\"JetBrainsMono Nerd Font\" weight=\"bold\">{padded}</span>  "
          f"<span foreground=\"#a99bc4\">{html.escape(desc)}</span>")
' | rofi -dmenu -i -markup-rows -p "Keybindings" -no-custom -theme-str 'window { width: 660px; } listview { lines: 14; } entry { placeholder: "Search keybindings..."; }' >/dev/null
