#!/bin/bash

initnet() {
    iptables -P FORWARD ACCEPT
    iptables -t nat -A POSTROUTING -o eth0 -s 172.22.255.0/24 -j MASQUERADE
    iptables -t nat -A PREROUTING -i eth0 -j DNAT --to-destination 172.22.255.42
}
confnet() {
    ifconfig $1 172.22.255.1 netmask 255.255.255.0
}


