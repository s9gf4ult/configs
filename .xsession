#!/bin/bash

NETWORKING_IPV6=no
xset m 0
xset r rate 200 100
setxkbmap -layout us -option '' # to reset posible stupid defaults
setxkbmap -layout us,ru -option 'grp:shift_toggle,grp_led:scroll'
synclient TapButton1=1 TapButton2=3 TapButton3=2
sudo xbacklight -set 35
kbdd
xbindkeys
# mpd
tint2 &
nm-applet &

# ssh-agent ~/.local/bin/xmonad-s9g
ssh-agent openbox

kill %1
# mpd --kill
