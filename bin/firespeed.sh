#!/bin/bash

function opt_file() {
    if file $1 | grep SQLite;then
        echo 'vacuum; reindex;' | sqlite3 $1
    fi
}

function optimize() {
    echo "start optimize $1"
    for file in $1/*;do
        if [[ -d $file ]];then
            optimize $file
        else
            opt_file $file
        fi
    done
}

for dir in ~/.mozilla ~/.config/chromium; do
    if [[ -d $dir ]];then
        optimize $dir
    fi
done
