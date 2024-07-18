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

cp "${THOME}/mvi/disk_wipe.sh" wipe.sh
chmod a+x wipe.sh

#
# don't want networking in the wipe environment
#
rm -f kernel/drv/amd64/e1000g*
rm -f kernel/drv/amd64/vnic*
rm -f kernel/drv/amd64/aggr*
rm -f kernel/drv/amd64/ip6*
rm -f kernel/drv/amd64/udp6*
rm -f kernel/drv/amd64/tcp6*
rm -f kernel/drv/amd64/icmp6*
rm -f kernel/drv/amd64/simnet*
rm -f kernel/drv/amd64/ip*
rm -f kernel/drv/amd64/st
rm -f kernel/drv/amd64/udp*
rm -f kernel/drv/amd64/tcp*
rm -f kernel/drv/amd64/icmp*
rm -f kernel/drv/amd64/arp*
rm -f kernel/drv/amd64/llc1*
rm -f kernel/drv/amd64/bridge*
rm -f kernel/drv/amd64/dlpistub*
# and the conf files
rm -f kernel/drv/e1000g*
rm -f kernel/drv/vnic*
rm -f kernel/drv/aggr*
rm -f kernel/drv/ip6*
rm -f kernel/drv/udp6*
rm -f kernel/drv/tcp6*
rm -f kernel/drv/icmp6*
rm -f kernel/drv/simnet*
rm -f kernel/drv/ip*
rm -f kernel/drv/st.conf
rm -f kernel/drv/udp*
rm -f kernel/drv/tcp*
rm -f kernel/drv/icmp*
rm -f kernel/drv/arp*
rm -f kernel/drv/llc1*
rm -f kernel/drv/bridge*
rm -f kernel/drv/dlpistub*
#
rm -fr kernel/mac
rm -fr kernel/ipp
rm -fr kernel/socketmod
rm -f kernel/strmod/amd64/ip
rm -f kernel/strmod/amd64/udp
rm -f kernel/strmod/amd64/tcp
rm -f kernel/strmod/amd64/icmp
rm -f kernel/strmod/amd64/arp
rm -f kernel/misc/amd64/net80211
rm -f kernel/sys/amd64/rpcmod
rm -f kernel/sys/amd64/c2audit
rm -f kernel/strmod/amd64/rpcmod
rm -f kernel/strmod/amd64/keysock
rm -f kernel/misc/amd64/rpcsec
rm -f kernel/misc/amd64/mii
rm -f kernel/misc/amd64/gld
rm -f kernel/misc/amd64/neti
rm -f kernel/drv/amd64/power*
rm -f kernel/drv/amd64/keysock*
rm -f kernel/drv/amd64/spdsock*
rm -f kernel/drv/amd64/kmdb*
rm -f kernel/drv/amd64/ecpp*
rm -f kernel/drv/amd64/usbprn
rm -f kernel/drv/amd64/ipsec*
rm -f kernel/strmod/amd64/ipsec*
rm -f kernel/drv/amd64/lofi*
rm -f kernel/drv/amd64/tzmon*
rm -f kernel/drv/amd64/iptun*
rm -f kernel/fs/amd64/autofs
rm -f kernel/sys/amd64/autofs
rm -f kernel/drv/amd64/usb_a*
rm -f kernel/strmod/amd64/usb_a*
rm -f kernel/misc/amd64/cardbus
rm -f kernel/misc/amd64/pcmcia
rm -f kernel/misc/amd64/kmdbmod
rm -f kernel/strmod/amd64/usbwcm
rm -f kernel/strmod/amd64/vuidm*
rm -f kernel/drv/amd64/acpi_toshiba
rm -f kernel/fs/amd64/sockfs
rm -f kernel/fs/amd64/lofs
rm -f kernel/fs/amd64/dcfs
rm -f kernel/fs/amd64/hsfs
rm -fr kernel/kmdb
rm -f kernel/misc/amd64/tlimod
rm -f kernel/drv/amd64/tl*
rm -f kernel/drv/amd64/rts*
rm -f kernel/misc/amd64/idmap
rm -f kernel/sys/amd64/kaio

#
rm -f etc/default/inetinit
rm -f etc/default/ipsec
rm -fr etc/ftpd
rm -fr etc/dladm
rm -fr etc/ipadm
rm -fr etc/rpcsec
rm -fr etc/net
rm -fr etc/dhcp
rm -f etc/services etc/inet/services
rm -f etc/netmasks etc/inet/netmasks
rm -f etc/networks etc/inet/networks
rm -f etc/protocols etc/inet/protocols
rm -f etc/inet/ipaddrsel.conf
rm -fr etc/rcm
rm etc/rpc
rm etc/ftpusers
rm etc/cfgadm
rm etc/clri
rm etc/cron
rm etc/dcopy
rm etc/fmthard
rm etc/fsck
rm etc/fsdb
rm etc/fstyp
rm etc/getty
rm etc/grpck
rm etc/halt
rm etc/install
rm etc/killall
rm etc/labelit
rm etc/log
rm etc/mkfs
rm etc/mknod
rm etc/prtconf
rm etc/prtvtoc
rm etc/reboot
rm etc/setmnt
rm etc/shutdown
rm etc/swap
rm etc/sysdef
rm etc/tar
rm etc/wall
rm etc/whodo
rm etc/mount
rm etc/mountall
rm etc/sulogin
rm etc/swapadd
rm etc/telinit
rm etc/uadmin
rm etc/umount
rm etc/umountall
rm etc/dumpdates
rm etc/logadm.conf
rm etc/mailcap
rm etc/mime.types
rm etc/magic
rm etc/remote
rm etc/inetd.conf
rm etc/inet/inetd.conf
rm etc/inet/ipsec*
rm -fr etc/inet/ike
rm -fr etc/inet/secret
rm etc/nsswitch.ad
rm etc/nsswitch.ldap
rm etc/nsswitch.files
rm etc/nsswitch.dns
rm etc/device.tab
rm -fr etc/security/*.d
rm -f etc/ttysrch
rmdir var/opt
rmdir var/logadm
rmdir var/cron
rmdir var/audit
rm -fr var/log
rmdir var/tmp
rm etc/default/cron
rm etc/default/devfsadm
rm etc/default/dhcpagent
rm etc/default/keyserv
rm etc/default/nss
rm etc/default/passwd
rm etc/default/su
rm etc/default/syslogd
rm etc/default/tar
rm etc/default/useradd
rm etc/default/utmpd
rm -fr etc/dev
rm -fr etc/fs/dev
rm -fr etc/usb
rm -fr etc/security/lib
rm -fr etc/security/audit*
rm etc/nscd.conf
rm etc/syslog.conf
rm -fr var/saf
rmdir var/cores
rmdir var/idmap
rmdir var/inet
rm var/adm/spellhist
rm var/adm/aculog
rmdir var/adm/*
rmdir export mnt opt home

#
rm -f usr/sbin/ifconfig sbin/ifconfig
rmdir usr/bin/amd64

#
rm boot/grub/reiser*
rm boot/grub/zfs*
rm boot/grub/jfs*
rm boot/grub/xfs*
rm boot/grub/e2fs*
rm boot/grub/minix*
rm boot/grub/vstafs*
rm boot/grub/fat*
rm boot/grub/ffs*
rm -fr boot/grub/bin
rm boot/grub/ufs*
rm boot/grub/stage2
rm -fr boot/acpi
rm -f boot/solaris/filelist*
rm -fr boot/solaris/bin

#
# 
#
export MRSIZE=40M
