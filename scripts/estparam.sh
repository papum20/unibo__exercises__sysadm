#!/bin/bash

path=$1

if [[ ! -e $path ]]
then
	echo "Error: path \"$path\" doesn't exist."
	exit 1
fi

shift 1
if [[ -z $* ]]
then
	echo \
"Usage: estparam.sh PATH EXTENSIONS...
e.g.:	estparam.sh \$HOME c java js"
	exit 1
fi

regex_extensions="$(tr ' ' '|' <<< "$*")"


ls -R1 $path 2> /dev/null | egrep -v ':$' | egrep '\.[^\./]*$' -o | cut -d'.' -f2 | sort | uniq -c | sort -nr | egrep -w "$regex_extensions"
