#!/bin/bash

GNUCASHDIR="/home/razor/gnucash"
SSHKEY="/home/razor/.ssh/bucket-s9gf4ult"

ssh-agent bash <<EOF
ssh-add $SSHKEY
pushd $GNUCASHDIR
git add .
git add -u .
git commit -m "autocommit by script"
git push origin master:master
popd
EOF
