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
# in general, a 64-bit build is about two thirds the base size
# mvix.sh can go below 48M
#
TSIZE=`echo $MRSIZE | sed s:M::`
TSIZE=$((2*$TSIZE/3))
MRSIZE=${TSIZE}M
