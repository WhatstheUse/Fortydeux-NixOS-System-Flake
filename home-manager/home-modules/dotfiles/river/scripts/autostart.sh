#!/usr/bin/env bash

pkill -f kanshi
kanshi &

pkill -f swaybg
swaybg -m fill -i ~/.config/wallpapers/balloon-wp.jpg &

dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY

pkill -f mako
mako &

pkill -f nm-applet
nm-applet &

pkill -f blueman-applet
blueman-applet &

pkill -f wlsunset
wlsunset -l 57.4 -L -1.9 &

pkill -f i3bar-river
i3bar-river &

pkill -f pcloud
pcloud & 

export wallpaper='~/.config/wallpapers/balloon-wp.jpg'

# Replaced by Stasis idle manager
# pkill -f swayidle
# swayidle -w \
# 	timeout 900 'swaylock -f -i $wallpaper' \
# 	timeout 1200 'wlopm --off \*;swaylock -F -i $wallpaper' resume 'wlopm --on \*' \
# 	before-sleep 'swaylock -f -i $wallpaper' &

pkill -f stasis
stasis &
