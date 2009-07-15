#!/bin/bash
# execute it for making symlinks in your workdirectory 
# to files in ~/configs
for ii in .*;do
    if [ -e $ii ];then
	if [ ! $ii = ".git" ];then
	    if [ -e ~/$ii ];then
		if [ $1 = '-f' ];then
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
