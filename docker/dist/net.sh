#!/bin/bash

export NET_DOCKER_IP=${NET_DOCKER_IP:-172.22.255.1}
export NET_VM_IP=${NET_VM_IP:-172.22.255.42}
export NET_ADDR=${NET_ADDR:-172.22.255.0}
export NET_MASK=${NET_MASK:-255.255.255.0}
export NET_MASKBITS=${NET_MASKBITS:-24}
export NET_NAMESERVERS=${NET_NAMESERVERS:-9.9.9.9 85.214.20.141 194.150.168.168 89.233.43.71 8.8.8.8 1.1.1.1}

initnet() {
    iptables -P FORWARD ACCEPT
    iptables -t nat -A POSTROUTING -o eth0 -s ${NET_ADDR}/${NET_MASKBITS} -j MASQUERADE
    iptables -t nat -A PREROUTING -i eth0 -j DNAT --to-destination ${NET_VM_IP}
}
confnet() {
    ifconfig $1 ${NET_DOCKER_IP} netmask ${NET_MASK}
}


