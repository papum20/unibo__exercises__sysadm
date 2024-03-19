#!/bin/bash

extglob_tmp=$(shopt -p extglob)
shopt -s extglob

function waitfile {

	cmd=$1
	filename=$2
	mode=$3
	N_sleep=10

	USAGE="\
	Usage: waitfile CMD FILENAME [MODE]
		CMD=ls|rm|touch
	"

	if [[ -z $cmd || -z $filename ]]
	then
		echo "Missing args."
		echo $USAGE
		exit 1
	elif [[ ! $cmd =~ ^(ls|rm|touch)$ ]]
	then
		echo "Error: CMD must be ls, rm or touch."
		echo $USAGE
		exit 1
	fi


	case $mode in
		force)
			$cmd $filename
			;;
		*([0-9]))
			if [[ -n $mode && $mode > 9 ]]
			then
				N_sleep=$mode
			fi
			
			for ((t=0; t<$N_sleep; t++))
			do
				if [[ -e $filename || $cmd == touch ]]
				then
					break
				else
					echo "Waiting for file \"$filename\" to exist, sleep n.\"$t\"."
					sleep 1
				fi
			done

			if [[ $cmd == touch ]]
			then
				echo "touch doesn't need to wait for file to exist, executing..."
				$cmd $filename
			elif [[ -e $filename ]]
			then
				echo "File exists, executing..."
				$cmd $filename
			else
				echo "File \"$filename\" doesn't exist, not executing."
			fi
			;;
		*)
			echo "Invalid mode."
			echo $USAGE
			$extglob_tmp
			exit 1
			;;
	esac

}


waitfile $*
$extglob_tmp
