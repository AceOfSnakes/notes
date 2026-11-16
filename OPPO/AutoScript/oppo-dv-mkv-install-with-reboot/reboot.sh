#!/bin/sh
FILE=$1
echo "Starting reboot...." >>$FILE 2>&1
sync
shutdown -n -r -t 1 now >>$FILE 2>&1
sync