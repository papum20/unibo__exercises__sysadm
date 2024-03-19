#!/bin/bash

cat /dev/null > log


declare -A pids
declare -A ended

count=0
for p in "$@"
do
	$p &
	pids[$count]=$!
	((count++))
done



sleep 10 &
PRIMO=$!
sleep 20 &
SECONDO=$!
while sleep 5 ; do

	count=0
	for i in "${!pids[@]}"
	do
		if [[ ended[$count] == 1 ]]
		then
			((count++))
			continue
		fi

		
	
		if ! ps "${pids[$i]}"
		then
			ended[$i]=1
		fi
	done

	STATO1=`ps hp $PRIMO | awk '{ print $3 }'`
	STATO2=`ps hp $SECONDO | awk '{ print $3 }'`
	if test -z "$STATO1" ; then STATO1=terminato ; fi
	if test -z "$STATO2" ; then STATO2=terminato ; fi
	echo "Stato del processo $PRIMO: $STATO1, stato del processo $SECONDO: $STATO2" | tee -a log
	# if test "$STATO1" = "terminato" -a "$STATO2" = "terminato" ; then break ; fi
	if ! ps "$PRIMO" && ! ps "$SECONDO" ; then break ; fi
done
