#!/bin/bash

if [ ! -f /etc/hosts.origin ]; then
    echo "Backup origin hosts file."
    cp /etc/hosts /etc/hosts.origin
fi
cat /etc/hosts.origin  "$@" > /etc/hosts