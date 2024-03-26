#!/bin/bash

echo "There are $(egrep -o 'a' $1 | uniq -c | egrep '[[:digit:]]*' -o) occurrencies of 'a'."
echo "There are $(egrep -oi 'sherlock' $1 | uniq -ci | egrep '[[:digit:]]*' -o) occurrencies of '[Ss]herlock'."
tr ' [:punct:]' '\n' < $1 | egrep -v '^[[:space:]]*$' | sort | uniq -c | sort -nr | head - | head -5  

