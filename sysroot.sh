#!/bin/ksh
#
# create an illumos sysroot, which is like an mvi zone image
#

#
# where the output should end up
#
ISO_NAME=/var/tmp/sysroot.tar.gz

#
# Tribblix version for illumos pkgs
#
DISTVER=20.6

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
if [ ! -x "${INSTZAP}" ]; then
    echo "ERROR: unable to find instzap"
    exit 1
fi

#
# *** CUSTOMIZE ***
# where your mvi configuration lives
#
MVI_DIR=${THOME}/mvi

#
# this is the starting list of packages
#
PKG_LIST="sysroot"

#
# argument processing
#
INSTALL_PKGS=${MVI_DIR}/install-from-local.sh
while getopts "frso:p:v:" opt; do
    case $opt in
	f)
	    # install from file system
	    INSTALL_PKGS=${MVI_DIR}/install-from-local.sh
	    if [ ! -d "$PROTO_DIR" ]; then
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
	    exit 1
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
if [ -d "$DESTDIR" ]; then
    echo "ERROR: $DESTDIR already exists"
    exit 1
fi
if [ -f "$DESTDIR" ]; then
    echo "ERROR: $DESTDIR already exists (as a file)"
    exit 1
fi
#
# check we have input to deal with
#
if [ ! -d "$MVI_DIR" ]; then
    echo "ERROR: unable to find mvi area $MVI_DIR"
    exit 1
fi
if [ ! -x "${INSTALL_PKGS}" ]; then
    echo "ERROR: unable to find install script ${INSTALL_PKGS}"
    exit 1
fi
if [ ! -f "${MVI_DIR}/${PKG_LIST}.pkgs" ]; then
    echo "ERROR: unable to find package list ${MVI_DIR}/${PKG_LIST}.pkgs"
    exit 1
fi

#
# clean up and populate
#
${INSTALL_PKGS} "${DISTVER}" "${DESTDIR}" "${MVI_DIR}/${PKG_LIST}.pkgs"

#
# this is where we deviate from mvi
# all we're really after are headers and libraries
#
cd ${DESTDIR} || exit
rm -fr usr/share \
   etc \
   var \
   usr/bin \
   usr/sbin \
   usr/ccs \
   sbin \
   bin

cd ${DESTDIR} || exit
tar cfz "$ISO_NAME" *
ls -lsh "$ISO_NAME"

#
# and clean up
#
cd /
rm -fr ${DESTDIR}
