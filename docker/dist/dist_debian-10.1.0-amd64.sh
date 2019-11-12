#!/bin/bash

export IMGSIZE=${IMGSIZE:-2048}
export MEM=${MEM:-256}

export INSTALLMEM=512

export ISOURL=${ISOURL:-https://cdimage.debian.org/debian-cd/10.1.0/amd64/iso-cd/debian-10.1.0-amd64-netinst.iso}
export ISOINITRD=${ISOINITRD:-install.amd/initrd.gz}
export ISOKERNEL=${ISOKERNEL:-install.amd/vmlinuz}
export MIRROR=${MIRROR:-ftp.de.debian.org}
export MIRRORPATH=${MIRRORPATH:-/debian}
export PACKAGES=${PACKAGES:-openssh-server}

export SRCDIR="${DISTDIR}/debian"

source "${DISTDIR}/src_debian.sh"
