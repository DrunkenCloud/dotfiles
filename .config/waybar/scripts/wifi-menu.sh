#!/bin/bash
# Wi-Fi dropdown: click a network to connect (or disconnect if it's the active one).
source ~/.config/waybar/scripts/menu-toggle.sh

THEME=~/.config/rofi/dropdown.rasi
I_ON=$'\U000F05A9' I_OFF=$'\U000F05AA' I_GEAR=$'' I_LOCK=$''
BARS=($'\U000F091F' $'\U000F0922' $'\U000F0925' $'\U000F0928')

rofi_menu() { rofi -dmenu -i -theme "$THEME" -format i "$@"; }

if [ "$(nmcli -t -f WIFI g)" = enabled ]; then
    rows=(); acts=()
    ssids=(); active=""
    while IFS=: read -r inuse signal sec ssid; do
        [ -z "$ssid" ] && continue
        [[ " ${ssids[*]} " == *" $ssid "* ]] && continue      # dedupe access points
        bar=${BARS[$(( signal >= 75 ? 3 : signal >= 50 ? 2 : signal >= 25 ? 1 : 0 ))]}
        lock=""; [ -n "$sec" ] && [ "$sec" != "--" ] && lock="  $I_LOCK"
        [ "$inuse" = "*" ] && active=${#rows[@]}
        rows+=("$bar  $ssid$lock"); acts+=("net:$sec:$ssid"); ssids+=("$ssid")
    done < <(nmcli -t --escape no -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan auto | sort -t: -k1,1r -k2,2nr)
    msg="$(nmcli -t -f NAME c show --active | grep -v '^lo$' | head -1)"
    msg=${msg:+Connected to $msg}
    rows+=("$I_OFF  Turn Wi-Fi off"); acts+=("off")
else
    rows=("$I_ON  Turn Wi-Fi on"); acts=("on"); msg="Wi-Fi is off"; active=""
fi
rows+=("$I_GEAR  Network settings"); acts+=("settings")

idx=$(printf '%s\n' "${rows[@]}" | rofi_menu -p "Wi-Fi" -mesg "${msg:-Not connected}" ${active:+-a $active}); rc=$?; now_ms > "$STAMP"; [ $rc -eq 0 ] || exit 0
act=${acts[$idx]}

case "$act" in
    on)  nmcli radio wifi on ;;
    off) nmcli radio wifi off ;;
    settings) nm-connection-editor & ;;
    net:*)
        rest=${act#net:}; sec=${rest%%:*}; ssid=${rest#*:}
        if [ "$idx" = "$active" ]; then
            nmcli c down id "$ssid"
        elif nmcli -t -f NAME c show | grep -Fxq "$ssid"; then
            out=$(nmcli c up id "$ssid" 2>&1) || rofi -e "Couldn't connect: $out" -theme "$THEME"
        elif [ -n "$sec" ] && [ "$sec" != "--" ]; then
            pw=$(rofi -dmenu -password -p "Password" -theme "$THEME" -mesg "$ssid" -l 0) || exit 0
            out=$(nmcli dev wifi connect "$ssid" password "$pw" 2>&1) || {
                nmcli c delete id "$ssid" >/dev/null 2>&1   # don't keep a profile with a wrong password
                rofi -e "Couldn't connect: $out" -theme "$THEME"; }
        else
            nmcli dev wifi connect "$ssid"
        fi ;;
esac
