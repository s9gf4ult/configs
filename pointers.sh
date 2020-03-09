#!/usr/bin/env bash

elecom='pointer:ELECOM TrackBall Mouse HUGE TrackBall'
logitec='pointer:Logitech G403 Prodigy Gaming Mouse'

xinput set-prop "$elecom" 'libinput Scroll Method Enabled' 0, 0, 1
xinput set-prop "$elecom" 'libinput Button Scrolling Button' 11

xinput set-prop "$logitec" 'libinput Accel Profile Enabled' 0, 1
xinput set-prop "$logitec" 'libinput Accel Speed' 0
xinput set-prop "$logitec" 'libinput Scroll Method Enabled' 0, 0, 1
xinput set-prop "$logitec" 'libinput Button Scrolling Button' 2
