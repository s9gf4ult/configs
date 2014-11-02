#!/bin/bash

tfile=$(tempfile)

find ./ -type f -iname '*.ape' -print0 > "$tfile"

cat "$tfile" | while read -d $'\0' file; do
    echo ">>>>> $file"
    dir=$(dirname "$file")
    input=$(basename "$file")
    name=$(basename "$file" .ape)
    pushd "$dir"
    ffmpeg -i "$input" "${name}.flac" && rm "$input"
    popd
done

rm "$tfile"
