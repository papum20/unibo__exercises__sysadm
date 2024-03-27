#!/bin/bash

# execute alarms


test -f "$1" || {
   echo specificare il file delle scadenze come parametro
   exit 1
}
FILEALLARMI="$1"
NOW=0
while sleep 20 ; do
   [[ $(date +%M) -eq $NOW ]] && continue
   NOW=$(date +%M)
   CURRENTMINUTE=$(( $(date +%s) / 60 * 60))
   egrep "^$CURRENTMINUTE" "$FILEALLARMI" | while read TIMESTAMP DATA ORA DESCRIZIONE ; do
       echo "$DESCRIZIONE scade il $DATA alle $ORA"
  done >> ~/promemoria
done