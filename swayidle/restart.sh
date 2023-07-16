notify-send "restarting swayidle"

pkill swayidle

# old version
# swayidle -w \
#   timeout 60 'if pgrep -x swaylock; then hyprctl dispatch dpms off; fi' \
#     resume 'hyprctl dispatch dpms on' \
#   timeout 240 'swaylock -f' \
#   timeout 270 'if pgrep -x swaylock; then systemctl suspend-then-hibernate; fi' \
#



display_off='hprctl dispatch dpms off'
display_on='hprctl dispatch dpms on'

ac_power() {
    if [ "$(cat /sys/class/power_supply/AC/online)" = "1" ]; then
        return 0
    else
        return 1
    fi
}

batter_power() {
    if [ "$(cat /sys/class/power_supply/AC/online)" = "0" ]; then
        return 0
    else
        return 1
    fi
}

ac_power=$(test $(cat /sys/class/power_supply/AC/online) -eq 1 && echo true || echo false )
battery_power=$(test ! $ac_power)

# new version
swayidle -w \
  timeout 3 'test $battery_power && light -O; light -S 5' \
    resume 'light -I' \
  timeout 50 'test $battery_power && $display_off' \
    resume '$display_on' \
  timeout 60 'test $battery_power && systemctl suspend-then-hibernate' \
  timeout 65 'test $ac_power && light -O; light -S 5' \
    resume 'light -I' \
  timeout 90 'test $ac_power && $display_off' \
    resume '$display_on' \
  timeout 120 'test $ac_power && systemctl suspend-then-hibernate' \
  before-sleep 'swaylock -e -f'
  timeout 300 'test $battery_power && light -O; light -S 5' \
    resume 'light -I' \
  timeout 500 'test $battery_power && $display_off' \
    resume $display_on \
  timeout 600 'test $battery_power && systemctl suspend-then-hibernate' \
  timeout 650 'test $ac_power && light -O; light -S 5' \
    resume 'light -I' \
  timeout 900 'test $ac_power && $display_off' \
    resume $display_on \
  timeout 1200 'test $ac_power && systemctl suspend-then-hibernate' \
  before-sleep 'swaylock -e -f'

# desired behavior
# at 270, suspend then hibernate 

# Behavior timestamps:
# At 240 seconds of inactivity, lock
# At 270 seconds, suspend-then-hibernate
# Lock screen after 240s idle and then (if locked) suspend-then-hibernate 30s later
# Turn monitors off if locked (swaylock running) and idle for 10 seconds
