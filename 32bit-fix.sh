#!/bin/sh
#
# clean the system ready for a 32-bit only boot
#
rm -fr `find usr -name amd64 -type d`
rm -fr `find kernel -name amd64 -type d`
rm -fr `find lib -name amd64 -type d`
rm -fr `find platform -name amd64 -type d`
#
# in general, a 32-bit build is about half the base size
#
TSIZE=`echo $MRSIZE | sed s:M::`
TSIZE=$(($TSIZE/2))
MRSIZE=${TSIZE}M
