#!/bin/sh
echo " usage: ./apn_config.sh eth0"
dev="${1:-eth0}"
nr="$(ip a | grep "^[0-9]*: $dev" | wc -l)"
name="$(echo "$dev" | sed 's/[^0-9a-fA-F]//g' | head -c 1)"
mac="ac:ac:1a:b0:a0:$name$nr"
set -e -x
sudo ip link add link $dev address $mac $dev.$nr type macvlan
sudo dhclient $dev.$nr
ip addr show dev $dev.$nr
