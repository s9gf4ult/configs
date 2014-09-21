#!/bin/bash

DEPTH=$1



find ./ -maxdepth $DEPTH -type d -print0 | while read -d $'\0' file; do
    (
        name=`basename "$(realpath "$file")"`
        if [[ ${#name} -le 12 ]]; then
            cd "$file"
            echo "$file"
            genpl.sh "${name}.m3u"
        fi
    )
done
