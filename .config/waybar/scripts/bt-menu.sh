#!/bin/bash
# Bluetooth dropdown: power toggle + paired devices (click to connect/disconnect).
source ~/.config/waybar/scripts/menu-toggle.sh

THEME=~/.config/rofi/dropdown.rasi
I_ON=$'\U000F00AF' I_OFF=$'\U000F00B2' I_DEV=$'\U000F00B1' I_GEAR=$'' I_SCAN=$''

if bluetoothctl show | grep -q "Powered: yes"; then
    rows=(); acts=(); actives=()
    while read -r _ mac name; do
        if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
            actives+=(${#rows[@]})
        fi
        rows+=("$I_DEV  $name"); acts+=("dev:$mac")
    done < <(bluetoothctl devices Paired)
    msg="${#actives[@]} connected"
    rows+=("$I_SCAN  Pair new device")
    acts+=("settings")
    rows+=("$I_OFF  Turn Bluetooth off"); acts+=("off")
else
    rows=("$I_ON  Turn Bluetooth on"); acts=("on"); actives=(); msg="Bluetooth is off"
fi
rows+=("$I_GEAR  Bluetooth settings"); acts+=("settings")

a=$(IFS=,; echo "${actives[*]}")
idx=$(printf '%s\n' "${rows[@]}" | rofi -dmenu -i -theme "$THEME" -format i -p "Bluetooth" -mesg "$msg" ${a:+-a $a}); rc=$?; now_ms > "$STAMP"; [ $rc -eq 0 ] || exit 0
act=${acts[$idx]}

case "$act" in
    on)  rfkill unblock bluetooth; bluetoothctl power on ;;
    off) bluetoothctl power off ;;
    settings) blueman-manager & ;;
    dev:*)
        mac=${act#dev:}
        if [[ ",$a," == *",$idx,"* ]]; then bluetoothctl disconnect "$mac"
        else out=$(bluetoothctl connect "$mac" 2>&1) || rofi -e "Couldn't connect: ${out##*$'\n'}" -theme "$THEME"
        fi ;;
esac
