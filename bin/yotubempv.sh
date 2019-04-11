#!/usr/bin/env bash

mpv --speed=1.5 --af=rubberband --cache-default=500000 --geometry=800 $(xclip -o)
