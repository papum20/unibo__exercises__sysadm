#!/bin/bash 

while getopts "f:s:" OPTION ; do
	case $OPTION in
		f)	FILE="$OPTARG"
			;;
		s)	SOGLIA="$OPTARG"
			;;
		?)	printf "Usage: %s [-f FILE_HOSTS] [-s SOGLIA_FALLIMENTI] \n" $(basename $0) >&2
			exit 1
			;;
	esac
done

if ! [[ -r "$FILE" ]] ; then
	echo "$FILE non è un file leggibile" >&2
	exit 2
fi

if ! [[ "$SOGLIA" =~ ^[0-9]+$ ]] ; then
	echo "$2 non è un numero intero" >&2
	exit 3
fi

shift $(($OPTIND - 1))

cat "$FILE" | while read IP ; do
    [[ $($HOME/failcount.sh $IP) -gt $SOGLIA ]] && ssh -oStrictHostKeyChecking=no -i $HOME/.ssh/snmp $IP "sudo shutdown -h now"
done

