#!/bin/sh
#
# SPDX-License-Identifier: CDDL-1.0
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
# Copyright 2025 Peter Tribble
#

#
# install packages using zap
#
# the version is ignored, we inherit from the current system, but all the
# install options are called with the same arguments
#
case $# in
    3)
	DISTVER=$1
	DESTDIR=$2
	PKGLIST=$3
	;;
    *)
	echo "Usage: $0 version dest_dir pkg_list"
	exit 2
	;;
esac

INSTZAP=/usr/lib/zap/install-pkg
if [ ! -x "${INSTZAP}" ]; then
    echo "ERROR: unable to find zap"
    exit 1
fi

mkdir -p "${DESTDIR}"
for pkg in $(<"${PKGLIST}")
do
    $INSTZAP -R "$DESTDIR" $(echo "$pkg" | awk -F. '{print $1}')
done
