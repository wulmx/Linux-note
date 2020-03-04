#!/bin/bash

#add by wulm at 20180906 
# for OS before RHEL7 that can't use cpupower


FREQ=$1
set -x
for i in `seq 0 11` ; do
  echo "cpu $i"
  cpufreq-set --min $FREQ -c $i
  cpufreq-set --max $FREQ -c $i
#  echo -n "avail: "
  cat /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_available_frequencies
#  echo -n "scaling_cur_freq: "
  cat /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_cur_freq
#  echo "min max:"
  cat /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_{min,max}_freq
done

set +x
for i in `seq 0 11` ; do
  cat /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_cur_freq
done
:q:q

