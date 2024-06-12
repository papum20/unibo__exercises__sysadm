#!/bin/bash

FILE_LOG=/var/log/newusers
SNMP_AGENT=10.22.22.1

while read MON DAY TIME R USER USERNAME ; do

	if [[ ! -e /home/$USERNAME ]]
	then
		mkdir /home/$USERNAME
		mkdir /home/$USERNAME/.ssh
		chown $USERNAME:$USERNAME /home/$USERNAME
		chown $USERNAME:$USERNAME /home/$USERNAME/.ssh
	fi

	if [[ $(hostname) =~ C[0-9]+ ]] 
	then
		# if on client
		snmpget -Ovq -v 1 -c public $SNMP_AGENT NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"${USERNAME}_PRIV\" > /home/$USERNAME/.ssh/id_rsa
		snmpget -Ovq -v 1 -c public $SNMP_AGENT NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"${USERNAME}_PUB\" > /home/$USERNAME/.ssh/id_rsa.pub
		chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/id_rsa*
	elif [[ $(hostname) =~ S[0-9]+ ]]
	then
		# if on server
		snmpget -Ovq -v 1 -c public $SNMP_AGENT NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"${USERNAME}_PUB\" >> /home/$USERNAME/.ssh/authorized_keys 
		chown $USERNAME:$USERNAME /home/$USERNAME/.ssh/authorized_keys
	fi


done < $FILE_LOG



