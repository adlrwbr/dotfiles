#!/bin/bash

# Check args
if [ ! $# -eq 1 ]; then
  echo "Usage: waybar.sh <path/to/waybarconfigfolder>"
  exit 1
fi

# get absolute path
dir_path=$(readlink -f "$1")

# Check if the provided directory exists
if [ ! -d "$dir_path" ]; then
  echo "The provided directory does not exist."
  exit 1
fi

set -e
killall waybar || true
echo $dir_path
rm -rf ~/.config/waybar
ln -s $dir_path ~/.config/waybar
waybar &
disown
