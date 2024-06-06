#!/bin/bash

CLIENT_PORT=$1

echo "client port is $CLIENT_PORT"


ORA=$(date +%s)
LOG_FILE=/tmp/connection-monitor_$ORA.pcap

touch $LOG_FILE
# sudo chown Debian-snmp /tmp/dump_$ORA.pcap &&

sudo tcpdump -U -i eth1 "port $CLIENT_PORT and port ssh" > $LOG_FILE



