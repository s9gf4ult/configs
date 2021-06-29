#!/usr/bin/env bash

xset m 0
xset r rate 200 100
~/configs/pointers.sh

setxkbmap -layout us -option '' # to reset posible stupid defaults
setxkbmap -layout us,ru -variant workman, -option 'grp:shift_toggle,grp_led:scroll'

xrandr --dpi 168
xrandr --output DisplayPort-0 --primary --pos 0x0 --output HDMI-A-0 --right-of DisplayPort-0 --output DVI-D-0 --scale 1.6x1.6 --pos -3072x0
xbindkeys

ssh-agent awesome &
redshift-gtk -l manual
wait %1
