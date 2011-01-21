#!/bin/bash

toggle () {
    myname=$(whoami)
    fpid=$(ps -U $myname -o '%c %p'| grep $1 | sed -e "s/^.*\ \([0-9]\+\)$/\1/")
    if [[ $fpid -ne 0 ]];then
        kill -SIGUSR1 $fpid
        sleep 5
    else
        $1 &
    fi
}

if [[ -n $1 ]];then
    toggle $1
fi
exit 0