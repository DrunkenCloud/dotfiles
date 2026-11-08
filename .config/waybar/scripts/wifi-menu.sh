#!/bin/bash
# Wi-Fi dropdown: click a network to connect (or disconnect if it's the active one).
source ~/.config/waybar/scripts/menu-toggle.sh

THEME=~/.config/rofi/dropdown.rasi
I_ON=$'\U000F05A9' I_OFF=$'\U000F05AA' I_GEAR=$'' I_LOCK=$''
BARS=($'\U000F091F' $'\U000F0922' $'\U000F0925' $'\U000F0928')

rofi_menu() { rofi -dmenu -i -theme "$THEME" -format i "$@"; }
# rofi renders -mesg/-e text as Pango markup: escape network names and errors.
esc() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }
fail() { rofi -e "Couldn't connect: $(esc "$1")" -theme "$THEME"; }

if [ "$(nmcli -t -f WIFI g)" = enabled ]; then
    rows=(); acts=(); active=""
    # One row per SSID (exact match). Several access points can share a name;
    # if ANY of them is secured, treat the network as secured, so an open
    # "evil twin" with a stronger signal can't make us connect without a password.
    declare -A seen secured best_sec
    order=()
    while IFS=: read -r inuse signal sec ssid; do
        [ -z "$ssid" ] && continue
        if [ -n "$sec" ] && [ "$sec" != "--" ]; then
            secured[$ssid]=1
            # Strongest wins: once any AP for this SSID offers WPA3, never let a
            # (possibly spoofed) WPA2-only AP downgrade the profile we create.
            [[ $sec == *WPA3* || ${best_sec[$ssid]} == WPA3 ]] && best_sec[$ssid]=WPA3 || best_sec[$ssid]=$sec
        fi
        [ -n "${seen[$ssid]}" ] && { [ "$inuse" = "*" ] && seen[$ssid]="*:$signal"; continue; }
        seen[$ssid]="$inuse:$signal"; order+=("$ssid")
    done < <(nmcli -t --escape no -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list --rescan auto | sort -t: -k1,1r -k2,2nr)
    for ssid in "${order[@]}"; do
        inuse=${seen[$ssid]%%:*}; signal=${seen[$ssid]#*:}
        bar=${BARS[$(( signal >= 75 ? 3 : signal >= 50 ? 2 : signal >= 25 ? 1 : 0 ))]}
        lock=""; [ -n "${secured[$ssid]}" ] && lock="  $I_LOCK"
        [ "$inuse" = "*" ] && active=${#rows[@]}
        rows+=("$bar  $ssid$lock"); acts+=("net:${best_sec[$ssid]}:$ssid")
    done
    msg="$(nmcli -t -f NAME c show --active | grep -v '^lo$' | head -1)"
    msg=${msg:+Connected to $msg}
    rows+=("$I_OFF  Turn Wi-Fi off"); acts+=("off")
else
    rows=("$I_ON  Turn Wi-Fi on"); acts=("on"); msg="Wi-Fi is off"; active=""
fi
rows+=("$I_GEAR  Network settings"); acts+=("settings")

idx=$(printf '%s\n' "${rows[@]}" | rofi_menu -p "Wi-Fi" -mesg "$(esc "${msg:-Not connected}")" ${active:+-a $active}); rc=$?; now_ms > "$STAMP"; [ $rc -eq 0 ] || exit 0
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
            out=$(nmcli c up id "$ssid" 2>&1) || fail "$out"
        elif [ -n "$sec" ]; then
            pw=$(rofi -dmenu -password -p "Password" -theme "$THEME" -mesg "$(esc "$ssid")" -l 0) || exit 0
            # Create the profile, then set the key over stdin (nmcli's editor), so the
            # password never appears in a process command line visible to `ps`.
            [[ $sec == WPA3 ]] && km=sae || km=wpa-psk   # WPA3 (incl. WPA2/3 transition APs) -> SAE
            nmcli c add type wifi con-name "$ssid" ssid "$ssid" wifi-sec.key-mgmt "$km" >/dev/null 2>&1
            printf 'set wifi-sec.psk %s\nsave\nquit\n' "$pw" | nmcli c edit id "$ssid" >/dev/null 2>&1
            unset pw
            out=$(nmcli c up id "$ssid" 2>&1) || {
                nmcli c delete id "$ssid" >/dev/null 2>&1   # don't keep a profile with a wrong password
                fail "$out"; }
        else
            out=$(nmcli dev wifi connect "$ssid" 2>&1) || fail "$out"
        fi ;;
esac
