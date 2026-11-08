# Sourced by the dropdown menus. Makes clicking the bar module a second time close the menu.
# Clicking outside rofi already makes it exit, and the same click then reaches waybar,
# which would open the menu right back up. So: if a menu closed <0.5s ago, don't reopen.
STAMP="${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR not set}/waybar-menu-closed"   # per-user, mode 0700
now_ms() { date +%s%3N; }
pkill -x rofi && { now_ms > "$STAMP"; exit 0; }
last=$(command cat "$STAMP" 2>/dev/null); [[ $last =~ ^[0-9]+$ ]] || last=0
[ $(( $(now_ms) - last )) -lt 500 ] && exit 0
trap 'now_ms > "$STAMP"' EXIT
