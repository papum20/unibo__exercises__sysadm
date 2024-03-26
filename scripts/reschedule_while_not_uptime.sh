#!/bin/bash


# reschedule `command` for 2 minutes while system load < `load`
# arguments: `load` (like in uptime), `command` to execute


load="$1"
command="$2"


# arg: command
function reschedule() {
	echo "$1" | at now + 1 minutes 2>log
}

# args: load, command
function check_load() {
	
	load=$(uptime | grep -o "average:.*" | cut -d' ' -f4)
	if [[ $load < $1 ]]
	then
		echo "Load is $load, rescheduling for 2 minutes."
		reschedule "check_load $1 > /home/danie/programm/unibo/sysadm/logg"
	else
		echo "Load is $load, executing."
		$2	
	fi
}


check_load $load "$command"
