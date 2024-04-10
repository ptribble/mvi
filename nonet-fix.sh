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
# remove networking, both the e1000g driver and the utilities
#
# designed to run alongside mvix and extreme
#
# originally mvix.sh 32bit extreme gave
#
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/lofi/1      28M   26M  2.1M  93% /tmp/nb.3689
#
# but that's back in the day when 32bit existed
#
rm -f kernel/drv/*/e1000g*
rm -f kernel/drv/e1000g*
rm -f kernel/drv/*/vnic*
rm -f kernel/drv/vnic*
rm -f kernel/drv/*/aggr*
rm -f kernel/drv/aggr*
rm -f kernel/mac/*/mac_ipv6
rm -f kernel/drv/simnet*
rm -f kernel/drv/*/ip*
rm -f kernel/drv/ip*
rm -f kernel/drv/*/udp*
rm -f kernel/drv/udp*
rm -f kernel/drv/*/tcp*
rm -f kernel/drv/tcp*
rm -f kernel/drv/*/icmp*
rm -f kernel/drv/icmp*
rm -f kernel/drv/*/arp*
rm -f kernel/drv/arp*
rm -f kernel/drv/*/llc1*
rm -f kernel/drv/llc1*
rm -f kernel/drv/bridge*
rm -f kernel/drv/*/bridge*
rm -f kernel/drv/dlpistub*
rm -f kernel/drv/*/dlpistub*
rm -f kernel/mac/*/mac_ipv4
rm -fr kernel/mac
rm -fr kernel/ipp
rm -fr kernel/socketmod
rm -f kernel/strmod/*/ip
rm -f kernel/strmod/*/udp
rm -f kernel/strmod/*/tcp
rm -f kernel/strmod/*/icmp
rm -f kernel/strmod/*/arp
rm -f kernel/misc/*/net80211
rm -f kernel/sys/*/rpcmod
rm -f kernel/strmod/*/rpcmod
rm -f kernel/strmod/*/keysock
rm -f kernel/misc/*/rpcsec
rm -f kernel/misc/*/mii
rm -f kernel/misc/*/gld
rm -f kernel/misc/*/neti
rm usr/sbin/ifconfig
rmdir usr/sbin
rm -f sbin/ifconfig
rm -fr var/inet
rm -fr lib/inet
rm -f lib/libdladm.so.1
rm -f lib/libdevinfo.so.1
rm -f lib/libdlpi.so.1
rm -f lib/libgen.so.1
rm -f lib/libipadm.so.1
rm -f lib/libxnet.so.1
rm -f etc/default/inetinit
rm -f etc/default/ipsec
rm -fr etc/dladm
rm -fr etc/ipadm
rm -fr etc/rpcsec
rm -fr etc/net
rm etc/rpc

#
# modify MRSIZE
#
TSIZE=$(echo $MRSIZE | sed s:M::)
TSIZE=$((TSIZE-4))
MRSIZE=${TSIZE}M
