#!/bin/bash

# count files in 2 dirs, recursively, with subprocesses.


dir1=$1
dir2=$2


function count_files_rec {
	find $1 | wc -w
	#ls -AR $1 | grep -v '.*:$' | wc -w
}


out1=$(mktemp)
out2=$(mktemp)

count_files_rec "$dir1" > $out1 &
count_files_rec "$dir2" > $out2 &

wait


files1=$(cat $out1)
files2=$(cat $out2)


echo "$dir1 has $files1 files, $dir2 has $files2 files."

if [[ $files1 > $files2 ]]
then
	echo "$dir1 has more files than $dir2"
else
	echo "$dir2 has more files than $dir1"
fi


rm -f $out1 $out2
