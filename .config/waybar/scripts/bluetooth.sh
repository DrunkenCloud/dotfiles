#!/bin/bash

POWERED=$(bluetoothctl show | grep "Powered: yes")
CONNECTED=$(bluetoothctl info | grep "Connected: yes")

if [ -z "$POWERED" ]; then
    echo '{"text": " off", "class": "off"}'
elif [ -n "$CONNECTED" ]; then
    echo '{"text": " connected", "class": "connected"}'
else
    echo '{"text": " on", "class": "on"}'
fi
