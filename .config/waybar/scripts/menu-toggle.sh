# Sourced by the dropdown menus. Makes clicking the bar module a second time close the menu.
# Clicking outside rofi already makes it exit, and the same click then reaches waybar,
# which would open the menu right back up. So: if a menu closed <0.5s ago, don't reopen.
STAMP="${XDG_RUNTIME_DIR:-/tmp}/waybar-menu-closed"
now_ms() { date +%s%3N; }
pkill -x rofi && { now_ms > "$STAMP"; exit 0; }
[ -f "$STAMP" ] && [ $(( $(now_ms) - $(cat "$STAMP") )) -lt 500 ] && exit 0
trap 'now_ms > "$STAMP"' EXIT
