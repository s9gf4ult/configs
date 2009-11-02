#!/bin/bash
while true;do
	xsetroot -name "_-=+\$ $(date "+%d %b %a %H:%M:%S") \$+=-_"
	sleep 1
done &
xset m 0
xset r rate 260 100
${HOME}/.dwm/dwm 
kill %1
