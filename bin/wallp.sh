#!/bin/bash

[[ $# -ne 3 ]] && exit 255
[[ $2 -gt 0 ]] || exit 255
[[ $3 -gt 0 ]] || exit 255
[[ -d $1 ]] || exit 255
    
cd "$1"
while true;do
    feh --bg-max $(ls --indicator-style=none -1 *.jpg | shuf | head -n 1)
    ss=$(seq $2 $3 | shuf | head -n1)
    sleep ${ss}s
done