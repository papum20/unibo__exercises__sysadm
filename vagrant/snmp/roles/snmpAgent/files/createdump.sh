#!/bin/bash

TIME=$(date +%s)
IPv4ETH1=$(ip a | grep "10.1.1." | awk '{ print $2 }' | awk -F '/' '{ print $1 }')

/usr/bin/sudo /usr/bin/tcpdump -n -U -i eth1 -c 100 -w /tmp/dump_$TIME.pcap &&
/usr/bin/sudo /usr/bin/chown Debian-snmp /tmp/dump_$TIME.pcap &&
/usr/bin/logger -n 10.1.1.254 -p local1.info "READY $IPv4ETH1 /tmp/dump_$TIME.pcap"
