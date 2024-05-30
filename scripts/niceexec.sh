#!/bin/bash

# Se il carico del sistema è inferiore ad una soglia specificata come primo parametro dello script,
# lancia il comando specificato come secondo parametro.
# Altrimenti, con at, rischedula il test dopo 2 minuti,
# e procede così finchè non riesce a lanciare il comando.

THIS="/home/papum/programm/unibo/sysadm/scripts/niceexec.sh"

THRESHOLD=$1
CMD="$2"

load() {
	uptime | uptime | grep -o 'load average: [0-9]*\.[0-9]*' | grep -o '[0-9]*\.[0-9]*'
}

next_minute() {
	date '+%H %M' | awk '{ print $1 ":" $2+1 }'
}


echo "cmd is ${CMD}"

if [[ $(echo "$(load) > ${THRESHOLD}" | bc ) -eq 1 ]]
then
	echo "exec"
	"$CMD" $ARGS
else
	echo "schedule"
	echo "$THIS $THRESHOLD $CMD $ARGS" | at $(next_minute)
fi
