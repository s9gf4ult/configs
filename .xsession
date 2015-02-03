#!/bin/bash
export OOO_FORCE_DESKTOP="gnome"
export VDPAU_DRIVER=va_gl
xset m 0
xset r rate 250 100
setxkbmap -layout us,ru -option 'grp:shift_toggle,grp_led:scroll,terminate:ctrl_alt_bksp'
kbdd
# xscreensaver &
tint2 &
#~/bin/wallp.sh ~/wallpaper.rc 3600 10800 &
# mpd
# compton &
# ssh-agent ~/.xmonad/xmonad
ssh-agent openbox
#mpd --kill
kill %1
#kill %2
#kill %3
