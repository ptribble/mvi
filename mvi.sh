#!/bin/ksh
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
# create a minimal viable illumos bootable image
#

#
# where the iso should end up
# override with -o
#
ISO_NAME=/tmp/mvi.iso

#
# Tribblix version for illumos pkgs
# override with -v
#
DISTVER=35

bail(){
    echo "ERROR: $1"
    exit 1
}

#
# *** CUSTOMIZE ***
# where your illumos and other packages live
#
THOME=${THOME:-/packages/localsrc/Tribblix}
export THOME
PROTO_DIR=${THOME}/illumos-pkgs-m${DISTVER}
INSTZAP=/usr/lib/zap/instzap
if [ ! -x "${INSTZAP}" ]; then
    INSTZAP=${THOME}/zap/usr/lib/zap/instzap
fi
if [ ! -x "${INSTZAP}" ]; then
    bail "unable to find instzap"
fi

#
# *** CUSTOMIZE ***
# where your mvi configuration lives
#
MVI_DIR=${THOME}/mvi

#
# argument processing
#
PKG_LIST="mvi"
INSTALL_PKGS=${MVI_DIR}/install-from-local.sh
while getopts "frso:p:v:" opt; do
    case $opt in
	f)
	    # install from file system
	    INSTALL_PKGS=${MVI_DIR}/install-from-local.sh
	    if [ ! -d "$PROTO_DIR" ]; then
		bail "unable to find packages area $PROTO_DIR"
	    fi
	    ;;
	r)
	    # install from repo
	    INSTALL_PKGS=${MVI_DIR}/install-from-repo.sh
	    echo "WARNING: not yet supported"
	    exit 2
	    ;;
	s)
	    # install via system (direct zap)
	    INSTALL_PKGS=${MVI_DIR}/install-with-zap.sh
	    ;;
	o)
	    # output file
	    ISO_NAME="$OPTARG"
	    ;;
	p)
	    # name of file containing pkg list
	    PKG_LIST="$OPTARG"
	    ;;
	v)
	    # tribblix version
	    DISTVER="$OPTARG"
	    PROTO_DIR=${THOME}/illumos-pkgs-m${DISTVER}
	    ;;
	*)
	    bail "invalid argument $opt"
	    ;;
    esac
done
shift $((OPTIND-1))

#
# this is the size of the ramdisk we create and should match the size
# of the packaged install
#
MRSIZE=160M
NBPI=16384

#
# this is the temporary area where we dump stuff while building
#
DESTDIR=/tmp/mvi.$$

#
# bail if something is already there
#
if [ -d "$DESTDIR" ]; then
    bail "$DESTDIR already exists"
fi
if [ -f "$DESTDIR" ]; then
    bail "$DESTDIR already exists (as a file)"
fi
#
# check we have input to deal with
#
if [ ! -d "$MVI_DIR" ]; then
    bail "unable to find mvi area $MVI_DIR"
fi
if [ ! -x "${INSTALL_PKGS}" ]; then
    bail "unable to find install script ${INSTALL_PKGS}"
fi
if [ ! -f "${MVI_DIR}/${PKG_LIST}.pkgs" ]; then
    bail "unable to find package list ${MVI_DIR}/${PKG_LIST}.pkgs"
fi

#
# clean up and populate
#
${INSTALL_PKGS} "${DISTVER}" ${DESTDIR} "${MVI_DIR}/${PKG_LIST}.pkgs"

#
# these are options
#
for xopt in "$@"
do
    if [ -f "${MVI_DIR}/${xopt}.pkgs" ]; then
	${INSTALL_PKGS} "${DISTVER}" ${DESTDIR} "${MVI_DIR}/${xopt}.pkgs"
    fi
done

#
# *** CUSTOMIZE ***
# this is where you can remove any junk from the ISO that you don't want
#
cd ${DESTDIR} || bail "cannot cd to ${DESTDIR}"
# no man pages
rm -fr usr/share/man
# there's no packaging
rm -fr var/sadm
rm -fr usr/sadm
# never need to build
rm -fr usr/include
# junk
rm -fr usr/demo
rm -fr usr/lib/spell
rm -fr usr/has
rm -fr usr/share/doc
rmdir usr/games
rm -f usr/dict
rm -fr usr/share/lib/dict
rm -f usr/mail
rm -f usr/tmp
rm -f usr/adm
rm -f usr/preserve
rm -f usr/src
rm -f usr/pub
rm -f usr/spool
rm -fr usr/share/lib/pub
rm -fr usr/share/lib/xml
rm -fr usr/lib/python2.6
rm -f usr/bin/edit usr/bin/vedit
rm -f usr/bin/ed usr/bin/red
rm -f usr/bin/csh
rm -f usr/bin/zonestat
rm -f usr/bin/tip
rm -f usr/bin/amd64/mdb usr/bin/amd64/adb
rm -f usr/bin/i86/mdb usr/bin/i86/adb
rm -f usr/bin/mdb usr/bin/adb
rm -f usr/bin/amd64/savecore usr/bin/i86/savecore usr/bin/savecore
rm -f usr/sbin/ufs* usr/sbin/clri usr/sbin/devnm
rm -f usr/sbin/pwck usr/sbin/grpck etc/grpck
rm -fr usr/lib/raidcfg
rm -f usr/sbin/raidctl
# we don't run smf, so don't need manifests
# although keep the method scripts in case we need to run them
rm -fr lib/svc/manifest
rm -fr var/svc/manifest
rm -fr lib/svc/seed
# don't need compat links
rm -fr usr/ccs
rm -fr usr/proc
#
# don't need mail
#
rm -fr var/mail
rm -fr usr/share/lib/mailx
rm -f usr/bin/*mail*
rm -f usr/lib/*mail*
rm -f usr/lib/amd64/*mail*
#
# let's hope no applications need this
#
rm -fr lib/libmvec*
rm -f lib/amd64/libmvec*
rm -f usr/lib/amd64/libmvec*
rm -f usr/lib/libmvec*
#
# it seems we can't remove the zfs kernel modules cleanly, as
# the system panics if you run a find on the device tree, so
# remove the commands by hand
#
rm -f sbin/zpool
rm -f usr/sbin/zpool
rm -f sbin/zfs
rm -f usr/sbin/zfs
rm -f usr/sbin/zstreamdump
rm -fr usr/lib/fs/zfs
rm -fr usr/lib/zfs
rm -fr etc/fs/zfs
rm -f usr/sbin/amd64/zdb usr/sbin/i86/zdb usr/sbin/zdb
#
# no zones (maybe revisit)
#
rm -fr usr/lib/brand
rm -fr usr/lib/zones
rm -f usr/sbin/zoneadm
rm -f usr/sbin/zonecfg
rm -f usr/sbin/zlogin
#
# all networking will be static
#
rm -f lib/inet/nwamd
rm -f lib/inet/in.mpathd
rm -f sbin/in.mpathd
rm -f usr/lib/inet/in.mpathd
rm -f sbin/ipmpstat
rm -f usr/sbin/ipmpstat
rm -f sbin/dlstat
rm -f sbin/flowstat
rm -f sbin/flowadm
rm -f usr/sbin/nwamcfg
rm -f usr/sbin/nwamadm
rm -fr etc/nwam
#
# no standard admin
#
rm -f usr/sbin/user*
rm -f usr/sbin/proj*
rm -f usr/sbin/group*
rm -f usr/sbin/role*
#
# these would only be needed in an installer
#
rm -f sbin/bootadm
rm -f usr/sbin/bootadm
rm -f sbin/installgrub
rm -f usr/sbin/installgrub
#
# don't support smf
#
rm -f usr/sbin/svccfg
rm -f usr/bin/svcs
rm -f usr/sbin/svcadm
rm -f usr/bin/svcprop
rm -fr lib/svc/bin

#
# run any requested cleanup scripts
# use . so they can set variables for us
#
for xopt in "$@"
do
    if [ -f "${MVI_DIR}/${xopt}-fix.sh" ]; then
	echo "Running ${xopt}-fix.sh"
	. "${MVI_DIR}/${xopt}-fix.sh"
    fi
done
#
# illumos itself cannot run SMF, that needs libxml2, so just run a shell
# this is a script so (a) we can emit a message saying we're ready,
# and (b) it's extensible
#
cd ${DESTDIR} || bail "cannot cd to ${DESTDIR}"
cat > ${DESTDIR}/etc/mvi.rc <<EOF
#!/sbin/sh
if [ ! -f /startup ]; then
  /etc/fs/ufs/mount -o remount,rw /devices/ramdisk:a /
  echo "y" > /startup
fi
EOF
for xopt in "$@"
do
    if [ -f "${MVI_DIR}/${xopt}.rc" ]; then
	cp "${MVI_DIR}/${xopt}.rc" "${DESTDIR}/etc/mvi-${xopt}.rc"
	chmod a+x "${DESTDIR}/etc/mvi-${xopt}.rc"
cat >> ${DESTDIR}/etc/mvi.rc <<EOF
echo " *** Running ${xopt} startup ***" > /dev/console
/etc/mvi-${xopt}.rc >/dev/console 2>&1 </dev/console
EOF
    fi
done
cat >> ${DESTDIR}/etc/mvi.rc <<EOF
echo " *** Welcome to minimal viable illumos ***" > /dev/console
/bin/ksh93 >/dev/console 2>&1 </dev/console
EOF
chmod a+x ${DESTDIR}/etc/mvi.rc
#
# init has intimate coupling with smf, there must be an smf entry here
#
mv ${DESTDIR}/etc/inittab ${DESTDIR}/etc/inittab.tmp
cat ${DESTDIR}/etc/inittab.tmp | grep -v startd > ${DESTDIR}/etc/inittab
rm ${DESTDIR}/etc/inittab.tmp
cat >> ${DESTDIR}/etc/inittab << _EOF
smf::sysinit:/etc/mvi.rc
_EOF

#
# https://blogs.oracle.com/darren/entry/sending_a_break_to_opensolaris
#
cat >> ${DESTDIR}/etc/system << _EOF
set pcplusmp:apic_kmdb_on_nmi=1
_EOF
#
# create the uefi boot block
#
"${MVI_DIR}"/uefi.sh ${DESTDIR}

#
# paranoia, we don't want a boot archive inside the boot archive
#
rm -f ${DESTDIR}/platform/i86pc/amd64/boot_archive
rm -f ${DESTDIR}/platform/*/boot_archive

#
# the live boot has the 32-bit archive and no hash
#
cat > ${DESTDIR}/boot/conf.d/livemedia <<EOF
boot_archive_load="YES"
boot_archive_type="rootfs"
boot_archive_name="/platform/i86pc/boot_archive"

boot_archive.hash_load="NO"
boot_archive.hash_type="hash"
boot_archive.hash_name="/platform/i86pc/${ISADIR}/boot_archive.hash"
EOF

#
# now we create a block device that will back a ufs file system
# that we will copy the constructed image to
#
mkfile ${MRSIZE} /tmp/${MRSIZE}
#
# gzip doesn't like the sticky bit
#
chmod -t /tmp/${MRSIZE}
LOFIDEV=$(lofiadm -a /tmp/${MRSIZE})
LOFINUM=$(echo "$LOFIDEV"|awk -F/ '{print $NF}')
echo "y" | env NOINUSE_CHECK=1 newfs -o space -m 0 -i $NBPI /dev/rlofi/"$LOFINUM"
BFS=/tmp/nb.$$
mkdir $BFS
mount -Fufs -o nologging "$LOFIDEV" $BFS
cd ${DESTDIR} || bail "cannot cd to ${DESTDIR}"
tar cf - . | ( cd $BFS ; tar xf -)
cd $BFS || bail "cannot cd to $BFS"
touch etc/mnttab
mkdir -p dev/fd devices/pseudo opt var var/run mnt
${DESTDIR}/usr/sbin/devfsadm -r ${BFS}
rm -f ${BFS}/dev/dsk/* ${BFS}/dev/rdsk/* ${BFS}/dev/usb/h*
rm -f ${BFS}/dev/removable-media/dsk/* ${BFS}/dev/removable-media/rdsk/*
rm -fr ${BFS}/dev/zcons/*
#
# it's useful to know how much space we use, so we can adjust MRSIZE
# and NBPI to suit
#
cd /
DF=/usr/bin/df
if [ -x /usr/gnu/bin/df ]; then
  DF=/usr/gnu/bin/df
  $DF -h $BFS
  $DF -i $BFS
else
  $DF -h $BFS
fi

#
# unmount, then compress the block device and copy it back
#
umount $BFS
lofiadm -d /dev/lofi/"$LOFINUM"
gzip /tmp/${MRSIZE}
cp /tmp/${MRSIZE}.gz ${DESTDIR}/platform/i86pc/boot_archive
rm /tmp/${MRSIZE}.gz
rmdir $BFS
#
# and tell the user how big it is
#
ls -lsh ${DESTDIR}/platform/i86pc/boot_archive

#
# all we need on the ISO is the platform and boot directories
#
cd ${DESTDIR} || bail "cannot cd to ${DESTDIR}"
rm bin
rm -fr dev devices etc export home kernel lib licenses mnt opt proc root sbin system tmp usr var

#
# now make the iso
#
CDBOOT="boot/cdboot"
UEFIBOOT="boot/efiboot.img"
/usr/bin/mkisofs -N -l -R -U -d -D -o "${ISO_NAME}" \
	-V "illumos" \
	-allow-multidot -no-iso-translate -cache-inodes \
	-c .catalog \
	-b ${CDBOOT} -no-emul-boot -boot-load-size 4 -boot-info-table \
	-eltorito-alt-boot -eltorito-platform efi \
	-eltorito-boot ${UEFIBOOT} -no-emul-boot \
	${DESTDIR}
sync
ls -lsh "$ISO_NAME"
echo "Hybridizing"
"${MVI_DIR}"/hybridize-iso "${ISO_NAME}" ${DESTDIR}
ls -lsh "$ISO_NAME"

#
# and clean up
#
cd /
rm -fr ${DESTDIR}
