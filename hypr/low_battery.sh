#!/bin/env bash

while true; do
	battery=$(upower -i "$(upower -e | grep BAT)" | grep -E "percentage" | awk '{print $2}' | tr -d '%')
	if [ "$battery" -le "20" ]; then
		notify-send "  Low battery: ${battery}%"
		sleep 240
	else
		sleep 120
	fi
done
