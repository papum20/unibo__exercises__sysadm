#!/bin/bash

function stop() {
    echo "$2"
    exit $1
}

if [[ -z "$1" ]] ; then
	#trying the local network
	NET=$(ip a list dev eth1 | grep 'inet ' | awk '{ print $2 }')
else
	NET=$1
fi

IP=$(echo "$NET" | cut -f1 -d/)
MASK=$(echo "$NET" | cut -f2 -d/)

{ [[ "$MASK" -lt 0 ]] ||  [[ "$MASK" -gt 32 ]] ; } && stop 2 "not a net/mask parameter"

echo "$IP" | sed -e 's/\./\n/g' | while read N ; do
	{ [[ "$N" -lt 0 ]] || [[ "$N" -gt 255 ]] ; } && stop 3 "not an IP"
done

DIR=$(mktemp -d)
MIN=$(ipcalc $NET | grep HostMin | awk '{ print $2 }')
MAX=$(ipcalc $NET | grep HostMax | awk '{ print $2 }')
declare -a F
declare -a L
OLDIFS="$IFS"
IFS=. 
F=($MIN)
L=($MAX)
IFS="$OLDIFS"

for IP1 in $(seq ${F[0]} ${L[0]}) ; do
  for IP2 in $(seq ${F[1]} ${L[1]}) ; do
    for IP3 in $(seq ${F[2]} ${L[2]}) ; do
      for IP4 in $(seq ${F[3]} ${L[3]}) ; do
	IP=$IP1.$IP2.$IP3.$IP4 
	snmpget -v 1 -c public "$IP" NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"numproc\" | awk -F 'STRING: ' '{ print $2 }' > "$DIR/$IP" &
      done
    done
  done
done 

wait

cd "$DIR"
# only consider files that contain an answer
for i in $(find . -type f -size +1c) ; do 
	echo $(cat $i) $i
done | sort -n | head -1 | cut -f2 -d/

cd ..
rm -rf "$DIR"

