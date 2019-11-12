#!/bin/bash

if [ -f /root/.inside_qemu ]; then
    cd /root/repo
    git pull
    make inside
fi
