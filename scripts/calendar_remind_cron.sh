#!/bin/bash
# NOTA: non dovrebbe mai succedere che il parametro sia errato
# visto che remind.sh è schedulato dall'altro script via cron
test -f "$1" || {
   echo specificare il file delle scadenze come parametro
   exit 1
}

FILEALLARMI="$1"
CURRENTMINUTE=$(( $(date +%s) / 60 * 60))
egrep "^$CURRENTMINUTE" "$FILEALLARMI" | while read TIMESTAMP DATA ORA DESCRIZIONE ; do
   echo "$DESCRIZIONE scade il $DATA alle $ORA"
done >> ~/promemoria