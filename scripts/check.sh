#!/bin/bash

ls -lR $1 2> /dev/null | egrep '^[^d].* [[:digit:]]* (.*){5}' | egrep '\.[^\.]*$' -o | cut -d'.' -f2 | sort | uniq -c | sort -nr | head -5
