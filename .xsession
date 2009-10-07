#!/bin/bash
while true;do
	xsetroot -name "_-=+\$ $(date +%H:%M:%S) \$+=-_"
	sleep 1
done &
xset m 0
${HOME}/.dwm/dwm 
kill %1
