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
# all it does is take a proto area and convert it into a bootable ramdisk
#

#
# where the iso should end up
# override with -o
#
ISO_NAME=/var/tmp/illumos-pureboot.iso

bail(){
    echo "ERROR: $1"
    exit 1
}

#
# *** CUSTOMIZE ***
# where your proto area is
#
THOME=${THOME:-/packages/localsrc/Tribblix}
export THOME
PROTO_DIR=${HOME}/illumos-gate/proto/root_i386

#
# *** CUSTOMIZE ***
# where your mvi configuration lives
#
MVI_DIR=${THOME}/mvi

#
# argument processing
#
while getopts "o:" opt; do
    case $opt in
	o)
	    # output file
	    ISO_NAME="$OPTARG"
	    ;;
	*)
	    bail "invalid argument $opt"
	    ;;
    esac
done
shift $((OPTIND-1))

#
# this is the size of the ramdisk we create and should match the size
# of the proto area (du should be reasonable)
# you can reduce it if you do any serious trimming of the image
#
MRSIZE=512M
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
if [ ! -d "$PROTO_DIR" ]; then
    bail "unable to find proto area $PROTO_DIR"
fi
#
# clean up and populate
#
mkdir -p ${DESTDIR}
if [ ! -d "$DESTDIR" ]; then
    bail "$DESTDIR could not be created"
fi
cd ${PROTO_DIR} || bail "cannot cd to ${PROTO_DIR}"
tar cf - . | ( cd ${DESTDIR} ; tar xf -)

#
# *** CUSTOMIZE ***
# this is where you can remove any junk from the ISO that you don't want
#
cd ${DESTDIR} || bail "cannot cd to ${DESTDIR}"
## rm -fr opt

#
# illumos itself cannot run SMF, that needs libxml2, so just run a shell
# this is a script so (a) we can emit a message saying we're ready,
# and (b) it's extensible
#
cd ${DESTDIR} || bail "cannot cd to ${DESTDIR}"
cat > ${DESTDIR}/etc/mvi.rc <<EOF
#!/sbin/sh
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
# so this is sort of stupid, the proto area contains blank versions
# of the critical kernel state files, so we need to add populated
# versions and we get those from the running system, because that's
# the only reliable source I know of
#
for kfile in driver_classes minor_perm name_to_major driver_aliases
do
    cp /etc/${kfile} ${DESTDIR}/etc
done

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
/usr/bin/chown -hR root:root .
touch reconfigure
${DESTDIR}/usr/sbin/devfsadm -r ${BFS}
rm -f ${BFS}/dev/dsk/* ${BFS}/dev/rdsk/* ${BFS}/dev/usb/h*
rm -f ${BFS}/dev/removable-media/dsk/* ${BFS}/dev/removable-media/rdsk/*
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
