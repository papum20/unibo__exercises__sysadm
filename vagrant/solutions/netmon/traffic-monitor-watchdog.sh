#!/bin/bash

SOGLIA=1000

# watchdog style: innesco l'attivazione di log-user condizionata al superamento della soglia
# se entro 60 secondi ciò non avviene, termino il monitor attivo e ne reinnesco uno nuovo

function monitor() {    
    tcpdump -i eth1 -nl -c $SOGLIA tcp and src host "$1" and dst host "$2" and src port "$3" and dst port "$4" >/dev/null 2>&1
    # notare parametro -c : arrivo qui solo se supero la soglia
	/root/log-user.sh "$@" &
    disown
}

while true ; do
    monitor "$@" &
    sleep 60
    kill $! 2>/dev/null
done
		

