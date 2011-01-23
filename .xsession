#!/bin/bash
xset m 0
xset r rate 250 100
setxkbmap -layout us,ru -option 'grp:shift_toggle,grp_led:scroll,terminate:ctrl_alt_bksp'
xscreensaver &
#wmii
#fbpanel &
tint2 &
openbox
kill %1
