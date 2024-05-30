#!/bin/bash
ORA=$(date +%s)
IPv4ETH1=$(ip a | grep "10.1.1." | awk '{ print $2 }' | awk -F '/' '{ print $1 }')

/usr/bin/sudo /usr/bin/tcpdump -n -U -i eth1 -c 10000 -w /tmp/dump_$ORA.pcap &&
/usr/bin/sudo /usr/bin/chown Debian-snmp /tmp/dump_$ORA.pcap &&
/usr/bin/logger -n 10.1.1.254 -p local1.info "READY $IPv4ETH1 /tmp/dump_$ORA.pcap"

# opzione 1: 
# configuro rsyslog dell'agent con
# local1.info  @10.1.1.254
# e rsyslog del controller con
# local1.info /var/log/dumps.log
# e uso
# logger -p local1.info "READY /tmp/dump_$ORA.pcap"

# opzione 2: 
# configuro rsyslog del controller con
# local1.info /var/log/dumps.log
# e uso
