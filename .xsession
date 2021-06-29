#!/bin/bash

xset m 0
xset r rate 200 100
~/configs/pointers.sh

setxkbmap -layout us -option '' # to reset posible stupid defaults
setxkbmap -layout us,ru -option 'grp:shift_toggle,grp_led:scroll'

# xmodmaprc ~/.xmodmaprc
xrandr --output DVI-D-0 --left-of DisplayPort-0
# kbdd
xbindkeys

ssh-agent awesome

# kill %1
# mpd --kill
