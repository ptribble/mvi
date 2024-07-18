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
# analogous to nonet, remove all support for disks
#
rm -f kernel/drv/*/ata*
rm -f kernel/drv/*/cmdk*
rm -f kernel/drv/*/mpt*
rm -f kernel/drv/*/ahci*
rm -f kernel/drv/*/sd*
rm -f kernel/drv/*/scsa2usb*
rm -f kernel/drv/*/scsi_vhci*
rm -f kernel/drv/*/sgen*
rm -f kernel/drv/ata*
rm -f kernel/drv/cmdk*
rm -f kernel/drv/mpt*
rm -f kernel/drv/ahci*
rm -f kernel/drv/sd*
rm -f kernel/drv/scsa2usb*
rm -f kernel/drv/scsi_vhci*
rm -f kernel/drv/sgen*
rm -fr kernel/misc/scsi_vhci
rm -f kernel/misc/*/dadk
rm -f kernel/misc/*/sata
rm -f kernel/misc/*/scsi
rm -f etc/default/mpathd

#
# modify MRSIZE
#
TSIZE=${MRSIZE/M/}
TSIZE=$((TSIZE-1))
export MRSIZE=${TSIZE}M
