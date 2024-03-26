#!/bin/bash

# Search input file for `text`, counting occurrencies,
# using 2 subprocesses, each searching a half of the file;
# when the first one terminates, the second one prints its temoporary result
# to "$file_tmp", before continuing
# *	arguments: input file

file_tmp="./count_parallel2_tmp.txt"
text='sherlock'


function save_count_tmp() {
	echo "$count" > $file_tmp
}


# arguments: regex
# input from stdin
function count_occurrencies() {

	trap save_count_tmp CONT

	count=0
	while read line ; do
		count=$((count + "$( (grep -oi $1 | wc -w) <<< "$line")" ))
	done

	echo $count
}


rows=$(grep -c .* < $1)
half_rows=$(( $rows / 2 ))
# reading the same number of rows, subprocess take approximately the same time,
# and you'll hardly see a temporary result different from the final - try instead with more imbalance
#half_rows=$(( $rows / 10 ))

out_head=$(mktemp)
out_tail=$(mktemp)


# at sigusr1, print tmp result in file
count_occurrencies "$text"	<<< "$(head $1 -n $half_rows)"					> $out_head &
count_occurrencies "$text"	<<< "$(tail $1 -n $(($rows - $half_rows)) )"	> $out_tail &

echo "Jobs: $(jobs -p | tr '\n' ' ')"


# wait the first to finish
wait -n

# be sure both didn't terminate at the same time
if [[ ! -z $(jobs -p) ]]
then
	echo "A job is still running ($(jobs -p)), saving temporary result."

	# kill the only child still running
	kill -s STOP $(jobs -p)
	kill -s CONT $(jobs -p)

	# wait the other one
	wait -n
else
	echo "Both jobs already terminated."
fi


# outputs
first=$(cat $out_head)
second=$(cat $out_tail)

echo "Results: $first , $second"
echo "Total occurrencies of case-insensitive 'sherlock': $(( $first + $second )) ($first + $second)"


rm -f $out_head $out_tail
