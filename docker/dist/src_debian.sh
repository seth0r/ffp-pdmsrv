#!/bin/bash

install() {
    ISOFILE=${ISODIR}/${DIST}.iso
    if [ ! -f "$ISOFILE" ]; then
        echo "Downloading ${ISOFILE}..."
        wget -O "$ISOFILE" "$ISOURL"
    fi

    envsubst < "${SRCDIR}/preseed.cfg" > "${TMPDIR}/preseed.cfg"

    echo "Extracting vmlinuz and initrd from netinstall.iso..."
    mkdir -p "${TMPDIR}/netinst"
    mount -o loop "$ISOFILE" "${TMPDIR}/netinst"
    cp "${TMPDIR}/netinst/$ISOKERNEL" "${TMPDIR}/vmlinuz"
    cp "${TMPDIR}/netinst/$ISOINITRD" "${TMPDIR}/initrd.gz"
    umount "${TMPDIR}/netinst"
    rmdir "${TMPDIR}/netinst"

    echo "Appending preseed.cfg to initrd.gz..."
    gunzip "${TMPDIR}/initrd.gz"
    tmp=`pwd`
    cd "$TMPDIR"
    echo preseed.cfg | cpio -H newc -o -A -F initrd
    cd "$tmp"
    unset tmp

    dd if=/dev/zero "of=${IMGFILE}.tmp" bs=1M seek=$IMGSIZE count=0
    KERNCMD="console=ttyS0 net.ifnames=0 biosdevname=0"
    con=""
    if [ "$DEBUG" == "1" ]; then
        con="-serial unix:${BASEDIR}/qemu.console,server,nowait"
        echo "!!! DEBUG MODE, console is redirected to ${BASEDIR}/qemu.console !!!"
    else
        KERNCMD="$KERNCMD TERM=dumb DEBIAN_FRONTEND=text"
    fi
    if [ $MEM -lt $INSTALLMEM ]; then
        echo "!!! For the installation the memory will be increased to $INSTALLMEM MiB !!!"
        sleep 10
    fi
    echo "Installing Debian-Base..."
    qemu-system-x86_64 \
        $( test "$KVM" == "1" && echo -enable-kvm ) \
        -m $( test $MEM -lt $INSTALLMEM && echo $INSTALLMEM || echo $MEM ) \
        -kernel "${TMPDIR}/vmlinuz" \
        -initrd "${TMPDIR}/initrd" \
        -append "${KERNCMD}" \
        -pidfile "${BASEDIR}/qemu.pid" \
        -no-reboot \
        -net nic -net tap \
        -nographic \
        -drive "file=${IMGFILE}.tmp,index=0,media=disk,format=raw" \
        -cdrom "$ISOFILE" \
        ${con} \
        -monitor "file:${BASEDIR}/qemu.mon" &
    sleep 3
    qemu_pid=`cat "${BASEDIR}/qemu.pid"`
    children="$children $qemu_pid"
        
    confnet tap0

    wait $qemu_pid
    if [ $? -eq 0 ]; then
        rm -f "${TMPDIR}/vmlinuz"
        rm -f "${TMPDIR}/initrd"
        rm -f "${TMPDIR}/preseed.cfg"
        mv "${IMGFILE}.tmp" "${IMGFILE}"
    else
        echo "!!! installation failed. !!!"
        exit 1
    fi
}
