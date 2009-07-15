#!/bin/bash
# execute it for making symlinks in your workdirectory 
# to files in ~/configs
for ii in .*;do
    if [ -e $ii ];then
	if [ ! $ii = ".git" ];then
	    ln -s -T ~/configs/$ii ~/$ii
	fi
    fi
done
######################################################################
# if you want use vimrc.local you must make symlink to ./vimrc.local #
# in /etc/vim directory						     #
######################################################################
