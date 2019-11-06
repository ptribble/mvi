#!/bin/ksh
#
# create a minimal viable illumos bootable image
#

#
# where the iso should end up
#
ISO_NAME=/var/tmp/mvi.iso

#
# Tribblix version for illumos pkgs
#
DISTVER=21.0

#
# *** CUSTOMIZE ***
# where your illumos and other packages live
#
THOME=${THOME:-/packages/localsrc/Tribblix}
export THOME
PROTO_DIR=${THOME}/illumos-pkgs-m${DISTVER}
INSTZAP=/usr/lib/zap/instzap
if [ ! -x ${INSTZAP} ]; then
    INSTZAP=${THOME}/zap/usr/lib/zap/instzap
fi
if [ ! -x ${INSTZAP} ]; then
    echo "ERROR: unable to find instzap"
    exit 1
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
while getopts "frsp:v:" opt; do
    case $opt in
	f)
	    # install from file system
	    INSTALL_PKGS=${MVI_DIR}/install-from-local.sh
	    if [ ! -d $PROTO_DIR ]; then
		echo "ERROR: unable to find packages area $PROTO_DIR"
		exit 1
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
	p)
	    # name of file containing pkg list
	    PKG_LIST="$OPTARG"
	    ;;
	v)
	    # tribblix version
	    DISTVER="$OPTARG"
	    PROTO_DIR=${THOME}/illumos-pkgs-m${DISTVER}
	    ;;
    esac
done
shift $((OPTIND-1))

#
# this is the size of the ramdisk we create and should match the size
# of the packaged install
#
MRSIZE=96M
NBPI=16384

#
# this is the temporary area where we dump stuff while building
#
DESTDIR=/tmp/mvi.$$

#
# bail if something is already there
#
if [ -d $DESTDIR ]; then
    echo "ERROR: $DESTDIR already exists"
    exit 1
fi
if [ -f $DESTDIR ]; then
    echo "ERROR: $DESTDIR already exists (as a file)"
    exit 1
fi
#
# check we have input to deal with
#
if [ ! -d $MVI_DIR ]; then
    echo "ERROR: unable to find mvi area $MVI_DIR"
    exit 1
fi
if [ ! -x ${INSTALL_PKGS} ]; then
    echo "ERROR: unable to find install script ${INSTALL_PKGS}"
    exit 1
fi
if [ ! -f ${MVI_DIR}/${PKG_LIST}.pkgs ]; then
    echo "ERROR: unable to find package list ${MVI_DIR}/${PKG_LIST}.pkgs"
    exit 1
fi

#
# clean up and populate
#
${INSTALL_PKGS} ${DISTVER} ${DESTDIR} ${MVI_DIR}/${PKG_LIST}.pkgs

#
# these are options
#
for xopt in $*
do
    if [ -f ${MVI_DIR}/${xopt}.pkgs ]; then
	${INSTALL_PKGS} ${DISTVER} ${DESTDIR} ${MVI_DIR}/${xopt}.pkgs
    fi
done

#
# the original mvi.sh started with the above and started cutting
# here we start from nothing and add files (using the installed packages
# as a stage)
#
cd ${DESTDIR}
mkdir stage
mv usr lib sbin stage
mkdir usr sbin lib lib/inet usr/lib usr/sbin usr/bin usr/bin/i86 usr/bin/amd64
#
# need init and sh
#
for file in `grep -v '^#' ${MVI_DIR}/mvi.dirs`
do
  mkdir -p $file
done
for file in `grep -v '^#' ${MVI_DIR}/mvi.files`
do
  mv stage/$file $file
done
#
# add specific files from the options
#
for xopt in $*
do
    if [ -f ${MVI_DIR}/${xopt}.dirs ]; then
	for file in `grep -v '^#' ${MVI_DIR}/${xopt}.dirs`
	do
	    mkdir -p $file
	done
    fi
    if [ -f ${MVI_DIR}/${xopt}.files ]; then
	for file in `grep -v '^#' ${MVI_DIR}/${xopt}.files`
	do
	    mv stage/$file $file
	done
    fi
done
#
# and clean up at the end
#
rm -fr stage

#
# clean up a bit
#
rm -fr etc/mail etc/nwam etc/zones etc/brand etc/skel
rm -fr etc/svc/profile
rm -fr etc/tm etc/saf etc/sasl etc/zfs etc/logadm.d
rm -fr var/sadm var/svc var/mail var/spool var/preserve var/games
rm -fr var/saf var/opt var/cron var/idmap var/logadm
rm -fr etc/rc?.d etc/init.d etc/cron.d etc/opt
rm -f etc/rc?
rm -fr etc/fs/hsfs etc/inet/ike etc/inet/secret
rm -fr platform/i86xpv
rm -fr boot/grub/pxegrub boot/grub/nbgrub
rm -fr kernel/kiconv
#
# run any requested cleanup scripts
# use . so they can set variables for us
#
for xopt in $*
do
    if [ -f ${MVI_DIR}/${xopt}-fix.sh ]; then
	echo "Running ${xopt}-fix.sh"
	. ${MVI_DIR}/${xopt}-fix.sh
    fi
done
#
# illumos itself cannot run SMF, that needs libxml2, so just run a shell
# this is a script so (a) we can emit a message saying we're ready,
# and (b) it's extensible
#
cd ${DESTDIR}
cat > ${DESTDIR}/etc/mvi.rc <<EOF
#!/sbin/sh
if [ ! -f /startup ]; then
  /etc/fs/ufs/mount -o remount,rw /devices/ramdisk:a /
  echo "y" > /startup
fi
EOF
for xopt in $*
do
    if [ -f ${MVI_DIR}/${xopt}.rc ]; then
	cp ${MVI_DIR}/${xopt}.rc ${DESTDIR}/etc/mvi-${xopt}.rc
	chmod a+x ${DESTDIR}/etc/mvi-${xopt}.rc
cat >> ${DESTDIR}/etc/mvi.rc <<EOF
echo " *** Running ${xopt} startup ***" > /dev/console
/etc/mvi-${xopt}.rc >/dev/console 2>&1 </dev/console
EOF
    fi
done
cat >> ${DESTDIR}/etc/mvi.rc <<EOF
echo " *** Welcome to minimal viable illumos ***" > /dev/console
/bin/sh >/dev/console 2>&1 </dev/console
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
# add a grub menu
#
cat >> ${DESTDIR}/boot/grub/menu.lst << _EOF
title minimal viable illumos
kernel\$ /platform/i86pc/kernel/\$ISADIR/unix
module\$ /platform/i86pc/boot_archive
title minimal viable illumos (ttya)
kernel\$ /platform/i86pc/kernel/\$ISADIR/unix -B console=ttya,input-device=ttya,output-device=ttya
module\$ /platform/i86pc/boot_archive
title Boot from hard disk
rootnoverify (hd0)
chainloader +1
_EOF
#
# https://blogs.oracle.com/darren/entry/sending_a_break_to_opensolaris
#
cat >> ${DESTDIR}/etc/system << _EOF
set pcplusmp:apic_kmdb_on_nmi=1
_EOF

#
# paranoia, we don't want a boot archive inside the boot archive
#
rm -f ${DESTDIR}/platform/i86pc/amd64/boot_archive
rm -f ${DESTDIR}/platform/*/boot_archive

#
# now we create a block device that will back a ufs file system
# that we will copy the constructed image to
#
mkfile ${MRSIZE} /tmp/${MRSIZE}
#
# gzip doesn't like the sticky bit
#
chmod -t /tmp/${MRSIZE}
LOFIDEV=`lofiadm -a /tmp/${MRSIZE}`
LOFINUM=`echo $LOFIDEV|awk -F/ '{print $NF}'`
echo "y" | env NOINUSE_CHECK=1 newfs -o space -m 0 -i $NBPI /dev/rlofi/$LOFINUM
BFS=/tmp/nb.$$
mkdir $BFS
mount -Fufs -o nologging $LOFIDEV $BFS
cd ${DESTDIR}
tar cf - . | ( cd $BFS ; tar xf -)
cd $BFS
touch etc/mnttab
mkdir -p dev/fd devices/pseudo opt var var/run mnt
/usr/sbin/devfsadm -r ${BFS}
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
lofiadm -d /dev/lofi/$LOFINUM
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
cd ${DESTDIR}
rm bin
rm -fr dev devices etc export home kernel lib licenses mnt opt proc root sbin system tmp usr var
rm -fr platform/i86pc/ucode
rm -fr platform/i86pc/kernel/cpu
rm -fr platform/i86pc/kernel/dacf
rm -fr platform/i86pc/kernel/drv
rm -fr platform/i86pc/kernel/mach
rm -fr platform/i86pc/kernel/misc

#
# now make the iso
#
/usr/bin/mkisofs -o ${ISO_NAME} -b boot/grub/stage2_eltorito \
	-c .catalog \
	-no-emul-boot -boot-load-size 4 -boot-info-table -N -l -R -U \
        -allow-multidot -no-iso-translate -cache-inodes -d -D \
	-V "illumos" ${DESTDIR}
sync
ls -lsh $ISO_NAME

#
# and clean up
#
cd /
rm -fr ${DESTDIR}
