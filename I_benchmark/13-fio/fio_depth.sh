
#!/bin/bash

export LANG=C
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

ROUND=3
RESULT_DIR="./log"
PWD=`pwd`
TEST_DIR=$PWD
SIZE=20GB
IOENGINE=libaio
RUNTIME=50
fname='/k8s_log/fiotest'
dir='/k8s_log'

for depth in 1 2 4 8 16; do
  for num_jobs in 1; do
    for line in "4k read sync 100" "4k write sync 0" "4k randrw sync 50" "4k randrw sync 20" "4k randrw sync 80"; do
      for round in `seq $ROUND` ; do
        array=($line)
        bs=${array[0]}
        rw=${array[1]}
        is_sync=${array[2]}
        mix=${array[3]}
        mode=direct-${bs}-${rw}-read${mix}-${num_jobs}jobs-${depth}depth
        log="$RESULT_DIR/$mode/round-$round"
        mkdir -p $log
        ../tool/log_start.sh $log/getperfinfo &
#        /home/matsu/remote_log_start.sh
        echo "mode=$mode round=$round"
        if [ $is_sync == "sync" ]; then
          #ssh 192.168.20.121 "sync"
	  sync
	  echo 3 > /proc/sys/vm/drop_caches
          echo "sync done"
        fi
        sleep 5
        echo "start fio"
        echo "fio -filename=$fname -iodepth=$depth -rw=$rw -bs=$bs -ioengine=$IOENGINE -direct=1 -size=$SIZE --runtime=$RUNTIME -numjobs=$num_jobs --rwmixread=$mix -directory=$dir -group_reporting -name=myFioTest" >> $log/log_fio.log
        fio -filename=$fname -iodepth=$depth -rw=$rw -bs=$bs -ioengine=$IOENGINE -direct=1 -size=$SIZE --runtime=$RUNTIME -numjobs=$num_jobs  --rwmixread=$mix  -directory=$dir -group_reporting -name=myFioTest >> $log/log_fio.log
	../tool/log_stop.sh
#        /home/matsu/remote_log_stop.sh $log
		
	sleep 5
      done
    done
  done
done

