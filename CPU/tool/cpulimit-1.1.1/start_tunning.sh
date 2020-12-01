#!/bin/bash

#export LANG=C
#export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

#PROGRAM_DIR="/root/wlm/cpulimit-1.1.1"
PROGRAM_DIR=`pwd`

CORE_LIST=`echo $1 | sed 's/,/ /g'`

PERCENTAGE=`echo "$2/$3" | bc -l`
ELAPSED_TIME=$4
PROCS=$3

execute () {
    for n in `seq 1 ${PROCS}`
    do
	    cp while1 loop${n}
        ./loop${n} &
	    WHILE1_PID=$!
	    taskset -cp $1 $WHILE1_PID 
	    echo $WHILE1_PID
            if [ -d PROGRAM_DIR ]; then
	    	cd $PROGRAM_DIR
	    fi
	    ./cpulimit -p $WHILE1_PID -l $PERCENTAGE &
    done
}

if [ $CORE_LIST == "all" ]; then
	TOTAL_CORE_NUM=`cat /proc/cpuinfo | grep processor | wc -l`
	CORE_NUMBER=`echo "$TOTAL_CORE_NUM -1 " | bc`
	for each_core in `seq 0 $CORE_NUMBER`
	do
		execute $each_core &
	done
else
	for each_part in $CORE_LIST
	do
		CONTINUOUS=`echo $each_part | grep '-'`
		if [[ -n $CONTINUOUS ]]; then
			CORE_BEGIN=`echo $CONTINUOUS | awk 'BEGIN {FS="-"} {print $1}'`
			CORE_END=`echo $CONTINUOUS | awk 'BEGIN {FS="-"} {print $2}'`
			for each_core in `seq $CORE_BEGIN $CORE_END`
			do
				execute $each_core &
			done
		else
			execute $each_part &
		fi
	done
fi

if [[ -n $ELAPSED_TIME ]]; then
	sleep $ELAPSED_TIME
	sh stop_tunning.sh
fi
echo "TUNNING STARTED: CORE $1 ${PERCENTAGE}%"
