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

   grep -qx "$DATA $ORA $DESCRIZIONE" "OLD-$CALENDARIO" || {
      at -t "$GIORNOPRIMA" <<< "flock $HOME/promemoria echo '$DESCRIZIONE scade il $DATA alle $ORA' >> $HOME/promemoria"
      at -t "$ORAPRIMA" <<< "flock $HOME/promemoria  echo '$DESCRIZIONE scade il $DATA alle $ORA' >> $HOME/promemoria"
   }
done 
cat "$CALENDARIO" > "OLD-$CALENDARIO"