#!/bin/bash
echo "Press CTRL-D to exit."
socat stdin,raw,echo=0,escape=0x04 "unix-connect:/data/pdmvpn.console"
