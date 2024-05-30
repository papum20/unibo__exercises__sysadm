#!/bin/bash

# con questa soluzione, il file degli allarmi viene ricreato
# quindi gli eventi rimossi dal calendario sono automaticamente
# esclusi anche dal promemoria
# aggiungiamo solo una funzionalità per aggiornarlo durante
# il ciclo infinito di check degli allarmi

FILEALLARMI=$(mktemp)

function update_alarms() {
	cat /dev/null > "$FILEALLARMI"

	cat calendario | while read DATA ORA DESCRIZIONE 
	do
   	SCADENZA=$(date +%s -d "$DATA $ORA") # conversione in secondi dal 1970-01-01 01:00
	   GIORNOPRIMA=$(( SCADENZA - 24*60*60 ))
   	ORAPRIMA=$(( SCADENZA - 60*60 ))
	   echo "$GIORNOPRIMA $DATA $ORA $DESCRIZIONE" >> "$FILEALLARMI"
   	echo "$ORAPRIMA $DATA $ORA $DESCRIZIONE" >> "$FILEALLARMI"
	done 

	CALCHANGE=$(stat -c %Y calendario)
}

update_alarms

# ho necessità di far eseguire il controllo una e una sola volta ogni minuto, 
# una possibilità è ciclare più di frequente e controllare se il minuto cambia
# in questo modo compenso anche l'imprevedibilità dei tempi di esecuzione
# del corpo del ciclo (mentre se usassi sleep 60 potrei andare alla deriva)

NOW=0
while sleep 20 ; do
	
	# controlliamo se nel frattempo il file calendario è cambiato
	CALNOW=$(stat -c %Y calendario)
   if [[ $CALNOW != $CALCHANGE ]] ; then
		update_alarms
	fi
		  
   [[ $(date +%M) -eq $NOW ]] && continue

   NOW=$(date +%M)

   # nota: i timestamp originali hanno la granularità del minuto, 
   # ma il tempo corrente considera i secondi, devo troncarli
   # trick, ma si può fare in altri modi: la divisione per 60 restituisce un intero...
   CURRENTMINUTE=$(( $(date +%s) / 60 * 60))

   # nota: ci possono essere zero, una o più righe col timestamp corrente
   # grep | while è il modo più semplice di gestirle, un'iterazione per ogni riga
   # incluso il caso di zero iterazioni nei minuti per cui non ci sono corrispondenze
   egrep "^$CURRENTMINUTE" "$FILEALLARMI" | while read TIMESTAMP DATA ORA DESCRIZIONE ; do
       echo "$DESCRIZIONE scade il $DATA alle $ORA"
  done >> ~/promemoria

done
