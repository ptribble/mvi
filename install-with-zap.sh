#!/bin/sh
#
# install packages using zap
#
# the version is ignored, we inherit from the current system
#
case $# in
    3)
	DISTVER=$1
	DESTDIR=$2
	PKGLIST=$3
	;;
    *)
	echo "Usage: $0 dest_dir pkg_list"
	exit 1
	;;
esac

INSTZAP=/usr/lib/zap/install-pkg
if [ ! -x ${INSTZAP} ]; then
    echo "ERROR: unable to find zap"
    exit 1
fi

mkdir -p ${DESTDIR}
for pkg in `cat ${PKGLIST}`
do
    $INSTZAP -R $DESTDIR `echo $pkg | awk -F. '{print $1}'`
done
