#!/bin/bash

tmount() {
    echo "Mounting system image..."
    pstart=$(( `fdisk -l "${IMGFILE}" | grep -A10 "^Device" | tail +2 | sed 's/ \+/ /g' | cut -d' ' -f3` * 512 ))
    mount -o "loop,offset=${pstart}" "$IMGFILE" "$1"
}
run() {
    echo "Starting Qemu..."
    qemu-system-x86_64 \
        $( test 1 == 1 && echo -enable-kvm ) \
        -m ${MEM} \
        -pidfile "${BASEDIR}/qemu.pid" \
        -no-reboot \
        -net nic -net tap \
        -nographic \
        -drive "file=${IMGFILE},index=0,media=disk,format=raw" \
        -drive "file=${BASEDIR}/qemu.env,media=disk,format=raw" \
        -serial "unix:${BASEDIR}/qemu.console,server,nowait" \
        -monitor "file:${BASEDIR}/qemu.mon" &
    sleep 3
    qemu_pid=`cat "${BASEDIR}/qemu.pid"`
    children="$children $qemu_pid"
        
    confnet tap0

    wait $qemu_pid
}
