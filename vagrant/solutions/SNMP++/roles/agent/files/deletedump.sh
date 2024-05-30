#!/bin/bash
( tail -f /var/log/deletedump.log | /usr/bin/grep -E --line-buffered 'DONE DOWNLOAD' | while read -r TAG TAG FILEPATH ; do
	/usr/bin/rm -f "$FILEPATH"
	exit 0
done ) &
