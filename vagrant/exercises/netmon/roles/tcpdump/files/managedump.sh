#!/bin/bash

TEMP="/tmp/running"
PCAPFOLDER="/tmp/pcap"
LASTAGENTRUNNING="/tmp/lastagent"

mkdir -p "$TEMP"
mkdir -p "$PCAPFOLDER"
touch /var/log/dumps.log

LASTAGENT="" 

if [[ -f "$LASTAGENTRUNNING" ]]; then
	LASTAGENT=$(cat "$LASTAGENTRUNNING")
else
	touch  "$LASTAGENTRUNNING"
fi

DHCPLEASE="/var/lib/misc/dnsmasq.leases"
AGENT1IPv4=""
AGENT2IPv4=""

while read -r ID MACADDRESS IPv4 HOSTNAME IPv6 ; do 
	if [[ "$HOSTNAME" == agent1 ]] ; then
		AGENT1IPv4="$IPv4"
	elif [[ "$HOSTNAME" == agent2 ]] ; then
		AGENT2IPv4="$IPv4"
	fi
done < "$DHCPLEASE"

function remotedump {
	/usr/bin/echo $$ > "$TEMP"/$$_"$1"_running
	tail -n 0 -f /var/log/dumps.log | /usr/bin/grep -E --line-buffered "READY $1" | while read -r TAG IPv4 REMOTEFILEPATH ; do
		/usr/bin/scp root@"$1":"$REMOTEFILEPATH" "$PCAPFOLDER"
		/usr/bin/logger -n "$1" -p local1.info "DONE DOWNLOAD $REMOTEFILEPATH"
		/usr/bin/snmpget -v 1 -c public "$1" 'NET-SNMP-EXTEND-MIB::nsExtendOutputFull."deletedump"'
		/usr/bin/rm -f "$TEMP"/$$_"$1"_running
		exit 0
	done
}

PROCESS_RUNNING=$(/usr/bin/find "$TEMP" -type f)

if [[ "$LASTAGENT" == "agent1" ]] && [[ $(/usr/bin/echo -ne "$PROCESS_RUNNING" | /usr/bin/wc -l) -lt 2 ]] ; then
	LASTAGENT="agent2"
       	/usr/bin/echo "$LASTAGENT">"$LASTAGENTRUNNING"
	# Prima mi metto in ascolto di nuove linee sul file di log 
	remotedump "$AGENT2IPv4" &
	/usr/bin/snmpget -v 1 -c public "$AGENT2IPv4" 'NET-SNMP-EXTEND-MIB::nsExtendOutputFull."createdump"'
elif [[ "$LASTAGENT" == "agent2" ]] && [[ $(/usr/bin/echo -ne "$PROCESS_RUNNING" | /usr/bin/wc -l) -lt 2 ]] ; then
	LASTAGENT="agent1"
	/usr/bin/echo "$LASTAGENT">"$LASTAGENTRUNNING"
	remotedump "$AGENT1IPv4" &
	/usr/bin/snmpget -v 1 -c public "$AGENT1IPv4" 'NET-SNMP-EXTEND-MIB::nsExtendOutputFull."createdump"'
elif [[ $(/usr/bin/echo -ne "$PROCESS_RUNNING" | /usr/bin/wc -l) -lt 2 ]] ; then
	# NON abbiamo nessun processo che sta andando quindi lanciamo e salviamo che stiamo andando
	LASTAGENT="agent1"
	/usr/bin/echo "$LASTAGENT">"$LASTAGENTRUNNING"
	remotedump "$AGENT1IPv4" &
	/usr/bin/snmpget -v 1 -c public "$AGENT1IPv4" 'NET-SNMP-EXTEND-MIB::nsExtendOutputFull."createdump"'
fi

exit 0
