#!/bin/bash
# Se il carico del sistema è inferiore ad una soglia specificata 
# come primo parametro dello script, lancia il comando specificato
# come secondo parametro.
# Altrimenti, con at, rischedula il test dopo 2 minuti, e procede
# così finchè non riesce a lanciare il comando.

# configurazione del nome dello script
# come si può ricavare automaticamente senza ambiguita'
# dovute a path relativi che potrebbero confondere atd?
THIS=/home/vagrant/niceexec-base.sh
# testare se $1 è un numero
if ! [[ "$1" =~ ^[0-9]+$ ]] ; then
	echo "$1 non è un numero"
	exit 1
fi

# $2 deve essere eseguibile, file standard e con path assoluto 
# per evitare problemi con l'environment di atd
if ! [[ -x "$2" && -f "$2" && "$2" =~ ^/ ]] ; then
	echo "$2" non è un eseguibile con path assoluto
	exit 1
fi

# ipotesi semplificativa: solo la parte intera del carico a 1 minuto
# per farlo, devo sapere qual è il delimitatore dei decimali 
# in accordo alla localizzazione attiva: man locale
LOAD=$(uptime | awk -F 'average: ' '{ print $2 }' | cut -f1 -d$(locale decimal_point))
if test $LOAD -lt "$1" ; then
	shift
	eval "$@"
else
	echo $THIS "$@" | at now +2 minutes
fi