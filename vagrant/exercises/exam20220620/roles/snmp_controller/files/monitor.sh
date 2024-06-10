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

snmpget -v 1 -c public 10.2.2.1 .1.3.6.1.4.1.2021.10.1.1
