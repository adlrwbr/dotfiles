dir="$HOME/.config/rofi/launchers/type-7"
theme='style-5'

rofi -show bookmarks rofi \
  -modi 'bookmarks: /home/adler/dotfiles/rofi/rofi-bookmarks/rofi-bookmarks.py' \
  -show bookmarks \
  -theme ${dir}/${theme}.rasi
