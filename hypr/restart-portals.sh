#!/usr/bin/env bash

# Recommended via https://wiki.hyprland.org/FAQ/#some-of-my-apps-take-a-really-long-time-to-open
sleep 4
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-gtk
killall xdg-desktop-portal
/usr/lib/xdg-desktop-portal-gtk &
/usr/lib/xdg-desktop-portal-hyprland &
sleep 4
/usr/lib/xdg-desktop-portal &