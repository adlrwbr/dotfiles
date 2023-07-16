#!/bin/bash

# See ~/.config/kanshi/config for why this is necessary

handle() {
  case $1 in
    monitoradded*) echo "auto_reload.sh: Detected monitor added" ;;
    monitorremoved*) echo "auto_reload.sh: Detected monitor removed" && sleep 2 && kanshictl reload ;;
  esac
}

echo "auto_reload.sh: Listening for hyprland events..."
socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
