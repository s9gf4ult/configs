#!/bin/bash
cd ~/dox
cp ~/tmp/assoo.txt .
git add assoo.txt
git commit -m 'assoo.txt changed'
git push local master:master
