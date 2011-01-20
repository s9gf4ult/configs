#!/bin/bash
xset m 0
xset r rate 260 100
setxkbmap -layout us,ru -option 'grp:shift_toggle,grp_led:scroll,terminate:ctrl_alt_bksp'
xscreensaver &
#wmii
fbpanel &
openbox
kill %1
