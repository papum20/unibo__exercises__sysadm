#!/bin/bash

SOGLIA=100
COUNT=0
DEADLINE=$(( $(date +%s) + 60 ))

tcpdump -i eth1 -nl tcp and src host "$1" and dst host "$2" and src port "$3" and dst port "$4" | while read PK ; do
	(( COUNT ++ ))
	if [[ $(date +%s) -gt $DEADLINE ]] ; then
		DEADLINE=$(( $(date +%s) + 60 ))
		COUNT=0
	elif [[ $COUNT -gt "$SOGLIA" ]]
		/root/log-user.sh "$@"
		DEADLINE=$(( $(date +%s) + 60 ))
		COUNT=0
	fi
done
		

