#!/bin/bash

tail -f /var/log/alerts.log | while read LINE ; do
	if [[ $LINE == 'STOP' ]] ; then
		#• viene avviato al boot e riavviato automaticamente se termina in modo anomalo
		#• legge le righe che appaiono via via nel file /var/log/alerts.log
		#• quando incontra una riga con testo "STOP", individua l'utente con più processi attivi, e ne
		#termina tutti i processi
	fi

done
