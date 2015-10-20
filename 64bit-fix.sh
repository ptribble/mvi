#!/bin/sh
#
# script to clean up for a 64-bit only boot
#
# note that userland isn't touched
#
OLDPWD=`pwd`
for dir in kernel platform usr/kernel
do
    for ddir in `find $dir -xdev -name amd64 -type d`
    do
	cd $ddir
	for file in *
	do
	    rm ../$file
	done
	cd $OLDPWD
    done
done
#
# mvi.sh would be sane at 144M
# mvix.sh can go below 48M
#
MRSIZE=48M
#MRSIZE=144M
