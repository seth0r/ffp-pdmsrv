#!/bin/bash

if [ -f /root/.inside_docker_inside_qemu ]; then
    cd /root/repo
    git pull
    make inside
fi
