#!/bin/bash

report () {
	echo $(date) osservate $TOT nuove righe
	TOT=0
}

echo $BASHPID # > /tmp/logwatch.pid
TOT=0
trap report USR1

exec 3<> $(tty) 0<&3
#exec 3> $(tty) >&3

ls /proc/self/fd -l

(tail -n +0 "$1" >&3) &
echo A
echo A
#cat <&3
echo C

while read R -u 3 ; do
	echo "r: $R $TOT"
	TOT=$(( $TOT + 1 ))
	echo "TOT $TOT"
done
echo B