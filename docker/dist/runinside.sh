#!/bin/bash

if [ -f /root/.inside_qemu ]; then
    tr -d '\0' < /dev/sdb | sed 's/^/export /g' > /root/env
    source /root/env
    cd /root/repo
    git pull --recurse-submodules > /root/git.log 2>&1
    make inside > /root/make.log 2>&1
fi
