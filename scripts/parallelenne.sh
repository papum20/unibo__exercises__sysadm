#!/bin/bash


cat /dev/null > log

declare -A pids
declare -A ended


function help {
	echo "\
Usage: ./parallelenne.sh "command1" "command2" "command3" ...

Launches the commands in parallel in background, and logs their state every 5 seconds in file './log'.
Terminates when all commands have terminated.
On Ctrl+C (SIGINT), kills all the processes and logs their termination.

Example: ./parallelenne.sh \"sleep 10\" \"sleep 20\" \"sleep 30\"\
"
}

function end_processes {
	for i in "${pids[@]}"
	do
		kill $i
		echo "Killed process with pid $i" | tee -a log
	done
}

trap end_processes SIGINT

if [[ $# == 0 ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]]
then
	help
	exit 1
fi


count=0
for p in "$@"
do
	$p &
	pids[$count]=$!
	((count++))
done

echo Pids: ${pids[@]}


running=${#pids[@]}
while [[ $running > 0 ]] && sleep 5
do

	count=0
	for i in "${pids[@]}"
	do
		if [[ ended[$count] == 1 ]]
		then
			((count++))
			continue
		fi

		read state command <<< $( ps hp $i | awk '{ print $3; for(i=5; i<=NF; i++) print $i }' | tr '\n' ' ' )

		if [[ -z $state ]]
		then
			ended[$i]=1
			((running--))
		else
			echo "State of process $command with pid $i: $state" | tee -a log
		fi

		((count++))
	done

done
