#!/usr/bin/env bash

case $1 in
  high)
    ddccontrol -r 0x10 -w 100 dev:/dev/i2c-1
    ddccontrol -r 0x10 -w 100 dev:/dev/i2c-2
    ddccontrol -r 0x14 -w 1 dev:/dev/i2c-3 && ddccontrol -r 0x10 -w 70 dev:/dev/i2c-3
    redshift -x
    ;;
  mid)
    ddccontrol -r 0x10 -w 15 dev:/dev/i2c-1
    ddccontrol -r 0x10 -w 15 dev:/dev/i2c-2
    ddccontrol -r 0x14 -w 11 dev:/dev/i2c-3 && ddccontrol -r 0x10 -w 5 dev:/dev/i2c-3
    redshift -x && redshift -O 3500
    ;;
  low)
    ddccontrol -r 0x10 -w 0 dev:/dev/i2c-1
    ddccontrol -r 0x10 -w 0 dev:/dev/i2c-2
    ddccontrol -r 0x14 -w 11 dev:/dev/i2c-3 && ddccontrol -r 0x10 -w 0 dev:/dev/i2c-3
    redshift -x && redshift -O 2500

esac
