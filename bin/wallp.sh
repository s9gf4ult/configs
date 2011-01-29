#!/bin/bash

[[ $# -ne 3 ]] && exit 255
[[ $2 -gt 0 ]] || exit 255
[[ $3 -gt 0 ]] || exit 255
[[ -f $1 ]] || exit 255
    
while true;do
    feh --bg-max "$(cat "$1" | shuf | head -n 1)"
    ss=$(seq $2 $3 | shuf | head -n1)
    sleep ${ss}s
done
