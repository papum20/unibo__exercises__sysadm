#!/bin/bash

test -f "$1" || {
   echo il primo parametro deve essere un file calendario esistente
   exit 1
}

CALENDARIO="$1"
test -f "OLD-$CALENDARIO" || touch "OLD-$CALENDARIO"

cat "$CALENDARIO" | while read DATA ORA DESCRIZIONE 
do
   SCADENZA=$(date +%s -d "$DATA $ORA") 
   GIORNOPRIMA="$(date '+%Y%m%d%H%M' -d @$(( SCADENZA - 24*60*60 )) )"
   ORAPRIMA="$(date '+%Y%m%d%H%M' -d @$(( SCADENZA - 60*60 )) )"

   # il grep fatto in questo verso prende solo le righe nuove aggiunte al calendario
   grep -qx "$DATA $ORA $DESCRIZIONE" "OLD-$CALENDARIO" || {

      # per poterli rimuovere, mi annoto i job number di at

      JOBGP=$(at -t "$GIORNOPRIMA" <<< "flock $HOME/promemoria echo '$DESCRIZIONE scade il $DATA alle $ORA' >> $HOME/promemoria" 2>&1 | grep ^job | cut -f2 -d' ')
      JOBOP=$(at -t "$ORAPRIMA" <<< "flock $HOME/promemoria  echo '$DESCRIZIONE scade il $DATA alle $ORA' >> $HOME/promemoria" 2>&1 | grep ^job | cut -f2 -d' ')

      echo "$JOBGP $JOBOP: $DATA $ORA $DESCRIZIONE" >> jobs
   }
done

cat "OLD-$CALENDARIO" | while read DATA ORA DESCRIZIONE 
do
   # il grep fatto in questo verso prende solo le righe che mancano nel nuovo calendario
   grep -qx "$DATA $ORA $DESCRIZIONE" "$CALENDARIO" || {
	atrm $(grep "$DATA $ORA $DESCRIZIONE$" jobs | cut -f1 -d:)
	grep -v "$DATA $ORA $DESCRIZIONE$" jobs > jobs.new
	mv -f jobs.new. jobs
   }
done 

# nota: invece dei due cicli si poteva usare diff, ma in caso di cambiamenti 
# molto rilevanti, l'output può diventare difficile da parsare

cat "$CALENDARIO" > "OLD-$CALENDARIO" 
