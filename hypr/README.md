# Hyprland config

## Dependencies
```
yay -S swaync pipewire wireplumber xdg-desktop-portal-hyprland-git grim slurp waybar-hyprland-git eww-wayland swaylock-effects-git hypridle wl-clipboard grimblast-git polkit-gnome gnome-keyring libsecret brightnessctl pavucontrol nm-applet kanshi hyprpicker swaybg wallutils
```

## rofi applets

`yay -S rofi-wayland rofimoji wtype`
See https://github.com/hyprwm/Hyprland/issues/5142#issuecomment-2002373675

My theme is based on those provided by
https://github.com/adi1090x/rofi


## firefox vim
`yay -S firefox-tridactyl firefox-tridactyl-native`

## SDDM hack

When systemd tries to shut down sddm.service, it failed with a timeout (see journalctl). `yay -S sddm-git` fixes this

## Screen sharing

**See the screensharing section in the Hyprland Wiki**

I tried installing a patch to allow XWayland applications (i.e. Discord, Skype) to share Wayland windows and screens with `yay -S xwaylandvideobridge-cursor-mode-2-git`, but it didn't work.

I really only need this functionality on Discord, so I installed `yay -S webcord` instead.

## Power management

- Power management
  - Adjust the time to transition from sleep to hibernate on `systemctl suspend-then-hibernate` in `/etc/systemd/sleep.conf`.
  - To configure the power button behavior / laptop lid switch, check out `/etc/systemd/logind.conf`

- Idle management
  - in [hyprland.conf](./hyprland.conf), I use `swayidle` to trigger a lock after some inactivity and then `systemctl suspend-then-hibernate` after more inactivity.

## Inspiration

Inspired by [Titus's Hyprland config](https://github.com/ChrisTitusTech/hyprland-titus):

```
yay -S hyprland polkit-gnome ffmpeg neovim viewnior rofi      \
pavucontrol thunar starship wl-clipboard wf-recorder swaybg   \
grimblast-git ffmpegthumbnailer tumbler playerctl             \
noise-suppression-for-voice thunar-archive-plugin kitty       \
waybar-hyprland wlogout swaylock-effects sddm-git pamixer     \
nwg-look-bin nordic-theme papirus-icon-theme dunst otf-sora   \
ttf-nerd-fonts-symbols-common otf-firamono-nerd inter-font    \
ttf-fantasque-nerd noto-fonts noto-fonts-emoji ttf-comfortaa  \
ttf-jetbrains-mono-nerd ttf-icomoon-feather ttf-iosevka-nerd  \
adobe-source-code-pro-fonts brightnessctl hyprpicker-git
```
