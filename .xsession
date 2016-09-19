#!/bin/bash

xset m 0
xset r rate 200 100
setxkbmap -layout us -option '' # to reset posible stupid defaults
setxkbmap -layout us,ru -option 'grp:shift_toggle,grp_led:scroll'
xrandr --output HDMI1 --primary --pos 0x0 --output HDMI2 --pos -1920x0
kbdd
xbindkeys
mpd
tint2 &

# ssh-agent ~/.local/bin/xmonad-s9g
ssh-agent openbox

kill %1
# mpd --kill
