#!/bin/bash

BATTERY_PATH="/org/freedesktop/UPower/devices/battery_BAT1"
NOTIFIED=0

while true; do
    PERCENT=$(upower -i "$BATTERY_PATH" | awk '/percentage:/ {gsub("%",""); print $2}')
    STATE=$(upower -i "$BATTERY_PATH" | awk '/state:/ {print $2}')

    if [[ $PERCENT -le 20 && "$STATE" == "discharging" && $NOTIFIED -eq 0 ]]; then
        notify-send -u critical -t 10000 "Battery Low ⚠️" "Battery is at ${PERCENT}%"
        NOTIFIED=1
    elif [[ $PERCENT -gt 20 ]]; then
        NOTIFIED=0
    fi

    sleep 60
done
