#!/bin/bash
export OOO_FORCE_DESKTOP="gnome"
xset m 0
xset r rate 250 100
setxkbmap -layout us,ru -option 'grp:shift_toggle,grp_led:scroll,terminate:ctrl_alt_bksp'
#xscreensaver &
#tint2 &
gnome-panel &
gnome-settings-daemon &
#~/bin/wallp.sh ~/wallpaper.rc 3599 10800 &
#mpd
ssh-agent openbox
#mpd --kill
kill %1
#kill %2
#kill %3
