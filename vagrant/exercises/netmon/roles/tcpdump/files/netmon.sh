#!/bin/bash

sudo tcpdump -U -i eth1 'port ssh' | while read LINE ; do

	echo $LINE

	CLIENT_PORT=$(echo $LINE | grep -o 'client\.[0-9]*' | cut -d'.' -f2)
	PROC_ON_PORT=$( jobs -r | grep "/usr/bin/connection-monitor.sh $CLIENT_PORT" | cut -d'[' -f2 | cut -d']' -f1 )
	
	if [[ $(echo $LINE | grep 'IP client\.[0-9]* > server.ssh: Flags \[S\],' ) ]]
	then
		logger -p local1.info "SSH STARTED client.$CLIENT_PORT > server"
		/usr/bin/connection-monitor.sh $CLIENT_PORT &
		echo "Started on port $CLIENT_PORT"
	fi


	if [[ $(echo $LINE | grep 'IP client\.[0-9]* > server.ssh: Flags \[F\.\],') ]]
	then
		logger -p local1.info "SSH TERMINATED client.$CLIENT_PORT > server"
		if [[ $PROC_ON_PORT ]] ; then 
			kill %$PROC_ON_PORT 
			echo "Killed $PROC_ON_PORT"
		fi
	fi
	
done


