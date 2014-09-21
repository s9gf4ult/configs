#!/bin/bash

PLNAME=$1

echo '#EXTM3U' > tmp

find ./ -iname '*.mp3' \
    -or -iname '*.flac' \
    -or -iname '*.ape' \
    -or -iname '*.ogg' \
    -or -iname '*.aac' \
    -or -iname '*.wav' \
    | sort -n \
    | sed -e 's|./||' \
    | sed -e 's|/|\\|g' >> tmp

unix2dos tmp

# iconv -c -f UTF-8 -t CP1251 tmp > $PLNAME
mv tmp "$PLNAME"

# rm tmp
