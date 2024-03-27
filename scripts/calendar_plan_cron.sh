#!/bin/bash

test -f "$1" || {
   echo il primo parametro deve essere un file calendario esistente
   exit 1
}

test "$2" || {
   echo servono due parametri, il secondo deve essere un nome di file delle scadenze da creare o aggiornare
   exit 2
}

CALENDARIO="$1"
FILEALLARMI="$2"

cat "$CALENDARIO" | while read DATA ORA DESCRIZIONE 
do
   SCADENZA=$(date +%s -d "$DATA $ORA") # conversione in secondi dal 1970-01-01 01:00
   RIGAGIORNOPRIMA="$(( SCADENZA - 24*60*60 )) $DATA $ORA $DESCRIZIONE"
   RIGAORAPRIMA="$(( SCADENZA - 60*60 )) $DATA $ORA $DESCRIZIONE"
   grep -qx "$RIGAGIORNOPRIMA" "$FILEALLARMI" || echo "$RIGAGIORNOPRIMA" >> "$FILEALLARMI"
   grep -qx "$RIGAORAPRIMA" "$FILEALLARMI" || echo "$RIGAORAPRIMA" >> "$FILEALLARMI"
done 

TMPCRON=$(mktemp)
RIGACRON="* * * * * $PWD/calendar_remind_cron.sh $FILEALLARMI"
crontab -l | grep -Fvx "$RIGACRON" > "$TMPCRON"
echo "$RIGACRON" >> "$TMPCRON"
crontab "$TMPCRON"
rm -f "$TMPCRON"
