#!/usr/bin/env bash

center="dev:/dev/i2c-7"
left="dev:/dev/i2c-6"
# right="dev:/dev/i2c-7"

case $1 in
  max)
    ddccontrol -r 0x14 -w 1 $center && ddccontrol -r 0x10 -w 100 $center
    ddccontrol -r 0x14 -w 1 $left && ddccontrol -r 0x10 -w 100 $left
    # ddccontrol -r 0x10 -w 100 $right
    redshift -x
    ;;
  high)
    ddccontrol -r 0x14 -w 1 $center && ddccontrol -r 0x10 -w 70 $center
    ddccontrol -r 0x14 -w 1 $left && ddccontrol -r 0x10 -w 70 $left
    # ddccontrol -r 0x10 -w 100 $right
    redshift -x
    ;;
  day)
    ddccontrol -r 0x14 -w 11 $center && ddccontrol -r 0x10 -w 40 $center
    ddccontrol -r 0x14 -w 11 $left && ddccontrol -r 0x10 -w 40 $left
    # ddccontrol -r 0x10 -w 100 $right
    redshift -x && redshift -O 5000
    ;;
  mid)
    ddccontrol -r 0x14 -w 11 $center && ddccontrol -r 0x10 -w 18 $center
    ddccontrol -r 0x14 -w 11 $left && ddccontrol -r 0x10 -w 18 $left
    # ddccontrol -r 0x10 -w 23 $right
    redshift -x && redshift -O 4000
    ;;
  night)
    ddccontrol -r 0x14 -w 11 $center && ddccontrol -r 0x10 -w 2 $center
    ddccontrol -r 0x14 -w 11 $left && ddccontrol -r 0x10 -w 2 $left
    # ddccontrol -r 0x10 -w 4 $right
    redshift -x && redshift -O 3500
    ;;
  low)
    ddccontrol -r 0x14 -w 11 $center && ddccontrol -r 0x10 -w 0 $center
    ddccontrol -r 0x14 -w 11 $left && ddccontrol -r 0x10 -w 0 $left
    # ddccontrol -r 0x10 -w 0 $right
    redshift -x && redshift -O 2500

esac
