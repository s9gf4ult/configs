#!/bin/bash

[[ $# -ne 3 ]] && exit 255
[[ $2 -gt 0 ]] || exit 255
[[ $3 -gt 0 ]] || exit 255
[[ -f $1 ]] || exit 255
    
while true;do
	 f1="$(cat "$1" | shuf | head -n 1)"
	 f2="$(cat "$1" | shuf | head -n 1)"
    nice -n 10 montage -tile 2x1 -geometry 1280x960 -background \#000000 "$f1" "$f2" tmp.png
    nice -n 10 feh --no-xinerama --bg-center tmp.png
    rm tmp.png
    ss=$(seq $2 $3 | shuf | head -n1)
    sleep ${ss}s
done
