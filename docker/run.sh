#!/bin/bash

_term() {
    echo "Caught SIGTERM signal!"
    kill -TERM $children 2>/dev/null
    losetup -d $lodev
}

trap _term SIGTERM
sleep 5

if [ "$HOSTNAME" == "" -o "$ROOT_PASSWORD" == "" ]; then
    echo "At least HOSTNAME and ROOT_PASSWORD has to be set."
    exit 1
fi

cd /data

export DEBUG=${DEBUG:-0}
export IMGSIZE=${IMGSIZE:-2048}

export ISOURL=${ISOURL:-https://cdimage.debian.org/debian-cd/10.1.0/amd64/iso-cd/debian-10.1.0-amd64-netinst.iso}
export ISOINITRD=${ISOINITRD:-install.amd/initrd.gz}
export ISOKERNEL=${ISOKERNEL:-install.amd/vmlinuz}
export MIRROR=${MIRROR:-ftp.de.debian.org}
export MIRRORPATH=${MIRRORPATH:-/debian}
export PACKAGES=${PACKAGES:-openssh-server vim-nox git build-essential}

export REPOURL=${REPOURL:-https://github.com/seth0r/ffp-pdmsrv}

envsubst < /etc/preseed.cfg > preseed.cfg
if [ "`md5sum -c preseed.md5 | grep -i ok`" == "" ]; then
    echo "preseed.cfg has changed..."
    rm -f initrd vmlinuz install.img config.img pdmvpn.img
    md5sum preseed.cfg > preseed.md5
fi

sleep 60

iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -s 172.22.255.0/24 -j MASQUERADE
iptables -t nat -A PREROUTING -i eth0 -j DNAT --to-destination 172.22.255.42

if [ ! -f pdmvpn.img ]; then
    if [ ! -f netinst.iso ]; then
        rm -f initrd vmlinuz config.img
        echo "Downloading Debian iso..."
        wget -O netinst.iso "$ISOURL"
    fi
    if [ ! -f vmlinuz -o ! -f initrd ]; then
        echo "Extracting vmlinuz and initrd from netinstall.iso..."
        rm -rf /data/netinst
        mkdir -p /data/netinst
        mount -o loop netinst.iso /data/netinst
        cp "netinst/$ISOKERNEL" ./vmlinuz
        cp "netinst/$ISOINITRD" ./initrd.gz
        umount /data/netinst
        rmdir /data/netinst
        echo "Appending preseed.cfg to initrd.gz..."
        gunzip initrd.gz
        echo preseed.cfg | cpio -H newc -o -A -F initrd
    fi
    if [ ! -f config.img ]; then
        con=""
        if [ "$DEBUG" == "1" ]; then
            con="-serial unix:/data/pdmvpn.console,server,nowait"
            echo "DEBUG mode, you can connect to the qemu console via qc.sh"
        else
            kerncmd="TERM=dumb DEBIAN_FRONTEND=text"
        fi
        dd if=/dev/zero of=install.img bs=1M seek=$IMGSIZE count=0
        echo "Installing Debian-Base..."
        qemu-system-x86_64 ${con} \
            -enable-kvm \
            -m 512 \
            -kernel /data/vmlinuz \
            -initrd /data/initrd \
            -append "console=ttyS0 net.ifnames=0 biosdevname=0 ${kerncmd}" \
            -pidfile /data/pdmvpn_qemu.pid \
            -no-reboot \
            -net nic -net tap \
            -nographic \
            -drive "file=/data/install.img,index=0,media=disk,format=raw" \
            -cdrom /data/netinst.iso \
            -monitor file:/data/pdmvpn.mon &
        sleep 3
        qemu_pid=`cat /data/pdmvpn_qemu.pid`
        children="$children $qemu_pid"
        ifconfig tap0 172.22.255.1 netmask 255.255.255.0
        wait $qemu_pid
        if [ $? -eq 0 ]; then
            mv install.img config.img
        fi
    fi
    if [ -f config.img ]; then
        echo "Configuring system..."
        pstart=$(( `fdisk -l config.img | grep -A10 "^Device" | tail +2 | sed 's/ \+/ /g' | cut -d' ' -f3` * 512 ))
        lodev=$(losetup -f)
        losetup -o $pstart $lodev /data/config.img
        mkdir -p /data/config
        mount $lodev /data/config
    
        touch /data/config/root/.inside_docker_inside_qemu
        ssh-keygen -f /root/.ssh/id_rsa -N ""
        mkdir /data/config/root/.ssh
        cat /root/.ssh/id_rsa.pub >> /data/config/root/.ssh/authorized_keys
        echo "PermitRootLogin yes" >> /data/config/etc/ssh/sshd_config
        git clone $REPOURL /data/config/root/repo
        cp /root/rc.local /data/config/etc/rc.local
        chmod +x /data/config/etc/rc.local

        sleep 30

        umount /data/config
        rmdir /data/config
        losetup -d $lodev
        mv config.img pdmvpn.img
    fi
fi
if [ -f pdmvpn.img ]; then
    echo "Starting Qemu..."
    qemu-system-x86_64 \
        -enable-kvm \
        -m 512 \
        -pidfile /data/pdmvpn_qemu.pid \
        -no-reboot \
        -net nic -net tap \
        -nographic \
        -drive "file=/data/pdmvpn.img,index=0,media=disk,format=raw" \
        -serial unix:/data/pdmvpn.console,server,nowait \
        -monitor file:/data/pdmvpn.mon &
    sleep 3
    qemu_pid=`cat /data/pdmvpn_qemu.pid`
    children="$children $qemu_pid"
    ifconfig tap0 172.22.255.1 netmask 255.255.255.0
    wait $qemu_pid
fi
#    -net nic,vlan=2 -net l2tpv3,vlan=2,$CONB,udp,rxsession=0xffffffff,txsession=0xffffffff,counter \
#    -net nic,vlan=3 -net l2tpv3,vlan=3,$CONC,udp,rxsession=0xffffffff,txsession=0xffffffff,counter \

#children="$children $!"

wait $children
