#!/usr/bin/env bash

setxkbmap -layout us -option '' # to reset posible stupid defaults
setxkbmap -layout us,ru -variant workman, -option 'grp:shift_toggle,grp_led:scroll'
