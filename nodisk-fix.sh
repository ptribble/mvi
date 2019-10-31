#!/bin/sh
#
# analagous to nonet, remove all support for disks
#
rm -f kernel/drv/*/ata*
rm -f kernel/drv/*/cmdk*
rm -f kernel/drv/*/mpt*
rm -f kernel/drv/*/ahci*
rm -f kernel/drv/*/sd*
rm -f kernel/drv/*/scsa2usb*
rm -f kernel/drv/*/scsi_vhci*
rm -f kernel/drv/*/sgen*
rm -f kernel/drv/ata*
rm -f kernel/drv/cmdk*
rm -f kernel/drv/mpt*
rm -f kernel/drv/ahci*
rm -f kernel/drv/sd*
rm -f kernel/drv/scsa2usb*
rm -f kernel/drv/scsi_vhci*
rm -f kernel/drv/sgen*
rm -fr kernel/misc/scsi_vhci
rm -f kernel/misc/*/dadk
rm -f kernel/misc/*/sata
rm -f kernel/misc/*/scsi
rm -f etc/default/mpathd

#
# modify MRSIZE
#
TSIZE=`echo $MRSIZE | sed s:M::`
TSIZE=$(($TSIZE-1))
MRSIZE=${TSIZE}M
