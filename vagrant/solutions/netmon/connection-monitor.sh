#!/bin/bash

# Jun  1 14:33:41 router las: _S_10.1.1.11_10.2.2.2_34804_22_

declare -A TM

tail -f /var/log/newconn | while IFS=_ read PRE FLA SIP DIP SPT DPT POST  ; do
	if [ "$FLA" = "S" ] ; then
		/root/traffic_monitor.sh $SIP $DIP $SPT $DPT &
		TM[${SIP}_${DIP}_${SPT}_${DPT}]=$!
	elif [ "$FLA" = "F" ] ; then
		kill ${TM[${SIP}_${DIP}_${SPT}_${DPT}]}
	else
		echo ok panico
	fi
done
