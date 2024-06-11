#!/bin/bash

read ACTIVE NEW <<< "$(snmpget -v 1 -c public 10.20.20.254 NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"attivo\" | \
	egrep -o 'STRING: .*' | cut -d' ' -f2)"

echo "Active, new: $ACTIVE, $NEW"

if [[ $ACTIVE == $HOSTNAME ]]
then
	echo "It's me!"
	sudo cp /tmp/eth2 /etc/network/interfaces.d/eth2
	sudo systemctl restart networking.service
else
	echo "It's not me..."
	sudo ifdown eth2
	sudo rm /etc/network/interfaces.d/eth2
fi


if [[ $NEW == 'new' ]]
then
	/usr/bin/ldap.sh new
else
	/usr/bin/ldap.sh
fi

