#!/bin/bash

function TASK {
	THRESHOLD=4
	snmpset -v 1 -c public $AGENT UCD-SNMP-MIB::laConfig.1 s $THRESHOLD
	AGENT=$1
	LOAD=$(snmpget -v 1 -c public $AGENT UCD-SNMP-MIB::laLoad.1)
	CHECK=$(snmpget -v 1 -c public $AGENT UCD-SNMP-MIB::laErrorFlag.1 | egrep -o 'INTEGER: .*' | cut -d' ' -f2)

	if [[ CHECK == 'error(1)' ]]
	then
		logger -p local5.info -n $AGENT <<< "STOP" 
	fi
}

MIN=0
MAX=255

for IP4 in $(seq $MIN $MAX) ; do
	IP=10.100.2.$IP4
	echo $IP 
	TASK $IP &
done