#!/bin/bash
report () {
	echo $(date) osservate $TOT nuove righe
	TOT=0
}
echo $BASHPID > /tmp/logwatch.pid
TOT=0
trap report USR1
tail -n +0 -f "$1" | while read R ; do
	echo "r: $R $TOT"
	TOT=$(( $TOT + 1 ))
done