#!/bin/bash

snmpget -v 1 -c public "$1" 'NET-SNMP-EXTEND-MIB::nsExtendOutputFull."failcount"' | rev | awk '{ print $1 }' | rev

