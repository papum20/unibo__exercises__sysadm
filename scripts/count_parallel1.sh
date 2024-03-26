#!/bin/bash

# arguments: input file



# arguments: regex
# input from stdin
function count_occurrencies() {
	egrep -oi $1 | wc -w
}


rows=$(grep -c .* < $1)
half_rows=$(( $rows / 2 ))

out_head=$(mktemp)
out_tail=$(mktemp)


( head $1 -n $half_rows				| count_occurrencies 'sherlock' > $out_head ) &
(tail $1 -n $(($rows - $half_rows))	| count_occurrencies 'sherlock' > $out_tail ) &

wait

first=$(cat $out_head)
second=$(cat $out_tail)


echo "Total occurrencies of case-insensitive 'sherlock': $(( $first + $second )) ($first + $second)"


rm -f $out_head $out_tail
