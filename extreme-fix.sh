#!/bin/sh
#
# assume mvix
#
rm -f kernel/fs/*/zfs
rm -f kernel/drv/*/zfs
rm -f kernel/drv/zfs.conf
rm -fr etc/fs/zfs
gsed -i '/zfs/d' etc/minor_perm
gsed -i '/zfs/d' etc/name_to_major
rm kernel/misc/*/kmdbmod
rm kernel/drv/*/bsc*
rm -fr kernel/crypto
rm -f kernel/misc/*/des
rm -f kernel/misc/*/skein
rm -f kernel/misc/*/sha1
rm -f kernel/misc/*/sha2
rm -f kernel/misc/*/edonr
rm -f kernel/misc/*/md5
rm -f kernel/misc/*/crypto
rm -f kernel/drv/*/kssl
rm -f kernel/drv/kssl.conf
rm -f kernel/misc/*/kcf
rm -fr etc/crypto
rm -f kernel/drv/*/power
rm -f kernel/drv/power.conf
rm -f kernel/drv/*/keysock
rm -f kernel/drv/keysock.conf
rm -f kernel/drv/*/spdsock
rm -f kernel/drv/spdsock.conf
rm -f kernel/drv/*/kmdb
rm -f kernel/drv/kmdb.conf
rm -f kernel/misc/*/ctf
rm -f kernel/misc/*/ksocket
rm -f kernel/sys/*/kaio
rm -f kernel/misc/*/tlimod
rm -f kernel/strmod/*/timod
rm -f kernel/strmod/*/tirdwr
rm -f kernel/drv/*/tl
rm -f kernel/drv/tl.conf
rm -f kernel/drv/*/rts
rm -f kernel/drv/rts.conf

#
# clean up even more
#
rm -fr etc/rcm
rm -fr etc/user_attr.d
rm -fr etc/sock2path.d
rm -fr etc/ftpd
rm etc/ftpusers
rm etc/cfgadm
rm etc/clri
rm etc/cron
rm etc/dcopy
rm etc/fmthard
rm etc/format
rm etc/fsck
rm etc/fsdb
rm etc/fstyp
rm etc/grpck
rm etc/halt
rm etc/install
rm etc/killall
rm etc/labelit
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
rm etc/rc0
rm etc/rc1
rm etc/rc2
rm etc/rc3
rm etc/rc5
rm etc/rc6
rm etc/rcS
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
rm etc/format.dat
rm -fr etc/dhcp
rm etc/device.tab
rm -fr etc/security/*.d
rm -fr etc/sysevent
rm -f etc/ttysrch
#
rmdir var/opt
rmdir var/logadm
rmdir var/cron
rmdir var/audit
rmdir var/log
rmdir var/tmp
rmdir var/ld/amd64
rmdir opt
rmdir export
rmdir mnt
rmdir home
#
rm kernel/drv/*/ecpp
rm kernel/drv/ecpp.conf
rm kernel/drv/*/usbprn
rm kernel/drv/*/ipsec*
rm kernel/drv/ipsec*.conf
rm kernel/strmod/*/ipsec*
rm kernel/drv/*/lofi
rm kernel/drv/lofi.conf
rm kernel/drv/*/tzmon
rm kernel/drv/tzmon.conf
rm kernel/drv/*/iptun
rm kernel/drv/iptun.conf
rm kernel/fs/*/autofs
rm kernel/sys/*/autofs
rm -fr kernel/kmdb
rm -fr kernel/dacf
rm kernel/drv/*/st kernel/drv/st.conf
rm kernel/drv/*/usb_a*
rm kernel/strmod/usb_a*
rm kernel/drv/*/mpt*
rm kernel/drv/mpt*
rm kernel/misc/*/cardbus
rm kernel/misc/*/pcmcia
rm kernel/strmod/*/usbwcm
rm kernel/strmod/*/vuidm*
rm kernel/drv/*/acpi_toshiba
rm kernel/fs/*/lofs
rm kernel/fs/*/dcfs
rm kernel/sys/*/msgsys
rm kernel/sys/*/semsys
rm kernel/sys/*/shmsys
rm kernel/drv/*/dtrace
rm kernel/drv/dtrace.conf
rm kernel/drv/*/systrace
rm kernel/drv/systrace.conf
rm kernel/drv/*/lockstat
rm kernel/drv/lockstat.conf
rm kernel/drv/*/fbt
rm kernel/drv/fbt.conf
rm kernel/drv/*/dcpc
rm kernel/drv/dcpc.conf
rm -fr kernel/dtrace
rm kernel/fs/*/hsfs
rm kernel/sys/*/c2audit
rm kernel/drv/*/fd*
rm kernel/drv/fd*
#
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
rm -fr platform/i86pc/ucode

#
# we use about 22M of space
# vbox will boot in 58M RAM
#
MRSIZE=22M
