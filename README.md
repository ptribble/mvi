MVI - Minimal Viable Illumos
============================

These are some scripts I've used to build a minimal illumos image
capable of running a single application.

The scripts, particularly the paths embedded in them, are specific
to Tribblix and my own build environment.

The master scripts are mvi.sh and mvix.sh, which take opposing approaches
to the minimization problem. With mvi.sh, everything is installed, and
then unnecessary files removed; with mvix.sh you have to explicitly list
the userland files that should be present.

Arguments to the scripts are:
 -f        install from file system
 -r	   install from repo (not yet implemented)
 -s	   install using system zap
 -p name   use name.pkgs as the list of packages, default mvi
 -v ver	   use packages from Tribblix version given

The scripts take option arguments, some examples are:

 - node will install node packages and run a simple node.js server
 - vboxnet will set up networking appropriate for VirtualBox
 - virtio will add virtio packages

For any argument foo, there may be some files:

 - foo.rc will be run as part of the boot sequence
 - foo.pkgs will add packages to the image
 - foo.dirs will create directories in the image (for mvix.sh)
 - foo.files will copy files into the image (for mvix.sh)
 - foo-fix.sh will be run

The intention here is that the system will often be booted under a hypervisor,
allowing most of the drivers and support files to be eliminated by default. I
have tested qemu and VirtualBox.

As an example:

./mvix.sh node vboxnet

will create a minimal (25M) iso suitable for booting under VirtualBox,
running a simple node webserver on http://192.168.56.56:8000

(For this to work you'll need to set up the VM network to be a Host-only
Adapter and make sure it's on the appropriate subnet.)

Another example:

./mvix.sh wipe

will create a 15M iso suitable for wiping disk drives (it's using
format/analyze/purge underneath, nothing complicated). This includes
most of the common storage drivers, so will boot on real hardware.

There's also a variant that can create a tarball suitable for unpacking as
the filesystem for a zone. In this case we don't need any drivers. For example

./zmvix.sh nonet node

will create a 11M compressed tarball containing enough to run the same
simple node webserver above in a zone (this assumes a shared-ip network
stack). If you wish to get into the zone then you'll need to use zlogin
with the -S flag. A full zlogin can be enabled with

./zmvix.sh node zlogin
