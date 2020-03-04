#!/bin/bash
#
# Program:
#        Stop all getPerfInfo  process
# History:
#        wulm 2018/1/29 1.0v
#
export LANG=C

PIDS=`ps -aux | grep getPerfInfo.sh  | grep -v "grep" | awk '{print $2}'`

if [ "${PIDS}" == "" ]; then

    echo "Note: NO getPerfInfo process is running."
    exit 1

fi

echo "${PIDS}" | while read PID
do

    getPerfInfo.sh --kill ${PID}

done

