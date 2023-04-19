#!/bin/sh

set -e

runHT () {
    name=$1
    shift
    pushd $name
    hasktags -e  $(find `pwd` -iname *.hs -and \( -not -path *.stack-work* \) -and \( -not -name Setup.hs \) -and -type f)
    popd
}

( runHT ./ )
