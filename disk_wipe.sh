#!/bin/sh
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# }}}
#
# Copyright 2024 Peter Tribble
#

#
# wipe a disk
#
# On solarish systems, format/analyze/purge met old DOD requirements for
# overwriting a disk. Truly secure data removal requires degaussing or
# physical destruction, but if any form of overwrite or disk wipe is
# good enough, this script will do that for you
#

#
# arguments
# -A - wipe all drives
# -B - fdisk the drives, so we overwrite the whole drive; by default
#    we just purge the Solaris partition
# -C - number of times to run the wipe [unimplemented]
# -D - switch defect lists (not valid for all drives)
# * - a list of drives to wipe
#

#
# this script has minimal requirements so that it can run under mvi
# ksh [as /bin/sh] format devfsadm fdisk cat rm
#

WIPEALL=""
BFLAG=""
DEFECT=""
COUNT=1

while getopts "ABC:D" opt; do
case $opt in
A)
  WIPEALL="y"
  ;;
B)
  BFLAG="-B"
  ;;
C)
  COUNT="$OPTARG"
  ;;
D)
  DEFECT="y"
  ;;
esac
done
shift $((OPTIND - 1))

#
# any remaining arguments must be disk names
# must give a list or -A
#
if [[ -n "$WIPEALL" && $# -gt 0 ]]; then
    echo "Cannot specify -A with disk names"
    exit 1
fi
if [[ -z "$WIPEALL" && $# -le 0 ]]; then
    echo "Must specify -A or provide a list of disks"
    exit 1
fi

#
# construct drive list
# we need the name of the *drive*, not slice or partition
# try and remove all removable devices from the list
#
DLIST=""
if [[ -n "$WIPEALL" ]]; then
    cd /dev/dsk
    for drive in c*s2
    do
	if [ ! -h /dev/removable-media/dsk/$drive ]; then
	    drive=${drive/s2/}
	    DLIST="${DLIST} ${drive}"
	fi
    done
    if [[ -z "$DLIST" ]]; then
	echo "No drives detected"
	exit 1
    else
	echo "Drive list is"
	echo $DLIST
    fi
else
    cd /dev/dsk
    for drive in $*
    do
	#
	# there's a complex dance here to normalize the drive name
	#
	drive=${drive/\/dev\/dsk\//}
	if [ -h ${drive}s2 ]; then
	    drive="${drive}s2"
	fi
	if [ -h /dev/dsk/${drive} ]; then
	    drivel=${#drive}
	    drivel=$((drivel-1))
	    drivel=$((drivel-1))
	    drive=${drive:0:$drivel}
	    drive="${drive}s2"
	    if [ -h /dev/removable-media/dsk/$drive ]; then
		echo "ERROR: $drive is removable, skipping"
	    else
		drive=${drive/s2/}
		DLIST="${DLIST} ${drive}"
	    fi
	else
	    echo "ERROR: $drive is invalid, skipping"
	fi
    done
    if [[ -z "$DLIST" ]]; then
	echo "No valid drives detected"
	exit 1
    else
	echo "Drive list is"
	echo $DLIST
    fi
fi

FFILE=/tmp/disk_wipe.$$.input
/bin/rm -f $FFILE
if [[ -n $DEFECT ]]; then
cat > $FFILE <<EOF
defect
primary
quit
analyze
purge
quit
defect
both
quit
analyze
purge
quit
backup
quit
EOF
else
cat > $FFILE <<EOF
analyze
purge
quit
EOF
fi

#
# this is where you do the work
#
if [[ -n $BFLAG ]]; then
  for disk in $DLIST
  do
    fdisk -B /dev/rdsk/${disk}p0
  done
fi
#
# while [[ $COUNT -gt 0 ]]
# do
for disk in $DLIST
do
    format -f $FFILE -l /tmp/disk_wipe.${disk}.log $disk > /dev/null 2>&1 &
    echo "log output is in /tmp/disk_wipe.${disk}.log"
done
# COUNT=$((COUNT-1))
# done
#

#
# clean up
#
/bin/rm -f $FFILE
