#!/bin/sh
#
# clean the system ready for a 32-bit only boot
#
rm -fr `find usr -name amd64 -type d`
rm -fr `find kernel -name amd64 -type d`
rm -fr `find lib -name amd64 -type d`
rm -fr `find platform -name amd64 -type d`
MRSIZE=90M
