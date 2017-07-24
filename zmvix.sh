#!/bin/ksh
#
# create a minimal viable illumos zone image
#

#
# where the output should end up
#
ISO_NAME=/var/tmp/zmvi.tar.gz

#
# Tribblix version for illumos pkgs
#
DISTVER=20
ILVER=0.${DISTVER}

#
# *** CUSTOMIZE ***
# where your illumos and other packages live
#
THOME=/packages/localsrc/Tribblix
export THOME
PROTO_DIR=${THOME}/illumos-pkgs-m${DISTVER}
PKG_DIR=${THOME}
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
	    ;;
    esac
done
shift $((OPTIND-1))

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
# need getent, see user_cmd in the brand's config.xml
# that will enable zlogin -S
# if you need zlogin, then look at zlogin.files
for file in `grep -v '^#' ${MVI_DIR}/mvi.files` usr/bin/getent
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
# this is for a zone, we don't need any boot or kernel
#
rm -fr boot
rm -fr kernel
rm -fr platform
rm -fr devices
mkdir devices
rm -fr dev
mkdir dev
rmdir export home devices mnt opt
rm reconfigure
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
# if we don't have bash, fix up the passwd file
#
cd ${DESTDIR}
if [ ! -f usr/bin/bash ]; then
    gsed -i s:/bash:/sh: etc/passwd
fi

cd ${DESTDIR}
tar cfz $ISO_NAME  *
ls -lsh $ISO_NAME

#
# and clean up
#
cd /
rm -fr ${DESTDIR}
