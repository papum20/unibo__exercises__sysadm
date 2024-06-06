#!/bin/bash

# 14:03:40.045962 IP 10.1.1.11.34774 > 10.2.2.2.ssh: Flags [F.], seq 1817785992, ack 3078262696, win 1115, options [nop,nop,TS val 1666738059 ecr 2920541746], length 0

# configurazione /etc/rsyslog.d/conn.conf
# local1.=info /var/log/newconn
# local2.=info /var/log/excess (per log-user.sh)

tcpdump -i eth1 -nl tcp and src net 10.1.1.0/24 and dst net 10.2.2.0/24 and dst port 22 and '( tcp[tcpflags] & (tcp-syn|tcp-fin) != 0 )' | while read TS IP SRC DIR DST FL FLAG RESTO ; do
	SIP=$(cut -f1-4 -d. <<< $SRC)
	DIP=$(cut -f1-4 -d. <<< $DST)
	SPT=$(cut -f5 -d. <<< $SRC)
	DPT=$(cut -f5 -d. <<< $DST | cut -f1 -d:)
	FLA=$(sed -e 's/[^SF]//g' <<< $FLAG)
	
	logger -p local1.info <<< "_${FLA}_${SIP}_${DIP}_${SPT}_${DPT}_" 
done
