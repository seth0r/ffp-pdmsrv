#!/bin/bash

export IMGSIZE=${IMGSIZE:-2048}
export MEM=${MEM:-256}

export INSTALLMEM=512

export ISOURL=${ISOURL:-https://cdimage.debian.org/debian-cd/10.1.0/i386/iso-cd/debian-10.1.0-i386-netinst.iso}
export ISOINITRD=${ISOINITRD:-install.386/initrd.gz}
export ISOKERNEL=${ISOKERNEL:-install.386/vmlinuz}
export MIRROR=${MIRROR:-ftp.de.debian.org}
export MIRRORPATH=${MIRRORPATH:-/debian}
export PACKAGES=${PACKAGES:-openssh-server}

export SRCDIR="${DISTDIR}/debian"

source "${DISTDIR}/src_debian.sh"
