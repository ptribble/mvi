#!/bin/sh
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
if [ ! -x ${INSTZAP} ]; then
    INSTZAP=${THOME}/zap/usr/lib/zap/instzap
fi
if [ ! -x ${INSTZAP} ]; then
    echo "ERROR: unable to find instzap"
    exit 1
fi
if [ ! -d ${PROTO_DIR}/pkgs ]; then
    echo "ERROR: unable to find packages area ${PROTO_DIR}/pkgs"
    exit 1
fi

mkdir -p ${DESTDIR}
for pkg in `cat ${PKGLIST}`
do
    if [ -f ${PROTO_DIR}/pkgs/${pkg}.${ILVER}.0.zap ]; then
	$INSTZAP -R $DESTDIR ${PROTO_DIR}/pkgs/${pkg}.${ILVER}.0.zap `echo $pkg | awk -F. '{print $1}'`
    else
	$INSTZAP -R $DESTDIR ${THOME}/pkgs/${pkg}.zap `echo $pkg | awk -F. '{print $1}'`
    fi
done
