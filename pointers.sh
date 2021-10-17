#!/usr/bin/env bash

xset m 0
xset r rate 200 100

elecom='pointer:ELECOM TrackBall Mouse HUGE TrackBall'
logitec='pointer:Logitech G403 Prodigy Gaming Mouse'
kana='pointer:SteelSeries Kana v2 Gaming Mouse'
zowie='pointer:Kingsis Corporation ZOWIE Gaming mouse'

xinput set-prop "$elecom" 'libinput Scroll Method Enabled' 0, 0, 1
xinput set-prop "$elecom" 'libinput Button Scrolling Button' 11
xinput set-prop "$elecom" "libinput Accel Speed" -0.85

xinput set-prop "$logitec" 'libinput Accel Profile Enabled' 0, 1
xinput set-prop "$logitec" 'libinput Accel Speed' 0
xinput set-prop "$logitec" 'libinput Scroll Method Enabled' 0, 0, 1
xinput set-prop "$logitec" 'libinput Button Scrolling Button' 2

xinput set-prop "$kana" 'libinput Accel Profile Enabled' 0, 1
xinput set-prop "$kana" 'libinput Accel Speed' 0
xinput set-prop "$kana" 'libinput Scroll Method Enabled' 0, 0, 1
xinput set-prop "$kana" 'libinput Button Scrolling Button' 2

xinput set-prop "$zowie" 'libinput Accel Profile Enabled' 0, 1
xinput set-prop "$zowie" 'libinput Accel Speed' 0
xinput set-prop "$zowie" 'libinput Scroll Method Enabled' 0, 0, 1
xinput set-prop "$zowie" 'libinput Button Scrolling Button' 2
