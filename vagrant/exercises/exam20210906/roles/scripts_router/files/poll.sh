#!/bin/bash

function getLoad() {
 snmpget -Ovq -v 1 -c public $1 NET-SNMP-EXTENDMIB::nsExtendOutputFull.\"poll\"
}
for S in 10.200.1.{1..254} ; do
 	getLoad $S > /tmp/$S &
done
wait
for S in 10.200.1.{1..254} ; do
 	echo $(cat /tmp/$S) $S
done | sort -n | head -1 | awk '{ print $2 }' > /tmp/bestserver