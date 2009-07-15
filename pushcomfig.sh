#!/bin/bash
# execute it for making symlinks in your workdirectory 
# to files in ~/configs
for ii in .*;do
    if [ -e $ii ];then
	if [ ! $ii = ".git" ]&&[ ! $ii = "." ]&&[ ! $ii = ".." ];then
	    if [ -e ~/$ii ];then
		if [ x$1 = "x-f" ];then
		    rm -rf ~/$ii
		    ln -s -T ~/configs/$ii ~/$ii
		else
		    echo "you can not do that::file ~/$ii is exist"
		fi
	    else
		ln -s -T ~/configs/$ii ~/$ii
	    fi
	fi
    fi
done
######################################################################
# if you want use vimrc.local you must make symlink to ./vimrc.local #
# in /etc/vim directory						     #
######################################################################
