#!/bin/bash
export OOO_FORCE_DESKTOP="gnome"
export auto_proxy="http://127.0.0.1:81/pac.js"
export http_proxy="http://192.168.160.151:3128"
xset m 0
xset r rate 250 100
setxkbmap -layout us,ru -option 'grp:shift_toggle,grp_led:scroll,terminate:ctrl_alt_bksp'
xscreensaver &
tint2 &
~/bin/wallp.sh ~/wallpaper.rc 3600 10800 &
mpd
openbox
mpd --kill
kill %1
kill %2
kill %3
