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
# Copyright 2024 Peter Tribble
#

#
# install packages from local directories
#
# this is really for my (ptribble) use
#
case $# in
    3)
	DISTVER=$1
	DESTDIR=$2
	PKGLIST=$3
	;;
    *)
	echo "Usage: $0 version dest_dir pkg_list"
	exit 1
	;;
esac

#
# THOME should be set in the environment
#
if [ -z "${THOME}" ]; then
    echo "ERROR: THOME not set"
    exit 1
fi

#
# Tribblix version for illumos pkgs
#
ILVER=0.${DISTVER}

PROTO_DIR=${THOME}/illumos-pkgs-m${DISTVER}
INSTZAP=/usr/lib/zap/instzap
if [ ! -x "${INSTZAP}" ]; then
    INSTZAP="${THOME}/zap/usr/lib/zap/instzap"
fi
if [ ! -x "${INSTZAP}" ]; then
    echo "ERROR: unable to find instzap"
    exit 1
fi
if [ ! -d "${PROTO_DIR}/pkgs" ]; then
    echo "ERROR: unable to find packages area ${PROTO_DIR}/pkgs"
    exit 1
fi

mkdir -p "${DESTDIR}"
for pkg in $(<"${PKGLIST}")
do
    if [ -f "${PROTO_DIR}/pkgs/${pkg}.${ILVER}.zap" ]; then
	$INSTZAP -R "$DESTDIR" "${PROTO_DIR}/pkgs/${pkg}.${ILVER}.zap" $(echo "$pkg" | awk -F. '{print $1}')
    else
	$INSTZAP -R "$DESTDIR" "${THOME}/pkgs/${pkg}.zap" $(echo "$pkg" | awk -F. '{print $1}')
    fi
done
