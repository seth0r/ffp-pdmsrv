#!/bin/bash

genkeys() {
    if [ ! -d "${BASEDIR}/ssh" ]; then
        mkdir "${BASEDIR}/ssh"
        ssh-keygen -f "${BASEDIR}/ssh/id_rsa" -N ""
    fi
    ln -s "${BASEDIR}/ssh" "/root/.ssh"
}

resetknownhosts() {
    rm -f "${BASEDIR}/ssh/known_hosts"
}

permitroot() {
    echo "PermitRootLogin yes" >> "$1/etc/ssh/sshd_config"
}

copykeys() {
    mkdir -p "$1"
    cp "${BASEDIR}/ssh/id_rsa" "$1/id_rsa"
    cp "${BASEDIR}/ssh/id_rsa.pub" "$1/id_rsa.pub"
    cat "${BASEDIR}/ssh/id_rsa.pub" >> "$1/authorized_keys"
}
