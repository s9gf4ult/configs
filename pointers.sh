#!/usr/bin/env bash

xset m 0
xset r rate 200 100

elecom=$(xinput list --id-only 'pointer:ELECOM TrackBall Mouse HUGE TrackBall' | grep -ve '^[[:space:]]*$')

if [ -n $elecom ]; then
  xinput set-prop "$elecom" 'libinput Scroll Method Enabled' 0, 0, 1
  xinput set-prop "$elecom" 'libinput Button Scrolling Button' 10
  xinput set-prop "$elecom" "libinput Accel Speed" 0
  xinput set-button-map "$elecom" 1 2 3 4 5 6 7 8 9 10 1 2
fi

logitec=$(xinput list --id-only 'pointer:Logitech G403 Prodigy Gaming Mouse')
if [ -n $logitec ]; then
  xinput set-prop "$logitec" 'libinput Accel Profile Enabled' 0, 1
  xinput set-prop "$logitec" 'libinput Accel Speed' 0
  xinput set-prop "$logitec" 'libinput Scroll Method Enabled' 0, 0, 1
  xinput set-prop "$logitec" 'libinput Button Scrolling Button' 2
fi

kana=$(xinput list --id-only 'pointer:SteelSeries Kana v2 Gaming Mouse')
if [ -n $kana ]; then
  xinput set-prop "$kana" 'libinput Accel Profile Enabled' 0, 1
  xinput set-prop "$kana" 'libinput Accel Speed' 0
  xinput set-prop "$kana" 'libinput Scroll Method Enabled' 0, 0, 1
  xinput set-prop "$kana" 'libinput Button Scrolling Button' 2
fi

zowie=$(xinput list --id-only 'pointer:Kingsis Corporation ZOWIE Gaming mouse')
if [ -n $zowie ]; then
  xinput set-prop "$zowie" 'libinput Accel Profile Enabled' 0, 1
  xinput set-prop "$zowie" 'libinput Accel Speed' 0
  xinput set-prop "$zowie" 'libinput Scroll Method Enabled' 0, 0, 1
  xinput set-prop "$zowie" 'libinput Button Scrolling Button' 2
fi
