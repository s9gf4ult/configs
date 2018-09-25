#!/bin/bash

NETWORKING_IPV6=no
xset m 0
xset r rate 200 100
setxkbmap -layout us -option '' # to reset posible stupid defaults
setxkbmap -layout us,ru -option 'grp:shift_toggle,grp_led:scroll'
xmodmaprc ~/.xmodmaprc
xrandr --output HDMI2 --primary --pos 0x0 --output HDMI1 --right-of HDMI2
# kbdd
xbindkeys
mpd
# tint2 &

# ssh-agent ~/.local/bin/xmonad-s9g
# ssh-agent openbox
startxfce4

# kill %1
# mpd --kill
