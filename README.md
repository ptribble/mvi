MVI - Minimal Viable Illumos
============================

These are some scripts I've used to build a minimal illumos iso
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

 - 32bit means create a 32-bit kernel image, with 32-bit userland
 - 64bit means to remove 32-bit kernel components
 - node will install node packages and run a simple node.js server
 - vboxnet will set up networking appropriate for VirtualBox
 - virtio will add virtio packages

For any argument foo, there may be some files:

 - foo.rc will be run as part of the boot sequence
 - foo.pkgs will add packages to the image
 - foo.dirs will create directories in the image (for mvix.sh)
 - foo.files will copy files into the image (for mvix.sh)
 - foo-fix.sh will be run

The intention here is that the system will be booted under a hypervisor,
allowing most of the drivers and support files to be eliminated. I have
tested qemu and VirtualBox.

As an example:

./mvix.sh 64bit node vboxnet

will create a minimal (25M) iso suitable for booting under VirtualBox,
running a simple node webserver on http://192.168.59.59:8000

(For this to work you'll need to set up the VM network to be a Host-only
Adapter and make sure it's on the appropriate subnet.)
